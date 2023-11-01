import os
import platform
import importlib
import sys
import xml.etree.ElementTree as XmlTree
import re
from enum import Enum

def install_dir():
	if platform.system() == "Windows":
		return os.path.join(os.getenv("LOCALAPPDATA"), "orca")
	else:
		return os.path.expanduser(os.path.join("~", ".orca"))


path_to_scripts = os.path.join(install_dir(), "bin", "sys_scripts")
path_to_reg_module = os.path.join(install_dir(), "bin", "sys_scripts", "reg_modified.py")
sys.path.append(path_to_scripts)

from reg_modified import *

class ZigGeneratorOptions(GeneratorOptions):
	def __init__(self,
				 filename = None,
				 apiname = None,
				 profile = None,
				 versions = '.*',
				 emitversions = '.*',
				 defaultExtensions = None,
				 addExtensions = None,
				 removeExtensions = None,
				 sortProcedure = regSortFeatures,
				 removeProc = []):
		GeneratorOptions.__init__(self, filename, apiname, profile,
								  versions, emitversions, defaultExtensions,
								  addExtensions, removeExtensions, sortProcedure)
		self.removeProc = removeProc

class TokenType(Enum):
	CONST = 1
	POINTER = 2
	STRING = 3

class Token():
	def __init__(self, tokenType, tag):
		self.tok = tokenType
		self.tag = tag

class ZigOutputGenerator(OutputGenerator):
	def __init__(self,
				 errFile = sys.stderr,
				 warnFile = sys.stderr,
				 diagFile = sys.stdout):
		OutputGenerator.__init__(self, errFile, warnFile, diagFile)

		# accumulators for different inner block text
		self.typeBody = ''
		self.enumBody = ''
		self.cmdBody = ''

		# compile these regexes once to be used multiple times in generator functions
		self.featureRegex = re.compile(r"gl_es_version_(\d+)_(\d+)")
		self.paramRegex = re.compile(r"(?P<const>const)?\s*(?P<type>\w+)\s*(?P<pointer>\*+)?\s*(?P<name>\w+)\s*")

		# translating C typedefs to zig table
		self.typedefToZigType = {
			'typedef char': 'i8',
			'typedef int': 'c_int',
			'typedef khronos_float_t': 'f32',
			'typedef khronos_int16_t': 'i16',
			'typedef khronos_int32_t': 'i32',
			'typedef khronos_int64_t': 'i64',
			'typedef khronos_int8_t': 'i8',
			'typedef khronos_intptr_t': 'isize',
			'typedef khronos_ssize_t': 'usize',
			'typedef khronos_uint16_t': 'u16',
			'typedef khronos_uint64_t': 'u64',
			'typedef khronos_uint8_t': 'u8',
			'typedef struct __GLsync *': '*anyopaque',
			'typedef unsigned char': 'u8',
			'typedef unsigned int' : 'c_uint',
			'typedef unsigned' : 'c_uint',
			'typedef unsigned' : 'c_uint',
			'typedef void': 'void',
		}

		self.features = []
		self.featureNameZig = ''

		# state for the current feature
		self.currentTypedefs = []
		self.featureTypedefs = {}

	def makeZigDecls(self, cmd):
		proto = cmd.find('proto')
		params = cmd.findall('param')

		return_const = ''
		return_type = ''
		return_pointer = ''

		return_const_or_type = noneStr(proto.text).strip()
		if return_const_or_type == 'const':
			return_const = 'const'
		else:
			return_type = return_const_or_type

		func_name = ''

		for elem in proto:
			text = noneStr(elem.text).strip()
			tail = noneStr(elem.tail).strip()

			assert(tail == '' or tail == '*')
			if tail == '*':
				return_pointer = '[*]'

			if (elem.tag == 'name'):
				func_name = text
			else:
				assert(return_type == '')
				return_type += text
				assert(return_type != '')

		zig_return_type = return_pointer
		if return_const != '':
			zig_return_type += return_const + ' '
		zig_return_type += return_type.strip()

		paramdecl = '('
		for i, param in enumerate(params):
			if i > 0:
				paramdecl += ', '

			c_param = ' '.join([t for t in param.itertext()])

			# tokenize the joined string to make it easier to arrange the keywords in the correct order and spacing
			tokens = []
			tok = ''
			for c in c_param:
				if c != ' ':
					tok = tok + c
				if tok == 'const':
					tokens.append(Token(TokenType.CONST, tok))
					tok = ''
				elif tok == '*':
					tokens.append(Token(TokenType.POINTER, tok))
					tok = ''
				elif c == ' ':
					if tok != '':
						tokens.append(Token(TokenType.STRING, tok))
						tok = ''
			if tok != '':
				tokens.append(Token(TokenType.STRING, tok))
				tok = ''

			last_token = tokens[len(tokens) - 1]
			assert(last_token.tok == TokenType.STRING)
			tokens.pop()

			if tokens[0].tok == TokenType.CONST:
				tokens[0], tokens[1] = tokens[1], tokens[0]

			tokens.reverse()

			param_name = last_token.tag

			paramdecl += param_name + ": "
			for i, token in enumerate(tokens):
				if token.tok == TokenType.STRING and i > 0:
					paramdecl += ' '
				paramdecl += token.tag

		paramdecl += ') ';
		return '\textern fn ' + func_name + paramdecl + zig_return_type + ";\n";

	def newline(self):
		write('', file=self.outFile)

	def beginFile(self, genOpts):
		OutputGenerator.beginFile(self, genOpts)

		write('///////////////////////////////////////////////////////////////////////////////', file=self.outFile)
		write('// Generated Zig bindings for:', file=self.outFile)
		write('// API:', genOpts.apiname, file=self.outFile)
		if (genOpts.profile):
			write('// Profile:', genOpts.profile, file=self.outFile)
		write('// Versions considered:', genOpts.versions, file=self.outFile)
		write('// Versions emitted:', genOpts.emitversions, file=self.outFile)
		write('// Default extensions included:', genOpts.defaultExtensions, file=self.outFile)
		write('// Additional extensions included:', genOpts.addExtensions, file=self.outFile)
		write('// Extensions removed:', genOpts.removeExtensions, file=self.outFile)
		write('///////////////////////////////////////////////////////////////////////////////', file=self.outFile)
		self.newline()

	def endFile(self):
		OutputGenerator.endFile(self)

	def beginFeature(self, interface, emit):
		OutputGenerator.beginFeature(self, interface, emit)

		match = self.featureRegex.fullmatch(self.featureName.lower())
		version_major = match.group(1)
		version_minor = match.group(2)
		self.featureNameZig = 'v' + version_major + '_' + version_minor

		# resetting accumulators
		self.typeBody = ''
		self.enumBody = ''
		self.cmdPointerBody = ''
		self.cmdBody = ''

	def endFeature(self):
		if (self.emit):
			# open gles version struct
			write('const', self.featureNameZig, '= struct {', file=self.outFile)
			for f in self.features:
				write('\tusingnamespace ' + f + ';', file=self.outFile)
			if len(self.features) > 0:
				self.newline()
			self.features.append(self.featureNameZig)

			# import any needed declarations from previous gles version structs
			for typedef, featureName in self.featureTypedefs.items():
				if featureName != self.featureNameZig:
					write('\tconst ' + typedef + ' = ' + featureName + '.' + typedef + ';', file=self.outFile)

			# write out new declarations
			if (self.typeBody != ''):
				write(self.typeBody, end='', file=self.outFile)
			if (self.enumBody != ''):
				write(self.enumBody, end='', file=self.outFile)
			if (self.cmdBody != ''):
				prefix = ''
				suffix = ''

				write(prefix + self.cmdBody + suffix, end='', file=self.outFile)

			write('};', file=self.outFile)
			self.newline()

		OutputGenerator.endFeature(self)

	def genType(self, typeinfo, name):
		OutputGenerator.genType(self, typeinfo, name)

		typeElem = typeinfo.elem

		typeText = noneStr(typeElem.text).strip()

		if typeText.startswith("#include"):
			return

		s = ''

		for elem in typeElem:
			if (elem.tag == 'apientry'):
				assert(False, "Shouldn't be hitting this code path with gles generation")
			else:
				if typeText in self.typedefToZigType:
					s = "\tconst " + elem.text + ' = ' + self.typedefToZigType[typeText] + ';'
					self.featureTypedefs[elem.text] = self.featureNameZig
				else:
					assert(False, "Shouldn't be hitting this code path with gles generation")
					s += noneStr(elem.text) + noneStr(elem.tail)
		if (len(s) > 0):
			self.typeBody += s + '\n'

	def genEnum(self, enuminfo, name):
		OutputGenerator.genEnum(self, enuminfo, name)

		self.enumBody += '\tconst ' + name + ': GLenum = ' + enuminfo.elem.get('value') + ';\n'

	def genCmd(self, cmdinfo, name):
		if name in self.genOpts.removeProc:
			return
		OutputGenerator.genCmd(self, cmdinfo, name)

		decl = self.makeZigDecls(cmdinfo.elem)
		self.cmdBody += decl

def gen_gles_bindings(spec, filename):
	gles2through31Pattern = '2\.[0-9]|3\.[01]'
	allVersions = '.*'

	# remove APIs that can't be sandboxed
	removeProc = [
		"glMapBuffer",
		"glMapBufferRange",
		"glUnmapBuffer",
		"glFlushMappedBufferRange",
		"glGetBufferPointerv"
	]

	genOpts = ZigGeneratorOptions(
		filename=filename,
		apiname='gles2',
		profile='common',
		versions=gles2through31Pattern,
		emitversions=allVersions,
		removeProc = removeProc)

	reg = Registry()
	tree = XmlTree.parse(spec)
	reg.loadElementTree(tree)

	gen = ZigOutputGenerator()
	reg.setGenerator(gen)
	reg.apiGen(genOpts)

if __name__ == "__main__":
	path_to_gl_xml = os.path.join(install_dir(), "src", "ext", "gl.xml")
	gen_gles_bindings(path_to_gl_xml, "../src/gles.zig")
