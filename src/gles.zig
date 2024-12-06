///////////////////////////////////////////////////////////////////////////////
//
//  Orca
//  Copyright 2023 Martin Fouilleul and the Orca project contributors
//  See LICENSE.txt for licensing information
//
///////////////////////////////////////////////////////////////////////////////

const std = @import("std");
const debug = @import("debug.zig");

pub const Api = enum {
    V2_0,
    V3_0,
    V3_1,

    fn hasCompat(comptime api: Api, comptime compat_api: Api) bool {
        return @intFromEnum(compat_api) <= @intFromEnum(api);
    }
};

pub fn getApi(comptime api: Api) type {
    return struct {
        const Helpers = struct {
            fn zigStringsToCStrings(strings: []const [:0]const u8, allocator: std.mem.Allocator) []const [*:0]const GLchar {
                const c_strings: [][*:0]const GLchar = allocator.alloc([*:0]const GLchar, strings.len) catch {
                    debug.abort("Out of memory allocating memory for converting {} zig string pointers to C string pointers.", .{strings.len}, @src());
                };

                for (strings, c_strings) |source, *dest| {
                    dest.* = @ptrCast(source.ptr);
                }

                return c_strings;
            }
        };

        const Externs = struct {
            // v2.0
            extern fn glActiveTexture(texture: GLenum) void;
            extern fn glAttachShader(program: GLuint, shader: GLuint) void;
            extern fn glBindAttribLocation(program: GLuint, index: GLuint, name: [*]const GLchar) void;
            extern fn glBindBuffer(target: GLenum, buffer: GLuint) void;
            extern fn glBindFramebuffer(target: GLenum, framebuffer: GLuint) void;
            extern fn glBindRenderbuffer(target: GLenum, renderbuffer: GLuint) void;
            extern fn glBindTexture(target: GLenum, texture: GLuint) void;
            extern fn glBlendColor(red: GLfloat, green: GLfloat, blue: GLfloat, alpha: GLfloat) void;
            extern fn glBlendEquation(mode: GLenum) void;
            extern fn glBlendEquationSeparate(modeRGB: GLenum, modeAlpha: GLenum) void;
            extern fn glBlendFunc(sfactor: GLenum, dfactor: GLenum) void;
            extern fn glBlendFuncSeparate(sfactorRGB: GLenum, dfactorRGB: GLenum, sfactorAlpha: GLenum, dfactorAlpha: GLenum) void;
            extern fn glBufferData(target: GLenum, size: GLsizeiptr, data: *const anyopaque, usage: GLenum) void;
            extern fn glBufferSubData(target: GLenum, offset: GLintptr, size: GLsizeiptr, data: *const anyopaque) void;
            extern fn glCheckFramebufferStatus(target: GLenum) GLenum;
            extern fn glClear(mask: GLbitfield) void;
            extern fn glClearColor(red: GLfloat, green: GLfloat, blue: GLfloat, alpha: GLfloat) void;
            extern fn glClearDepthf(d: GLfloat) void;
            extern fn glClearStencil(s: GLint) void;
            extern fn glColorMask(red: GLboolean, green: GLboolean, blue: GLboolean, alpha: GLboolean) void;
            extern fn glCompileShader(shader: GLuint) void;
            extern fn glCompressedTexImage2D(target: GLenum, level: GLint, internalformat: GLenum, width: GLsizei, height: GLsizei, border: GLint, imageSize: GLsizei, data: *const anyopaque) void;
            extern fn glCompressedTexSubImage2D(target: GLenum, level: GLint, xoffset: GLint, yoffset: GLint, width: GLsizei, height: GLsizei, format: GLenum, imageSize: GLsizei, data: *const anyopaque) void;
            extern fn glCopyTexImage2D(target: GLenum, level: GLint, internalformat: GLenum, x: GLint, y: GLint, width: GLsizei, height: GLsizei, border: GLint) void;
            extern fn glCopyTexSubImage2D(target: GLenum, level: GLint, xoffset: GLint, yoffset: GLint, x: GLint, y: GLint, width: GLsizei, height: GLsizei) void;
            extern fn glCreateProgram() GLuint;
            extern fn glCreateShader(type: GLenum) GLuint;
            extern fn glCullFace(mode: GLenum) void;
            extern fn glDeleteBuffers(n: GLsizei, buffers: [*]const GLuint) void;
            extern fn glDeleteFramebuffers(n: GLsizei, framebuffers: [*]const GLuint) void;
            extern fn glDeleteProgram(program: GLuint) void;
            extern fn glDeleteRenderbuffers(n: GLsizei, renderbuffers: [*]const GLuint) void;
            extern fn glDeleteShader(shader: GLuint) void;
            extern fn glDeleteTextures(n: GLsizei, textures: [*]const GLuint) void;
            extern fn glDepthFunc(func: GLenum) void;
            extern fn glDepthMask(flag: GLboolean) void;
            extern fn glDepthRangef(n: GLfloat, f: GLfloat) void;
            extern fn glDetachShader(program: GLuint, shader: GLuint) void;
            extern fn glDisable(cap: GLenum) void;
            extern fn glDisableVertexAttribArray(index: GLuint) void;
            extern fn glDrawArrays(mode: GLenum, first: GLint, count: GLsizei) void;
            extern fn glDrawElements(mode: GLenum, count: GLsizei, type: GLenum, indices: [*]const void) void;
            extern fn glEnable(cap: GLenum) void;
            extern fn glEnableVertexAttribArray(index: GLuint) void;
            extern fn glFinish() void;
            extern fn glFlush() void;
            extern fn glFramebufferRenderbuffer(target: GLenum, attachment: GLenum, renderbuffertarget: GLenum, renderbuffer: GLuint) void;
            extern fn glFramebufferTexture2D(target: GLenum, attachment: GLenum, textarget: GLenum, texture: GLuint, level: GLint) void;
            extern fn glFrontFace(mode: GLenum) void;
            extern fn glGenBuffers(n: GLsizei, buffers: [*]GLuint) void;
            extern fn glGenerateMipmap(target: GLenum) void;
            extern fn glGenFramebuffers(n: GLsizei, framebuffers: [*]GLuint) void;
            extern fn glGenRenderbuffers(n: GLsizei, renderbuffers: [*]GLuint) void;
            extern fn glGenTextures(n: GLsizei, textures: [*]GLuint) void;
            extern fn glGetActiveAttrib(program: GLuint, index: GLuint, bufSize: GLsizei, length: *GLsizei, size: *GLint, type: *GLenum, name: [*]GLchar) void;
            extern fn glGetActiveUniform(program: GLuint, index: GLuint, bufSize: GLsizei, length: *GLsizei, size: *GLint, type: *GLenum, name: [*]GLchar) void;
            extern fn glGetAttachedShaders(program: GLuint, maxCount: GLsizei, count: *GLsizei, shaders: [*]GLuint) void;
            extern fn glGetAttribLocation(program: GLuint, name: [*]const GLchar) GLint;
            extern fn glGetBooleanv(pname: GLenum, data: [*]GLboolean) void;
            extern fn glGetBufferParameteriv(target: GLenum, pname: GLenum, params: [*]GLint) void;
            extern fn glGetError() GLenum;
            extern fn glGetFloatv(pname: GLenum, data: [*]GLfloat) void;
            extern fn glGetFramebufferAttachmentParameteriv(target: GLenum, attachment: GLenum, pname: GLenum, params: [*]GLint) void;
            extern fn glGetIntegerv(pname: GLenum, data: [*]GLint) void;
            extern fn glGetProgramiv(program: GLuint, pname: GLenum, params: [*]GLint) void;
            extern fn glGetProgramInfoLog(program: GLuint, bufSize: GLsizei, length: *GLsizei, infoLog: [*]GLchar) void;
            extern fn glGetRenderbufferParameteriv(target: GLenum, pname: GLenum, params: *GLint) void;
            extern fn glGetShaderiv(shader: GLuint, pname: GLenum, params: [*]GLint) void;
            extern fn glGetShaderInfoLog(shader: GLuint, bufSize: GLsizei, length: *GLsizei, infoLog: [*]GLchar) void;
            extern fn glGetShaderPrecisionFormat(shadertype: GLenum, precisiontype: GLenum, range: *GLint, precision: *GLint) void;
            extern fn glGetShaderSource(shader: GLuint, bufSize: GLsizei, length: *GLsizei, source: [*]GLchar) void;
            extern fn glGetString(name: GLenum) [*:0]const GLubyte;
            extern fn glGetTexParameterfv(target: GLenum, pname: GLenum, params: [*]GLfloat) void;
            extern fn glGetTexParameteriv(target: GLenum, pname: GLenum, params: [*]GLint) void;
            extern fn glGetUniformfv(program: GLuint, location: GLint, params: [*]GLfloat) void;
            extern fn glGetUniformiv(program: GLuint, location: GLint, params: [*]GLint) void;
            extern fn glGetUniformLocation(program: GLuint, name: [*]const GLchar) GLint;
            extern fn glGetVertexAttribfv(index: GLuint, pname: GLenum, params: [*]GLfloat) void;
            extern fn glGetVertexAttribiv(index: GLuint, pname: GLenum, params: [*]GLint) void;
            extern fn glGetVertexAttribPointerv(index: GLuint, pname: GLenum, pointer: **anyopaque) void;
            extern fn glHint(target: GLenum, mode: GLenum) void;
            extern fn glIsBuffer(buffer: GLuint) GLboolean;
            extern fn glIsEnabled(cap: GLenum) GLboolean;
            extern fn glIsFramebuffer(framebuffer: GLuint) GLboolean;
            extern fn glIsProgram(program: GLuint) GLboolean;
            extern fn glIsRenderbuffer(renderbuffer: GLuint) GLboolean;
            extern fn glIsShader(shader: GLuint) GLboolean;
            extern fn glIsTexture(texture: GLuint) GLboolean;
            extern fn glLineWidth(width: GLfloat) void;
            extern fn glLinkProgram(program: GLuint) void;
            extern fn glPixelStorei(pname: GLenum, param: GLint) void;
            extern fn glPolygonOffset(factor: GLfloat, units: GLfloat) void;
            extern fn glReadPixels(x: GLint, y: GLint, width: GLsizei, height: GLsizei, format: GLenum, type: GLenum, pixels: *anyopaque) void;
            extern fn glReleaseShaderCompiler() void;
            extern fn glRenderbufferStorage(target: GLenum, internalformat: GLenum, width: GLsizei, height: GLsizei) void;
            extern fn glSampleCoverage(value: GLfloat, invert: GLboolean) void;
            extern fn glScissor(x: GLint, y: GLint, width: GLsizei, height: GLsizei) void;
            extern fn glShaderBinary(count: GLsizei, shaders: *const GLuint, binaryFormat: GLenum, binary: *const void, length: GLsizei) void;
            extern fn glShaderSource(shader: GLuint, count: GLsizei, string: [*]const [*:0]const GLchar, length: ?[*]const GLint) void;
            extern fn glStencilFunc(func: GLenum, ref: GLint, mask: GLuint) void;
            extern fn glStencilFuncSeparate(face: GLenum, func: GLenum, ref: GLint, mask: GLuint) void;
            extern fn glStencilMask(mask: GLuint) void;
            extern fn glStencilMaskSeparate(face: GLenum, mask: GLuint) void;
            extern fn glStencilOp(fail: GLenum, zfail: GLenum, zpass: GLenum) void;
            extern fn glStencilOpSeparate(face: GLenum, sfail: GLenum, dpfail: GLenum, dppass: GLenum) void;
            extern fn glTexImage2D(target: GLenum, level: GLint, internalformat: GLint, width: GLsizei, height: GLsizei, border: GLint, format: GLenum, type: GLenum, pixels: [*]const void) void;
            extern fn glTexParameterf(target: GLenum, pname: GLenum, param: GLfloat) void;
            extern fn glTexParameterfv(target: GLenum, pname: GLenum, params: *const GLfloat) void;
            extern fn glTexParameteri(target: GLenum, pname: GLenum, param: GLint) void;
            extern fn glTexParameteriv(target: GLenum, pname: GLenum, params: *const GLint) void;
            extern fn glTexSubImage2D(target: GLenum, level: GLint, xoffset: GLint, yoffset: GLint, width: GLsizei, height: GLsizei, format: GLenum, type: GLenum, pixels: [*]const void) void;
            extern fn glUniform1f(location: GLint, v0: GLfloat) void;
            extern fn glUniform1fv(location: GLint, count: GLsizei, value: [*]const GLfloat) void;
            extern fn glUniform1i(location: GLint, v0: GLint) void;
            extern fn glUniform1iv(location: GLint, count: GLsizei, value: [*]const GLint) void;
            extern fn glUniform2f(location: GLint, v0: GLfloat, v1: GLfloat) void;
            extern fn glUniform2fv(location: GLint, count: GLsizei, value: [*]const GLfloat) void;
            extern fn glUniform2i(location: GLint, v0: GLint, v1: GLint) void;
            extern fn glUniform2iv(location: GLint, count: GLsizei, value: [*]const GLint) void;
            extern fn glUniform3f(location: GLint, v0: GLfloat, v1: GLfloat, v2: GLfloat) void;
            extern fn glUniform3fv(location: GLint, count: GLsizei, value: [*]const GLfloat) void;
            extern fn glUniform3i(location: GLint, v0: GLint, v1: GLint, v2: GLint) void;
            extern fn glUniform3iv(location: GLint, count: GLsizei, value: [*]const GLint) void;
            extern fn glUniform4f(location: GLint, v0: GLfloat, v1: GLfloat, v2: GLfloat, v3: GLfloat) void;
            extern fn glUniform4fv(location: GLint, count: GLsizei, value: [*]const GLfloat) void;
            extern fn glUniform4i(location: GLint, v0: GLint, v1: GLint, v2: GLint, v3: GLint) void;
            extern fn glUniform4iv(location: GLint, count: GLsizei, value: [*]const GLint) void;
            extern fn glUniformMatrix2fv(location: GLint, count: GLsizei, transpose: GLboolean, value: [*]const GLfloat) void;
            extern fn glUniformMatrix3fv(location: GLint, count: GLsizei, transpose: GLboolean, value: [*]const GLfloat) void;
            extern fn glUniformMatrix4fv(location: GLint, count: GLsizei, transpose: GLboolean, value: [*]const GLfloat) void;
            extern fn glUseProgram(program: GLuint) void;
            extern fn glValidateProgram(program: GLuint) void;
            extern fn glVertexAttrib1f(index: GLuint, x: GLfloat) void;
            extern fn glVertexAttrib1fv(index: GLuint, v: [*]const GLfloat) void;
            extern fn glVertexAttrib2f(index: GLuint, x: GLfloat, y: GLfloat) void;
            extern fn glVertexAttrib2fv(index: GLuint, v: [*]const GLfloat) void;
            extern fn glVertexAttrib3f(index: GLuint, x: GLfloat, y: GLfloat, z: GLfloat) void;
            extern fn glVertexAttrib3fv(index: GLuint, v: [*]const GLfloat) void;
            extern fn glVertexAttrib4f(index: GLuint, x: GLfloat, y: GLfloat, z: GLfloat, w: GLfloat) void;
            extern fn glVertexAttrib4fv(index: GLuint, v: [*]const GLfloat) void;
            extern fn glVertexAttribPointer(index: GLuint, size: GLint, type: GLenum, normalized: GLboolean, stride: GLsizei, pointer: ?*const anyopaque) void;
            extern fn glViewport(x: GLint, y: GLint, width: GLsizei, height: GLsizei) void;

            // v3.0
            extern fn glReadBuffer(src: GLenum) void;
            extern fn glDrawRangeElements(mode: GLenum, start: GLuint, end: GLuint, count: GLsizei, type: GLenum, indices: *const anyopaque) void;
            extern fn glTexImage3D(target: GLenum, level: GLint, internalformat: GLint, width: GLsizei, height: GLsizei, depth: GLsizei, border: GLint, format: GLenum, type: GLenum, pixels: *const anyopaque) void;
            extern fn glTexSubImage3D(target: GLenum, level: GLint, xoffset: GLint, yoffset: GLint, zoffset: GLint, width: GLsizei, height: GLsizei, depth: GLsizei, format: GLenum, type: GLenum, pixels: *const anyopaque) void;
            extern fn glCopyTexSubImage3D(target: GLenum, level: GLint, xoffset: GLint, yoffset: GLint, zoffset: GLint, x: GLint, y: GLint, width: GLsizei, height: GLsizei) void;
            extern fn glCompressedTexImage3D(target: GLenum, level: GLint, internalformat: GLenum, width: GLsizei, height: GLsizei, depth: GLsizei, border: GLint, imageSize: GLsizei, data: *const anyopaque) void;
            extern fn glCompressedTexSubImage3D(target: GLenum, level: GLint, xoffset: GLint, yoffset: GLint, zoffset: GLint, width: GLsizei, height: GLsizei, depth: GLsizei, format: GLenum, imageSize: GLsizei, data: *const anyopaque) void;
            extern fn glGenQueries(n: GLsizei, ids: [*]GLuint) void;
            extern fn glDeleteQueries(n: GLsizei, ids: [*]const GLuint) void;
            extern fn glIsQuery(id: GLuint) GLboolean;
            extern fn glBeginQuery(target: GLenum, id: GLuint) void;
            extern fn glEndQuery(target: GLenum) void;
            extern fn glGetQueryiv(target: GLenum, pname: GLenum, params: [*]GLint) void;
            extern fn glGetQueryObjectuiv(id: GLuint, pname: GLenum, params: [*]GLuint) void;
            extern fn glDrawBuffers(n: GLsizei, bufs: [*]const GLenum) void;
            extern fn glUniformMatrix2x3fv(location: GLint, count: GLsizei, transpose: GLboolean, value: [*]const GLfloat) void;
            extern fn glUniformMatrix3x2fv(location: GLint, count: GLsizei, transpose: GLboolean, value: [*]const GLfloat) void;
            extern fn glUniformMatrix2x4fv(location: GLint, count: GLsizei, transpose: GLboolean, value: [*]const GLfloat) void;
            extern fn glUniformMatrix4x2fv(location: GLint, count: GLsizei, transpose: GLboolean, value: [*]const GLfloat) void;
            extern fn glUniformMatrix3x4fv(location: GLint, count: GLsizei, transpose: GLboolean, value: [*]const GLfloat) void;
            extern fn glUniformMatrix4x3fv(location: GLint, count: GLsizei, transpose: GLboolean, value: [*]const GLfloat) void;
            extern fn glBlitFramebuffer(srcX0: GLint, srcY0: GLint, srcX1: GLint, srcY1: GLint, dstX0: GLint, dstY0: GLint, dstX1: GLint, dstY1: GLint, mask: GLbitfield, filter: GLenum) void;
            extern fn glRenderbufferStorageMultisample(target: GLenum, samples: GLsizei, internalformat: GLenum, width: GLsizei, height: GLsizei) void;
            extern fn glFramebufferTextureLayer(target: GLenum, attachment: GLenum, texture: GLuint, level: GLint, layer: GLint) void;
            extern fn glBindVertexArray(array: GLuint) void;
            extern fn glDeleteVertexArrays(n: GLsizei, arrays: [*]const GLuint) void;
            extern fn glGenVertexArrays(n: GLsizei, arrays: [*]GLuint) void;
            extern fn glIsVertexArray(array: GLuint) GLboolean;
            extern fn glGetIntegeri_v(target: GLenum, index: GLuint, data: [*]GLint) void;
            extern fn glBeginTransformFeedback(primitiveMode: GLenum) void;
            extern fn glEndTransformFeedback() void;
            extern fn glBindBufferRange(target: GLenum, index: GLuint, buffer: GLuint, offset: GLintptr, size: GLsizeiptr) void;
            extern fn glBindBufferBase(target: GLenum, index: GLuint, buffer: GLuint) void;
            extern fn glTransformFeedbackVaryings(program: GLuint, count: GLsizei, varyings: [*]const [*:0]const GLchar, bufferMode: GLenum) void;
            extern fn glGetTransformFeedbackVarying(program: GLuint, index: GLuint, bufSize: GLsizei, length: *GLsizei, size: *GLsizei, type: *GLenum, name: [*]GLchar) void;
            extern fn glVertexAttribIPointer(index: GLuint, size: GLint, type: GLenum, stride: GLsizei, pointer: ?*const anyopaque) void;
            extern fn glGetVertexAttribIiv(index: GLuint, pname: GLenum, params: [*]GLint) void;
            extern fn glGetVertexAttribIuiv(index: GLuint, pname: GLenum, params: [*]GLuint) void;
            extern fn glVertexAttribI4i(index: GLuint, x: GLint, y: GLint, z: GLint, w: GLint) void;
            extern fn glVertexAttribI4ui(index: GLuint, x: GLuint, y: GLuint, z: GLuint, w: GLuint) void;
            extern fn glVertexAttribI4iv(index: GLuint, v: [*]const GLint) void;
            extern fn glVertexAttribI4uiv(index: GLuint, v: [*]const GLuint) void;
            extern fn glGetUniformuiv(program: GLuint, location: GLint, params: [*]GLuint) void;
            extern fn glGetFragDataLocation(program: GLuint, name: [*]const GLchar) GLint;
            extern fn glUniform1ui(location: GLint, v0: GLuint) void;
            extern fn glUniform2ui(location: GLint, v0: GLuint, v1: GLuint) void;
            extern fn glUniform3ui(location: GLint, v0: GLuint, v1: GLuint, v2: GLuint) void;
            extern fn glUniform4ui(location: GLint, v0: GLuint, v1: GLuint, v2: GLuint, v3: GLuint) void;
            extern fn glUniform1uiv(location: GLint, count: GLsizei, value: [*]const GLuint) void;
            extern fn glUniform2uiv(location: GLint, count: GLsizei, value: [*]const GLuint) void;
            extern fn glUniform3uiv(location: GLint, count: GLsizei, value: [*]const GLuint) void;
            extern fn glUniform4uiv(location: GLint, count: GLsizei, value: [*]const GLuint) void;
            extern fn glClearBufferiv(buffer: GLenum, drawbuffer: GLint, value: [*]const GLint) void;
            extern fn glClearBufferuiv(buffer: GLenum, drawbuffer: GLint, value: [*]const GLuint) void;
            extern fn glClearBufferfv(buffer: GLenum, drawbuffer: GLint, value: [*]const GLfloat) void;
            extern fn glClearBufferfi(buffer: GLenum, drawbuffer: GLint, depth: GLfloat, stencil: GLint) void;
            extern fn glGetStringi(name: GLenum, index: GLuint) [*:0]const GLubyte;
            extern fn glCopyBufferSubData(readTarget: GLenum, writeTarget: GLenum, readOffset: GLintptr, writeOffset: GLintptr, size: GLsizeiptr) void;
            extern fn glGetUniformIndices(program: GLuint, uniformCount: GLsizei, uniformNames: [*]const [*:0]const GLchar, uniformIndices: [*]GLuint) void;
            extern fn glGetActiveUniformsiv(program: GLuint, uniformCount: GLsizei, uniformIndices: [*]const GLuint, pname: GLenum, params: [*]GLint) void;
            extern fn glGetUniformBlockIndex(program: GLuint, uniformBlockName: [*]const GLchar) GLuint;
            extern fn glGetActiveUniformBlockiv(program: GLuint, uniformBlockIndex: GLuint, pname: GLenum, params: [*]GLint) void;
            extern fn glGetActiveUniformBlockName(program: GLuint, uniformBlockIndex: GLuint, bufSize: GLsizei, length: *GLsizei, uniformBlockName: [*]GLchar) void;
            extern fn glUniformBlockBinding(program: GLuint, uniformBlockIndex: GLuint, uniformBlockBinding: GLuint) void;
            extern fn glDrawArraysInstanced(mode: GLenum, first: GLint, count: GLsizei, instancecount: GLsizei) void;
            extern fn glDrawElementsInstanced(mode: GLenum, count: GLsizei, type: GLenum, indices: *const anyopaque, instancecount: GLsizei) void;
            extern fn glFenceSync(condition: GLenum, flags: GLbitfield) GLsync;
            extern fn glIsSync(sync: GLsync) GLboolean;
            extern fn glDeleteSync(sync: GLsync) void;
            extern fn glClientWaitSync(sync: GLsync, flags: GLbitfield, timeout: GLuint64) GLenum;
            extern fn glWaitSync(sync: GLsync, flags: GLbitfield, timeout: GLuint64) void;
            extern fn glGetInteger64v(pname: GLenum, data: [*]GLint64) void;
            extern fn glGetSynciv(sync: GLsync, pname: GLenum, count: GLsizei, length: *GLsizei, values: [*]GLint) void;
            extern fn glGetInteger64i_v(target: GLenum, index: GLuint, data: [*]GLint64) void;
            extern fn glGetBufferParameteri64v(target: GLenum, pname: GLenum, params: [*]GLint64) void;
            extern fn glGenSamplers(count: GLsizei, samplers: [*]GLuint) void;
            extern fn glDeleteSamplers(count: GLsizei, samplers: [*]const GLuint) void;
            extern fn glIsSampler(sampler: GLuint) GLboolean;
            extern fn glBindSampler(unit: GLuint, sampler: GLuint) void;
            extern fn glSamplerParameteri(sampler: GLuint, pname: GLenum, param: GLint) void;
            extern fn glSamplerParameteriv(sampler: GLuint, pname: GLenum, params: [*]const GLint) void;
            extern fn glSamplerParameterf(sampler: GLuint, pname: GLenum, param: GLfloat) void;
            extern fn glSamplerParameterfv(sampler: GLuint, pname: GLenum, params: [*]const GLfloat) void;
            extern fn glGetSamplerParameteriv(sampler: GLuint, pname: GLenum, params: [*]GLint) void;
            extern fn glGetSamplerParameterfv(sampler: GLuint, pname: GLenum, params: [*]GLfloat) void;
            extern fn glVertexAttribDivisor(index: GLuint, divisor: GLuint) void;
            extern fn glBindTransformFeedback(target: GLenum, id: GLuint) void;
            extern fn glDeleteTransformFeedbacks(n: GLsizei, ids: [*]const GLuint) void;
            extern fn glGenTransformFeedbacks(n: GLsizei, ids: [*]GLuint) void;
            extern fn glIsTransformFeedback(id: GLuint) GLboolean;
            extern fn glPauseTransformFeedback() void;
            extern fn glResumeTransformFeedback() void;
            extern fn glGetProgramBinary(program: GLuint, bufSize: GLsizei, length: *GLsizei, binaryFormat: *GLenum, binary: *anyopaque) void;
            extern fn glProgramBinary(program: GLuint, binaryFormat: GLenum, binary: *const anyopaque, length: GLsizei) void;
            extern fn glProgramParameteri(program: GLuint, pname: GLenum, value: GLint) void;
            extern fn glInvalidateFramebuffer(target: GLenum, numAttachments: GLsizei, attachments: [*]const GLenum) void;
            extern fn glInvalidateSubFramebuffer(target: GLenum, numAttachments: GLsizei, attachments: [*]const GLenum, x: GLint, y: GLint, width: GLsizei, height: GLsizei) void;
            extern fn glTexStorage2D(target: GLenum, levels: GLsizei, internalformat: GLenum, width: GLsizei, height: GLsizei) void;
            extern fn glTexStorage3D(target: GLenum, levels: GLsizei, internalformat: GLenum, width: GLsizei, height: GLsizei, depth: GLsizei) void;
            extern fn glGetInternalformativ(target: GLenum, internalformat: GLenum, pname: GLenum, count: GLsizei, params: [*]GLint) void;

            // v3.1
            extern fn glDispatchCompute(num_groups_x: GLuint, num_groups_y: GLuint, num_groups_z: GLuint) void;
            extern fn glDispatchComputeIndirect(indirect: GLintptr) void;
            extern fn glDrawArraysIndirect(mode: GLenum, indirect: ?*const anyopaque) void;
            extern fn glDrawElementsIndirect(mode: GLenum, type: GLenum, indirect: ?*const anyopaque) void;
            extern fn glFramebufferParameteri(target: GLenum, pname: GLenum, param: GLint) void;
            extern fn glGetFramebufferParameteriv(target: GLenum, pname: GLenum, params: [*]GLint) void;
            extern fn glGetProgramInterfaceiv(program: GLuint, programInterface: GLenum, pname: GLenum, params: [*]GLint) void;
            extern fn glGetProgramResourceIndex(program: GLuint, programInterface: GLenum, name: [*:0]const GLchar) GLuint;
            extern fn glGetProgramResourceName(program: GLuint, programInterface: GLenum, index: GLuint, bufSize: GLsizei, length: [*]GLsizei, name: [*:0]GLchar) void;
            extern fn glGetProgramResourceiv(program: GLuint, programInterface: GLenum, index: GLuint, propCount: GLsizei, props: [*]const GLenum, count: GLsizei, length: *GLsizei, params: [*]GLint) void;
            extern fn glGetProgramResourceLocation(program: GLuint, programInterface: GLenum, name: [*:0]const GLchar) GLint;
            extern fn glUseProgramStages(pipeline: GLuint, stages: GLbitfield, program: GLuint) void;
            extern fn glActiveShaderProgram(pipeline: GLuint, program: GLuint) void;
            extern fn glCreateShaderProgramv(type: GLenum, count: GLsizei, strings: [*]const [*:0]const GLchar) GLuint;
            extern fn glBindProgramPipeline(pipeline: GLuint) void;
            extern fn glDeleteProgramPipelines(n: GLsizei, pipelines: [*]const GLuint) void;
            extern fn glGenProgramPipelines(n: GLsizei, pipelines: [*]GLuint) void;
            extern fn glIsProgramPipeline(pipeline: GLuint) GLboolean;
            extern fn glGetProgramPipelineiv(pipeline: GLuint, pname: GLenum, params: [*]GLint) void;
            extern fn glProgramUniform1i(program: GLuint, location: GLint, v0: GLint) void;
            extern fn glProgramUniform2i(program: GLuint, location: GLint, v0: GLint, v1: GLint) void;
            extern fn glProgramUniform3i(program: GLuint, location: GLint, v0: GLint, v1: GLint, v2: GLint) void;
            extern fn glProgramUniform4i(program: GLuint, location: GLint, v0: GLint, v1: GLint, v2: GLint, v3: GLint) void;
            extern fn glProgramUniform1ui(program: GLuint, location: GLint, v0: GLuint) void;
            extern fn glProgramUniform2ui(program: GLuint, location: GLint, v0: GLuint, v1: GLuint) void;
            extern fn glProgramUniform3ui(program: GLuint, location: GLint, v0: GLuint, v1: GLuint, v2: GLuint) void;
            extern fn glProgramUniform4ui(program: GLuint, location: GLint, v0: GLuint, v1: GLuint, v2: GLuint, v3: GLuint) void;
            extern fn glProgramUniform1f(program: GLuint, location: GLint, v0: GLfloat) void;
            extern fn glProgramUniform2f(program: GLuint, location: GLint, v0: GLfloat, v1: GLfloat) void;
            extern fn glProgramUniform3f(program: GLuint, location: GLint, v0: GLfloat, v1: GLfloat, v2: GLfloat) void;
            extern fn glProgramUniform4f(program: GLuint, location: GLint, v0: GLfloat, v1: GLfloat, v2: GLfloat, v3: GLfloat) void;
            extern fn glProgramUniform1iv(program: GLuint, location: GLint, count: GLsizei, value: [*]const GLint) void;
            extern fn glProgramUniform2iv(program: GLuint, location: GLint, count: GLsizei, value: [*]const GLint) void;
            extern fn glProgramUniform3iv(program: GLuint, location: GLint, count: GLsizei, value: [*]const GLint) void;
            extern fn glProgramUniform4iv(program: GLuint, location: GLint, count: GLsizei, value: [*]const GLint) void;
            extern fn glProgramUniform1uiv(program: GLuint, location: GLint, count: GLsizei, value: [*]const GLuint) void;
            extern fn glProgramUniform2uiv(program: GLuint, location: GLint, count: GLsizei, value: [*]const GLuint) void;
            extern fn glProgramUniform3uiv(program: GLuint, location: GLint, count: GLsizei, value: [*]const GLuint) void;
            extern fn glProgramUniform4uiv(program: GLuint, location: GLint, count: GLsizei, value: [*]const GLuint) void;
            extern fn glProgramUniform1fv(program: GLuint, location: GLint, count: GLsizei, value: [*]const GLfloat) void;
            extern fn glProgramUniform2fv(program: GLuint, location: GLint, count: GLsizei, value: [*]const GLfloat) void;
            extern fn glProgramUniform3fv(program: GLuint, location: GLint, count: GLsizei, value: [*]const GLfloat) void;
            extern fn glProgramUniform4fv(program: GLuint, location: GLint, count: GLsizei, value: [*]const GLfloat) void;
            extern fn glProgramUniformMatrix2fv(program: GLuint, location: GLint, count: GLsizei, transpose: GLboolean, value: [*]const GLfloat) void;
            extern fn glProgramUniformMatrix3fv(program: GLuint, location: GLint, count: GLsizei, transpose: GLboolean, value: [*]const GLfloat) void;
            extern fn glProgramUniformMatrix4fv(program: GLuint, location: GLint, count: GLsizei, transpose: GLboolean, value: [*]const GLfloat) void;
            extern fn glProgramUniformMatrix2x3fv(program: GLuint, location: GLint, count: GLsizei, transpose: GLboolean, value: [*]const GLfloat) void;
            extern fn glProgramUniformMatrix3x2fv(program: GLuint, location: GLint, count: GLsizei, transpose: GLboolean, value: [*]const GLfloat) void;
            extern fn glProgramUniformMatrix2x4fv(program: GLuint, location: GLint, count: GLsizei, transpose: GLboolean, value: [*]const GLfloat) void;
            extern fn glProgramUniformMatrix4x2fv(program: GLuint, location: GLint, count: GLsizei, transpose: GLboolean, value: [*]const GLfloat) void;
            extern fn glProgramUniformMatrix3x4fv(program: GLuint, location: GLint, count: GLsizei, transpose: GLboolean, value: [*]const GLfloat) void;
            extern fn glProgramUniformMatrix4x3fv(program: GLuint, location: GLint, count: GLsizei, transpose: GLboolean, value: [*]const GLfloat) void;
            extern fn glValidateProgramPipeline(pipeline: GLuint) void;
            extern fn glGetProgramPipelineInfoLog(pipeline: GLuint, bufSize: GLsizei, length: *GLsizei, infoLog: [*]GLchar) void;
            extern fn glBindImageTexture(unit: GLuint, texture: GLuint, level: GLint, layered: GLboolean, layer: GLint, access: GLenum, format: GLenum) void;
            extern fn glGetBooleani_v(target: GLenum, index: GLuint, data: [*]GLboolean) void;
            extern fn glMemoryBarrier(barriers: GLbitfield) void;
            extern fn glMemoryBarrierByRegion(barriers: GLbitfield) void;
            extern fn glTexStorage2DMultisample(target: GLenum, samples: GLsizei, internalformat: GLenum, width: GLsizei, height: GLsizei, fixedsamplelocations: GLboolean) void;
            extern fn glGetMultisamplefv(pname: GLenum, index: GLuint, val: [*]GLfloat) void;
            extern fn glSampleMaski(maskNumber: GLuint, mask: GLbitfield) void;
            extern fn glGetTexLevelParameteriv(target: GLenum, level: GLint, pname: GLenum, params: [*]GLint) void;
            extern fn glGetTexLevelParameterfv(target: GLenum, level: GLint, pname: GLenum, params: [*]GLfloat) void;
            extern fn glBindVertexBuffer(bindingindex: GLuint, buffer: GLuint, offset: GLintptr, stride: GLsizei) void;
            extern fn glVertexAttribFormat(attribindex: GLuint, size: GLint, type: GLenum, normalized: GLboolean, relativeoffset: GLuint) void;
            extern fn glVertexAttribIFormat(attribindex: GLuint, size: GLint, type: GLenum, relativeoffset: GLuint) void;
            extern fn glVertexAttribBinding(attribindex: GLuint, bindingindex: GLuint) void;
            extern fn glVertexBindingDivisor(bindingindex: GLuint, divisor: GLuint) void;
        };

        const Bindings = struct {
            // V2.0
            fn glBindAttribLocation(program: GLuint, index: GLuint, name: [:0]const u8) void {
                const c_name: [*]GLchar = @ptrCast(name.ptr);
                Externs.glBindAttribLocation(program, index, c_name);
            }

            fn glBufferData(target: GLenum, data: []const u8, usage: GLenum) void {
                Externs.glBufferData(target, data.len, data.ptr, usage);
            }

            fn glBufferSubData(target: GLenum, offset: GLintptr, data: []const u8) void {
                Externs.glBufferSubData(target, offset, data.len, data.ptr);
            }

            fn glCompressedTexImage2D(target: GLenum, level: GLint, internalformat: GLenum, width: GLsizei, height: GLsizei, border: GLint, data: []const u8) void {
                Externs.glCompressedTexImage2D(target, level, internalformat, width, height, border, data.len, data.ptr);
            }

            fn glCompressedTexSubImage2D(target: GLenum, level: GLint, xoffset: GLint, yoffset: GLint, width: GLsizei, height: GLsizei, format: GLenum, data: []const u8) void {
                Externs.glCompressedTexSubImage2D(target, level, xoffset, yoffset, width, height, format, data.len, data.ptr);
            }

            fn glDeleteBuffers(buffers: []const GLuint) void {
                Externs.glDeleteBuffers(buffers.len, buffers.ptr);
            }

            fn glDeleteFramebuffers(framebuffers: []const GLuint) void {
                Externs.glDeleteFramebuffers(framebuffers.len, framebuffers.ptr);
            }

            fn glDeleteRenderbuffers(renderbuffers: []const GLuint) void {
                Externs.glDeleteRenderbuffers(renderbuffers.len, renderbuffers.ptr);
            }

            fn glDeleteTextures(textures: []const GLuint) void {
                Externs.glDeleteTextures(textures);
            }

            fn glGenBuffers(buffers: []GLuint) void {
                Externs.glGenBuffers(@intCast(buffers.len), buffers.ptr);
            }

            fn glGenFramebuffers(framebuffers: []GLuint) void {
                Externs.glGenFramebuffers(@intCast(framebuffers.len), framebuffers.ptr);
            }

            fn glGenRenderbuffers(renderbuffers: []GLuint) void {
                Externs.glGenRenderbuffers(@intCast(renderbuffers.len), renderbuffers.ptr);
            }

            fn glGenTextures(textures: []GLuint) void {
                Externs.glGenTextures(textures.len, textures.ptr);
            }

            fn glGetActiveAttrib(program: GLuint, index: GLuint, size: *GLint, out_type: *GLenum, name: []u8) []u8 {
                var written: GLsizei = 0;
                Externs.glGetActiveAttrib(program, index, name.len, &written, size, out_type, @ptrCast(name.ptr));
                return name[0..written];
            }

            fn glGetActiveUniform(program: GLuint, index: GLuint, size: *GLint, out_type: *GLenum, name: []u8) []u8 {
                var written: GLsizei = 0;
                Externs.glGetActiveUniform(program, index, name.len, &written, size, out_type, @ptrCast(name.ptr));
                return name[0..written];
            }

            fn glGetAttachedShaders(program: GLuint, shaders: []GLuint) []GLuint {
                var written: GLsizei = 0;
                Externs.glGetAttachedShaders(program, shaders.len, &written, shaders.ptr);
                return shaders[0..written];
            }

            fn glGetAttribLocation(program: GLuint, name: [:0]const u8) GLint {
                return Externs.glGetAttribLocation(program, @ptrCast(name.ptr));
            }

            fn glGetError() ?GLenum {
                const err = Externs.glGetError();
                if (err == GL_NO_ERROR) {
                    return null;
                }
                return err;
            }

            fn glGetProgramInfoLog(program: GLuint, info_log: []u8) []u8 {
                var written: GLsizei = 0;
                Externs.glGetProgramInfoLog(program, info_log.len, &written, @ptrCast(info_log.ptr));
                return info_log[0..written];
            }

            fn glGetShaderInfoLog(shader: GLuint, info_log: []u8) []u8 {
                var written: GLsizei = 0;
                Externs.glGetShaderInfoLog(shader, info_log.len, &written, @ptrCast(info_log.ptr));
                return info_log[0..written];
            }

            fn glGetShaderSource(shader: GLuint, source: []u8) []u8 {
                var written: GLsizei = 0;
                Externs.glGetShaderSource(shader, source.len, &written, @ptrCast(source.ptr));
                return source[0..written];
            }

            fn glGetString(name: GLenum) []const u8 {
                return std.mem.span(Externs.glGetString(name));
            }

            fn glGetUniformLocation(program: GLuint, name: []const u8) GLint {
                return Externs.glGetUniformLocation(program, @ptrCast(name.ptr));
            }

            fn glShaderSource(shader: GLuint, strings: []const [:0]const u8) void {
                var mem: [4096]u8 = undefined;
                var fba = std.heap.FixedBufferAllocator.init(&mem);

                const c_strings: []const [*:0]const GLchar = Helpers.zigStringsToCStrings(strings, fba.allocator());

                Externs.glShaderSource(shader, @intCast(c_strings.len), c_strings.ptr, null);
            }

            fn glUniform1fv(location: GLint, uniform_count: GLsizei, value: []const GLfloat) void {
                Externs.glUniform1fv(location, uniform_count, value.ptr);
            }

            fn glUniform1iv(location: GLint, uniform_count: GLsizei, value: []const GLint) void {
                Externs.glUniform1iv(location, uniform_count, value.ptr);
            }

            fn glUniform2fv(location: GLint, uniform_count: GLsizei, value: []const GLfloat) void {
                Externs.glUniform2fv(location, uniform_count, value.ptr);
            }

            fn glUniform2iv(location: GLint, uniform_count: GLsizei, value: []const GLint) void {
                Externs.glUniform2iv(location, uniform_count, value.ptr);
            }

            fn glUniform3fv(location: GLint, uniform_count: GLsizei, value: []const GLfloat) void {
                Externs.glUniform3fv(location, uniform_count, value.ptr);
            }

            fn glUniform3iv(location: GLint, uniform_count: GLsizei, value: []const GLint) void {
                Externs.glUniform3iv(location, uniform_count, value.ptr);
            }

            fn glUniform4fv(location: GLint, uniform_count: GLsizei, value: []const GLfloat) void {
                Externs.glUniform4fv(location, uniform_count, value.ptr);
            }

            fn glUniform4iv(location: GLint, uniform_count: GLsizei, value: []const GLint) void {
                Externs.glUniform4iv(location, uniform_count, value.ptr);
            }

            fn glUniformMatrix2fv(location: GLint, uniform_count: GLsizei, transpose: bool, value: []const GLfloat) void {
                const gl_transpose: u8 = if (transpose) 1 else 0;
                Externs.glUniformMatrix2fv(location, uniform_count, gl_transpose, value.ptr);
            }

            fn glUniformMatrix3fv(location: GLint, uniform_count: GLsizei, transpose: bool, value: []const GLfloat) void {
                const gl_transpose: u8 = if (transpose) 1 else 0;
                Externs.glUniformMatrix3fv(location, uniform_count, gl_transpose, value.ptr);
            }

            fn glUniformMatrix4fv(location: GLint, uniform_count: GLsizei, transpose: bool, value: []const GLfloat) void {
                const gl_transpose: u8 = if (transpose) 1 else 0;
                Externs.glUniformMatrix4fv(location, uniform_count, gl_transpose, value.ptr);
            }

            // V3.0

            fn glDrawRangeElements(mode: GLenum, start: GLuint, end: GLuint, count: GLsizei, index_type: GLenum, indices: []const u8) void {
                Externs.glDrawRangeElements(mode, start, end, count, index_type, indices.ptr);
            }

            fn glTexImage3D(target: GLenum, level: GLint, internalformat: GLint, width: GLsizei, height: GLsizei, depth: GLsizei, border: GLint, format: GLenum, pixel_type: GLenum, pixels: []const u8) void {
                Externs.glTexImage3D(target, level, internalformat, width, height, depth, border, format, pixel_type, pixels.ptr);
            }

            fn glTexSubImage3D(target: GLenum, level: GLint, xoffset: GLint, yoffset: GLint, zoffset: GLint, width: GLsizei, height: GLsizei, depth: GLsizei, format: GLenum, pixel_type: GLenum, pixels: []const u8) void {
                Externs.glTexSubImage3D(target, level, xoffset, yoffset, zoffset, width, height, depth, format, pixel_type, pixels.ptr);
            }

            fn glCompressedTexImage3D(target: GLenum, level: GLint, internalformat: GLenum, width: GLsizei, height: GLsizei, depth: GLsizei, border: GLint, data: []const u8) void {
                Externs.glCompressedTexImage3D(target, level, internalformat, width, height, depth, border, data.len, data.ptr);
            }

            fn glCompressedTexSubImage3D(target: GLenum, level: GLint, xoffset: GLint, yoffset: GLint, zoffset: GLint, width: GLsizei, height: GLsizei, depth: GLsizei, format: GLenum, data: []const u8) void {
                Externs.glCompressedTexSubImage3D(target, level, xoffset, yoffset, zoffset, width, height, depth, format, data.len, data.ptr);
            }

            fn glGenQueries(ids: []GLuint) void {
                Externs.glGenQueries(ids.len, ids.ptr);
            }

            fn glDeleteQueries(ids: []const GLuint) void {
                Externs.glDeleteQueries(ids.len, ids.ptr);
            }

            fn glGetQueryiv(target: GLenum, pname: GLenum, params: []GLint) void {
                Externs.glGetQueryiv(target, pname, params.ptr);
            }

            fn glGetQueryObjectuiv(id: GLuint, pname: GLenum, params: []GLuint) void {
                Externs.glGetQueryObjectuiv(id, pname, params.ptr);
            }

            fn glDrawBuffers(bufs: []const GLenum) void {
                Externs.glDrawBuffers(bufs.len, bufs.ptr);
            }

            fn glUniformMatrix2x3fv(location: GLint, count: GLsizei, transpose: bool, value: []const GLfloat) void {
                const c_transpose = if (transpose) GL_TRUE else GL_FALSE;
                Externs.glUniformMatrix2x3fv(location, count, c_transpose, value.ptr);
            }

            fn glUniformMatrix3x2fv(location: GLint, count: GLsizei, transpose: bool, value: []const GLfloat) void {
                const c_transpose = if (transpose) GL_TRUE else GL_FALSE;
                Externs.glUniformMatrix3x2fv(location, count, c_transpose, value.ptr);
            }

            fn glUniformMatrix2x4fv(location: GLint, count: GLsizei, transpose: bool, value: []const GLfloat) void {
                const c_transpose = if (transpose) GL_TRUE else GL_FALSE;
                Externs.glUniformMatrix2x4fv(location, count, c_transpose, value.ptr);
            }

            fn glUniformMatrix4x2fv(location: GLint, count: GLsizei, transpose: bool, value: []const GLfloat) void {
                const c_transpose = if (transpose) GL_TRUE else GL_FALSE;
                Externs.glUniformMatrix4x2fv(location, count, c_transpose, value.ptr);
            }

            fn glUniformMatrix3x4fv(location: GLint, count: GLsizei, transpose: bool, value: []const GLfloat) void {
                const c_transpose = if (transpose) GL_TRUE else GL_FALSE;
                Externs.glUniformMatrix3x4fv(location, count, c_transpose, value.ptr);
            }

            fn glUniformMatrix4x3fv(location: GLint, count: GLsizei, transpose: bool, value: []const GLfloat) void {
                const c_transpose = if (transpose) GL_TRUE else GL_FALSE;
                Externs.glUniformMatrix4x3fv(location, count, c_transpose, value.ptr);
            }

            fn glDeleteVertexArrays(arrays: []const GLuint) void {
                Externs.glDeleteVertexArrays(arrays.len, arrays.ptr);
            }

            fn glGenVertexArrays(arrays: []GLuint) void {
                Externs.glGenVertexArrays(arrays.len, arrays.ptr);
            }

            fn glGetIntegeri_v(target: GLenum, index: GLuint, data: []GLint) void {
                Externs.glGetIntegeri_v(target, index, data.ptr);
            }

            fn glTransformFeedbackVaryings(program: GLuint, varyings: []const [:0]const u8, buffer_mode: GLenum) void {
                var mem: [4096]u8 = undefined;
                var fba = std.heap.FixedBufferAllocator.init(&mem);

                const c_varyings: []const [*:0]const GLchar = Helpers.zigStringsToCStrings(varyings, fba.allocator());

                Externs.glTransformFeedbackVaryings(program, c_varyings.len, c_varyings.ptr, buffer_mode);
            }

            fn glGetTransformFeedbackVarying(program: GLuint, index: GLuint, varying_type: *GLenum, name: []u8) []u8 {
                var written: GLsizei = 0;
                Externs.glGetTransformFeedbackVarying(program, index, name.len, &written, varying_type, @ptrCast(name.ptr));
                return name[0..written];
            }

            fn glGetVertexAttribIiv(index: GLuint, pname: GLenum, params: []GLint) void {
                Externs.glGetVertexAttribIiv(index, pname, params.ptr);
            }

            fn glGetVertexAttribIuiv(index: GLuint, pname: GLenum, params: []GLuint) void {
                Externs.glGetVertexAttribIuiv(index, pname, params.ptr);
            }

            fn glVertexAttribI4iv(index: GLuint, v: []const GLint) void {
                Externs.glVertexAttribI4iv(index, v.ptr);
            }

            fn glVertexAttribI4uiv(index: GLuint, v: []const GLuint) void {
                Externs.glVertexAttribI4uiv(index, v.ptr);
            }

            fn glUniform1uiv(location: GLint, count: GLsizei, value: []const GLuint) void {
                Externs.glUniform1uiv(location, count, value.ptr);
            }

            fn glUniform2uiv(location: GLint, count: GLsizei, value: []const GLuint) void {
                Externs.glUniform2uiv(location, count, value.ptr);
            }

            fn glUniform3uiv(location: GLint, count: GLsizei, value: []const GLuint) void {
                Externs.glUniform3uiv(location, count, value.ptr);
            }

            fn glUniform4uiv(location: GLint, count: GLsizei, value: []const GLuint) void {
                Externs.glUniform4uiv(location, count, value.ptr);
            }

            fn glClearBufferiv(buffer: GLenum, drawbuffer: GLint, value: []const GLint) void {
                Externs.glClearBufferiv(buffer, drawbuffer, value.ptr);
            }

            fn glClearBufferuiv(buffer: GLenum, drawbuffer: GLint, value: []const GLuint) void {
                Externs.glClearBufferuiv(buffer, drawbuffer, value.ptr);
            }

            fn glClearBufferfv(buffer: GLenum, drawbuffer: GLint, value: []const GLfloat) void {
                Externs.glClearBufferfv(buffer, drawbuffer, value.ptr);
            }

            fn glGetStringi(name: GLenum, index: GLuint) []const u8 {
                return std.mem.span(Externs.glGetStringi(name, index));
            }

            fn glGetUniformIndices(program: GLuint, uniform_names: []const [:0]const u8, uniform_indices: []GLuint) void {
                debug.assert(uniform_names.len == uniform_indices.len);

                var mem: [4096]u8 = undefined;
                var fba = std.heap.FixedBufferAllocator.init(&mem);

                const c_names: []const [*:0]const GLchar = Helpers.zigStringsToCStrings(uniform_names, fba.allocator());

                Externs.glGetUniformIndices(program, c_names.len, c_names, uniform_indices.ptr);
            }

            fn glGetActiveUniformsiv(program: GLuint, uniform_indices: []const GLuint, pname: GLenum, params: []GLint) void {
                Externs.glGetActiveUniformsiv(program, program, uniform_indices.len, uniform_indices.len, pname, params.ptr);
            }

            fn glGetUniformBlockIndex(program: GLuint, uniform_block_name: [:0]const u8) GLuint {
                Externs.glGetUniformBlockIndex(program, @ptrCast(uniform_block_name.ptr));
            }

            fn glGetActiveUniformBlockiv(program: GLuint, uniform_block_index: GLuint, pname: GLenum, params: []GLint) void {
                Externs.glGetActiveUniformBlockiv(program, uniform_block_index, pname, params.ptr);
            }

            fn glGetActiveUniformBlockName(program: GLuint, uniform_block_index: GLuint, uniform_block_name: [*]u8) []const u8 {
                var written: GLsizei = 0;
                Externs.glGetActiveUniformBlockName(program, uniform_block_index, uniform_block_name.len, &written, @ptrCast(uniform_block_name.ptr));
                return uniform_block_name[0..written];
            }

            fn glDrawElementsInstanced(mode: GLenum, count: GLsizei, index_type: GLenum, indices: []const u8, instancecount: GLsizei) void {
                Externs.glDrawElementsInstanced(mode, count, index_type, indices.ptr, instancecount);
            }

            fn glGetInteger64v(pname: GLenum, data: []GLint64) void {
                Externs.glGetInteger64v(pname, data.ptr);
            }

            fn glGetSynciv(sync: GLsync, pname: GLenum, values: []GLint) []GLint {
                var written: GLsizei = 0;
                Externs.glGetSynciv(sync, pname, values.len, &written, values.ptr);
                return values[0..written];
            }

            fn glGetInteger64i_v(target: GLenum, index: GLuint, data: []GLint64) void {
                Externs.glGetInteger64i_v(target, index, data.ptr);
            }

            fn glGetBufferParameteri64v(target: GLenum, pname: GLenum, params: []GLint64) void {
                Externs.glGetBufferParameteri64v(target, pname, params.ptr);
            }

            fn glGenSamplers(samplers: []GLuint) void {
                Externs.glGenSamplers(samplers.len, samplers.ptr);
            }

            fn glDeleteSamplers(samplers: []const GLuint) void {
                Externs.glDeleteSamplers(samplers.len, samplers.ptr);
            }

            fn glSamplerParameteriv(sampler: GLuint, pname: GLenum, params: []const GLint) void {
                Externs.glSamplerParameteriv(sampler, pname, params.ptr);
            }

            fn glSamplerParameterfv(sampler: GLuint, pname: GLenum, params: []const GLfloat) void {
                Externs.glSamplerParameterfv(sampler, pname, params.ptr);
            }

            fn glGetSamplerParameteriv(sampler: GLuint, pname: GLenum, params: []GLint) void {
                Externs.glGetSamplerParameteriv(sampler, pname, params.ptr);
            }

            fn glGetSamplerParameterfv(sampler: GLuint, pname: GLenum, params: []GLfloat) void {
                Externs.glGetSamplerParameterfv(sampler, pname, params.ptr);
            }

            fn glDeleteTransformFeedbacks(ids: []const GLuint) void {
                Externs.glDeleteTransformFeedbacks(ids.len, ids.ptr);
            }

            fn glGenTransformFeedbacks(ids: []GLuint) void {
                Externs.glGenTransformFeedbacks(ids.len, ids.ptr);
            }

            fn glGetProgramBinary(program: GLuint, binary_format: *GLenum, binary: []u8) void {
                var written: GLsizei = 0;
                Externs.glGetProgramBinary(program, binary.len, &written, binary_format, binary.ptr);
                return binary[0..written];
            }

            fn glProgramBinary(program: GLuint, binary_format: GLenum, binary: []const u8) void {
                Externs.glProgramBinary(program, binary_format, binary.ptr, binary.len);
            }

            fn glInvalidateFramebuffer(target: GLenum, attachments: []const GLenum) void {
                Externs.glInvalidateFramebuffer(target, attachments.len, attachments.ptr);
            }

            fn glInvalidateSubFramebuffer(target: GLenum, attachments: []const GLenum, x: GLint, y: GLint, width: GLsizei, height: GLsizei) void {
                Externs.glInvalidateSubFramebuffer(target, attachments.len, attachments.ptr, x, y, width, height);
            }

            fn glGetInternalformativ(target: GLenum, internal_format: GLenum, pname: GLenum, params: []GLint) void {
                Externs.glGetInternalformativ(target, internal_format, pname, params.len, params.ptr);
            }

            fn glGetFramebufferParameteriv(target: GLenum, pname: GLenum, params: []GLint) void {
                Externs.glGetFramebufferParameteriv(target, pname, params.ptr);
            }

            fn glGetProgramInterfaceiv(program: GLuint, program_interface: GLenum, pname: GLenum, params: []GLint) void {
                Externs.glGetProgramInterfaceiv(program, program_interface, pname, params.ptr);
            }

            fn glGetProgramResourceIndex(program: GLuint, program_interface: GLenum, name: [:0]const u8) GLuint {
                return Externs.glGetProgramResourceIndex(program, program_interface, @ptrCast(name.ptr));
            }

            fn glGetProgramResourceName(program: GLuint, program_interface: GLenum, index: GLuint, name: [:0]u8) []u8 {
                var written: GLsizei = 0;
                Externs.glGetProgramResourceName(program, program_interface, index, name.len, &written, @ptrCast(name.ptr));
                return name[0..written];
            }

            fn glGetProgramResourceiv(program: GLuint, program_interface: GLenum, index: GLuint, props: []const GLenum, params: []GLint) []GLint {
                var written: GLsizei = 0;
                Externs.glGetProgramResourceiv(program, program_interface, index, props.len, props.ptr, params.len, &written, params.ptr);
                return params[0..written];
            }

            fn glGetProgramResourceLocation(program: GLuint, program_interface: GLenum, name: [:0]const u8) GLint {
                return Externs.glGetProgramResourceLocation(program, program_interface, @ptrCast(name.ptr));
            }

            fn glCreateShaderProgramv(shader_type: GLenum, strings: []const [:0]const u8) GLuint {
                var mem: [4096]u8 = undefined;
                var fba = std.heap.FixedBufferAllocator.init(&mem);

                const c_names: []const [*:0]const GLchar = Helpers.zigStringsToCStrings(strings, fba.allocator());

                return Externs.glCreateShaderProgramv(shader_type, c_names.len, @ptrCast(c_names.ptr));
            }

            fn glDeleteProgramPipelines(pipelines: []const GLuint) void {
                Externs.glDeleteProgramPipelines(pipelines.len, pipelines.ptr);
            }

            fn glGenProgramPipelines(pipelines: []GLuint) void {
                Externs.glGenProgramPipelines(pipelines.len, pipelines.ptr);
            }

            fn glGetProgramPipelineiv(pipeline: GLuint, pname: GLenum, params: []GLint) void {
                Externs.glGetProgramPipelineiv(pipeline, pname, params.ptr);
            }

            fn glProgramUniform1iv(program: GLuint, location: GLint, count: GLsizei, value: []const GLint) void {
                Externs.glProgramUniform1iv(program, location, count, value.ptr);
            }

            fn glProgramUniform2iv(program: GLuint, location: GLint, count: GLsizei, value: []const GLint) void {
                Externs.glProgramUniform2iv(program, location, count, value.ptr);
            }

            fn glProgramUniform3iv(program: GLuint, location: GLint, count: GLsizei, value: []const GLint) void {
                Externs.glProgramUniform3iv(program, location, count, value.ptr);
            }

            fn glProgramUniform4iv(program: GLuint, location: GLint, count: GLsizei, value: []const GLint) void {
                Externs.glProgramUniform4iv(program, location, count, value.ptr);
            }

            fn glProgramUniform1uiv(program: GLuint, location: GLint, count: GLsizei, value: []const GLuint) void {
                Externs.glProgramUniform1uiv(program, location, count, value.ptr);
            }

            fn glProgramUniform2uiv(program: GLuint, location: GLint, count: GLsizei, value: []const GLuint) void {
                Externs.glProgramUniform2uiv(program, location, count, value.ptr);
            }

            fn glProgramUniform3uiv(program: GLuint, location: GLint, count: GLsizei, value: []const GLuint) void {
                Externs.glProgramUniform3uiv(program, location, count, value.ptr);
            }

            fn glProgramUniform4uiv(program: GLuint, location: GLint, count: GLsizei, value: []const GLuint) void {
                Externs.glProgramUniform4uiv(program, location, count, value.ptr);
            }

            fn glProgramUniform1fv(program: GLuint, location: GLint, count: GLsizei, value: []const GLfloat) void {
                Externs.glProgramUniform1fv(program, location, count, value.ptr);
            }

            fn glProgramUniform2fv(program: GLuint, location: GLint, count: GLsizei, value: []const GLfloat) void {
                Externs.glProgramUniform2fv(program, location, count, value.ptr);
            }

            fn glProgramUniform3fv(program: GLuint, location: GLint, count: GLsizei, value: []const GLfloat) void {
                Externs.glProgramUniform3fv(program, location, count, value.ptr);
            }

            fn glProgramUniform4fv(program: GLuint, location: GLint, count: GLsizei, value: []const GLfloat) void {
                Externs.glProgramUniform4fv(program, location, count, value.ptr);
            }

            fn glProgramUniformMatrix2fv(program: GLuint, location: GLint, count: GLsizei, transpose: bool, value: []const GLfloat) void {
                const c_transpose = if (transpose) GL_TRUE else GL_FALSE;
                Externs.glProgramUniformMatrix2fv(program, location, count, c_transpose, value.ptr);
            }

            fn glProgramUniformMatrix3fv(program: GLuint, location: GLint, count: GLsizei, transpose: bool, value: []const GLfloat) void {
                const c_transpose = if (transpose) GL_TRUE else GL_FALSE;
                Externs.glProgramUniformMatrix3fv(program, location, count, c_transpose, value.ptr);
            }

            fn glProgramUniformMatrix4fv(program: GLuint, location: GLint, count: GLsizei, transpose: bool, value: []const GLfloat) void {
                const c_transpose = if (transpose) GL_TRUE else GL_FALSE;
                Externs.glProgramUniformMatrix4fv(program, location, count, c_transpose, value.ptr);
            }

            fn glProgramUniformMatrix2x3fv(program: GLuint, location: GLint, count: GLsizei, transpose: bool, value: []const GLfloat) void {
                const c_transpose = if (transpose) GL_TRUE else GL_FALSE;
                Externs.glProgramUniformMatrix2x3fv(program, location, count, c_transpose, value.ptr);
            }

            fn glProgramUniformMatrix3x2fv(program: GLuint, location: GLint, count: GLsizei, transpose: bool, value: []const GLfloat) void {
                const c_transpose = if (transpose) GL_TRUE else GL_FALSE;
                Externs.glProgramUniformMatrix3x2fv(program, location, count, c_transpose, value.ptr);
            }

            fn glProgramUniformMatrix2x4fv(program: GLuint, location: GLint, count: GLsizei, transpose: bool, value: []const GLfloat) void {
                const c_transpose = if (transpose) GL_TRUE else GL_FALSE;
                Externs.glProgramUniformMatrix2x4fv(program, location, count, c_transpose, value.ptr);
            }

            fn glProgramUniformMatrix4x2fv(program: GLuint, location: GLint, count: GLsizei, transpose: bool, value: []const GLfloat) void {
                const c_transpose = if (transpose) GL_TRUE else GL_FALSE;
                Externs.glProgramUniformMatrix4x2fv(program, location, count, c_transpose, value.ptr);
            }

            fn glProgramUniformMatrix3x4fv(program: GLuint, location: GLint, count: GLsizei, transpose: bool, value: []const GLfloat) void {
                const c_transpose = if (transpose) GL_TRUE else GL_FALSE;
                Externs.glProgramUniformMatrix3x4fv(program, location, count, c_transpose, value.ptr);
            }

            fn glProgramUniformMatrix4x3fv(program: GLuint, location: GLint, count: GLsizei, transpose: bool, value: []const GLfloat) void {
                const c_transpose = if (transpose) GL_TRUE else GL_FALSE;
                Externs.glProgramUniformMatrix4x3fv(program, location, count, c_transpose, value.ptr);
            }

            fn glGetProgramPipelineInfoLog(pipeline: GLuint, info_log: []u8) []u8 {
                var written: GLsizei = 0;
                Externs.glGetProgramPipelineInfoLog(pipeline, info_log.len, &written, @ptrCast(info_log.ptr));
                return info_log[0..written];
            }

            fn glGetBooleani_v(target: GLenum, index: GLuint, data: []GLboolean) void {
                Externs.glGetBooleani_v(target, index, data.ptr);
            }

            fn glGetMultisamplefv(pname: GLenum, index: GLuint, val: []GLfloat) void {
                Externs.glGetMultisamplefv(pname, index, val.ptr);
            }

            fn glGetTexLevelParameteriv(target: GLenum, level: GLint, pname: GLenum, params: []GLint) void {
                Externs.glGetTexLevelParameteriv(target, level, pname, params.ptr);
            }

            fn glGetTexLevelParameterfv(target: GLenum, level: GLint, pname: GLenum, params: []GLfloat) void {
                Externs.glGetTexLevelParameterfv(target, level, pname, params.ptr);
            }
        };

        // v2.0
        pub const GLbyte = i8;
        pub const GLclampf = f32;
        pub const GLfixed = i32;
        pub const GLshort = i16;
        pub const GLushort = u16;
        pub const GLvoid = void;
        pub const GLsync = *anyopaque;
        pub const GLint64 = i64;
        pub const GLuint64 = u64;
        pub const GLenum = c_uint;
        pub const GLuint = c_uint;
        pub const GLchar = i8;
        pub const GLfloat = f32;
        pub const GLsizeiptr = usize;
        pub const GLintptr = isize;
        pub const GLbitfield = c_uint;
        pub const GLint = c_int;
        pub const GLboolean = u8;
        pub const GLsizei = c_int;
        pub const GLubyte = u8;

        pub const GL_DEPTH_BUFFER_BIT: GLenum = 0x00000100;
        pub const GL_STENCIL_BUFFER_BIT: GLenum = 0x00000400;
        pub const GL_COLOR_BUFFER_BIT: GLenum = 0x00004000;
        pub const GL_FALSE: GLenum = 0;
        pub const GL_TRUE: GLenum = 1;
        pub const GL_POINTS: GLenum = 0x0000;
        pub const GL_LINES: GLenum = 0x0001;
        pub const GL_LINE_LOOP: GLenum = 0x0002;
        pub const GL_LINE_STRIP: GLenum = 0x0003;
        pub const GL_TRIANGLES: GLenum = 0x0004;
        pub const GL_TRIANGLE_STRIP: GLenum = 0x0005;
        pub const GL_TRIANGLE_FAN: GLenum = 0x0006;
        pub const GL_ZERO: GLenum = 0;
        pub const GL_ONE: GLenum = 1;
        pub const GL_SRC_COLOR: GLenum = 0x0300;
        pub const GL_ONE_MINUS_SRC_COLOR: GLenum = 0x0301;
        pub const GL_SRC_ALPHA: GLenum = 0x0302;
        pub const GL_ONE_MINUS_SRC_ALPHA: GLenum = 0x0303;
        pub const GL_DST_ALPHA: GLenum = 0x0304;
        pub const GL_ONE_MINUS_DST_ALPHA: GLenum = 0x0305;
        pub const GL_DST_COLOR: GLenum = 0x0306;
        pub const GL_ONE_MINUS_DST_COLOR: GLenum = 0x0307;
        pub const GL_SRC_ALPHA_SATURATE: GLenum = 0x0308;
        pub const GL_FUNC_ADD: GLenum = 0x8006;
        pub const GL_BLEND_EQUATION: GLenum = 0x8009;
        pub const GL_BLEND_EQUATION_RGB: GLenum = 0x8009;
        pub const GL_BLEND_EQUATION_ALPHA: GLenum = 0x883D;
        pub const GL_FUNC_SUBTRACT: GLenum = 0x800A;
        pub const GL_FUNC_REVERSE_SUBTRACT: GLenum = 0x800B;
        pub const GL_BLEND_DST_RGB: GLenum = 0x80C8;
        pub const GL_BLEND_SRC_RGB: GLenum = 0x80C9;
        pub const GL_BLEND_DST_ALPHA: GLenum = 0x80CA;
        pub const GL_BLEND_SRC_ALPHA: GLenum = 0x80CB;
        pub const GL_CONSTANT_COLOR: GLenum = 0x8001;
        pub const GL_ONE_MINUS_CONSTANT_COLOR: GLenum = 0x8002;
        pub const GL_CONSTANT_ALPHA: GLenum = 0x8003;
        pub const GL_ONE_MINUS_CONSTANT_ALPHA: GLenum = 0x8004;
        pub const GL_BLEND_COLOR: GLenum = 0x8005;
        pub const GL_ARRAY_BUFFER: GLenum = 0x8892;
        pub const GL_ELEMENT_ARRAY_BUFFER: GLenum = 0x8893;
        pub const GL_ARRAY_BUFFER_BINDING: GLenum = 0x8894;
        pub const GL_ELEMENT_ARRAY_BUFFER_BINDING: GLenum = 0x8895;
        pub const GL_STREAM_DRAW: GLenum = 0x88E0;
        pub const GL_STATIC_DRAW: GLenum = 0x88E4;
        pub const GL_DYNAMIC_DRAW: GLenum = 0x88E8;
        pub const GL_BUFFER_SIZE: GLenum = 0x8764;
        pub const GL_BUFFER_USAGE: GLenum = 0x8765;
        pub const GL_CURRENT_VERTEX_ATTRIB: GLenum = 0x8626;
        pub const GL_FRONT: GLenum = 0x0404;
        pub const GL_BACK: GLenum = 0x0405;
        pub const GL_FRONT_AND_BACK: GLenum = 0x0408;
        pub const GL_TEXTURE_2D: GLenum = 0x0DE1;
        pub const GL_CULL_FACE: GLenum = 0x0B44;
        pub const GL_BLEND: GLenum = 0x0BE2;
        pub const GL_DITHER: GLenum = 0x0BD0;
        pub const GL_STENCIL_TEST: GLenum = 0x0B90;
        pub const GL_DEPTH_TEST: GLenum = 0x0B71;
        pub const GL_SCISSOR_TEST: GLenum = 0x0C11;
        pub const GL_POLYGON_OFFSET_FILL: GLenum = 0x8037;
        pub const GL_SAMPLE_ALPHA_TO_COVERAGE: GLenum = 0x809E;
        pub const GL_SAMPLE_COVERAGE: GLenum = 0x80A0;
        pub const GL_NO_ERROR: GLenum = 0;
        pub const GL_INVALID_ENUM: GLenum = 0x0500;
        pub const GL_INVALID_VALUE: GLenum = 0x0501;
        pub const GL_INVALID_OPERATION: GLenum = 0x0502;
        pub const GL_OUT_OF_MEMORY: GLenum = 0x0505;
        pub const GL_CW: GLenum = 0x0900;
        pub const GL_CCW: GLenum = 0x0901;
        pub const GL_LINE_WIDTH: GLenum = 0x0B21;
        pub const GL_ALIASED_POINT_SIZE_RANGE: GLenum = 0x846D;
        pub const GL_ALIASED_LINE_WIDTH_RANGE: GLenum = 0x846E;
        pub const GL_CULL_FACE_MODE: GLenum = 0x0B45;
        pub const GL_FRONT_FACE: GLenum = 0x0B46;
        pub const GL_DEPTH_RANGE: GLenum = 0x0B70;
        pub const GL_DEPTH_WRITEMASK: GLenum = 0x0B72;
        pub const GL_DEPTH_CLEAR_VALUE: GLenum = 0x0B73;
        pub const GL_DEPTH_FUNC: GLenum = 0x0B74;
        pub const GL_STENCIL_CLEAR_VALUE: GLenum = 0x0B91;
        pub const GL_STENCIL_FUNC: GLenum = 0x0B92;
        pub const GL_STENCIL_FAIL: GLenum = 0x0B94;
        pub const GL_STENCIL_PASS_DEPTH_FAIL: GLenum = 0x0B95;
        pub const GL_STENCIL_PASS_DEPTH_PASS: GLenum = 0x0B96;
        pub const GL_STENCIL_REF: GLenum = 0x0B97;
        pub const GL_STENCIL_VALUE_MASK: GLenum = 0x0B93;
        pub const GL_STENCIL_WRITEMASK: GLenum = 0x0B98;
        pub const GL_STENCIL_BACK_FUNC: GLenum = 0x8800;
        pub const GL_STENCIL_BACK_FAIL: GLenum = 0x8801;
        pub const GL_STENCIL_BACK_PASS_DEPTH_FAIL: GLenum = 0x8802;
        pub const GL_STENCIL_BACK_PASS_DEPTH_PASS: GLenum = 0x8803;
        pub const GL_STENCIL_BACK_REF: GLenum = 0x8CA3;
        pub const GL_STENCIL_BACK_VALUE_MASK: GLenum = 0x8CA4;
        pub const GL_STENCIL_BACK_WRITEMASK: GLenum = 0x8CA5;
        pub const GL_VIEWPORT: GLenum = 0x0BA2;
        pub const GL_SCISSOR_BOX: GLenum = 0x0C10;
        pub const GL_COLOR_CLEAR_VALUE: GLenum = 0x0C22;
        pub const GL_COLOR_WRITEMASK: GLenum = 0x0C23;
        pub const GL_UNPACK_ALIGNMENT: GLenum = 0x0CF5;
        pub const GL_PACK_ALIGNMENT: GLenum = 0x0D05;
        pub const GL_MAX_TEXTURE_SIZE: GLenum = 0x0D33;
        pub const GL_MAX_VIEWPORT_DIMS: GLenum = 0x0D3A;
        pub const GL_SUBPIXEL_BITS: GLenum = 0x0D50;
        pub const GL_RED_BITS: GLenum = 0x0D52;
        pub const GL_GREEN_BITS: GLenum = 0x0D53;
        pub const GL_BLUE_BITS: GLenum = 0x0D54;
        pub const GL_ALPHA_BITS: GLenum = 0x0D55;
        pub const GL_DEPTH_BITS: GLenum = 0x0D56;
        pub const GL_STENCIL_BITS: GLenum = 0x0D57;
        pub const GL_POLYGON_OFFSET_UNITS: GLenum = 0x2A00;
        pub const GL_POLYGON_OFFSET_FACTOR: GLenum = 0x8038;
        pub const GL_TEXTURE_BINDING_2D: GLenum = 0x8069;
        pub const GL_SAMPLE_BUFFERS: GLenum = 0x80A8;
        pub const GL_SAMPLES: GLenum = 0x80A9;
        pub const GL_SAMPLE_COVERAGE_VALUE: GLenum = 0x80AA;
        pub const GL_SAMPLE_COVERAGE_INVERT: GLenum = 0x80AB;
        pub const GL_NUM_COMPRESSED_TEXTURE_FORMATS: GLenum = 0x86A2;
        pub const GL_COMPRESSED_TEXTURE_FORMATS: GLenum = 0x86A3;
        pub const GL_DONT_CARE: GLenum = 0x1100;
        pub const GL_FASTEST: GLenum = 0x1101;
        pub const GL_NICEST: GLenum = 0x1102;
        pub const GL_GENERATE_MIPMAP_HINT: GLenum = 0x8192;
        pub const GL_BYTE: GLenum = 0x1400;
        pub const GL_UNSIGNED_BYTE: GLenum = 0x1401;
        pub const GL_SHORT: GLenum = 0x1402;
        pub const GL_UNSIGNED_SHORT: GLenum = 0x1403;
        pub const GL_INT: GLenum = 0x1404;
        pub const GL_UNSIGNED_INT: GLenum = 0x1405;
        pub const GL_FLOAT: GLenum = 0x1406;
        pub const GL_FIXED: GLenum = 0x140C;
        pub const GL_DEPTH_COMPONENT: GLenum = 0x1902;
        pub const GL_ALPHA: GLenum = 0x1906;
        pub const GL_RGB: GLenum = 0x1907;
        pub const GL_RGBA: GLenum = 0x1908;
        pub const GL_LUMINANCE: GLenum = 0x1909;
        pub const GL_LUMINANCE_ALPHA: GLenum = 0x190A;
        pub const GL_UNSIGNED_SHORT_4_4_4_4: GLenum = 0x8033;
        pub const GL_UNSIGNED_SHORT_5_5_5_1: GLenum = 0x8034;
        pub const GL_UNSIGNED_SHORT_5_6_5: GLenum = 0x8363;
        pub const GL_FRAGMENT_SHADER: GLenum = 0x8B30;
        pub const GL_VERTEX_SHADER: GLenum = 0x8B31;
        pub const GL_MAX_VERTEX_ATTRIBS: GLenum = 0x8869;
        pub const GL_MAX_VERTEX_UNIFORM_VECTORS: GLenum = 0x8DFB;
        pub const GL_MAX_VARYING_VECTORS: GLenum = 0x8DFC;
        pub const GL_MAX_COMBINED_TEXTURE_IMAGE_UNITS: GLenum = 0x8B4D;
        pub const GL_MAX_VERTEX_TEXTURE_IMAGE_UNITS: GLenum = 0x8B4C;
        pub const GL_MAX_TEXTURE_IMAGE_UNITS: GLenum = 0x8872;
        pub const GL_MAX_FRAGMENT_UNIFORM_VECTORS: GLenum = 0x8DFD;
        pub const GL_SHADER_TYPE: GLenum = 0x8B4F;
        pub const GL_DELETE_STATUS: GLenum = 0x8B80;
        pub const GL_LINK_STATUS: GLenum = 0x8B82;
        pub const GL_VALIDATE_STATUS: GLenum = 0x8B83;
        pub const GL_ATTACHED_SHADERS: GLenum = 0x8B85;
        pub const GL_ACTIVE_UNIFORMS: GLenum = 0x8B86;
        pub const GL_ACTIVE_UNIFORM_MAX_LENGTH: GLenum = 0x8B87;
        pub const GL_ACTIVE_ATTRIBUTES: GLenum = 0x8B89;
        pub const GL_ACTIVE_ATTRIBUTE_MAX_LENGTH: GLenum = 0x8B8A;
        pub const GL_SHADING_LANGUAGE_VERSION: GLenum = 0x8B8C;
        pub const GL_CURRENT_PROGRAM: GLenum = 0x8B8D;
        pub const GL_NEVER: GLenum = 0x0200;
        pub const GL_LESS: GLenum = 0x0201;
        pub const GL_EQUAL: GLenum = 0x0202;
        pub const GL_LEQUAL: GLenum = 0x0203;
        pub const GL_GREATER: GLenum = 0x0204;
        pub const GL_NOTEQUAL: GLenum = 0x0205;
        pub const GL_GEQUAL: GLenum = 0x0206;
        pub const GL_ALWAYS: GLenum = 0x0207;
        pub const GL_KEEP: GLenum = 0x1E00;
        pub const GL_REPLACE: GLenum = 0x1E01;
        pub const GL_INCR: GLenum = 0x1E02;
        pub const GL_DECR: GLenum = 0x1E03;
        pub const GL_INVERT: GLenum = 0x150A;
        pub const GL_INCR_WRAP: GLenum = 0x8507;
        pub const GL_DECR_WRAP: GLenum = 0x8508;
        pub const GL_VENDOR: GLenum = 0x1F00;
        pub const GL_RENDERER: GLenum = 0x1F01;
        pub const GL_VERSION: GLenum = 0x1F02;
        pub const GL_EXTENSIONS: GLenum = 0x1F03;
        pub const GL_NEAREST: GLenum = 0x2600;
        pub const GL_LINEAR: GLenum = 0x2601;
        pub const GL_NEAREST_MIPMAP_NEAREST: GLenum = 0x2700;
        pub const GL_LINEAR_MIPMAP_NEAREST: GLenum = 0x2701;
        pub const GL_NEAREST_MIPMAP_LINEAR: GLenum = 0x2702;
        pub const GL_LINEAR_MIPMAP_LINEAR: GLenum = 0x2703;
        pub const GL_TEXTURE_MAG_FILTER: GLenum = 0x2800;
        pub const GL_TEXTURE_MIN_FILTER: GLenum = 0x2801;
        pub const GL_TEXTURE_WRAP_S: GLenum = 0x2802;
        pub const GL_TEXTURE_WRAP_T: GLenum = 0x2803;
        pub const GL_TEXTURE: GLenum = 0x1702;
        pub const GL_TEXTURE_CUBE_MAP: GLenum = 0x8513;
        pub const GL_TEXTURE_BINDING_CUBE_MAP: GLenum = 0x8514;
        pub const GL_TEXTURE_CUBE_MAP_POSITIVE_X: GLenum = 0x8515;
        pub const GL_TEXTURE_CUBE_MAP_NEGATIVE_X: GLenum = 0x8516;
        pub const GL_TEXTURE_CUBE_MAP_POSITIVE_Y: GLenum = 0x8517;
        pub const GL_TEXTURE_CUBE_MAP_NEGATIVE_Y: GLenum = 0x8518;
        pub const GL_TEXTURE_CUBE_MAP_POSITIVE_Z: GLenum = 0x8519;
        pub const GL_TEXTURE_CUBE_MAP_NEGATIVE_Z: GLenum = 0x851A;
        pub const GL_MAX_CUBE_MAP_TEXTURE_SIZE: GLenum = 0x851C;
        pub const GL_TEXTURE0: GLenum = 0x84C0;
        pub const GL_TEXTURE1: GLenum = 0x84C1;
        pub const GL_TEXTURE2: GLenum = 0x84C2;
        pub const GL_TEXTURE3: GLenum = 0x84C3;
        pub const GL_TEXTURE4: GLenum = 0x84C4;
        pub const GL_TEXTURE5: GLenum = 0x84C5;
        pub const GL_TEXTURE6: GLenum = 0x84C6;
        pub const GL_TEXTURE7: GLenum = 0x84C7;
        pub const GL_TEXTURE8: GLenum = 0x84C8;
        pub const GL_TEXTURE9: GLenum = 0x84C9;
        pub const GL_TEXTURE10: GLenum = 0x84CA;
        pub const GL_TEXTURE11: GLenum = 0x84CB;
        pub const GL_TEXTURE12: GLenum = 0x84CC;
        pub const GL_TEXTURE13: GLenum = 0x84CD;
        pub const GL_TEXTURE14: GLenum = 0x84CE;
        pub const GL_TEXTURE15: GLenum = 0x84CF;
        pub const GL_TEXTURE16: GLenum = 0x84D0;
        pub const GL_TEXTURE17: GLenum = 0x84D1;
        pub const GL_TEXTURE18: GLenum = 0x84D2;
        pub const GL_TEXTURE19: GLenum = 0x84D3;
        pub const GL_TEXTURE20: GLenum = 0x84D4;
        pub const GL_TEXTURE21: GLenum = 0x84D5;
        pub const GL_TEXTURE22: GLenum = 0x84D6;
        pub const GL_TEXTURE23: GLenum = 0x84D7;
        pub const GL_TEXTURE24: GLenum = 0x84D8;
        pub const GL_TEXTURE25: GLenum = 0x84D9;
        pub const GL_TEXTURE26: GLenum = 0x84DA;
        pub const GL_TEXTURE27: GLenum = 0x84DB;
        pub const GL_TEXTURE28: GLenum = 0x84DC;
        pub const GL_TEXTURE29: GLenum = 0x84DD;
        pub const GL_TEXTURE30: GLenum = 0x84DE;
        pub const GL_TEXTURE31: GLenum = 0x84DF;
        pub const GL_ACTIVE_TEXTURE: GLenum = 0x84E0;
        pub const GL_REPEAT: GLenum = 0x2901;
        pub const GL_CLAMP_TO_EDGE: GLenum = 0x812F;
        pub const GL_MIRRORED_REPEAT: GLenum = 0x8370;
        pub const GL_FLOAT_VEC2: GLenum = 0x8B50;
        pub const GL_FLOAT_VEC3: GLenum = 0x8B51;
        pub const GL_FLOAT_VEC4: GLenum = 0x8B52;
        pub const GL_INT_VEC2: GLenum = 0x8B53;
        pub const GL_INT_VEC3: GLenum = 0x8B54;
        pub const GL_INT_VEC4: GLenum = 0x8B55;
        pub const GL_BOOL: GLenum = 0x8B56;
        pub const GL_BOOL_VEC2: GLenum = 0x8B57;
        pub const GL_BOOL_VEC3: GLenum = 0x8B58;
        pub const GL_BOOL_VEC4: GLenum = 0x8B59;
        pub const GL_FLOAT_MAT2: GLenum = 0x8B5A;
        pub const GL_FLOAT_MAT3: GLenum = 0x8B5B;
        pub const GL_FLOAT_MAT4: GLenum = 0x8B5C;
        pub const GL_SAMPLER_2D: GLenum = 0x8B5E;
        pub const GL_SAMPLER_CUBE: GLenum = 0x8B60;
        pub const GL_VERTEX_ATTRIB_ARRAY_ENABLED: GLenum = 0x8622;
        pub const GL_VERTEX_ATTRIB_ARRAY_SIZE: GLenum = 0x8623;
        pub const GL_VERTEX_ATTRIB_ARRAY_STRIDE: GLenum = 0x8624;
        pub const GL_VERTEX_ATTRIB_ARRAY_TYPE: GLenum = 0x8625;
        pub const GL_VERTEX_ATTRIB_ARRAY_NORMALIZED: GLenum = 0x886A;
        pub const GL_VERTEX_ATTRIB_ARRAY_POINTER: GLenum = 0x8645;
        pub const GL_VERTEX_ATTRIB_ARRAY_BUFFER_BINDING: GLenum = 0x889F;
        pub const GL_IMPLEMENTATION_COLOR_READ_TYPE: GLenum = 0x8B9A;
        pub const GL_IMPLEMENTATION_COLOR_READ_FORMAT: GLenum = 0x8B9B;
        pub const GL_COMPILE_STATUS: GLenum = 0x8B81;
        pub const GL_INFO_LOG_LENGTH: GLenum = 0x8B84;
        pub const GL_SHADER_SOURCE_LENGTH: GLenum = 0x8B88;
        pub const GL_SHADER_COMPILER: GLenum = 0x8DFA;
        pub const GL_SHADER_BINARY_FORMATS: GLenum = 0x8DF8;
        pub const GL_NUM_SHADER_BINARY_FORMATS: GLenum = 0x8DF9;
        pub const GL_LOW_FLOAT: GLenum = 0x8DF0;
        pub const GL_MEDIUM_FLOAT: GLenum = 0x8DF1;
        pub const GL_HIGH_FLOAT: GLenum = 0x8DF2;
        pub const GL_LOW_INT: GLenum = 0x8DF3;
        pub const GL_MEDIUM_INT: GLenum = 0x8DF4;
        pub const GL_HIGH_INT: GLenum = 0x8DF5;
        pub const GL_FRAMEBUFFER: GLenum = 0x8D40;
        pub const GL_RENDERBUFFER: GLenum = 0x8D41;
        pub const GL_RGBA4: GLenum = 0x8056;
        pub const GL_RGB5_A1: GLenum = 0x8057;
        pub const GL_RGB565: GLenum = 0x8D62;
        pub const GL_DEPTH_COMPONENT16: GLenum = 0x81A5;
        pub const GL_STENCIL_INDEX8: GLenum = 0x8D48;
        pub const GL_RENDERBUFFER_WIDTH: GLenum = 0x8D42;
        pub const GL_RENDERBUFFER_HEIGHT: GLenum = 0x8D43;
        pub const GL_RENDERBUFFER_INTERNAL_FORMAT: GLenum = 0x8D44;
        pub const GL_RENDERBUFFER_RED_SIZE: GLenum = 0x8D50;
        pub const GL_RENDERBUFFER_GREEN_SIZE: GLenum = 0x8D51;
        pub const GL_RENDERBUFFER_BLUE_SIZE: GLenum = 0x8D52;
        pub const GL_RENDERBUFFER_ALPHA_SIZE: GLenum = 0x8D53;
        pub const GL_RENDERBUFFER_DEPTH_SIZE: GLenum = 0x8D54;
        pub const GL_RENDERBUFFER_STENCIL_SIZE: GLenum = 0x8D55;
        pub const GL_FRAMEBUFFER_ATTACHMENT_OBJECT_TYPE: GLenum = 0x8CD0;
        pub const GL_FRAMEBUFFER_ATTACHMENT_OBJECT_NAME: GLenum = 0x8CD1;
        pub const GL_FRAMEBUFFER_ATTACHMENT_TEXTURE_LEVEL: GLenum = 0x8CD2;
        pub const GL_FRAMEBUFFER_ATTACHMENT_TEXTURE_CUBE_MAP_FACE: GLenum = 0x8CD3;
        pub const GL_COLOR_ATTACHMENT0: GLenum = 0x8CE0;
        pub const GL_DEPTH_ATTACHMENT: GLenum = 0x8D00;
        pub const GL_STENCIL_ATTACHMENT: GLenum = 0x8D20;
        pub const GL_NONE: GLenum = 0;
        pub const GL_FRAMEBUFFER_COMPLETE: GLenum = 0x8CD5;
        pub const GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT: GLenum = 0x8CD6;
        pub const GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT: GLenum = 0x8CD7;
        pub const GL_FRAMEBUFFER_INCOMPLETE_DIMENSIONS: GLenum = 0x8CD9;
        pub const GL_FRAMEBUFFER_UNSUPPORTED: GLenum = 0x8CDD;
        pub const GL_FRAMEBUFFER_BINDING: GLenum = 0x8CA6;
        pub const GL_RENDERBUFFER_BINDING: GLenum = 0x8CA7;
        pub const GL_MAX_RENDERBUFFER_SIZE: GLenum = 0x84E8;
        pub const GL_INVALID_FRAMEBUFFER_OPERATION: GLenum = 0x0506;

        pub const glActiveTexture = Externs.glActiveTexture;
        pub const glAttachShader = Externs.glAttachShader;
        pub const glBindAttribLocation = Bindings.glBindAttribLocation;
        pub const glBindBuffer = Externs.glBindBuffer;
        pub const glBindFramebuffer = Externs.glBindFramebuffer;
        pub const glBindRenderbuffer = Externs.glBindRenderbuffer;
        pub const glBindTexture = Externs.glBindTexture;
        pub const glBlendColor = Externs.glBlendColor;
        pub const glBlendEquation = Externs.glBlendEquation;
        pub const glBlendEquationSeparate = Externs.glBlendEquationSeparate;
        pub const glBlendFunc = Externs.glBlendFunc;
        pub const glBlendFuncSeparate = Externs.glBlendFuncSeparate;
        pub const glBufferData = Bindings.glBufferData;
        pub const glBufferSubData = Bindings.glBufferSubData;
        pub const glCheckFramebufferStatus = Externs.glCheckFramebufferStatus;
        pub const glClear = Externs.glClear;
        pub const glClearColor = Externs.glClearColor;
        pub const glClearDepthf = Externs.glClearDepthf;
        pub const glClearStencil = Externs.glClearStencil;
        pub const glColorMask = Externs.glColorMask;
        pub const glCompileShader = Externs.glCompileShader;
        pub const glCompressedTexImage2D = Bindings.glCompressedTexImage2D;
        pub const glCompressedTexSubImage2D = Bindings.glCompressedTexSubImage2D;
        pub const glCopyTexImage2D = Externs.glCopyTexImage2D;
        pub const glCopyTexSubImage2D = Externs.glCopyTexSubImage2D;
        pub const glCreateProgram = Externs.glCreateProgram;
        pub const glCreateShader = Externs.glCreateShader;
        pub const glCullFace = Externs.glCullFace;
        pub const glDeleteBuffers = Bindings.glDeleteBuffers;
        pub const glDeleteFramebuffers = Bindings.glDeleteFramebuffers;
        pub const glDeleteProgram = Externs.glDeleteProgram;
        pub const glDeleteRenderbuffers = Bindings.glDeleteRenderbuffers;
        pub const glDeleteShader = Externs.glDeleteShader;
        pub const glDeleteTextures = Bindings.glDeleteTextures;
        pub const glDepthFunc = Externs.glDepthFunc;
        pub const glDepthMask = Externs.glDepthMask;
        pub const glDepthRangef = Externs.glDepthRangef;
        pub const glDetachShader = Externs.glDetachShader;
        pub const glDisable = Externs.glDisable;
        pub const glDisableVertexAttribArray = Externs.glDisableVertexAttribArray;
        pub const glDrawArrays = Externs.glDrawArrays;
        pub const glDrawElements = Externs.glDrawElements;
        pub const glEnable = Externs.glEnable;
        pub const glEnableVertexAttribArray = Externs.glEnableVertexAttribArray;
        pub const glFinish = Externs.glFinish;
        pub const glFlush = Externs.glFlush;
        pub const glFramebufferRenderbuffer = Externs.glFramebufferRenderbuffer;
        pub const glFramebufferTexture2D = Externs.glFramebufferTexture2D;
        pub const glFrontFace = Externs.glFrontFace;
        pub const glGenBuffers = Bindings.glGenBuffers;
        pub const glGenerateMipmap = Externs.glGenerateMipmap;
        pub const glGenFramebuffers = Bindings.glGenFramebuffers;
        pub const glGenRenderbuffers = Bindings.glGenRenderbuffers;
        pub const glGenTextures = Bindings.glGenTextures;
        pub const glGetActiveAttrib = Bindings.glGetActiveAttrib;
        pub const glGetActiveUniform = Bindings.glGetActiveUniform;
        pub const glGetAttachedShaders = Bindings.glGetAttachedShaders;
        pub const glGetAttribLocation = Bindings.glGetAttribLocation;
        pub const glGetBooleanv = Externs.glGetBooleanv;
        pub const glGetBufferParameteriv = Externs.glGetBufferParameteriv;
        pub const glGetError = Bindings.glGetError;
        pub const glGetFloatv = Externs.glGetFloatv;
        pub const glGetFramebufferAttachmentParameteriv = Externs.glGetFramebufferAttachmentParameteriv;
        pub const glGetIntegerv = Externs.glGetIntegerv;
        pub const glGetProgramiv = Externs.glGetProgramiv;
        pub const glGetProgramInfoLog = Bindings.glGetProgramInfoLog;
        pub const glGetRenderbufferParameteriv = Externs.glGetRenderbufferParameteriv;
        pub const glGetShaderiv = Externs.glGetShaderiv;
        pub const glGetShaderInfoLog = Bindings.glGetShaderInfoLog;
        pub const glGetShaderPrecisionFormat = Externs.glGetShaderPrecisionFormat;
        pub const glGetShaderSource = Bindings.glGetShaderSource;
        pub const glGetString = Bindings.glGetString;
        pub const glGetTexParameterfv = Externs.glGetTexParameterfv;
        pub const glGetTexParameteriv = Externs.glGetTexParameteriv;
        pub const glGetUniformfv = Externs.glGetUniformfv;
        pub const glGetUniformiv = Externs.glGetUniformiv;
        pub const glGetUniformLocation = Bindings.glGetUniformLocation;
        pub const glGetVertexAttribfv = Externs.glGetVertexAttribfv;
        pub const glGetVertexAttribiv = Externs.glGetVertexAttribiv;
        pub const glGetVertexAttribPointerv = Externs.glGetVertexAttribPointerv;
        pub const glHint = Externs.glHint;
        pub const glIsBuffer = Externs.glIsBuffer;
        pub const glIsEnabled = Externs.glIsEnabled;
        pub const glIsFramebuffer = Externs.glIsFramebuffer;
        pub const glIsProgram = Externs.glIsProgram;
        pub const glIsRenderbuffer = Externs.glIsRenderbuffer;
        pub const glIsShader = Externs.glIsShader;
        pub const glIsTexture = Externs.glIsTexture;
        pub const glLineWidth = Externs.glLineWidth;
        pub const glLinkProgram = Externs.glLinkProgram;
        pub const glPixelStorei = Externs.glPixelStorei;
        pub const glPolygonOffset = Externs.glPolygonOffset;
        pub const glReadPixels = Externs.glReadPixels;
        pub const glReleaseShaderCompiler = Externs.glReleaseShaderCompiler;
        pub const glRenderbufferStorage = Externs.glRenderbufferStorage;
        pub const glSampleCoverage = Externs.glSampleCoverage;
        pub const glScissor = Externs.glScissor;
        pub const glShaderBinary = Externs.glShaderBinary;
        pub const glShaderSource = Bindings.glShaderSource;
        pub const glStencilFunc = Externs.glStencilFunc;
        pub const glStencilFuncSeparate = Externs.glStencilFuncSeparate;
        pub const glStencilMask = Externs.glStencilMask;
        pub const glStencilMaskSeparate = Externs.glStencilMaskSeparate;
        pub const glStencilOp = Externs.glStencilOp;
        pub const glStencilOpSeparate = Externs.glStencilOpSeparate;
        pub const glTexImage2D = Externs.glTexImage2D;
        pub const glTexParameterf = Externs.glTexParameterf;
        pub const glTexParameterfv = Externs.glTexParameterfv;
        pub const glTexParameteri = Externs.glTexParameteri;
        pub const glTexParameteriv = Externs.glTexParameteriv;
        pub const glTexSubImage2D = Externs.glTexSubImage2D;
        pub const glUniform1f = Externs.glUniform1f;
        pub const glUniform1fv = Bindings.glUniform1fv;
        pub const glUniform1i = Externs.glUniform1i;
        pub const glUniform1iv = Bindings.glUniform1iv;
        pub const glUniform2f = Externs.glUniform2f;
        pub const glUniform2fv = Bindings.glUniform2fv;
        pub const glUniform2i = Externs.glUniform2i;
        pub const glUniform2iv = Bindings.glUniform2iv;
        pub const glUniform3f = Externs.glUniform3f;
        pub const glUniform3fv = Bindings.glUniform3fv;
        pub const glUniform3i = Externs.glUniform3i;
        pub const glUniform3iv = Bindings.glUniform3iv;
        pub const glUniform4f = Externs.glUniform4f;
        pub const glUniform4fv = Bindings.glUniform4fv;
        pub const glUniform4i = Externs.glUniform4i;
        pub const glUniform4iv = Bindings.glUniform4iv;
        pub const glUniformMatrix2fv = Bindings.glUniformMatrix2fv;
        pub const glUniformMatrix3fv = Bindings.glUniformMatrix3fv;
        pub const glUniformMatrix4fv = Bindings.glUniformMatrix4fv;
        pub const glUseProgram = Externs.glUseProgram;
        pub const glValidateProgram = Externs.glValidateProgram;
        pub const glVertexAttrib1f = Externs.glVertexAttrib1f;
        pub const glVertexAttrib1fv = Externs.glVertexAttrib1fv;
        pub const glVertexAttrib2f = Externs.glVertexAttrib2f;
        pub const glVertexAttrib2fv = Externs.glVertexAttrib2fv;
        pub const glVertexAttrib3f = Externs.glVertexAttrib3f;
        pub const glVertexAttrib3fv = Externs.glVertexAttrib3fv;
        pub const glVertexAttrib4f = Externs.glVertexAttrib4f;
        pub const glVertexAttrib4fv = Externs.glVertexAttrib4fv;
        pub const glVertexAttribPointer = Externs.glVertexAttribPointer;
        pub const glViewport = Externs.glViewport;

        // v3.0
        pub const GLhalf = if (api.hasCompat(.V3_0)) u16 else @compileError("GLHalf only available with GLES 3.0+");

        pub const GL_READ_BUFFER: GLenum = if (api.hasCompat(.V3_0)) 0x0C02 else @compileError("GL_READ_BUFFER only available with GLES 3.0+");
        pub const GL_UNPACK_ROW_LENGTH: GLenum = if (api.hasCompat(.V3_0)) 0x0CF2 else @compileError("GL_UNPACK_ROW_LENGTH only available with GLES 3.0+");
        pub const GL_UNPACK_SKIP_ROWS: GLenum = if (api.hasCompat(.V3_0)) 0x0CF3 else @compileError("GL_UNPACK_SKIP_ROWS only available with GLES 3.0+");
        pub const GL_UNPACK_SKIP_PIXELS: GLenum = if (api.hasCompat(.V3_0)) 0x0CF4 else @compileError("GL_UNPACK_SKIP_PIXELS only available with GLES 3.0+");
        pub const GL_PACK_ROW_LENGTH: GLenum = if (api.hasCompat(.V3_0)) 0x0D02 else @compileError("GL_PACK_ROW_LENGTH only available with GLES 3.0+");
        pub const GL_PACK_SKIP_ROWS: GLenum = if (api.hasCompat(.V3_0)) 0x0D03 else @compileError("GL_PACK_SKIP_ROWS only available with GLES 3.0+");
        pub const GL_PACK_SKIP_PIXELS: GLenum = if (api.hasCompat(.V3_0)) 0x0D04 else @compileError("GL_PACK_SKIP_PIXELS only available with GLES 3.0+");
        pub const GL_COLOR: GLenum = if (api.hasCompat(.V3_0)) 0x1800 else @compileError("GL_COLOR only available with GLES 3.0+");
        pub const GL_DEPTH: GLenum = if (api.hasCompat(.V3_0)) 0x1801 else @compileError("GL_DEPTH only available with GLES 3.0+");
        pub const GL_STENCIL: GLenum = if (api.hasCompat(.V3_0)) 0x1802 else @compileError("GL_STENCIL only available with GLES 3.0+");
        pub const GL_RED: GLenum = if (api.hasCompat(.V3_0)) 0x1903 else @compileError("GL_RED only available with GLES 3.0+");
        pub const GL_RGB8: GLenum = if (api.hasCompat(.V3_0)) 0x8051 else @compileError("GL_RGB8 only available with GLES 3.0+");
        pub const GL_RGBA8: GLenum = if (api.hasCompat(.V3_0)) 0x8058 else @compileError("GL_RGBA8 only available with GLES 3.0+");
        pub const GL_RGB10_A2: GLenum = if (api.hasCompat(.V3_0)) 0x8059 else @compileError("GL_RGB10_A2 only available with GLES 3.0+");
        pub const GL_TEXTURE_BINDING_3D: GLenum = if (api.hasCompat(.V3_0)) 0x806A else @compileError("GL_TEXTURE_BINDING_3D only available with GLES 3.0+");
        pub const GL_UNPACK_SKIP_IMAGES: GLenum = if (api.hasCompat(.V3_0)) 0x806D else @compileError("GL_UNPACK_SKIP_IMAGES only available with GLES 3.0+");
        pub const GL_UNPACK_IMAGE_HEIGHT: GLenum = if (api.hasCompat(.V3_0)) 0x806E else @compileError("GL_UNPACK_IMAGE_HEIGHT only available with GLES 3.0+");
        pub const GL_TEXTURE_3D: GLenum = if (api.hasCompat(.V3_0)) 0x806F else @compileError("GL_TEXTURE_3D only available with GLES 3.0+");
        pub const GL_TEXTURE_WRAP_R: GLenum = if (api.hasCompat(.V3_0)) 0x8072 else @compileError("GL_TEXTURE_WRAP_R only available with GLES 3.0+");
        pub const GL_MAX_3D_TEXTURE_SIZE: GLenum = if (api.hasCompat(.V3_0)) 0x8073 else @compileError("GL_MAX_3D_TEXTURE_SIZE only available with GLES 3.0+");
        pub const GL_UNSIGNED_INT_2_10_10_10_REV: GLenum = if (api.hasCompat(.V3_0)) 0x8368 else @compileError("GL_UNSIGNED_INT_2_10_10_10_REV only available with GLES 3.0+");
        pub const GL_MAX_ELEMENTS_VERTICES: GLenum = if (api.hasCompat(.V3_0)) 0x80E8 else @compileError("GL_MAX_ELEMENTS_VERTICES only available with GLES 3.0+");
        pub const GL_MAX_ELEMENTS_INDICES: GLenum = if (api.hasCompat(.V3_0)) 0x80E9 else @compileError("GL_MAX_ELEMENTS_INDICES only available with GLES 3.0+");
        pub const GL_TEXTURE_MIN_LOD: GLenum = if (api.hasCompat(.V3_0)) 0x813A else @compileError("GL_TEXTURE_MIN_LOD only available with GLES 3.0+");
        pub const GL_TEXTURE_MAX_LOD: GLenum = if (api.hasCompat(.V3_0)) 0x813B else @compileError("GL_TEXTURE_MAX_LOD only available with GLES 3.0+");
        pub const GL_TEXTURE_BASE_LEVEL: GLenum = if (api.hasCompat(.V3_0)) 0x813C else @compileError("GL_TEXTURE_BASE_LEVEL only available with GLES 3.0+");
        pub const GL_TEXTURE_MAX_LEVEL: GLenum = if (api.hasCompat(.V3_0)) 0x813D else @compileError("GL_TEXTURE_MAX_LEVEL only available with GLES 3.0+");
        pub const GL_MIN: GLenum = if (api.hasCompat(.V3_0)) 0x8007 else @compileError("GL_MIN only available with GLES 3.0+");
        pub const GL_MAX: GLenum = if (api.hasCompat(.V3_0)) 0x8008 else @compileError("GL_MAX only available with GLES 3.0+");
        pub const GL_DEPTH_COMPONENT24: GLenum = if (api.hasCompat(.V3_0)) 0x81A6 else @compileError("GL_DEPTH_COMPONENT24 only available with GLES 3.0+");
        pub const GL_MAX_TEXTURE_LOD_BIAS: GLenum = if (api.hasCompat(.V3_0)) 0x84FD else @compileError("GL_MAX_TEXTURE_LOD_BIAS only available with GLES 3.0+");
        pub const GL_TEXTURE_COMPARE_MODE: GLenum = if (api.hasCompat(.V3_0)) 0x884C else @compileError("GL_TEXTURE_COMPARE_MODE only available with GLES 3.0+");
        pub const GL_TEXTURE_COMPARE_FUNC: GLenum = if (api.hasCompat(.V3_0)) 0x884D else @compileError("GL_TEXTURE_COMPARE_FUNC only available with GLES 3.0+");
        pub const GL_CURRENT_QUERY: GLenum = if (api.hasCompat(.V3_0)) 0x8865 else @compileError("GL_CURRENT_QUERY only available with GLES 3.0+");
        pub const GL_QUERY_RESULT: GLenum = if (api.hasCompat(.V3_0)) 0x8866 else @compileError("GL_QUERY_RESULT only available with GLES 3.0+");
        pub const GL_QUERY_RESULT_AVAILABLE: GLenum = if (api.hasCompat(.V3_0)) 0x8867 else @compileError("GL_QUERY_RESULT_AVAILABLE only available with GLES 3.0+");
        pub const GL_BUFFER_MAPPED: GLenum = if (api.hasCompat(.V3_0)) 0x88BC else @compileError("GL_BUFFER_MAPPED only available with GLES 3.0+");
        pub const GL_BUFFER_MAP_POINTER: GLenum = if (api.hasCompat(.V3_0)) 0x88BD else @compileError("GL_BUFFER_MAP_POINTER only available with GLES 3.0+");
        pub const GL_STREAM_READ: GLenum = if (api.hasCompat(.V3_0)) 0x88E1 else @compileError("GL_STREAM_READ only available with GLES 3.0+");
        pub const GL_STREAM_COPY: GLenum = if (api.hasCompat(.V3_0)) 0x88E2 else @compileError("GL_STREAM_COPY only available with GLES 3.0+");
        pub const GL_STATIC_READ: GLenum = if (api.hasCompat(.V3_0)) 0x88E5 else @compileError("GL_STATIC_READ only available with GLES 3.0+");
        pub const GL_STATIC_COPY: GLenum = if (api.hasCompat(.V3_0)) 0x88E6 else @compileError("GL_STATIC_COPY only available with GLES 3.0+");
        pub const GL_DYNAMIC_READ: GLenum = if (api.hasCompat(.V3_0)) 0x88E9 else @compileError("GL_DYNAMIC_READ only available with GLES 3.0+");
        pub const GL_DYNAMIC_COPY: GLenum = if (api.hasCompat(.V3_0)) 0x88EA else @compileError("GL_DYNAMIC_COPY only available with GLES 3.0+");
        pub const GL_MAX_DRAW_BUFFERS: GLenum = if (api.hasCompat(.V3_0)) 0x8824 else @compileError("GL_MAX_DRAW_BUFFERS only available with GLES 3.0+");
        pub const GL_DRAW_BUFFER0: GLenum = if (api.hasCompat(.V3_0)) 0x8825 else @compileError("GL_DRAW_BUFFER0 only available with GLES 3.0+");
        pub const GL_DRAW_BUFFER1: GLenum = if (api.hasCompat(.V3_0)) 0x8826 else @compileError("GL_DRAW_BUFFER1 only available with GLES 3.0+");
        pub const GL_DRAW_BUFFER2: GLenum = if (api.hasCompat(.V3_0)) 0x8827 else @compileError("GL_DRAW_BUFFER2 only available with GLES 3.0+");
        pub const GL_DRAW_BUFFER3: GLenum = if (api.hasCompat(.V3_0)) 0x8828 else @compileError("GL_DRAW_BUFFER3 only available with GLES 3.0+");
        pub const GL_DRAW_BUFFER4: GLenum = if (api.hasCompat(.V3_0)) 0x8829 else @compileError("GL_DRAW_BUFFER4 only available with GLES 3.0+");
        pub const GL_DRAW_BUFFER5: GLenum = if (api.hasCompat(.V3_0)) 0x882A else @compileError("GL_DRAW_BUFFER5 only available with GLES 3.0+");
        pub const GL_DRAW_BUFFER6: GLenum = if (api.hasCompat(.V3_0)) 0x882B else @compileError("GL_DRAW_BUFFER6 only available with GLES 3.0+");
        pub const GL_DRAW_BUFFER7: GLenum = if (api.hasCompat(.V3_0)) 0x882C else @compileError("GL_DRAW_BUFFER7 only available with GLES 3.0+");
        pub const GL_DRAW_BUFFER8: GLenum = if (api.hasCompat(.V3_0)) 0x882D else @compileError("GL_DRAW_BUFFER8 only available with GLES 3.0+");
        pub const GL_DRAW_BUFFER9: GLenum = if (api.hasCompat(.V3_0)) 0x882E else @compileError("GL_DRAW_BUFFER9 only available with GLES 3.0+");
        pub const GL_DRAW_BUFFER10: GLenum = if (api.hasCompat(.V3_0)) 0x882F else @compileError("GL_DRAW_BUFFER10 only available with GLES 3.0+");
        pub const GL_DRAW_BUFFER11: GLenum = if (api.hasCompat(.V3_0)) 0x8830 else @compileError("GL_DRAW_BUFFER11 only available with GLES 3.0+");
        pub const GL_DRAW_BUFFER12: GLenum = if (api.hasCompat(.V3_0)) 0x8831 else @compileError("GL_DRAW_BUFFER12 only available with GLES 3.0+");
        pub const GL_DRAW_BUFFER13: GLenum = if (api.hasCompat(.V3_0)) 0x8832 else @compileError("GL_DRAW_BUFFER13 only available with GLES 3.0+");
        pub const GL_DRAW_BUFFER14: GLenum = if (api.hasCompat(.V3_0)) 0x8833 else @compileError("GL_DRAW_BUFFER14 only available with GLES 3.0+");
        pub const GL_DRAW_BUFFER15: GLenum = if (api.hasCompat(.V3_0)) 0x8834 else @compileError("GL_DRAW_BUFFER15 only available with GLES 3.0+");
        pub const GL_MAX_FRAGMENT_UNIFORM_COMPONENTS: GLenum = if (api.hasCompat(.V3_0)) 0x8B49 else @compileError("GL_MAX_FRAGMENT_UNIFORM_COMPONENTS only available with GLES 3.0+");
        pub const GL_MAX_VERTEX_UNIFORM_COMPONENTS: GLenum = if (api.hasCompat(.V3_0)) 0x8B4A else @compileError("GL_MAX_VERTEX_UNIFORM_COMPONENTS only available with GLES 3.0+");
        pub const GL_SAMPLER_3D: GLenum = if (api.hasCompat(.V3_0)) 0x8B5F else @compileError("GL_SAMPLER_3D only available with GLES 3.0+");
        pub const GL_SAMPLER_2D_SHADOW: GLenum = if (api.hasCompat(.V3_0)) 0x8B62 else @compileError("GL_SAMPLER_2D_SHADOW only available with GLES 3.0+");
        pub const GL_FRAGMENT_SHADER_DERIVATIVE_HINT: GLenum = if (api.hasCompat(.V3_0)) 0x8B8B else @compileError("GL_FRAGMENT_SHADER_DERIVATIVE_HINT only available with GLES 3.0+");
        pub const GL_PIXEL_PACK_BUFFER: GLenum = if (api.hasCompat(.V3_0)) 0x88EB else @compileError("GL_PIXEL_PACK_BUFFER only available with GLES 3.0+");
        pub const GL_PIXEL_UNPACK_BUFFER: GLenum = if (api.hasCompat(.V3_0)) 0x88EC else @compileError("GL_PIXEL_UNPACK_BUFFER only available with GLES 3.0+");
        pub const GL_PIXEL_PACK_BUFFER_BINDING: GLenum = if (api.hasCompat(.V3_0)) 0x88ED else @compileError("GL_PIXEL_PACK_BUFFER_BINDING only available with GLES 3.0+");
        pub const GL_PIXEL_UNPACK_BUFFER_BINDING: GLenum = if (api.hasCompat(.V3_0)) 0x88EF else @compileError("GL_PIXEL_UNPACK_BUFFER_BINDING only available with GLES 3.0+");
        pub const GL_FLOAT_MAT2x3: GLenum = if (api.hasCompat(.V3_0)) 0x8B65 else @compileError("GL_FLOAT_MAT2x3 only available with GLES 3.0+");
        pub const GL_FLOAT_MAT2x4: GLenum = if (api.hasCompat(.V3_0)) 0x8B66 else @compileError("GL_FLOAT_MAT2x4 only available with GLES 3.0+");
        pub const GL_FLOAT_MAT3x2: GLenum = if (api.hasCompat(.V3_0)) 0x8B67 else @compileError("GL_FLOAT_MAT3x2 only available with GLES 3.0+");
        pub const GL_FLOAT_MAT3x4: GLenum = if (api.hasCompat(.V3_0)) 0x8B68 else @compileError("GL_FLOAT_MAT3x4 only available with GLES 3.0+");
        pub const GL_FLOAT_MAT4x2: GLenum = if (api.hasCompat(.V3_0)) 0x8B69 else @compileError("GL_FLOAT_MAT4x2 only available with GLES 3.0+");
        pub const GL_FLOAT_MAT4x3: GLenum = if (api.hasCompat(.V3_0)) 0x8B6A else @compileError("GL_FLOAT_MAT4x3 only available with GLES 3.0+");
        pub const GL_SRGB: GLenum = if (api.hasCompat(.V3_0)) 0x8C40 else @compileError("GL_SRGB only available with GLES 3.0+");
        pub const GL_SRGB8: GLenum = if (api.hasCompat(.V3_0)) 0x8C41 else @compileError("GL_SRGB8 only available with GLES 3.0+");
        pub const GL_SRGB8_ALPHA8: GLenum = if (api.hasCompat(.V3_0)) 0x8C43 else @compileError("GL_SRGB8_ALPHA8 only available with GLES 3.0+");
        pub const GL_COMPARE_REF_TO_TEXTURE: GLenum = if (api.hasCompat(.V3_0)) 0x884E else @compileError("GL_COMPARE_REF_TO_TEXTURE only available with GLES 3.0+");
        pub const GL_MAJOR_VERSION: GLenum = if (api.hasCompat(.V3_0)) 0x821B else @compileError("GL_MAJOR_VERSION only available with GLES 3.0+");
        pub const GL_MINOR_VERSION: GLenum = if (api.hasCompat(.V3_0)) 0x821C else @compileError("GL_MINOR_VERSION only available with GLES 3.0+");
        pub const GL_NUM_EXTENSIONS: GLenum = if (api.hasCompat(.V3_0)) 0x821D else @compileError("GL_NUM_EXTENSIONS only available with GLES 3.0+");
        pub const GL_RGBA32F: GLenum = if (api.hasCompat(.V3_0)) 0x8814 else @compileError("GL_RGBA32F only available with GLES 3.0+");
        pub const GL_RGB32F: GLenum = if (api.hasCompat(.V3_0)) 0x8815 else @compileError("GL_RGB32F only available with GLES 3.0+");
        pub const GL_RGBA16F: GLenum = if (api.hasCompat(.V3_0)) 0x881A else @compileError("GL_RGBA16F only available with GLES 3.0+");
        pub const GL_RGB16F: GLenum = if (api.hasCompat(.V3_0)) 0x881B else @compileError("GL_RGB16F only available with GLES 3.0+");
        pub const GL_VERTEX_ATTRIB_ARRAY_INTEGER: GLenum = if (api.hasCompat(.V3_0)) 0x88FD else @compileError("GL_VERTEX_ATTRIB_ARRAY_INTEGER only available with GLES 3.0+");
        pub const GL_MAX_ARRAY_TEXTURE_LAYERS: GLenum = if (api.hasCompat(.V3_0)) 0x88FF else @compileError("GL_MAX_ARRAY_TEXTURE_LAYERS only available with GLES 3.0+");
        pub const GL_MIN_PROGRAM_TEXEL_OFFSET: GLenum = if (api.hasCompat(.V3_0)) 0x8904 else @compileError("GL_MIN_PROGRAM_TEXEL_OFFSET only available with GLES 3.0+");
        pub const GL_MAX_PROGRAM_TEXEL_OFFSET: GLenum = if (api.hasCompat(.V3_0)) 0x8905 else @compileError("GL_MAX_PROGRAM_TEXEL_OFFSET only available with GLES 3.0+");
        pub const GL_MAX_VARYING_COMPONENTS: GLenum = if (api.hasCompat(.V3_0)) 0x8B4B else @compileError("GL_MAX_VARYING_COMPONENTS only available with GLES 3.0+");
        pub const GL_TEXTURE_2D_ARRAY: GLenum = if (api.hasCompat(.V3_0)) 0x8C1A else @compileError("GL_TEXTURE_2D_ARRAY only available with GLES 3.0+");
        pub const GL_TEXTURE_BINDING_2D_ARRAY: GLenum = if (api.hasCompat(.V3_0)) 0x8C1D else @compileError("GL_TEXTURE_BINDING_2D_ARRAY only available with GLES 3.0+");
        pub const GL_R11F_G11F_B10F: GLenum = if (api.hasCompat(.V3_0)) 0x8C3A else @compileError("GL_R11F_G11F_B10F only available with GLES 3.0+");
        pub const GL_UNSIGNED_INT_10F_11F_11F_REV: GLenum = if (api.hasCompat(.V3_0)) 0x8C3B else @compileError("GL_UNSIGNED_INT_10F_11F_11F_REV only available with GLES 3.0+");
        pub const GL_RGB9_E5: GLenum = if (api.hasCompat(.V3_0)) 0x8C3D else @compileError("GL_RGB9_E5 only available with GLES 3.0+");
        pub const GL_UNSIGNED_INT_5_9_9_9_REV: GLenum = if (api.hasCompat(.V3_0)) 0x8C3E else @compileError("GL_UNSIGNED_INT_5_9_9_9_REV only available with GLES 3.0+");
        pub const GL_TRANSFORM_FEEDBACK_VARYING_MAX_LENGTH: GLenum = if (api.hasCompat(.V3_0)) 0x8C76 else @compileError("GL_TRANSFORM_FEEDBACK_VARYING_MAX_LENGTH only available with GLES 3.0+");
        pub const GL_TRANSFORM_FEEDBACK_BUFFER_MODE: GLenum = if (api.hasCompat(.V3_0)) 0x8C7F else @compileError("GL_TRANSFORM_FEEDBACK_BUFFER_MODE only available with GLES 3.0+");
        pub const GL_MAX_TRANSFORM_FEEDBACK_SEPARATE_COMPONENTS: GLenum = if (api.hasCompat(.V3_0)) 0x8C80 else @compileError("GL_MAX_TRANSFORM_FEEDBACK_SEPARATE_COMPONENTS only available with GLES 3.0+");
        pub const GL_TRANSFORM_FEEDBACK_VARYINGS: GLenum = if (api.hasCompat(.V3_0)) 0x8C83 else @compileError("GL_TRANSFORM_FEEDBACK_VARYINGS only available with GLES 3.0+");
        pub const GL_TRANSFORM_FEEDBACK_BUFFER_START: GLenum = if (api.hasCompat(.V3_0)) 0x8C84 else @compileError("GL_TRANSFORM_FEEDBACK_BUFFER_START only available with GLES 3.0+");
        pub const GL_TRANSFORM_FEEDBACK_BUFFER_SIZE: GLenum = if (api.hasCompat(.V3_0)) 0x8C85 else @compileError("GL_TRANSFORM_FEEDBACK_BUFFER_SIZE only available with GLES 3.0+");
        pub const GL_TRANSFORM_FEEDBACK_PRIMITIVES_WRITTEN: GLenum = if (api.hasCompat(.V3_0)) 0x8C88 else @compileError("GL_TRANSFORM_FEEDBACK_PRIMITIVES_WRITTEN only available with GLES 3.0+");
        pub const GL_RASTERIZER_DISCARD: GLenum = if (api.hasCompat(.V3_0)) 0x8C89 else @compileError("GL_RASTERIZER_DISCARD only available with GLES 3.0+");
        pub const GL_MAX_TRANSFORM_FEEDBACK_INTERLEAVED_COMPONENTS: GLenum = if (api.hasCompat(.V3_0)) 0x8C8A else @compileError("GL_MAX_TRANSFORM_FEEDBACK_INTERLEAVED_COMPONENTS only available with GLES 3.0+");
        pub const GL_MAX_TRANSFORM_FEEDBACK_SEPARATE_ATTRIBS: GLenum = if (api.hasCompat(.V3_0)) 0x8C8B else @compileError("GL_MAX_TRANSFORM_FEEDBACK_SEPARATE_ATTRIBS only available with GLES 3.0+");
        pub const GL_INTERLEAVED_ATTRIBS: GLenum = if (api.hasCompat(.V3_0)) 0x8C8C else @compileError("GL_INTERLEAVED_ATTRIBS only available with GLES 3.0+");
        pub const GL_SEPARATE_ATTRIBS: GLenum = if (api.hasCompat(.V3_0)) 0x8C8D else @compileError("GL_SEPARATE_ATTRIBS only available with GLES 3.0+");
        pub const GL_TRANSFORM_FEEDBACK_BUFFER: GLenum = if (api.hasCompat(.V3_0)) 0x8C8E else @compileError("GL_TRANSFORM_FEEDBACK_BUFFER only available with GLES 3.0+");
        pub const GL_TRANSFORM_FEEDBACK_BUFFER_BINDING: GLenum = if (api.hasCompat(.V3_0)) 0x8C8F else @compileError("GL_TRANSFORM_FEEDBACK_BUFFER_BINDING only available with GLES 3.0+");
        pub const GL_RGBA32UI: GLenum = if (api.hasCompat(.V3_0)) 0x8D70 else @compileError("GL_RGBA32UI only available with GLES 3.0+");
        pub const GL_RGB32UI: GLenum = if (api.hasCompat(.V3_0)) 0x8D71 else @compileError("GL_RGB32UI only available with GLES 3.0+");
        pub const GL_RGBA16UI: GLenum = if (api.hasCompat(.V3_0)) 0x8D76 else @compileError("GL_RGBA16UI only available with GLES 3.0+");
        pub const GL_RGB16UI: GLenum = if (api.hasCompat(.V3_0)) 0x8D77 else @compileError("GL_RGB16UI only available with GLES 3.0+");
        pub const GL_RGBA8UI: GLenum = if (api.hasCompat(.V3_0)) 0x8D7C else @compileError("GL_RGBA8UI only available with GLES 3.0+");
        pub const GL_RGB8UI: GLenum = if (api.hasCompat(.V3_0)) 0x8D7D else @compileError("GL_RGB8UI only available with GLES 3.0+");
        pub const GL_RGBA32I: GLenum = if (api.hasCompat(.V3_0)) 0x8D82 else @compileError("GL_RGBA32I only available with GLES 3.0+");
        pub const GL_RGB32I: GLenum = if (api.hasCompat(.V3_0)) 0x8D83 else @compileError("GL_RGB32I only available with GLES 3.0+");
        pub const GL_RGBA16I: GLenum = if (api.hasCompat(.V3_0)) 0x8D88 else @compileError("GL_RGBA16I only available with GLES 3.0+");
        pub const GL_RGB16I: GLenum = if (api.hasCompat(.V3_0)) 0x8D89 else @compileError("GL_RGB16I only available with GLES 3.0+");
        pub const GL_RGBA8I: GLenum = if (api.hasCompat(.V3_0)) 0x8D8E else @compileError("GL_RGBA8I only available with GLES 3.0+");
        pub const GL_RGB8I: GLenum = if (api.hasCompat(.V3_0)) 0x8D8F else @compileError("GL_RGB8I only available with GLES 3.0+");
        pub const GL_RED_INTEGER: GLenum = if (api.hasCompat(.V3_0)) 0x8D94 else @compileError("GL_RED_INTEGER only available with GLES 3.0+");
        pub const GL_RGB_INTEGER: GLenum = if (api.hasCompat(.V3_0)) 0x8D98 else @compileError("GL_RGB_INTEGER only available with GLES 3.0+");
        pub const GL_RGBA_INTEGER: GLenum = if (api.hasCompat(.V3_0)) 0x8D99 else @compileError("GL_RGBA_INTEGER only available with GLES 3.0+");
        pub const GL_SAMPLER_2D_ARRAY: GLenum = if (api.hasCompat(.V3_0)) 0x8DC1 else @compileError("GL_SAMPLER_2D_ARRAY only available with GLES 3.0+");
        pub const GL_SAMPLER_2D_ARRAY_SHADOW: GLenum = if (api.hasCompat(.V3_0)) 0x8DC4 else @compileError("GL_SAMPLER_2D_ARRAY_SHADOW only available with GLES 3.0+");
        pub const GL_SAMPLER_CUBE_SHADOW: GLenum = if (api.hasCompat(.V3_0)) 0x8DC5 else @compileError("GL_SAMPLER_CUBE_SHADOW only available with GLES 3.0+");
        pub const GL_UNSIGNED_INT_VEC2: GLenum = if (api.hasCompat(.V3_0)) 0x8DC6 else @compileError("GL_UNSIGNED_INT_VEC2 only available with GLES 3.0+");
        pub const GL_UNSIGNED_INT_VEC3: GLenum = if (api.hasCompat(.V3_0)) 0x8DC7 else @compileError("GL_UNSIGNED_INT_VEC3 only available with GLES 3.0+");
        pub const GL_UNSIGNED_INT_VEC4: GLenum = if (api.hasCompat(.V3_0)) 0x8DC8 else @compileError("GL_UNSIGNED_INT_VEC4 only available with GLES 3.0+");
        pub const GL_INT_SAMPLER_2D: GLenum = if (api.hasCompat(.V3_0)) 0x8DCA else @compileError("GL_INT_SAMPLER_2D only available with GLES 3.0+");
        pub const GL_INT_SAMPLER_3D: GLenum = if (api.hasCompat(.V3_0)) 0x8DCB else @compileError("GL_INT_SAMPLER_3D only available with GLES 3.0+");
        pub const GL_INT_SAMPLER_CUBE: GLenum = if (api.hasCompat(.V3_0)) 0x8DCC else @compileError("GL_INT_SAMPLER_CUBE only available with GLES 3.0+");
        pub const GL_INT_SAMPLER_2D_ARRAY: GLenum = if (api.hasCompat(.V3_0)) 0x8DCF else @compileError("GL_INT_SAMPLER_2D_ARRAY only available with GLES 3.0+");
        pub const GL_UNSIGNED_INT_SAMPLER_2D: GLenum = if (api.hasCompat(.V3_0)) 0x8DD2 else @compileError("GL_UNSIGNED_INT_SAMPLER_2D only available with GLES 3.0+");
        pub const GL_UNSIGNED_INT_SAMPLER_3D: GLenum = if (api.hasCompat(.V3_0)) 0x8DD3 else @compileError("GL_UNSIGNED_INT_SAMPLER_3D only available with GLES 3.0+");
        pub const GL_UNSIGNED_INT_SAMPLER_CUBE: GLenum = if (api.hasCompat(.V3_0)) 0x8DD4 else @compileError("GL_UNSIGNED_INT_SAMPLER_CUBE only available with GLES 3.0+");
        pub const GL_UNSIGNED_INT_SAMPLER_2D_ARRAY: GLenum = if (api.hasCompat(.V3_0)) 0x8DD7 else @compileError("GL_UNSIGNED_INT_SAMPLER_2D_ARRAY only available with GLES 3.0+");
        pub const GL_BUFFER_ACCESS_FLAGS: GLenum = if (api.hasCompat(.V3_0)) 0x911F else @compileError("GL_BUFFER_ACCESS_FLAGS only available with GLES 3.0+");
        pub const GL_BUFFER_MAP_LENGTH: GLenum = if (api.hasCompat(.V3_0)) 0x9120 else @compileError("GL_BUFFER_MAP_LENGTH only available with GLES 3.0+");
        pub const GL_BUFFER_MAP_OFFSET: GLenum = if (api.hasCompat(.V3_0)) 0x9121 else @compileError("GL_BUFFER_MAP_OFFSET only available with GLES 3.0+");
        pub const GL_DEPTH_COMPONENT32F: GLenum = if (api.hasCompat(.V3_0)) 0x8CAC else @compileError("GL_DEPTH_COMPONENT32F only available with GLES 3.0+");
        pub const GL_DEPTH32F_STENCIL8: GLenum = if (api.hasCompat(.V3_0)) 0x8CAD else @compileError("GL_DEPTH32F_STENCIL8 only available with GLES 3.0+");
        pub const GL_FLOAT_32_UNSIGNED_INT_24_8_REV: GLenum = if (api.hasCompat(.V3_0)) 0x8DAD else @compileError("GL_FLOAT_32_UNSIGNED_INT_24_8_REV only available with GLES 3.0+");
        pub const GL_FRAMEBUFFER_ATTACHMENT_COLOR_ENCODING: GLenum = if (api.hasCompat(.V3_0)) 0x8210 else @compileError("GL_FRAMEBUFFER_ATTACHMENT_COLOR_ENCODING only available with GLES 3.0+");
        pub const GL_FRAMEBUFFER_ATTACHMENT_COMPONENT_TYPE: GLenum = if (api.hasCompat(.V3_0)) 0x8211 else @compileError("GL_FRAMEBUFFER_ATTACHMENT_COMPONENT_TYPE only available with GLES 3.0+");
        pub const GL_FRAMEBUFFER_ATTACHMENT_RED_SIZE: GLenum = if (api.hasCompat(.V3_0)) 0x8212 else @compileError("GL_FRAMEBUFFER_ATTACHMENT_RED_SIZE only available with GLES 3.0+");
        pub const GL_FRAMEBUFFER_ATTACHMENT_GREEN_SIZE: GLenum = if (api.hasCompat(.V3_0)) 0x8213 else @compileError("GL_FRAMEBUFFER_ATTACHMENT_GREEN_SIZE only available with GLES 3.0+");
        pub const GL_FRAMEBUFFER_ATTACHMENT_BLUE_SIZE: GLenum = if (api.hasCompat(.V3_0)) 0x8214 else @compileError("GL_FRAMEBUFFER_ATTACHMENT_BLUE_SIZE only available with GLES 3.0+");
        pub const GL_FRAMEBUFFER_ATTACHMENT_ALPHA_SIZE: GLenum = if (api.hasCompat(.V3_0)) 0x8215 else @compileError("GL_FRAMEBUFFER_ATTACHMENT_ALPHA_SIZE only available with GLES 3.0+");
        pub const GL_FRAMEBUFFER_ATTACHMENT_DEPTH_SIZE: GLenum = if (api.hasCompat(.V3_0)) 0x8216 else @compileError("GL_FRAMEBUFFER_ATTACHMENT_DEPTH_SIZE only available with GLES 3.0+");
        pub const GL_FRAMEBUFFER_ATTACHMENT_STENCIL_SIZE: GLenum = if (api.hasCompat(.V3_0)) 0x8217 else @compileError("GL_FRAMEBUFFER_ATTACHMENT_STENCIL_SIZE only available with GLES 3.0+");
        pub const GL_FRAMEBUFFER_DEFAULT: GLenum = if (api.hasCompat(.V3_0)) 0x8218 else @compileError("GL_FRAMEBUFFER_DEFAULT only available with GLES 3.0+");
        pub const GL_FRAMEBUFFER_UNDEFINED: GLenum = if (api.hasCompat(.V3_0)) 0x8219 else @compileError("GL_FRAMEBUFFER_UNDEFINED only available with GLES 3.0+");
        pub const GL_DEPTH_STENCIL_ATTACHMENT: GLenum = if (api.hasCompat(.V3_0)) 0x821A else @compileError("GL_DEPTH_STENCIL_ATTACHMENT only available with GLES 3.0+");
        pub const GL_DEPTH_STENCIL: GLenum = if (api.hasCompat(.V3_0)) 0x84F9 else @compileError("GL_DEPTH_STENCIL only available with GLES 3.0+");
        pub const GL_UNSIGNED_INT_24_8: GLenum = if (api.hasCompat(.V3_0)) 0x84FA else @compileError("GL_UNSIGNED_INT_24_8 only available with GLES 3.0+");
        pub const GL_DEPTH24_STENCIL8: GLenum = if (api.hasCompat(.V3_0)) 0x88F0 else @compileError("GL_DEPTH24_STENCIL8 only available with GLES 3.0+");
        pub const GL_UNSIGNED_NORMALIZED: GLenum = if (api.hasCompat(.V3_0)) 0x8C17 else @compileError("GL_UNSIGNED_NORMALIZED only available with GLES 3.0+");
        pub const GL_DRAW_FRAMEBUFFER_BINDING: GLenum = if (api.hasCompat(.V3_0)) 0x8CA6 else @compileError("GL_DRAW_FRAMEBUFFER_BINDING only available with GLES 3.0+");
        pub const GL_READ_FRAMEBUFFER: GLenum = if (api.hasCompat(.V3_0)) 0x8CA8 else @compileError("GL_READ_FRAMEBUFFER only available with GLES 3.0+");
        pub const GL_DRAW_FRAMEBUFFER: GLenum = if (api.hasCompat(.V3_0)) 0x8CA9 else @compileError("GL_DRAW_FRAMEBUFFER only available with GLES 3.0+");
        pub const GL_READ_FRAMEBUFFER_BINDING: GLenum = if (api.hasCompat(.V3_0)) 0x8CAA else @compileError("GL_READ_FRAMEBUFFER_BINDING only available with GLES 3.0+");
        pub const GL_RENDERBUFFER_SAMPLES: GLenum = if (api.hasCompat(.V3_0)) 0x8CAB else @compileError("GL_RENDERBUFFER_SAMPLES only available with GLES 3.0+");
        pub const GL_FRAMEBUFFER_ATTACHMENT_TEXTURE_LAYER: GLenum = if (api.hasCompat(.V3_0)) 0x8CD4 else @compileError("GL_FRAMEBUFFER_ATTACHMENT_TEXTURE_LAYER only available with GLES 3.0+");
        pub const GL_MAX_COLOR_ATTACHMENTS: GLenum = if (api.hasCompat(.V3_0)) 0x8CDF else @compileError("GL_MAX_COLOR_ATTACHMENTS only available with GLES 3.0+");
        pub const GL_COLOR_ATTACHMENT1: GLenum = if (api.hasCompat(.V3_0)) 0x8CE1 else @compileError("GL_COLOR_ATTACHMENT1 only available with GLES 3.0+");
        pub const GL_COLOR_ATTACHMENT2: GLenum = if (api.hasCompat(.V3_0)) 0x8CE2 else @compileError("GL_COLOR_ATTACHMENT2 only available with GLES 3.0+");
        pub const GL_COLOR_ATTACHMENT3: GLenum = if (api.hasCompat(.V3_0)) 0x8CE3 else @compileError("GL_COLOR_ATTACHMENT3 only available with GLES 3.0+");
        pub const GL_COLOR_ATTACHMENT4: GLenum = if (api.hasCompat(.V3_0)) 0x8CE4 else @compileError("GL_COLOR_ATTACHMENT4 only available with GLES 3.0+");
        pub const GL_COLOR_ATTACHMENT5: GLenum = if (api.hasCompat(.V3_0)) 0x8CE5 else @compileError("GL_COLOR_ATTACHMENT5 only available with GLES 3.0+");
        pub const GL_COLOR_ATTACHMENT6: GLenum = if (api.hasCompat(.V3_0)) 0x8CE6 else @compileError("GL_COLOR_ATTACHMENT6 only available with GLES 3.0+");
        pub const GL_COLOR_ATTACHMENT7: GLenum = if (api.hasCompat(.V3_0)) 0x8CE7 else @compileError("GL_COLOR_ATTACHMENT7 only available with GLES 3.0+");
        pub const GL_COLOR_ATTACHMENT8: GLenum = if (api.hasCompat(.V3_0)) 0x8CE8 else @compileError("GL_COLOR_ATTACHMENT8 only available with GLES 3.0+");
        pub const GL_COLOR_ATTACHMENT9: GLenum = if (api.hasCompat(.V3_0)) 0x8CE9 else @compileError("GL_COLOR_ATTACHMENT9 only available with GLES 3.0+");
        pub const GL_COLOR_ATTACHMENT10: GLenum = if (api.hasCompat(.V3_0)) 0x8CEA else @compileError("GL_COLOR_ATTACHMENT10 only available with GLES 3.0+");
        pub const GL_COLOR_ATTACHMENT11: GLenum = if (api.hasCompat(.V3_0)) 0x8CEB else @compileError("GL_COLOR_ATTACHMENT11 only available with GLES 3.0+");
        pub const GL_COLOR_ATTACHMENT12: GLenum = if (api.hasCompat(.V3_0)) 0x8CEC else @compileError("GL_COLOR_ATTACHMENT12 only available with GLES 3.0+");
        pub const GL_COLOR_ATTACHMENT13: GLenum = if (api.hasCompat(.V3_0)) 0x8CED else @compileError("GL_COLOR_ATTACHMENT13 only available with GLES 3.0+");
        pub const GL_COLOR_ATTACHMENT14: GLenum = if (api.hasCompat(.V3_0)) 0x8CEE else @compileError("GL_COLOR_ATTACHMENT14 only available with GLES 3.0+");
        pub const GL_COLOR_ATTACHMENT15: GLenum = if (api.hasCompat(.V3_0)) 0x8CEF else @compileError("GL_COLOR_ATTACHMENT15 only available with GLES 3.0+");
        pub const GL_COLOR_ATTACHMENT16: GLenum = if (api.hasCompat(.V3_0)) 0x8CF0 else @compileError("GL_COLOR_ATTACHMENT16 only available with GLES 3.0+");
        pub const GL_COLOR_ATTACHMENT17: GLenum = if (api.hasCompat(.V3_0)) 0x8CF1 else @compileError("GL_COLOR_ATTACHMENT17 only available with GLES 3.0+");
        pub const GL_COLOR_ATTACHMENT18: GLenum = if (api.hasCompat(.V3_0)) 0x8CF2 else @compileError("GL_COLOR_ATTACHMENT18 only available with GLES 3.0+");
        pub const GL_COLOR_ATTACHMENT19: GLenum = if (api.hasCompat(.V3_0)) 0x8CF3 else @compileError("GL_COLOR_ATTACHMENT19 only available with GLES 3.0+");
        pub const GL_COLOR_ATTACHMENT20: GLenum = if (api.hasCompat(.V3_0)) 0x8CF4 else @compileError("GL_COLOR_ATTACHMENT20 only available with GLES 3.0+");
        pub const GL_COLOR_ATTACHMENT21: GLenum = if (api.hasCompat(.V3_0)) 0x8CF5 else @compileError("GL_COLOR_ATTACHMENT21 only available with GLES 3.0+");
        pub const GL_COLOR_ATTACHMENT22: GLenum = if (api.hasCompat(.V3_0)) 0x8CF6 else @compileError("GL_COLOR_ATTACHMENT22 only available with GLES 3.0+");
        pub const GL_COLOR_ATTACHMENT23: GLenum = if (api.hasCompat(.V3_0)) 0x8CF7 else @compileError("GL_COLOR_ATTACHMENT23 only available with GLES 3.0+");
        pub const GL_COLOR_ATTACHMENT24: GLenum = if (api.hasCompat(.V3_0)) 0x8CF8 else @compileError("GL_COLOR_ATTACHMENT24 only available with GLES 3.0+");
        pub const GL_COLOR_ATTACHMENT25: GLenum = if (api.hasCompat(.V3_0)) 0x8CF9 else @compileError("GL_COLOR_ATTACHMENT25 only available with GLES 3.0+");
        pub const GL_COLOR_ATTACHMENT26: GLenum = if (api.hasCompat(.V3_0)) 0x8CFA else @compileError("GL_COLOR_ATTACHMENT26 only available with GLES 3.0+");
        pub const GL_COLOR_ATTACHMENT27: GLenum = if (api.hasCompat(.V3_0)) 0x8CFB else @compileError("GL_COLOR_ATTACHMENT27 only available with GLES 3.0+");
        pub const GL_COLOR_ATTACHMENT28: GLenum = if (api.hasCompat(.V3_0)) 0x8CFC else @compileError("GL_COLOR_ATTACHMENT28 only available with GLES 3.0+");
        pub const GL_COLOR_ATTACHMENT29: GLenum = if (api.hasCompat(.V3_0)) 0x8CFD else @compileError("GL_COLOR_ATTACHMENT29 only available with GLES 3.0+");
        pub const GL_COLOR_ATTACHMENT30: GLenum = if (api.hasCompat(.V3_0)) 0x8CFE else @compileError("GL_COLOR_ATTACHMENT30 only available with GLES 3.0+");
        pub const GL_COLOR_ATTACHMENT31: GLenum = if (api.hasCompat(.V3_0)) 0x8CFF else @compileError("GL_COLOR_ATTACHMENT31 only available with GLES 3.0+");
        pub const GL_FRAMEBUFFER_INCOMPLETE_MULTISAMPLE: GLenum = if (api.hasCompat(.V3_0)) 0x8D56 else @compileError("GL_FRAMEBUFFER_INCOMPLETE_MULTISAMPLE only available with GLES 3.0+");
        pub const GL_MAX_SAMPLES: GLenum = if (api.hasCompat(.V3_0)) 0x8D57 else @compileError("GL_MAX_SAMPLES only available with GLES 3.0+");
        pub const GL_HALF_FLOAT: GLenum = if (api.hasCompat(.V3_0)) 0x140B else @compileError("GL_HALF_FLOAT only available with GLES 3.0+");
        pub const GL_MAP_READ_BIT: GLenum = if (api.hasCompat(.V3_0)) 0x0001 else @compileError("GL_MAP_READ_BIT only available with GLES 3.0+");
        pub const GL_MAP_WRITE_BIT: GLenum = if (api.hasCompat(.V3_0)) 0x0002 else @compileError("GL_MAP_WRITE_BIT only available with GLES 3.0+");
        pub const GL_MAP_INVALIDATE_RANGE_BIT: GLenum = if (api.hasCompat(.V3_0)) 0x0004 else @compileError("GL_MAP_INVALIDATE_RANGE_BIT only available with GLES 3.0+");
        pub const GL_MAP_INVALIDATE_BUFFER_BIT: GLenum = if (api.hasCompat(.V3_0)) 0x0008 else @compileError("GL_MAP_INVALIDATE_BUFFER_BIT only available with GLES 3.0+");
        pub const GL_MAP_FLUSH_EXPLICIT_BIT: GLenum = if (api.hasCompat(.V3_0)) 0x0010 else @compileError("GL_MAP_FLUSH_EXPLICIT_BIT only available with GLES 3.0+");
        pub const GL_MAP_UNSYNCHRONIZED_BIT: GLenum = if (api.hasCompat(.V3_0)) 0x0020 else @compileError("GL_MAP_UNSYNCHRONIZED_BIT only available with GLES 3.0+");
        pub const GL_RG: GLenum = if (api.hasCompat(.V3_0)) 0x8227 else @compileError("GL_RG only available with GLES 3.0+");
        pub const GL_RG_INTEGER: GLenum = if (api.hasCompat(.V3_0)) 0x8228 else @compileError("GL_RG_INTEGER only available with GLES 3.0+");
        pub const GL_R8: GLenum = if (api.hasCompat(.V3_0)) 0x8229 else @compileError("GL_R8 only available with GLES 3.0+");
        pub const GL_RG8: GLenum = if (api.hasCompat(.V3_0)) 0x822B else @compileError("GL_RG8 only available with GLES 3.0+");
        pub const GL_R16F: GLenum = if (api.hasCompat(.V3_0)) 0x822D else @compileError("GL_R16F only available with GLES 3.0+");
        pub const GL_R32F: GLenum = if (api.hasCompat(.V3_0)) 0x822E else @compileError("GL_R32F only available with GLES 3.0+");
        pub const GL_RG16F: GLenum = if (api.hasCompat(.V3_0)) 0x822F else @compileError("GL_RG16F only available with GLES 3.0+");
        pub const GL_RG32F: GLenum = if (api.hasCompat(.V3_0)) 0x8230 else @compileError("GL_RG32F only available with GLES 3.0+");
        pub const GL_R8I: GLenum = if (api.hasCompat(.V3_0)) 0x8231 else @compileError("GL_R8I only available with GLES 3.0+");
        pub const GL_R8UI: GLenum = if (api.hasCompat(.V3_0)) 0x8232 else @compileError("GL_R8UI only available with GLES 3.0+");
        pub const GL_R16I: GLenum = if (api.hasCompat(.V3_0)) 0x8233 else @compileError("GL_R16I only available with GLES 3.0+");
        pub const GL_R16UI: GLenum = if (api.hasCompat(.V3_0)) 0x8234 else @compileError("GL_R16UI only available with GLES 3.0+");
        pub const GL_R32I: GLenum = if (api.hasCompat(.V3_0)) 0x8235 else @compileError("GL_R32I only available with GLES 3.0+");
        pub const GL_R32UI: GLenum = if (api.hasCompat(.V3_0)) 0x8236 else @compileError("GL_R32UI only available with GLES 3.0+");
        pub const GL_RG8I: GLenum = if (api.hasCompat(.V3_0)) 0x8237 else @compileError("GL_RG8I only available with GLES 3.0+");
        pub const GL_RG8UI: GLenum = if (api.hasCompat(.V3_0)) 0x8238 else @compileError("GL_RG8UI only available with GLES 3.0+");
        pub const GL_RG16I: GLenum = if (api.hasCompat(.V3_0)) 0x8239 else @compileError("GL_RG16I only available with GLES 3.0+");
        pub const GL_RG16UI: GLenum = if (api.hasCompat(.V3_0)) 0x823A else @compileError("GL_RG16UI only available with GLES 3.0+");
        pub const GL_RG32I: GLenum = if (api.hasCompat(.V3_0)) 0x823B else @compileError("GL_RG32I only available with GLES 3.0+");
        pub const GL_RG32UI: GLenum = if (api.hasCompat(.V3_0)) 0x823C else @compileError("GL_RG32UI only available with GLES 3.0+");
        pub const GL_VERTEX_ARRAY_BINDING: GLenum = if (api.hasCompat(.V3_0)) 0x85B5 else @compileError("GL_VERTEX_ARRAY_BINDING only available with GLES 3.0+");
        pub const GL_R8_SNORM: GLenum = if (api.hasCompat(.V3_0)) 0x8F94 else @compileError("GL_R8_SNORM only available with GLES 3.0+");
        pub const GL_RG8_SNORM: GLenum = if (api.hasCompat(.V3_0)) 0x8F95 else @compileError("GL_RG8_SNORM only available with GLES 3.0+");
        pub const GL_RGB8_SNORM: GLenum = if (api.hasCompat(.V3_0)) 0x8F96 else @compileError("GL_RGB8_SNORM only available with GLES 3.0+");
        pub const GL_RGBA8_SNORM: GLenum = if (api.hasCompat(.V3_0)) 0x8F97 else @compileError("GL_RGBA8_SNORM only available with GLES 3.0+");
        pub const GL_SIGNED_NORMALIZED: GLenum = if (api.hasCompat(.V3_0)) 0x8F9C else @compileError("GL_SIGNED_NORMALIZED only available with GLES 3.0+");
        pub const GL_PRIMITIVE_RESTART_FIXED_INDEX: GLenum = if (api.hasCompat(.V3_0)) 0x8D69 else @compileError("GL_PRIMITIVE_RESTART_FIXED_INDEX only available with GLES 3.0+");
        pub const GL_COPY_READ_BUFFER: GLenum = if (api.hasCompat(.V3_0)) 0x8F36 else @compileError("GL_COPY_READ_BUFFER only available with GLES 3.0+");
        pub const GL_COPY_WRITE_BUFFER: GLenum = if (api.hasCompat(.V3_0)) 0x8F37 else @compileError("GL_COPY_WRITE_BUFFER only available with GLES 3.0+");
        pub const GL_COPY_READ_BUFFER_BINDING: GLenum = if (api.hasCompat(.V3_0)) 0x8F36 else @compileError("GL_COPY_READ_BUFFER_BINDING only available with GLES 3.0+");
        pub const GL_COPY_WRITE_BUFFER_BINDING: GLenum = if (api.hasCompat(.V3_0)) 0x8F37 else @compileError("GL_COPY_WRITE_BUFFER_BINDING only available with GLES 3.0+");
        pub const GL_UNIFORM_BUFFER: GLenum = if (api.hasCompat(.V3_0)) 0x8A11 else @compileError("GL_UNIFORM_BUFFER only available with GLES 3.0+");
        pub const GL_UNIFORM_BUFFER_BINDING: GLenum = if (api.hasCompat(.V3_0)) 0x8A28 else @compileError("GL_UNIFORM_BUFFER_BINDING only available with GLES 3.0+");
        pub const GL_UNIFORM_BUFFER_START: GLenum = if (api.hasCompat(.V3_0)) 0x8A29 else @compileError("GL_UNIFORM_BUFFER_START only available with GLES 3.0+");
        pub const GL_UNIFORM_BUFFER_SIZE: GLenum = if (api.hasCompat(.V3_0)) 0x8A2A else @compileError("GL_UNIFORM_BUFFER_SIZE only available with GLES 3.0+");
        pub const GL_MAX_VERTEX_UNIFORM_BLOCKS: GLenum = if (api.hasCompat(.V3_0)) 0x8A2B else @compileError("GL_MAX_VERTEX_UNIFORM_BLOCKS only available with GLES 3.0+");
        pub const GL_MAX_FRAGMENT_UNIFORM_BLOCKS: GLenum = if (api.hasCompat(.V3_0)) 0x8A2D else @compileError("GL_MAX_FRAGMENT_UNIFORM_BLOCKS only available with GLES 3.0+");
        pub const GL_MAX_COMBINED_UNIFORM_BLOCKS: GLenum = if (api.hasCompat(.V3_0)) 0x8A2E else @compileError("GL_MAX_COMBINED_UNIFORM_BLOCKS only available with GLES 3.0+");
        pub const GL_MAX_UNIFORM_BUFFER_BINDINGS: GLenum = if (api.hasCompat(.V3_0)) 0x8A2F else @compileError("GL_MAX_UNIFORM_BUFFER_BINDINGS only available with GLES 3.0+");
        pub const GL_MAX_UNIFORM_BLOCK_SIZE: GLenum = if (api.hasCompat(.V3_0)) 0x8A30 else @compileError("GL_MAX_UNIFORM_BLOCK_SIZE only available with GLES 3.0+");
        pub const GL_MAX_COMBINED_VERTEX_UNIFORM_COMPONENTS: GLenum = if (api.hasCompat(.V3_0)) 0x8A31 else @compileError("GL_MAX_COMBINED_VERTEX_UNIFORM_COMPONENTS only available with GLES 3.0+");
        pub const GL_MAX_COMBINED_FRAGMENT_UNIFORM_COMPONENTS: GLenum = if (api.hasCompat(.V3_0)) 0x8A33 else @compileError("GL_MAX_COMBINED_FRAGMENT_UNIFORM_COMPONENTS only available with GLES 3.0+");
        pub const GL_UNIFORM_BUFFER_OFFSET_ALIGNMENT: GLenum = if (api.hasCompat(.V3_0)) 0x8A34 else @compileError("GL_UNIFORM_BUFFER_OFFSET_ALIGNMENT only available with GLES 3.0+");
        pub const GL_ACTIVE_UNIFORM_BLOCK_MAX_NAME_LENGTH: GLenum = if (api.hasCompat(.V3_0)) 0x8A35 else @compileError("GL_ACTIVE_UNIFORM_BLOCK_MAX_NAME_LENGTH only available with GLES 3.0+");
        pub const GL_ACTIVE_UNIFORM_BLOCKS: GLenum = if (api.hasCompat(.V3_0)) 0x8A36 else @compileError("GL_ACTIVE_UNIFORM_BLOCKS only available with GLES 3.0+");
        pub const GL_UNIFORM_TYPE: GLenum = if (api.hasCompat(.V3_0)) 0x8A37 else @compileError("GL_UNIFORM_TYPE only available with GLES 3.0+");
        pub const GL_UNIFORM_SIZE: GLenum = if (api.hasCompat(.V3_0)) 0x8A38 else @compileError("GL_UNIFORM_SIZE only available with GLES 3.0+");
        pub const GL_UNIFORM_NAME_LENGTH: GLenum = if (api.hasCompat(.V3_0)) 0x8A39 else @compileError("GL_UNIFORM_NAME_LENGTH only available with GLES 3.0+");
        pub const GL_UNIFORM_BLOCK_INDEX: GLenum = if (api.hasCompat(.V3_0)) 0x8A3A else @compileError("GL_UNIFORM_BLOCK_INDEX only available with GLES 3.0+");
        pub const GL_UNIFORM_OFFSET: GLenum = if (api.hasCompat(.V3_0)) 0x8A3B else @compileError("GL_UNIFORM_OFFSET only available with GLES 3.0+");
        pub const GL_UNIFORM_ARRAY_STRIDE: GLenum = if (api.hasCompat(.V3_0)) 0x8A3C else @compileError("GL_UNIFORM_ARRAY_STRIDE only available with GLES 3.0+");
        pub const GL_UNIFORM_MATRIX_STRIDE: GLenum = if (api.hasCompat(.V3_0)) 0x8A3D else @compileError("GL_UNIFORM_MATRIX_STRIDE only available with GLES 3.0+");
        pub const GL_UNIFORM_IS_ROW_MAJOR: GLenum = if (api.hasCompat(.V3_0)) 0x8A3E else @compileError("GL_UNIFORM_IS_ROW_MAJOR only available with GLES 3.0+");
        pub const GL_UNIFORM_BLOCK_BINDING: GLenum = if (api.hasCompat(.V3_0)) 0x8A3F else @compileError("GL_UNIFORM_BLOCK_BINDING only available with GLES 3.0+");
        pub const GL_UNIFORM_BLOCK_DATA_SIZE: GLenum = if (api.hasCompat(.V3_0)) 0x8A40 else @compileError("GL_UNIFORM_BLOCK_DATA_SIZE only available with GLES 3.0+");
        pub const GL_UNIFORM_BLOCK_NAME_LENGTH: GLenum = if (api.hasCompat(.V3_0)) 0x8A41 else @compileError("GL_UNIFORM_BLOCK_NAME_LENGTH only available with GLES 3.0+");
        pub const GL_UNIFORM_BLOCK_ACTIVE_UNIFORMS: GLenum = if (api.hasCompat(.V3_0)) 0x8A42 else @compileError("GL_UNIFORM_BLOCK_ACTIVE_UNIFORMS only available with GLES 3.0+");
        pub const GL_UNIFORM_BLOCK_ACTIVE_UNIFORM_INDICES: GLenum = if (api.hasCompat(.V3_0)) 0x8A43 else @compileError("GL_UNIFORM_BLOCK_ACTIVE_UNIFORM_INDICES only available with GLES 3.0+");
        pub const GL_UNIFORM_BLOCK_REFERENCED_BY_VERTEX_SHADER: GLenum = if (api.hasCompat(.V3_0)) 0x8A44 else @compileError("GL_UNIFORM_BLOCK_REFERENCED_BY_VERTEX_SHADER only available with GLES 3.0+");
        pub const GL_UNIFORM_BLOCK_REFERENCED_BY_FRAGMENT_SHADER: GLenum = if (api.hasCompat(.V3_0)) 0x8A46 else @compileError("GL_UNIFORM_BLOCK_REFERENCED_BY_FRAGMENT_SHADER only available with GLES 3.0+");
        pub const GL_INVALID_INDEX: GLenum = if (api.hasCompat(.V3_0)) 0xFFFFFFFF else @compileError("GL_INVALID_INDEX only available with GLES 3.0+");
        pub const GL_MAX_VERTEX_OUTPUT_COMPONENTS: GLenum = if (api.hasCompat(.V3_0)) 0x9122 else @compileError("GL_MAX_VERTEX_OUTPUT_COMPONENTS only available with GLES 3.0+");
        pub const GL_MAX_FRAGMENT_INPUT_COMPONENTS: GLenum = if (api.hasCompat(.V3_0)) 0x9125 else @compileError("GL_MAX_FRAGMENT_INPUT_COMPONENTS only available with GLES 3.0+");
        pub const GL_MAX_SERVER_WAIT_TIMEOUT: GLenum = if (api.hasCompat(.V3_0)) 0x9111 else @compileError("GL_MAX_SERVER_WAIT_TIMEOUT only available with GLES 3.0+");
        pub const GL_OBJECT_TYPE: GLenum = if (api.hasCompat(.V3_0)) 0x9112 else @compileError("GL_OBJECT_TYPE only available with GLES 3.0+");
        pub const GL_SYNC_CONDITION: GLenum = if (api.hasCompat(.V3_0)) 0x9113 else @compileError("GL_SYNC_CONDITION only available with GLES 3.0+");
        pub const GL_SYNC_STATUS: GLenum = if (api.hasCompat(.V3_0)) 0x9114 else @compileError("GL_SYNC_STATUS only available with GLES 3.0+");
        pub const GL_SYNC_FLAGS: GLenum = if (api.hasCompat(.V3_0)) 0x9115 else @compileError("GL_SYNC_FLAGS only available with GLES 3.0+");
        pub const GL_SYNC_FENCE: GLenum = if (api.hasCompat(.V3_0)) 0x9116 else @compileError("GL_SYNC_FENCE only available with GLES 3.0+");
        pub const GL_SYNC_GPU_COMMANDS_COMPLETE: GLenum = if (api.hasCompat(.V3_0)) 0x9117 else @compileError("GL_SYNC_GPU_COMMANDS_COMPLETE only available with GLES 3.0+");
        pub const GL_UNSIGNALED: GLenum = if (api.hasCompat(.V3_0)) 0x9118 else @compileError("GL_UNSIGNALED only available with GLES 3.0+");
        pub const GL_SIGNALED: GLenum = if (api.hasCompat(.V3_0)) 0x9119 else @compileError("GL_SIGNALED only available with GLES 3.0+");
        pub const GL_ALREADY_SIGNALED: GLenum = if (api.hasCompat(.V3_0)) 0x911A else @compileError("GL_ALREADY_SIGNALED only available with GLES 3.0+");
        pub const GL_TIMEOUT_EXPIRED: GLenum = if (api.hasCompat(.V3_0)) 0x911B else @compileError("GL_TIMEOUT_EXPIRED only available with GLES 3.0+");
        pub const GL_CONDITION_SATISFIED: GLenum = if (api.hasCompat(.V3_0)) 0x911C else @compileError("GL_CONDITION_SATISFIED only available with GLES 3.0+");
        pub const GL_WAIT_FAILED: GLenum = if (api.hasCompat(.V3_0)) 0x911D else @compileError("GL_WAIT_FAILED only available with GLES 3.0+");
        pub const GL_SYNC_FLUSH_COMMANDS_BIT: GLenum = if (api.hasCompat(.V3_0)) 0x00000001 else @compileError("GL_SYNC_FLUSH_COMMANDS_BIT only available with GLES 3.0+");
        pub const GL_TIMEOUT_IGNORED: GLenum = if (api.hasCompat(.V3_0)) 0xFFFFFFFFFFFFFFFF else @compileError("GL_TIMEOUT_IGNORED only available with GLES 3.0+");
        pub const GL_VERTEX_ATTRIB_ARRAY_DIVISOR: GLenum = if (api.hasCompat(.V3_0)) 0x88FE else @compileError("GL_VERTEX_ATTRIB_ARRAY_DIVISOR only available with GLES 3.0+");
        pub const GL_ANY_SAMPLES_PASSED: GLenum = if (api.hasCompat(.V3_0)) 0x8C2F else @compileError("GL_ANY_SAMPLES_PASSED only available with GLES 3.0+");
        pub const GL_ANY_SAMPLES_PASSED_CONSERVATIVE: GLenum = if (api.hasCompat(.V3_0)) 0x8D6A else @compileError("GL_ANY_SAMPLES_PASSED_CONSERVATIVE only available with GLES 3.0+");
        pub const GL_SAMPLER_BINDING: GLenum = if (api.hasCompat(.V3_0)) 0x8919 else @compileError("GL_SAMPLER_BINDING only available with GLES 3.0+");
        pub const GL_RGB10_A2UI: GLenum = if (api.hasCompat(.V3_0)) 0x906F else @compileError("GL_RGB10_A2UI only available with GLES 3.0+");
        pub const GL_TEXTURE_SWIZZLE_R: GLenum = if (api.hasCompat(.V3_0)) 0x8E42 else @compileError("GL_TEXTURE_SWIZZLE_R only available with GLES 3.0+");
        pub const GL_TEXTURE_SWIZZLE_G: GLenum = if (api.hasCompat(.V3_0)) 0x8E43 else @compileError("GL_TEXTURE_SWIZZLE_G only available with GLES 3.0+");
        pub const GL_TEXTURE_SWIZZLE_B: GLenum = if (api.hasCompat(.V3_0)) 0x8E44 else @compileError("GL_TEXTURE_SWIZZLE_B only available with GLES 3.0+");
        pub const GL_TEXTURE_SWIZZLE_A: GLenum = if (api.hasCompat(.V3_0)) 0x8E45 else @compileError("GL_TEXTURE_SWIZZLE_A only available with GLES 3.0+");
        pub const GL_GREEN: GLenum = if (api.hasCompat(.V3_0)) 0x1904 else @compileError("GL_GREEN only available with GLES 3.0+");
        pub const GL_BLUE: GLenum = if (api.hasCompat(.V3_0)) 0x1905 else @compileError("GL_BLUE only available with GLES 3.0+");
        pub const GL_INT_2_10_10_10_REV: GLenum = if (api.hasCompat(.V3_0)) 0x8D9F else @compileError("GL_INT_2_10_10_10_REV only available with GLES 3.0+");
        pub const GL_TRANSFORM_FEEDBACK: GLenum = if (api.hasCompat(.V3_0)) 0x8E22 else @compileError("GL_TRANSFORM_FEEDBACK only available with GLES 3.0+");
        pub const GL_TRANSFORM_FEEDBACK_PAUSED: GLenum = if (api.hasCompat(.V3_0)) 0x8E23 else @compileError("GL_TRANSFORM_FEEDBACK_PAUSED only available with GLES 3.0+");
        pub const GL_TRANSFORM_FEEDBACK_ACTIVE: GLenum = if (api.hasCompat(.V3_0)) 0x8E24 else @compileError("GL_TRANSFORM_FEEDBACK_ACTIVE only available with GLES 3.0+");
        pub const GL_TRANSFORM_FEEDBACK_BINDING: GLenum = if (api.hasCompat(.V3_0)) 0x8E25 else @compileError("GL_TRANSFORM_FEEDBACK_BINDING only available with GLES 3.0+");
        pub const GL_PROGRAM_BINARY_RETRIEVABLE_HINT: GLenum = if (api.hasCompat(.V3_0)) 0x8257 else @compileError("GL_PROGRAM_BINARY_RETRIEVABLE_HINT only available with GLES 3.0+");
        pub const GL_PROGRAM_BINARY_LENGTH: GLenum = if (api.hasCompat(.V3_0)) 0x8741 else @compileError("GL_PROGRAM_BINARY_LENGTH only available with GLES 3.0+");
        pub const GL_NUM_PROGRAM_BINARY_FORMATS: GLenum = if (api.hasCompat(.V3_0)) 0x87FE else @compileError("GL_NUM_PROGRAM_BINARY_FORMATS only available with GLES 3.0+");
        pub const GL_PROGRAM_BINARY_FORMATS: GLenum = if (api.hasCompat(.V3_0)) 0x87FF else @compileError("GL_PROGRAM_BINARY_FORMATS only available with GLES 3.0+");
        pub const GL_COMPRESSED_R11_EAC: GLenum = if (api.hasCompat(.V3_0)) 0x9270 else @compileError("GL_COMPRESSED_R11_EAC only available with GLES 3.0+");
        pub const GL_COMPRESSED_SIGNED_R11_EAC: GLenum = if (api.hasCompat(.V3_0)) 0x9271 else @compileError("GL_COMPRESSED_SIGNED_R11_EAC only available with GLES 3.0+");
        pub const GL_COMPRESSED_RG11_EAC: GLenum = if (api.hasCompat(.V3_0)) 0x9272 else @compileError("GL_COMPRESSED_RG11_EAC only available with GLES 3.0+");
        pub const GL_COMPRESSED_SIGNED_RG11_EAC: GLenum = if (api.hasCompat(.V3_0)) 0x9273 else @compileError("GL_COMPRESSED_SIGNED_RG11_EAC only available with GLES 3.0+");
        pub const GL_COMPRESSED_RGB8_ETC2: GLenum = if (api.hasCompat(.V3_0)) 0x9274 else @compileError("GL_COMPRESSED_RGB8_ETC2 only available with GLES 3.0+");
        pub const GL_COMPRESSED_SRGB8_ETC2: GLenum = if (api.hasCompat(.V3_0)) 0x9275 else @compileError("GL_COMPRESSED_SRGB8_ETC2 only available with GLES 3.0+");
        pub const GL_COMPRESSED_RGB8_PUNCHTHROUGH_ALPHA1_ETC2: GLenum = if (api.hasCompat(.V3_0)) 0x9276 else @compileError("GL_COMPRESSED_RGB8_PUNCHTHROUGH_ALPHA1_ETC2 only available with GLES 3.0+");
        pub const GL_COMPRESSED_SRGB8_PUNCHTHROUGH_ALPHA1_ETC2: GLenum = if (api.hasCompat(.V3_0)) 0x9277 else @compileError("GL_COMPRESSED_SRGB8_PUNCHTHROUGH_ALPHA1_ETC2 only available with GLES 3.0+");
        pub const GL_COMPRESSED_RGBA8_ETC2_EAC: GLenum = if (api.hasCompat(.V3_0)) 0x9278 else @compileError("GL_COMPRESSED_RGBA8_ETC2_EAC only available with GLES 3.0+");
        pub const GL_COMPRESSED_SRGB8_ALPHA8_ETC2_EAC: GLenum = if (api.hasCompat(.V3_0)) 0x9279 else @compileError("GL_COMPRESSED_SRGB8_ALPHA8_ETC2_EAC only available with GLES 3.0+");
        pub const GL_TEXTURE_IMMUTABLE_FORMAT: GLenum = if (api.hasCompat(.V3_0)) 0x912F else @compileError("GL_TEXTURE_IMMUTABLE_FORMAT only available with GLES 3.0+");
        pub const GL_MAX_ELEMENT_INDEX: GLenum = if (api.hasCompat(.V3_0)) 0x8D6B else @compileError("GL_MAX_ELEMENT_INDEX only available with GLES 3.0+");
        pub const GL_NUM_SAMPLE_COUNTS: GLenum = if (api.hasCompat(.V3_0)) 0x9380 else @compileError("GL_NUM_SAMPLE_COUNTS only available with GLES 3.0+");
        pub const GL_TEXTURE_IMMUTABLE_LEVELS: GLenum = if (api.hasCompat(.V3_0)) 0x82DF else @compileError("GL_TEXTURE_IMMUTABLE_LEVELS only available with GLES 3.0+");

        pub const glReadBuffer = if (api.hasCompat(.V3_0)) Externs.glReadBuffer else @compileError("glReadBuffer on available with GLES 3.0+");
        pub const glDrawRangeElements = if (api.hasCompat(.V3_0)) Bindings.glDrawRangeElements else @compileError("glDrawRangeElements on available with GLES 3.0+");
        pub const glTexImage3D = if (api.hasCompat(.V3_0)) Bindings.glTexImage3D else @compileError("glTexImage3D on available with GLES 3.0+");
        pub const glTexSubImage3D = if (api.hasCompat(.V3_0)) Bindings.glTexSubImage3D else @compileError("glTexSubImage3D on available with GLES 3.0+");
        pub const glCopyTexSubImage3D = if (api.hasCompat(.V3_0)) Externs.glCopyTexSubImage3D else @compileError("glCopyTexSubImage3D on available with GLES 3.0+");
        pub const glCompressedTexImage3D = if (api.hasCompat(.V3_0)) Bindings.glCompressedTexImage3D else @compileError("glCompressedTexImage3D on available with GLES 3.0+");
        pub const glCompressedTexSubImage3D = if (api.hasCompat(.V3_0)) Bindings.glCompressedTexSubImage3D else @compileError("glCompressedTexSubImage3D on available with GLES 3.0+");
        pub const glGenQueries = if (api.hasCompat(.V3_0)) Bindings.glGenQueries else @compileError("glGenQueries on available with GLES 3.0+");
        pub const glDeleteQueries = if (api.hasCompat(.V3_0)) Bindings.glDeleteQueries else @compileError("glDeleteQueries on available with GLES 3.0+");
        pub const glIsQuery = if (api.hasCompat(.V3_0)) Externs.glIsQuery else @compileError("glIsQuery on available with GLES 3.0+");
        pub const glBeginQuery = if (api.hasCompat(.V3_0)) Externs.glBeginQuery else @compileError("glBeginQuery on available with GLES 3.0+");
        pub const glEndQuery = if (api.hasCompat(.V3_0)) Externs.glEndQuery else @compileError("glEndQuery on available with GLES 3.0+");
        pub const glGetQueryiv = if (api.hasCompat(.V3_0)) Bindings.glGetQueryiv else @compileError("glGetQueryiv on available with GLES 3.0+");
        pub const glGetQueryObjectuiv = if (api.hasCompat(.V3_0)) Bindings.glGetQueryObjectuiv else @compileError("glGetQueryObjectuiv on available with GLES 3.0+");
        pub const glDrawBuffers = if (api.hasCompat(.V3_0)) Bindings.glDrawBuffers else @compileError("glDrawBuffers on available with GLES 3.0+");
        pub const glUniformMatrix2x3fv = if (api.hasCompat(.V3_0)) Bindings.glUniformMatrix2x3fv else @compileError("glUniformMatrix2x3fv on available with GLES 3.0+");
        pub const glUniformMatrix3x2fv = if (api.hasCompat(.V3_0)) Bindings.glUniformMatrix3x2fv else @compileError("glUniformMatrix3x2fv on available with GLES 3.0+");
        pub const glUniformMatrix2x4fv = if (api.hasCompat(.V3_0)) Bindings.glUniformMatrix2x4fv else @compileError("glUniformMatrix2x4fv on available with GLES 3.0+");
        pub const glUniformMatrix4x2fv = if (api.hasCompat(.V3_0)) Bindings.glUniformMatrix4x2fv else @compileError("glUniformMatrix4x2fv on available with GLES 3.0+");
        pub const glUniformMatrix3x4fv = if (api.hasCompat(.V3_0)) Bindings.glUniformMatrix3x4fv else @compileError("glUniformMatrix3x4fv on available with GLES 3.0+");
        pub const glUniformMatrix4x3fv = if (api.hasCompat(.V3_0)) Bindings.glUniformMatrix4x3fv else @compileError("glUniformMatrix4x3fv on available with GLES 3.0+");
        pub const glBlitFramebuffer = if (api.hasCompat(.V3_0)) Externs.glBlitFramebuffer else @compileError("glBlitFramebuffer on available with GLES 3.0+");
        pub const glRenderbufferStorageMultisample = if (api.hasCompat(.V3_0)) Externs.glRenderbufferStorageMultisample else @compileError("glRenderbufferStorageMultisample on available with GLES 3.0+");
        pub const glFramebufferTextureLayer = if (api.hasCompat(.V3_0)) Externs.glFramebufferTextureLayer else @compileError("glFramebufferTextureLayer on available with GLES 3.0+");
        pub const glBindVertexArray = if (api.hasCompat(.V3_0)) Externs.glBindVertexArray else @compileError("glBindVertexArray on available with GLES 3.0+");
        pub const glDeleteVertexArrays = if (api.hasCompat(.V3_0)) Bindings.glDeleteVertexArrays else @compileError("glDeleteVertexArrays on available with GLES 3.0+");
        pub const glGenVertexArrays = if (api.hasCompat(.V3_0)) Bindings.glGenVertexArrays else @compileError("glGenVertexArrays on available with GLES 3.0+");
        pub const glIsVertexArray = if (api.hasCompat(.V3_0)) Externs.glIsVertexArray else @compileError("glIsVertexArray on available with GLES 3.0+");
        pub const glGetIntegeri_v = if (api.hasCompat(.V3_0)) Bindings.glGetIntegeri_v else @compileError("glGetIntegeri_v on available with GLES 3.0+");
        pub const glBeginTransformFeedback = if (api.hasCompat(.V3_0)) Externs.glBeginTransformFeedback else @compileError("glBeginTransformFeedback on available with GLES 3.0+");
        pub const glEndTransformFeedback = if (api.hasCompat(.V3_0)) Externs.glEndTransformFeedback else @compileError("glEndTransformFeedback on available with GLES 3.0+");
        pub const glBindBufferRange = if (api.hasCompat(.V3_0)) Externs.glBindBufferRange else @compileError("glBindBufferRange on available with GLES 3.0+");
        pub const glBindBufferBase = if (api.hasCompat(.V3_0)) Externs.glBindBufferBase else @compileError("glBindBufferBase on available with GLES 3.0+");
        pub const glTransformFeedbackVaryings = if (api.hasCompat(.V3_0)) Bindings.glTransformFeedbackVaryings else @compileError("glTransformFeedbackVaryings on available with GLES 3.0+");
        pub const glGetTransformFeedbackVarying = if (api.hasCompat(.V3_0)) Bindings.glGetTransformFeedbackVarying else @compileError("glGetTransformFeedbackVarying on available with GLES 3.0+");
        pub const glVertexAttribIPointer = if (api.hasCompat(.V3_0)) Externs.glVertexAttribIPointer else @compileError("glVertexAttribIPointer on available with GLES 3.0+");
        pub const glGetVertexAttribIiv = if (api.hasCompat(.V3_0)) Bindings.glGetVertexAttribIiv else @compileError("glGetVertexAttribIiv on available with GLES 3.0+");
        pub const glGetVertexAttribIuiv = if (api.hasCompat(.V3_0)) Bindings.glGetVertexAttribIuiv else @compileError("glGetVertexAttribIuiv on available with GLES 3.0+");
        pub const glVertexAttribI4i = if (api.hasCompat(.V3_0)) Externs.glVertexAttribI4i else @compileError("glVertexAttribI4i on available with GLES 3.0+");
        pub const glVertexAttribI4ui = if (api.hasCompat(.V3_0)) Externs.glVertexAttribI4ui else @compileError("glVertexAttribI4ui on available with GLES 3.0+");
        pub const glVertexAttribI4iv = if (api.hasCompat(.V3_0)) Bindings.glVertexAttribI4iv else @compileError("glVertexAttribI4iv on available with GLES 3.0+");
        pub const glVertexAttribI4uiv = if (api.hasCompat(.V3_0)) Bindings.glVertexAttribI4uiv else @compileError("glVertexAttribI4uiv on available with GLES 3.0+");
        pub const glGetUniformuiv = if (api.hasCompat(.V3_0)) Externs.glGetUniformuiv else @compileError("glGetUniformuiv on available with GLES 3.0+");
        pub const glGetFragDataLocation = if (api.hasCompat(.V3_0)) Externs.glGetFragDataLocation else @compileError("glGetFragDataLocation on available with GLES 3.0+");
        pub const glUniform1ui = if (api.hasCompat(.V3_0)) Externs.glUniform1ui else @compileError("glUniform1ui on available with GLES 3.0+");
        pub const glUniform2ui = if (api.hasCompat(.V3_0)) Externs.glUniform2ui else @compileError("glUniform2ui on available with GLES 3.0+");
        pub const glUniform3ui = if (api.hasCompat(.V3_0)) Externs.glUniform3ui else @compileError("glUniform3ui on available with GLES 3.0+");
        pub const glUniform4ui = if (api.hasCompat(.V3_0)) Externs.glUniform4ui else @compileError("glUniform4ui on available with GLES 3.0+");
        pub const glUniform1uiv = if (api.hasCompat(.V3_0)) Bindings.glUniform1uiv else @compileError("glUniform1uiv on available with GLES 3.0+");
        pub const glUniform2uiv = if (api.hasCompat(.V3_0)) Bindings.glUniform2uiv else @compileError("glUniform2uiv on available with GLES 3.0+");
        pub const glUniform3uiv = if (api.hasCompat(.V3_0)) Bindings.glUniform3uiv else @compileError("glUniform3uiv on available with GLES 3.0+");
        pub const glUniform4uiv = if (api.hasCompat(.V3_0)) Bindings.glUniform4uiv else @compileError("glUniform4uiv on available with GLES 3.0+");
        pub const glClearBufferiv = if (api.hasCompat(.V3_0)) Bindings.glClearBufferiv else @compileError("glClearBufferiv on available with GLES 3.0+");
        pub const glClearBufferuiv = if (api.hasCompat(.V3_0)) Bindings.glClearBufferuiv else @compileError("glClearBufferuiv on available with GLES 3.0+");
        pub const glClearBufferfv = if (api.hasCompat(.V3_0)) Bindings.glClearBufferfv else @compileError("glClearBufferfv on available with GLES 3.0+");
        pub const glClearBufferfi = if (api.hasCompat(.V3_0)) Externs.glClearBufferfi else @compileError("glClearBufferfi on available with GLES 3.0+");
        pub const glGetStringi = if (api.hasCompat(.V3_0)) Bindings.glGetStringi else @compileError("glGetStringi on available with GLES 3.0+");
        pub const glCopyBufferSubData = if (api.hasCompat(.V3_0)) Externs.glCopyBufferSubData else @compileError("glCopyBufferSubData on available with GLES 3.0+");
        pub const glGetUniformIndices = if (api.hasCompat(.V3_0)) Bindings.glGetUniformIndices else @compileError("glGetUniformIndices on available with GLES 3.0+");
        pub const glGetActiveUniformsiv = if (api.hasCompat(.V3_0)) Bindings.glGetActiveUniformsiv else @compileError("glGetActiveUniformsiv on available with GLES 3.0+");
        pub const glGetUniformBlockIndex = if (api.hasCompat(.V3_0)) Bindings.glGetUniformBlockIndex else @compileError("glGetUniformBlockIndex on available with GLES 3.0+");
        pub const glGetActiveUniformBlockiv = if (api.hasCompat(.V3_0)) Bindings.glGetActiveUniformBlockiv else @compileError("glGetActiveUniformBlockiv on available with GLES 3.0+");
        pub const glGetActiveUniformBlockName = if (api.hasCompat(.V3_0)) Bindings.glGetActiveUniformBlockName else @compileError("glGetActiveUniformBlockName on available with GLES 3.0+");
        pub const glUniformBlockBinding = if (api.hasCompat(.V3_0)) Externs.glUniformBlockBinding else @compileError("glUniformBlockBinding on available with GLES 3.0+");
        pub const glDrawArraysInstanced = if (api.hasCompat(.V3_0)) Externs.glDrawArraysInstanced else @compileError("glDrawArraysInstanced on available with GLES 3.0+");
        pub const glDrawElementsInstanced = if (api.hasCompat(.V3_0)) Bindings.glDrawElementsInstanced else @compileError("glDrawElementsInstanced on available with GLES 3.0+");
        pub const glFenceSync = if (api.hasCompat(.V3_0)) Externs.glFenceSync else @compileError("glFenceSync on available with GLES 3.0+");
        pub const glIsSync = if (api.hasCompat(.V3_0)) Externs.glIsSync else @compileError("glIsSync on available with GLES 3.0+");
        pub const glDeleteSync = if (api.hasCompat(.V3_0)) Externs.glDeleteSync else @compileError("glDeleteSync on available with GLES 3.0+");
        pub const glClientWaitSync = if (api.hasCompat(.V3_0)) Externs.glClientWaitSync else @compileError("glClientWaitSync on available with GLES 3.0+");
        pub const glWaitSync = if (api.hasCompat(.V3_0)) Externs.glWaitSync else @compileError("glWaitSync on available with GLES 3.0+");
        pub const glGetInteger64v = if (api.hasCompat(.V3_0)) Bindings.glGetInteger64v else @compileError("glGetInteger64v on available with GLES 3.0+");
        pub const glGetSynciv = if (api.hasCompat(.V3_0)) Bindings.glGetSynciv else @compileError("glGetSynciv on available with GLES 3.0+");
        pub const glGetInteger64i_v = if (api.hasCompat(.V3_0)) Bindings.glGetInteger64i_v else @compileError("glGetInteger64i_v on available with GLES 3.0+");
        pub const glGetBufferParameteri64v = if (api.hasCompat(.V3_0)) Bindings.glGetBufferParameteri64v else @compileError("glGetBufferParameteri64v on available with GLES 3.0+");
        pub const glGenSamplers = if (api.hasCompat(.V3_0)) Bindings.glGenSamplers else @compileError("glGenSamplers on available with GLES 3.0+");
        pub const glDeleteSamplers = if (api.hasCompat(.V3_0)) Bindings.glDeleteSamplers else @compileError("glDeleteSamplers on available with GLES 3.0+");
        pub const glIsSampler = if (api.hasCompat(.V3_0)) Externs.glIsSampler else @compileError("glIsSampler on available with GLES 3.0+");
        pub const glBindSampler = if (api.hasCompat(.V3_0)) Externs.glBindSampler else @compileError("glBindSampler on available with GLES 3.0+");
        pub const glSamplerParameteri = if (api.hasCompat(.V3_0)) Externs.glSamplerParameteri else @compileError("glSamplerParameteri on available with GLES 3.0+");
        pub const glSamplerParameteriv = if (api.hasCompat(.V3_0)) Bindings.glSamplerParameteriv else @compileError("glSamplerParameteriv on available with GLES 3.0+");
        pub const glSamplerParameterf = if (api.hasCompat(.V3_0)) Externs.glSamplerParameterf else @compileError("glSamplerParameterf on available with GLES 3.0+");
        pub const glSamplerParameterfv = if (api.hasCompat(.V3_0)) Bindings.glSamplerParameterfv else @compileError("glSamplerParameterfv on available with GLES 3.0+");
        pub const glGetSamplerParameteriv = if (api.hasCompat(.V3_0)) Bindings.glGetSamplerParameteriv else @compileError("glGetSamplerParameteriv on available with GLES 3.0+");
        pub const glGetSamplerParameterfv = if (api.hasCompat(.V3_0)) Bindings.glGetSamplerParameterfv else @compileError("glGetSamplerParameterfv on available with GLES 3.0+");
        pub const glVertexAttribDivisor = if (api.hasCompat(.V3_0)) Externs.glVertexAttribDivisor else @compileError("glVertexAttribDivisor on available with GLES 3.0+");
        pub const glBindTransformFeedback = if (api.hasCompat(.V3_0)) Externs.glBindTransformFeedback else @compileError("glBindTransformFeedback on available with GLES 3.0+");
        pub const glDeleteTransformFeedbacks = if (api.hasCompat(.V3_0)) Bindings.glDeleteTransformFeedbacks else @compileError("glDeleteTransformFeedbacks on available with GLES 3.0+");
        pub const glGenTransformFeedbacks = if (api.hasCompat(.V3_0)) Bindings.glGenTransformFeedbacks else @compileError("glGenTransformFeedbacks on available with GLES 3.0+");
        pub const glIsTransformFeedback = if (api.hasCompat(.V3_0)) Externs.glIsTransformFeedback else @compileError("glIsTransformFeedback on available with GLES 3.0+");
        pub const glPauseTransformFeedback = if (api.hasCompat(.V3_0)) Externs.glPauseTransformFeedback else @compileError("glPauseTransformFeedback on available with GLES 3.0+");
        pub const glResumeTransformFeedback = if (api.hasCompat(.V3_0)) Externs.glResumeTransformFeedback else @compileError("glResumeTransformFeedback on available with GLES 3.0+");
        pub const glGetProgramBinary = if (api.hasCompat(.V3_0)) Bindings.glGetProgramBinary else @compileError("glGetProgramBinary on available with GLES 3.0+");
        pub const glProgramBinary = if (api.hasCompat(.V3_0)) Bindings.glProgramBinary else @compileError("glProgramBinary on available with GLES 3.0+");
        pub const glProgramParameteri = if (api.hasCompat(.V3_0)) Externs.glProgramParameteri else @compileError("glProgramParameteri on available with GLES 3.0+");
        pub const glInvalidateFramebuffer = if (api.hasCompat(.V3_0)) Bindings.glInvalidateFramebuffer else @compileError("glInvalidateFramebuffer on available with GLES 3.0+");
        pub const glInvalidateSubFramebuffer = if (api.hasCompat(.V3_0)) Bindings.glInvalidateSubFramebuffer else @compileError("glInvalidateSubFramebuffer on available with GLES 3.0+");
        pub const glTexStorage2D = if (api.hasCompat(.V3_0)) Externs.glTexStorage2D else @compileError("glTexStorage2D on available with GLES 3.0+");
        pub const glTexStorage3D = if (api.hasCompat(.V3_0)) Externs.glTexStorage3D else @compileError("glTexStorage3D on available with GLES 3.0+");
        pub const glGetInternalformativ = if (api.hasCompat(.V3_0)) Bindings.glGetInternalformativ else @compileError("glGetInternalformativ on available with GLES 3.0+");

        // v3.1
        const GL_COMPUTE_SHADER: GLenum = if (api.hasCompat(.V3_1)) 0x91B9 else @compileError("GL_COMPUTE_SHADER only available with GLES 3.1+");
        const GL_MAX_COMPUTE_UNIFORM_BLOCKS: GLenum = if (api.hasCompat(.V3_1)) 0x91BB else @compileError("GL_MAX_COMPUTE_UNIFORM_BLOCKS only available with GLES 3.1+");
        const GL_MAX_COMPUTE_TEXTURE_IMAGE_UNITS: GLenum = if (api.hasCompat(.V3_1)) 0x91BC else @compileError("GL_MAX_COMPUTE_TEXTURE_IMAGE_UNITS only available with GLES 3.1+");
        const GL_MAX_COMPUTE_IMAGE_UNIFORMS: GLenum = if (api.hasCompat(.V3_1)) 0x91BD else @compileError("GL_MAX_COMPUTE_IMAGE_UNIFORMS only available with GLES 3.1+");
        const GL_MAX_COMPUTE_SHARED_MEMORY_SIZE: GLenum = if (api.hasCompat(.V3_1)) 0x8262 else @compileError("GL_MAX_COMPUTE_SHARED_MEMORY_SIZE only available with GLES 3.1+");
        const GL_MAX_COMPUTE_UNIFORM_COMPONENTS: GLenum = if (api.hasCompat(.V3_1)) 0x8263 else @compileError("GL_MAX_COMPUTE_UNIFORM_COMPONENTS only available with GLES 3.1+");
        const GL_MAX_COMPUTE_ATOMIC_COUNTER_BUFFERS: GLenum = if (api.hasCompat(.V3_1)) 0x8264 else @compileError("GL_MAX_COMPUTE_ATOMIC_COUNTER_BUFFERS only available with GLES 3.1+");
        const GL_MAX_COMPUTE_ATOMIC_COUNTERS: GLenum = if (api.hasCompat(.V3_1)) 0x8265 else @compileError("GL_MAX_COMPUTE_ATOMIC_COUNTERS only available with GLES 3.1+");
        const GL_MAX_COMBINED_COMPUTE_UNIFORM_COMPONENTS: GLenum = if (api.hasCompat(.V3_1)) 0x8266 else @compileError("GL_MAX_COMBINED_COMPUTE_UNIFORM_COMPONENTS only available with GLES 3.1+");
        const GL_MAX_COMPUTE_WORK_GROUP_INVOCATIONS: GLenum = if (api.hasCompat(.V3_1)) 0x90EB else @compileError("GL_MAX_COMPUTE_WORK_GROUP_INVOCATIONS only available with GLES 3.1+");
        const GL_MAX_COMPUTE_WORK_GROUP_COUNT: GLenum = if (api.hasCompat(.V3_1)) 0x91BE else @compileError("GL_MAX_COMPUTE_WORK_GROUP_COUNT only available with GLES 3.1+");
        const GL_MAX_COMPUTE_WORK_GROUP_SIZE: GLenum = if (api.hasCompat(.V3_1)) 0x91BF else @compileError("GL_MAX_COMPUTE_WORK_GROUP_SIZE only available with GLES 3.1+");
        const GL_COMPUTE_WORK_GROUP_SIZE: GLenum = if (api.hasCompat(.V3_1)) 0x8267 else @compileError("GL_COMPUTE_WORK_GROUP_SIZE only available with GLES 3.1+");
        const GL_DISPATCH_INDIRECT_BUFFER: GLenum = if (api.hasCompat(.V3_1)) 0x90EE else @compileError("GL_DISPATCH_INDIRECT_BUFFER only available with GLES 3.1+");
        const GL_DISPATCH_INDIRECT_BUFFER_BINDING: GLenum = if (api.hasCompat(.V3_1)) 0x90EF else @compileError("GL_DISPATCH_INDIRECT_BUFFER_BINDING only available with GLES 3.1+");
        const GL_COMPUTE_SHADER_BIT: GLenum = if (api.hasCompat(.V3_1)) 0x00000020 else @compileError("GL_COMPUTE_SHADER_BIT only available with GLES 3.1+");
        const GL_DRAW_INDIRECT_BUFFER: GLenum = if (api.hasCompat(.V3_1)) 0x8F3F else @compileError("GL_DRAW_INDIRECT_BUFFER only available with GLES 3.1+");
        const GL_DRAW_INDIRECT_BUFFER_BINDING: GLenum = if (api.hasCompat(.V3_1)) 0x8F43 else @compileError("GL_DRAW_INDIRECT_BUFFER_BINDING only available with GLES 3.1+");
        const GL_MAX_UNIFORM_LOCATIONS: GLenum = if (api.hasCompat(.V3_1)) 0x826E else @compileError("GL_MAX_UNIFORM_LOCATIONS only available with GLES 3.1+");
        const GL_FRAMEBUFFER_DEFAULT_WIDTH: GLenum = if (api.hasCompat(.V3_1)) 0x9310 else @compileError("GL_FRAMEBUFFER_DEFAULT_WIDTH only available with GLES 3.1+");
        const GL_FRAMEBUFFER_DEFAULT_HEIGHT: GLenum = if (api.hasCompat(.V3_1)) 0x9311 else @compileError("GL_FRAMEBUFFER_DEFAULT_HEIGHT only available with GLES 3.1+");
        const GL_FRAMEBUFFER_DEFAULT_SAMPLES: GLenum = if (api.hasCompat(.V3_1)) 0x9313 else @compileError("GL_FRAMEBUFFER_DEFAULT_SAMPLES only available with GLES 3.1+");
        const GL_FRAMEBUFFER_DEFAULT_FIXED_SAMPLE_LOCATIONS: GLenum = if (api.hasCompat(.V3_1)) 0x9314 else @compileError("GL_FRAMEBUFFER_DEFAULT_FIXED_SAMPLE_LOCATIONS only available with GLES 3.1+");
        const GL_MAX_FRAMEBUFFER_WIDTH: GLenum = if (api.hasCompat(.V3_1)) 0x9315 else @compileError("GL_MAX_FRAMEBUFFER_WIDTH only available with GLES 3.1+");
        const GL_MAX_FRAMEBUFFER_HEIGHT: GLenum = if (api.hasCompat(.V3_1)) 0x9316 else @compileError("GL_MAX_FRAMEBUFFER_HEIGHT only available with GLES 3.1+");
        const GL_MAX_FRAMEBUFFER_SAMPLES: GLenum = if (api.hasCompat(.V3_1)) 0x9318 else @compileError("GL_MAX_FRAMEBUFFER_SAMPLES only available with GLES 3.1+");
        const GL_UNIFORM: GLenum = if (api.hasCompat(.V3_1)) 0x92E1 else @compileError("GL_UNIFORM only available with GLES 3.1+");
        const GL_UNIFORM_BLOCK: GLenum = if (api.hasCompat(.V3_1)) 0x92E2 else @compileError("GL_UNIFORM_BLOCK only available with GLES 3.1+");
        const GL_PROGRAM_INPUT: GLenum = if (api.hasCompat(.V3_1)) 0x92E3 else @compileError("GL_PROGRAM_INPUT only available with GLES 3.1+");
        const GL_PROGRAM_OUTPUT: GLenum = if (api.hasCompat(.V3_1)) 0x92E4 else @compileError("GL_PROGRAM_OUTPUT only available with GLES 3.1+");
        const GL_BUFFER_VARIABLE: GLenum = if (api.hasCompat(.V3_1)) 0x92E5 else @compileError("GL_BUFFER_VARIABLE only available with GLES 3.1+");
        const GL_SHADER_STORAGE_BLOCK: GLenum = if (api.hasCompat(.V3_1)) 0x92E6 else @compileError("GL_SHADER_STORAGE_BLOCK only available with GLES 3.1+");
        const GL_ATOMIC_COUNTER_BUFFER: GLenum = if (api.hasCompat(.V3_1)) 0x92C0 else @compileError("GL_ATOMIC_COUNTER_BUFFER only available with GLES 3.1+");
        const GL_TRANSFORM_FEEDBACK_VARYING: GLenum = if (api.hasCompat(.V3_1)) 0x92F4 else @compileError("GL_TRANSFORM_FEEDBACK_VARYING only available with GLES 3.1+");
        const GL_ACTIVE_RESOURCES: GLenum = if (api.hasCompat(.V3_1)) 0x92F5 else @compileError("GL_ACTIVE_RESOURCES only available with GLES 3.1+");
        const GL_MAX_NAME_LENGTH: GLenum = if (api.hasCompat(.V3_1)) 0x92F6 else @compileError("GL_MAX_NAME_LENGTH only available with GLES 3.1+");
        const GL_MAX_NUM_ACTIVE_VARIABLES: GLenum = if (api.hasCompat(.V3_1)) 0x92F7 else @compileError("GL_MAX_NUM_ACTIVE_VARIABLES only available with GLES 3.1+");
        const GL_NAME_LENGTH: GLenum = if (api.hasCompat(.V3_1)) 0x92F9 else @compileError("GL_NAME_LENGTH only available with GLES 3.1+");
        const GL_TYPE: GLenum = if (api.hasCompat(.V3_1)) 0x92FA else @compileError("GL_TYPE only available with GLES 3.1+");
        const GL_ARRAY_SIZE: GLenum = if (api.hasCompat(.V3_1)) 0x92FB else @compileError("GL_ARRAY_SIZE only available with GLES 3.1+");
        const GL_OFFSET: GLenum = if (api.hasCompat(.V3_1)) 0x92FC else @compileError("GL_OFFSET only available with GLES 3.1+");
        const GL_BLOCK_INDEX: GLenum = if (api.hasCompat(.V3_1)) 0x92FD else @compileError("GL_BLOCK_INDEX only available with GLES 3.1+");
        const GL_ARRAY_STRIDE: GLenum = if (api.hasCompat(.V3_1)) 0x92FE else @compileError("GL_ARRAY_STRIDE only available with GLES 3.1+");
        const GL_MATRIX_STRIDE: GLenum = if (api.hasCompat(.V3_1)) 0x92FF else @compileError("GL_MATRIX_STRIDE only available with GLES 3.1+");
        const GL_IS_ROW_MAJOR: GLenum = if (api.hasCompat(.V3_1)) 0x9300 else @compileError("GL_IS_ROW_MAJOR only available with GLES 3.1+");
        const GL_ATOMIC_COUNTER_BUFFER_INDEX: GLenum = if (api.hasCompat(.V3_1)) 0x9301 else @compileError("GL_ATOMIC_COUNTER_BUFFER_INDEX only available with GLES 3.1+");
        const GL_BUFFER_BINDING: GLenum = if (api.hasCompat(.V3_1)) 0x9302 else @compileError("GL_BUFFER_BINDING only available with GLES 3.1+");
        const GL_BUFFER_DATA_SIZE: GLenum = if (api.hasCompat(.V3_1)) 0x9303 else @compileError("GL_BUFFER_DATA_SIZE only available with GLES 3.1+");
        const GL_NUM_ACTIVE_VARIABLES: GLenum = if (api.hasCompat(.V3_1)) 0x9304 else @compileError("GL_NUM_ACTIVE_VARIABLES only available with GLES 3.1+");
        const GL_ACTIVE_VARIABLES: GLenum = if (api.hasCompat(.V3_1)) 0x9305 else @compileError("GL_ACTIVE_VARIABLES only available with GLES 3.1+");
        const GL_REFERENCED_BY_VERTEX_SHADER: GLenum = if (api.hasCompat(.V3_1)) 0x9306 else @compileError("GL_REFERENCED_BY_VERTEX_SHADER only available with GLES 3.1+");
        const GL_REFERENCED_BY_FRAGMENT_SHADER: GLenum = if (api.hasCompat(.V3_1)) 0x930A else @compileError("GL_REFERENCED_BY_FRAGMENT_SHADER only available with GLES 3.1+");
        const GL_REFERENCED_BY_COMPUTE_SHADER: GLenum = if (api.hasCompat(.V3_1)) 0x930B else @compileError("GL_REFERENCED_BY_COMPUTE_SHADER only available with GLES 3.1+");
        const GL_TOP_LEVEL_ARRAY_SIZE: GLenum = if (api.hasCompat(.V3_1)) 0x930C else @compileError("GL_TOP_LEVEL_ARRAY_SIZE only available with GLES 3.1+");
        const GL_TOP_LEVEL_ARRAY_STRIDE: GLenum = if (api.hasCompat(.V3_1)) 0x930D else @compileError("GL_TOP_LEVEL_ARRAY_STRIDE only available with GLES 3.1+");
        const GL_LOCATION: GLenum = if (api.hasCompat(.V3_1)) 0x930E else @compileError("GL_LOCATION only available with GLES 3.1+");
        const GL_VERTEX_SHADER_BIT: GLenum = if (api.hasCompat(.V3_1)) 0x00000001 else @compileError("GL_VERTEX_SHADER_BIT only available with GLES 3.1+");
        const GL_FRAGMENT_SHADER_BIT: GLenum = if (api.hasCompat(.V3_1)) 0x00000002 else @compileError("GL_FRAGMENT_SHADER_BIT only available with GLES 3.1+");
        const GL_ALL_SHADER_BITS: GLenum = if (api.hasCompat(.V3_1)) 0xFFFFFFFF else @compileError("GL_ALL_SHADER_BITS only available with GLES 3.1+");
        const GL_PROGRAM_SEPARABLE: GLenum = if (api.hasCompat(.V3_1)) 0x8258 else @compileError("GL_PROGRAM_SEPARABLE only available with GLES 3.1+");
        const GL_ACTIVE_PROGRAM: GLenum = if (api.hasCompat(.V3_1)) 0x8259 else @compileError("GL_ACTIVE_PROGRAM only available with GLES 3.1+");
        const GL_PROGRAM_PIPELINE_BINDING: GLenum = if (api.hasCompat(.V3_1)) 0x825A else @compileError("GL_PROGRAM_PIPELINE_BINDING only available with GLES 3.1+");
        const GL_ATOMIC_COUNTER_BUFFER_BINDING: GLenum = if (api.hasCompat(.V3_1)) 0x92C1 else @compileError("GL_ATOMIC_COUNTER_BUFFER_BINDING only available with GLES 3.1+");
        const GL_ATOMIC_COUNTER_BUFFER_START: GLenum = if (api.hasCompat(.V3_1)) 0x92C2 else @compileError("GL_ATOMIC_COUNTER_BUFFER_START only available with GLES 3.1+");
        const GL_ATOMIC_COUNTER_BUFFER_SIZE: GLenum = if (api.hasCompat(.V3_1)) 0x92C3 else @compileError("GL_ATOMIC_COUNTER_BUFFER_SIZE only available with GLES 3.1+");
        const GL_MAX_VERTEX_ATOMIC_COUNTER_BUFFERS: GLenum = if (api.hasCompat(.V3_1)) 0x92CC else @compileError("GL_MAX_VERTEX_ATOMIC_COUNTER_BUFFERS only available with GLES 3.1+");
        const GL_MAX_FRAGMENT_ATOMIC_COUNTER_BUFFERS: GLenum = if (api.hasCompat(.V3_1)) 0x92D0 else @compileError("GL_MAX_FRAGMENT_ATOMIC_COUNTER_BUFFERS only available with GLES 3.1+");
        const GL_MAX_COMBINED_ATOMIC_COUNTER_BUFFERS: GLenum = if (api.hasCompat(.V3_1)) 0x92D1 else @compileError("GL_MAX_COMBINED_ATOMIC_COUNTER_BUFFERS only available with GLES 3.1+");
        const GL_MAX_VERTEX_ATOMIC_COUNTERS: GLenum = if (api.hasCompat(.V3_1)) 0x92D2 else @compileError("GL_MAX_VERTEX_ATOMIC_COUNTERS only available with GLES 3.1+");
        const GL_MAX_FRAGMENT_ATOMIC_COUNTERS: GLenum = if (api.hasCompat(.V3_1)) 0x92D6 else @compileError("GL_MAX_FRAGMENT_ATOMIC_COUNTERS only available with GLES 3.1+");
        const GL_MAX_COMBINED_ATOMIC_COUNTERS: GLenum = if (api.hasCompat(.V3_1)) 0x92D7 else @compileError("GL_MAX_COMBINED_ATOMIC_COUNTERS only available with GLES 3.1+");
        const GL_MAX_ATOMIC_COUNTER_BUFFER_SIZE: GLenum = if (api.hasCompat(.V3_1)) 0x92D8 else @compileError("GL_MAX_ATOMIC_COUNTER_BUFFER_SIZE only available with GLES 3.1+");
        const GL_MAX_ATOMIC_COUNTER_BUFFER_BINDINGS: GLenum = if (api.hasCompat(.V3_1)) 0x92DC else @compileError("GL_MAX_ATOMIC_COUNTER_BUFFER_BINDINGS only available with GLES 3.1+");
        const GL_ACTIVE_ATOMIC_COUNTER_BUFFERS: GLenum = if (api.hasCompat(.V3_1)) 0x92D9 else @compileError("GL_ACTIVE_ATOMIC_COUNTER_BUFFERS only available with GLES 3.1+");
        const GL_UNSIGNED_INT_ATOMIC_COUNTER: GLenum = if (api.hasCompat(.V3_1)) 0x92DB else @compileError("GL_UNSIGNED_INT_ATOMIC_COUNTER only available with GLES 3.1+");
        const GL_MAX_IMAGE_UNITS: GLenum = if (api.hasCompat(.V3_1)) 0x8F38 else @compileError("GL_MAX_IMAGE_UNITS only available with GLES 3.1+");
        const GL_MAX_VERTEX_IMAGE_UNIFORMS: GLenum = if (api.hasCompat(.V3_1)) 0x90CA else @compileError("GL_MAX_VERTEX_IMAGE_UNIFORMS only available with GLES 3.1+");
        const GL_MAX_FRAGMENT_IMAGE_UNIFORMS: GLenum = if (api.hasCompat(.V3_1)) 0x90CE else @compileError("GL_MAX_FRAGMENT_IMAGE_UNIFORMS only available with GLES 3.1+");
        const GL_MAX_COMBINED_IMAGE_UNIFORMS: GLenum = if (api.hasCompat(.V3_1)) 0x90CF else @compileError("GL_MAX_COMBINED_IMAGE_UNIFORMS only available with GLES 3.1+");
        const GL_IMAGE_BINDING_NAME: GLenum = if (api.hasCompat(.V3_1)) 0x8F3A else @compileError("GL_IMAGE_BINDING_NAME only available with GLES 3.1+");
        const GL_IMAGE_BINDING_LEVEL: GLenum = if (api.hasCompat(.V3_1)) 0x8F3B else @compileError("GL_IMAGE_BINDING_LEVEL only available with GLES 3.1+");
        const GL_IMAGE_BINDING_LAYERED: GLenum = if (api.hasCompat(.V3_1)) 0x8F3C else @compileError("GL_IMAGE_BINDING_LAYERED only available with GLES 3.1+");
        const GL_IMAGE_BINDING_LAYER: GLenum = if (api.hasCompat(.V3_1)) 0x8F3D else @compileError("GL_IMAGE_BINDING_LAYER only available with GLES 3.1+");
        const GL_IMAGE_BINDING_ACCESS: GLenum = if (api.hasCompat(.V3_1)) 0x8F3E else @compileError("GL_IMAGE_BINDING_ACCESS only available with GLES 3.1+");
        const GL_IMAGE_BINDING_FORMAT: GLenum = if (api.hasCompat(.V3_1)) 0x906E else @compileError("GL_IMAGE_BINDING_FORMAT only available with GLES 3.1+");
        const GL_VERTEX_ATTRIB_ARRAY_BARRIER_BIT: GLenum = if (api.hasCompat(.V3_1)) 0x00000001 else @compileError("GL_VERTEX_ATTRIB_ARRAY_BARRIER_BIT only available with GLES 3.1+");
        const GL_ELEMENT_ARRAY_BARRIER_BIT: GLenum = if (api.hasCompat(.V3_1)) 0x00000002 else @compileError("GL_ELEMENT_ARRAY_BARRIER_BIT only available with GLES 3.1+");
        const GL_UNIFORM_BARRIER_BIT: GLenum = if (api.hasCompat(.V3_1)) 0x00000004 else @compileError("GL_UNIFORM_BARRIER_BIT only available with GLES 3.1+");
        const GL_TEXTURE_FETCH_BARRIER_BIT: GLenum = if (api.hasCompat(.V3_1)) 0x00000008 else @compileError("GL_TEXTURE_FETCH_BARRIER_BIT only available with GLES 3.1+");
        const GL_SHADER_IMAGE_ACCESS_BARRIER_BIT: GLenum = if (api.hasCompat(.V3_1)) 0x00000020 else @compileError("GL_SHADER_IMAGE_ACCESS_BARRIER_BIT only available with GLES 3.1+");
        const GL_COMMAND_BARRIER_BIT: GLenum = if (api.hasCompat(.V3_1)) 0x00000040 else @compileError("GL_COMMAND_BARRIER_BIT only available with GLES 3.1+");
        const GL_PIXEL_BUFFER_BARRIER_BIT: GLenum = if (api.hasCompat(.V3_1)) 0x00000080 else @compileError("GL_PIXEL_BUFFER_BARRIER_BIT only available with GLES 3.1+");
        const GL_TEXTURE_UPDATE_BARRIER_BIT: GLenum = if (api.hasCompat(.V3_1)) 0x00000100 else @compileError("GL_TEXTURE_UPDATE_BARRIER_BIT only available with GLES 3.1+");
        const GL_BUFFER_UPDATE_BARRIER_BIT: GLenum = if (api.hasCompat(.V3_1)) 0x00000200 else @compileError("GL_BUFFER_UPDATE_BARRIER_BIT only available with GLES 3.1+");
        const GL_FRAMEBUFFER_BARRIER_BIT: GLenum = if (api.hasCompat(.V3_1)) 0x00000400 else @compileError("GL_FRAMEBUFFER_BARRIER_BIT only available with GLES 3.1+");
        const GL_TRANSFORM_FEEDBACK_BARRIER_BIT: GLenum = if (api.hasCompat(.V3_1)) 0x00000800 else @compileError("GL_TRANSFORM_FEEDBACK_BARRIER_BIT only available with GLES 3.1+");
        const GL_ATOMIC_COUNTER_BARRIER_BIT: GLenum = if (api.hasCompat(.V3_1)) 0x00001000 else @compileError("GL_ATOMIC_COUNTER_BARRIER_BIT only available with GLES 3.1+");
        const GL_ALL_BARRIER_BITS: GLenum = if (api.hasCompat(.V3_1)) 0xFFFFFFFF else @compileError("GL_ALL_BARRIER_BITS only available with GLES 3.1+");
        const GL_IMAGE_2D: GLenum = if (api.hasCompat(.V3_1)) 0x904D else @compileError("GL_IMAGE_2D only available with GLES 3.1+");
        const GL_IMAGE_3D: GLenum = if (api.hasCompat(.V3_1)) 0x904E else @compileError("GL_IMAGE_3D only available with GLES 3.1+");
        const GL_IMAGE_CUBE: GLenum = if (api.hasCompat(.V3_1)) 0x9050 else @compileError("GL_IMAGE_CUBE only available with GLES 3.1+");
        const GL_IMAGE_2D_ARRAY: GLenum = if (api.hasCompat(.V3_1)) 0x9053 else @compileError("GL_IMAGE_2D_ARRAY only available with GLES 3.1+");
        const GL_INT_IMAGE_2D: GLenum = if (api.hasCompat(.V3_1)) 0x9058 else @compileError("GL_INT_IMAGE_2D only available with GLES 3.1+");
        const GL_INT_IMAGE_3D: GLenum = if (api.hasCompat(.V3_1)) 0x9059 else @compileError("GL_INT_IMAGE_3D only available with GLES 3.1+");
        const GL_INT_IMAGE_CUBE: GLenum = if (api.hasCompat(.V3_1)) 0x905B else @compileError("GL_INT_IMAGE_CUBE only available with GLES 3.1+");
        const GL_INT_IMAGE_2D_ARRAY: GLenum = if (api.hasCompat(.V3_1)) 0x905E else @compileError("GL_INT_IMAGE_2D_ARRAY only available with GLES 3.1+");
        const GL_UNSIGNED_INT_IMAGE_2D: GLenum = if (api.hasCompat(.V3_1)) 0x9063 else @compileError("GL_UNSIGNED_INT_IMAGE_2D only available with GLES 3.1+");
        const GL_UNSIGNED_INT_IMAGE_3D: GLenum = if (api.hasCompat(.V3_1)) 0x9064 else @compileError("GL_UNSIGNED_INT_IMAGE_3D only available with GLES 3.1+");
        const GL_UNSIGNED_INT_IMAGE_CUBE: GLenum = if (api.hasCompat(.V3_1)) 0x9066 else @compileError("GL_UNSIGNED_INT_IMAGE_CUBE only available with GLES 3.1+");
        const GL_UNSIGNED_INT_IMAGE_2D_ARRAY: GLenum = if (api.hasCompat(.V3_1)) 0x9069 else @compileError("GL_UNSIGNED_INT_IMAGE_2D_ARRAY only available with GLES 3.1+");
        const GL_IMAGE_FORMAT_COMPATIBILITY_TYPE: GLenum = if (api.hasCompat(.V3_1)) 0x90C7 else @compileError("GL_IMAGE_FORMAT_COMPATIBILITY_TYPE only available with GLES 3.1+");
        const GL_IMAGE_FORMAT_COMPATIBILITY_BY_SIZE: GLenum = if (api.hasCompat(.V3_1)) 0x90C8 else @compileError("GL_IMAGE_FORMAT_COMPATIBILITY_BY_SIZE only available with GLES 3.1+");
        const GL_IMAGE_FORMAT_COMPATIBILITY_BY_CLASS: GLenum = if (api.hasCompat(.V3_1)) 0x90C9 else @compileError("GL_IMAGE_FORMAT_COMPATIBILITY_BY_CLASS only available with GLES 3.1+");
        const GL_READ_ONLY: GLenum = if (api.hasCompat(.V3_1)) 0x88B8 else @compileError("GL_READ_ONLY only available with GLES 3.1+");
        const GL_WRITE_ONLY: GLenum = if (api.hasCompat(.V3_1)) 0x88B9 else @compileError("GL_WRITE_ONLY only available with GLES 3.1+");
        const GL_READ_WRITE: GLenum = if (api.hasCompat(.V3_1)) 0x88BA else @compileError("GL_READ_WRITE only available with GLES 3.1+");
        const GL_SHADER_STORAGE_BUFFER: GLenum = if (api.hasCompat(.V3_1)) 0x90D2 else @compileError("GL_SHADER_STORAGE_BUFFER only available with GLES 3.1+");
        const GL_SHADER_STORAGE_BUFFER_BINDING: GLenum = if (api.hasCompat(.V3_1)) 0x90D3 else @compileError("GL_SHADER_STORAGE_BUFFER_BINDING only available with GLES 3.1+");
        const GL_SHADER_STORAGE_BUFFER_START: GLenum = if (api.hasCompat(.V3_1)) 0x90D4 else @compileError("GL_SHADER_STORAGE_BUFFER_START only available with GLES 3.1+");
        const GL_SHADER_STORAGE_BUFFER_SIZE: GLenum = if (api.hasCompat(.V3_1)) 0x90D5 else @compileError("GL_SHADER_STORAGE_BUFFER_SIZE only available with GLES 3.1+");
        const GL_MAX_VERTEX_SHADER_STORAGE_BLOCKS: GLenum = if (api.hasCompat(.V3_1)) 0x90D6 else @compileError("GL_MAX_VERTEX_SHADER_STORAGE_BLOCKS only available with GLES 3.1+");
        const GL_MAX_FRAGMENT_SHADER_STORAGE_BLOCKS: GLenum = if (api.hasCompat(.V3_1)) 0x90DA else @compileError("GL_MAX_FRAGMENT_SHADER_STORAGE_BLOCKS only available with GLES 3.1+");
        const GL_MAX_COMPUTE_SHADER_STORAGE_BLOCKS: GLenum = if (api.hasCompat(.V3_1)) 0x90DB else @compileError("GL_MAX_COMPUTE_SHADER_STORAGE_BLOCKS only available with GLES 3.1+");
        const GL_MAX_COMBINED_SHADER_STORAGE_BLOCKS: GLenum = if (api.hasCompat(.V3_1)) 0x90DC else @compileError("GL_MAX_COMBINED_SHADER_STORAGE_BLOCKS only available with GLES 3.1+");
        const GL_MAX_SHADER_STORAGE_BUFFER_BINDINGS: GLenum = if (api.hasCompat(.V3_1)) 0x90DD else @compileError("GL_MAX_SHADER_STORAGE_BUFFER_BINDINGS only available with GLES 3.1+");
        const GL_MAX_SHADER_STORAGE_BLOCK_SIZE: GLenum = if (api.hasCompat(.V3_1)) 0x90DE else @compileError("GL_MAX_SHADER_STORAGE_BLOCK_SIZE only available with GLES 3.1+");
        const GL_SHADER_STORAGE_BUFFER_OFFSET_ALIGNMENT: GLenum = if (api.hasCompat(.V3_1)) 0x90DF else @compileError("GL_SHADER_STORAGE_BUFFER_OFFSET_ALIGNMENT only available with GLES 3.1+");
        const GL_SHADER_STORAGE_BARRIER_BIT: GLenum = if (api.hasCompat(.V3_1)) 0x00002000 else @compileError("GL_SHADER_STORAGE_BARRIER_BIT only available with GLES 3.1+");
        const GL_MAX_COMBINED_SHADER_OUTPUT_RESOURCES: GLenum = if (api.hasCompat(.V3_1)) 0x8F39 else @compileError("GL_MAX_COMBINED_SHADER_OUTPUT_RESOURCES only available with GLES 3.1+");
        const GL_DEPTH_STENCIL_TEXTURE_MODE: GLenum = if (api.hasCompat(.V3_1)) 0x90EA else @compileError("GL_DEPTH_STENCIL_TEXTURE_MODE only available with GLES 3.1+");
        const GL_STENCIL_INDEX: GLenum = if (api.hasCompat(.V3_1)) 0x1901 else @compileError("GL_STENCIL_INDEX only available with GLES 3.1+");
        const GL_MIN_PROGRAM_TEXTURE_GATHER_OFFSET: GLenum = if (api.hasCompat(.V3_1)) 0x8E5E else @compileError("GL_MIN_PROGRAM_TEXTURE_GATHER_OFFSET only available with GLES 3.1+");
        const GL_MAX_PROGRAM_TEXTURE_GATHER_OFFSET: GLenum = if (api.hasCompat(.V3_1)) 0x8E5F else @compileError("GL_MAX_PROGRAM_TEXTURE_GATHER_OFFSET only available with GLES 3.1+");
        const GL_SAMPLE_POSITION: GLenum = if (api.hasCompat(.V3_1)) 0x8E50 else @compileError("GL_SAMPLE_POSITION only available with GLES 3.1+");
        const GL_SAMPLE_MASK: GLenum = if (api.hasCompat(.V3_1)) 0x8E51 else @compileError("GL_SAMPLE_MASK only available with GLES 3.1+");
        const GL_SAMPLE_MASK_VALUE: GLenum = if (api.hasCompat(.V3_1)) 0x8E52 else @compileError("GL_SAMPLE_MASK_VALUE only available with GLES 3.1+");
        const GL_TEXTURE_2D_MULTISAMPLE: GLenum = if (api.hasCompat(.V3_1)) 0x9100 else @compileError("GL_TEXTURE_2D_MULTISAMPLE only available with GLES 3.1+");
        const GL_MAX_SAMPLE_MASK_WORDS: GLenum = if (api.hasCompat(.V3_1)) 0x8E59 else @compileError("GL_MAX_SAMPLE_MASK_WORDS only available with GLES 3.1+");
        const GL_MAX_COLOR_TEXTURE_SAMPLES: GLenum = if (api.hasCompat(.V3_1)) 0x910E else @compileError("GL_MAX_COLOR_TEXTURE_SAMPLES only available with GLES 3.1+");
        const GL_MAX_DEPTH_TEXTURE_SAMPLES: GLenum = if (api.hasCompat(.V3_1)) 0x910F else @compileError("GL_MAX_DEPTH_TEXTURE_SAMPLES only available with GLES 3.1+");
        const GL_MAX_INTEGER_SAMPLES: GLenum = if (api.hasCompat(.V3_1)) 0x9110 else @compileError("GL_MAX_INTEGER_SAMPLES only available with GLES 3.1+");
        const GL_TEXTURE_BINDING_2D_MULTISAMPLE: GLenum = if (api.hasCompat(.V3_1)) 0x9104 else @compileError("GL_TEXTURE_BINDING_2D_MULTISAMPLE only available with GLES 3.1+");
        const GL_TEXTURE_SAMPLES: GLenum = if (api.hasCompat(.V3_1)) 0x9106 else @compileError("GL_TEXTURE_SAMPLES only available with GLES 3.1+");
        const GL_TEXTURE_FIXED_SAMPLE_LOCATIONS: GLenum = if (api.hasCompat(.V3_1)) 0x9107 else @compileError("GL_TEXTURE_FIXED_SAMPLE_LOCATIONS only available with GLES 3.1+");
        const GL_TEXTURE_WIDTH: GLenum = if (api.hasCompat(.V3_1)) 0x1000 else @compileError("GL_TEXTURE_WIDTH only available with GLES 3.1+");
        const GL_TEXTURE_HEIGHT: GLenum = if (api.hasCompat(.V3_1)) 0x1001 else @compileError("GL_TEXTURE_HEIGHT only available with GLES 3.1+");
        const GL_TEXTURE_DEPTH: GLenum = if (api.hasCompat(.V3_1)) 0x8071 else @compileError("GL_TEXTURE_DEPTH only available with GLES 3.1+");
        const GL_TEXTURE_INTERNAL_FORMAT: GLenum = if (api.hasCompat(.V3_1)) 0x1003 else @compileError("GL_TEXTURE_INTERNAL_FORMAT only available with GLES 3.1+");
        const GL_TEXTURE_RED_SIZE: GLenum = if (api.hasCompat(.V3_1)) 0x805C else @compileError("GL_TEXTURE_RED_SIZE only available with GLES 3.1+");
        const GL_TEXTURE_GREEN_SIZE: GLenum = if (api.hasCompat(.V3_1)) 0x805D else @compileError("GL_TEXTURE_GREEN_SIZE only available with GLES 3.1+");
        const GL_TEXTURE_BLUE_SIZE: GLenum = if (api.hasCompat(.V3_1)) 0x805E else @compileError("GL_TEXTURE_BLUE_SIZE only available with GLES 3.1+");
        const GL_TEXTURE_ALPHA_SIZE: GLenum = if (api.hasCompat(.V3_1)) 0x805F else @compileError("GL_TEXTURE_ALPHA_SIZE only available with GLES 3.1+");
        const GL_TEXTURE_DEPTH_SIZE: GLenum = if (api.hasCompat(.V3_1)) 0x884A else @compileError("GL_TEXTURE_DEPTH_SIZE only available with GLES 3.1+");
        const GL_TEXTURE_STENCIL_SIZE: GLenum = if (api.hasCompat(.V3_1)) 0x88F1 else @compileError("GL_TEXTURE_STENCIL_SIZE only available with GLES 3.1+");
        const GL_TEXTURE_SHARED_SIZE: GLenum = if (api.hasCompat(.V3_1)) 0x8C3F else @compileError("GL_TEXTURE_SHARED_SIZE only available with GLES 3.1+");
        const GL_TEXTURE_RED_TYPE: GLenum = if (api.hasCompat(.V3_1)) 0x8C10 else @compileError("GL_TEXTURE_RED_TYPE only available with GLES 3.1+");
        const GL_TEXTURE_GREEN_TYPE: GLenum = if (api.hasCompat(.V3_1)) 0x8C11 else @compileError("GL_TEXTURE_GREEN_TYPE only available with GLES 3.1+");
        const GL_TEXTURE_BLUE_TYPE: GLenum = if (api.hasCompat(.V3_1)) 0x8C12 else @compileError("GL_TEXTURE_BLUE_TYPE only available with GLES 3.1+");
        const GL_TEXTURE_ALPHA_TYPE: GLenum = if (api.hasCompat(.V3_1)) 0x8C13 else @compileError("GL_TEXTURE_ALPHA_TYPE only available with GLES 3.1+");
        const GL_TEXTURE_DEPTH_TYPE: GLenum = if (api.hasCompat(.V3_1)) 0x8C16 else @compileError("GL_TEXTURE_DEPTH_TYPE only available with GLES 3.1+");
        const GL_TEXTURE_COMPRESSED: GLenum = if (api.hasCompat(.V3_1)) 0x86A1 else @compileError("GL_TEXTURE_COMPRESSED only available with GLES 3.1+");
        const GL_SAMPLER_2D_MULTISAMPLE: GLenum = if (api.hasCompat(.V3_1)) 0x9108 else @compileError("GL_SAMPLER_2D_MULTISAMPLE only available with GLES 3.1+");
        const GL_INT_SAMPLER_2D_MULTISAMPLE: GLenum = if (api.hasCompat(.V3_1)) 0x9109 else @compileError("GL_INT_SAMPLER_2D_MULTISAMPLE only available with GLES 3.1+");
        const GL_UNSIGNED_INT_SAMPLER_2D_MULTISAMPLE: GLenum = if (api.hasCompat(.V3_1)) 0x910A else @compileError("GL_UNSIGNED_INT_SAMPLER_2D_MULTISAMPLE only available with GLES 3.1+");
        const GL_VERTEX_ATTRIB_BINDING: GLenum = if (api.hasCompat(.V3_1)) 0x82D4 else @compileError("GL_VERTEX_ATTRIB_BINDING only available with GLES 3.1+");
        const GL_VERTEX_ATTRIB_RELATIVE_OFFSET: GLenum = if (api.hasCompat(.V3_1)) 0x82D5 else @compileError("GL_VERTEX_ATTRIB_RELATIVE_OFFSET only available with GLES 3.1+");
        const GL_VERTEX_BINDING_DIVISOR: GLenum = if (api.hasCompat(.V3_1)) 0x82D6 else @compileError("GL_VERTEX_BINDING_DIVISOR only available with GLES 3.1+");
        const GL_VERTEX_BINDING_OFFSET: GLenum = if (api.hasCompat(.V3_1)) 0x82D7 else @compileError("GL_VERTEX_BINDING_OFFSET only available with GLES 3.1+");
        const GL_VERTEX_BINDING_STRIDE: GLenum = if (api.hasCompat(.V3_1)) 0x82D8 else @compileError("GL_VERTEX_BINDING_STRIDE only available with GLES 3.1+");
        const GL_VERTEX_BINDING_BUFFER: GLenum = if (api.hasCompat(.V3_1)) 0x8F4F else @compileError("GL_VERTEX_BINDING_BUFFER only available with GLES 3.1+");
        const GL_MAX_VERTEX_ATTRIB_RELATIVE_OFFSET: GLenum = if (api.hasCompat(.V3_1)) 0x82D9 else @compileError("GL_MAX_VERTEX_ATTRIB_RELATIVE_OFFSET only available with GLES 3.1+");
        const GL_MAX_VERTEX_ATTRIB_BINDINGS: GLenum = if (api.hasCompat(.V3_1)) 0x82DA else @compileError("GL_MAX_VERTEX_ATTRIB_BINDINGS only available with GLES 3.1+");
        const GL_MAX_VERTEX_ATTRIB_STRIDE: GLenum = if (api.hasCompat(.V3_1)) 0x82E5 else @compileError("GL_MAX_VERTEX_ATTRIB_STRIDE only available with GLES 3.1+");

        const glDispatchCompute = if (api.hasCompat(.V3_1)) Externs.glDispatchCompute else @compileError("glDispatchCompute only available with GLES 3.1+");
        const glDispatchComputeIndirect = if (api.hasCompat(.V3_1)) Externs.glDispatchComputeIndirect else @compileError("glDispatchComputeIndirect only available with GLES 3.1+");
        const glDrawArraysIndirect = if (api.hasCompat(.V3_1)) Externs.glDrawArraysIndirect else @compileError("glDrawArraysIndirect only available with GLES 3.1+");
        const glDrawElementsIndirect = if (api.hasCompat(.V3_1)) Externs.glDrawElementsIndirect else @compileError("glDrawElementsIndirect only available with GLES 3.1+");
        const glFramebufferParameteri = if (api.hasCompat(.V3_1)) Externs.glFramebufferParameteri else @compileError("glFramebufferParameteri only available with GLES 3.1+");
        const glGetFramebufferParameteriv = if (api.hasCompat(.V3_1)) Bindings.glGetFramebufferParameteriv else @compileError("glGetFramebufferParameteriv only available with GLES 3.1+");
        const glGetProgramInterfaceiv = if (api.hasCompat(.V3_1)) Bindings.glGetProgramInterfaceiv else @compileError("glGetProgramInterfaceiv only available with GLES 3.1+");
        const glGetProgramResourceIndex = if (api.hasCompat(.V3_1)) Bindings.glGetProgramResourceIndex else @compileError("glGetProgramResourceIndex only available with GLES 3.1+");
        const glGetProgramResourceName = if (api.hasCompat(.V3_1)) Bindings.glGetProgramResourceName else @compileError("glGetProgramResourceName only available with GLES 3.1+");
        const glGetProgramResourceiv = if (api.hasCompat(.V3_1)) Bindings.glGetProgramResourceiv else @compileError("glGetProgramResourceiv only available with GLES 3.1+");
        const glGetProgramResourceLocation = if (api.hasCompat(.V3_1)) Bindings.glGetProgramResourceLocation else @compileError("glGetProgramResourceLocation only available with GLES 3.1+");
        const glUseProgramStages = if (api.hasCompat(.V3_1)) Externs.glUseProgramStages else @compileError("glUseProgramStages only available with GLES 3.1+");
        const glActiveShaderProgram = if (api.hasCompat(.V3_1)) Externs.glActiveShaderProgram else @compileError("glActiveShaderProgram only available with GLES 3.1+");
        const glCreateShaderProgramv = if (api.hasCompat(.V3_1)) Bindings.glCreateShaderProgramv else @compileError("glCreateShaderProgramv only available with GLES 3.1+");
        const glBindProgramPipeline = if (api.hasCompat(.V3_1)) Externs.glBindProgramPipeline else @compileError("glBindProgramPipeline only available with GLES 3.1+");
        const glDeleteProgramPipelines = if (api.hasCompat(.V3_1)) Bindings.glDeleteProgramPipelines else @compileError("glDeleteProgramPipelines only available with GLES 3.1+");
        const glGenProgramPipelines = if (api.hasCompat(.V3_1)) Bindings.glGenProgramPipelines else @compileError("glGenProgramPipelines only available with GLES 3.1+");
        const glIsProgramPipeline = if (api.hasCompat(.V3_1)) Externs.glIsProgramPipeline else @compileError("glIsProgramPipeline only available with GLES 3.1+");
        const glGetProgramPipelineiv = if (api.hasCompat(.V3_1)) Bindings.glGetProgramPipelineiv else @compileError("glGetProgramPipelineiv only available with GLES 3.1+");
        const glProgramUniform1i = if (api.hasCompat(.V3_1)) Externs.glProgramUniform1i else @compileError("glProgramUniform1i only available with GLES 3.1+");
        const glProgramUniform2i = if (api.hasCompat(.V3_1)) Externs.glProgramUniform2i else @compileError("glProgramUniform2i only available with GLES 3.1+");
        const glProgramUniform3i = if (api.hasCompat(.V3_1)) Externs.glProgramUniform3i else @compileError("glProgramUniform3i only available with GLES 3.1+");
        const glProgramUniform4i = if (api.hasCompat(.V3_1)) Externs.glProgramUniform4i else @compileError("glProgramUniform4i only available with GLES 3.1+");
        const glProgramUniform1ui = if (api.hasCompat(.V3_1)) Externs.glProgramUniform1ui else @compileError("glProgramUniform1ui only available with GLES 3.1+");
        const glProgramUniform2ui = if (api.hasCompat(.V3_1)) Externs.glProgramUniform2ui else @compileError("glProgramUniform2ui only available with GLES 3.1+");
        const glProgramUniform3ui = if (api.hasCompat(.V3_1)) Externs.glProgramUniform3ui else @compileError("glProgramUniform3ui only available with GLES 3.1+");
        const glProgramUniform4ui = if (api.hasCompat(.V3_1)) Externs.glProgramUniform4ui else @compileError("glProgramUniform4ui only available with GLES 3.1+");
        const glProgramUniform1f = if (api.hasCompat(.V3_1)) Externs.glProgramUniform1f else @compileError("glProgramUniform1f only available with GLES 3.1+");
        const glProgramUniform2f = if (api.hasCompat(.V3_1)) Externs.glProgramUniform2f else @compileError("glProgramUniform2f only available with GLES 3.1+");
        const glProgramUniform3f = if (api.hasCompat(.V3_1)) Externs.glProgramUniform3f else @compileError("glProgramUniform3f only available with GLES 3.1+");
        const glProgramUniform4f = if (api.hasCompat(.V3_1)) Externs.glProgramUniform4f else @compileError("glProgramUniform4f only available with GLES 3.1+");
        const glProgramUniform1iv = if (api.hasCompat(.V3_1)) Bindings.glProgramUniform1iv else @compileError("glProgramUniform1iv only available with GLES 3.1+");
        const glProgramUniform2iv = if (api.hasCompat(.V3_1)) Bindings.glProgramUniform2iv else @compileError("glProgramUniform2iv only available with GLES 3.1+");
        const glProgramUniform3iv = if (api.hasCompat(.V3_1)) Bindings.glProgramUniform3iv else @compileError("glProgramUniform3iv only available with GLES 3.1+");
        const glProgramUniform4iv = if (api.hasCompat(.V3_1)) Bindings.glProgramUniform4iv else @compileError("glProgramUniform4iv only available with GLES 3.1+");
        const glProgramUniform1uiv = if (api.hasCompat(.V3_1)) Bindings.glProgramUniform1uiv else @compileError("glProgramUniform1uiv only available with GLES 3.1+");
        const glProgramUniform2uiv = if (api.hasCompat(.V3_1)) Bindings.glProgramUniform2uiv else @compileError("glProgramUniform2uiv only available with GLES 3.1+");
        const glProgramUniform3uiv = if (api.hasCompat(.V3_1)) Bindings.glProgramUniform3uiv else @compileError("glProgramUniform3uiv only available with GLES 3.1+");
        const glProgramUniform4uiv = if (api.hasCompat(.V3_1)) Bindings.glProgramUniform4uiv else @compileError("glProgramUniform4uiv only available with GLES 3.1+");
        const glProgramUniform1fv = if (api.hasCompat(.V3_1)) Bindings.glProgramUniform1fv else @compileError("glProgramUniform1fv only available with GLES 3.1+");
        const glProgramUniform2fv = if (api.hasCompat(.V3_1)) Bindings.glProgramUniform2fv else @compileError("glProgramUniform2fv only available with GLES 3.1+");
        const glProgramUniform3fv = if (api.hasCompat(.V3_1)) Bindings.glProgramUniform3fv else @compileError("glProgramUniform3fv only available with GLES 3.1+");
        const glProgramUniform4fv = if (api.hasCompat(.V3_1)) Bindings.glProgramUniform4fv else @compileError("glProgramUniform4fv only available with GLES 3.1+");
        const glProgramUniformMatrix2fv = if (api.hasCompat(.V3_1)) Bindings.glProgramUniformMatrix2fv else @compileError("glProgramUniformMatrix2fv only available with GLES 3.1+");
        const glProgramUniformMatrix3fv = if (api.hasCompat(.V3_1)) Bindings.glProgramUniformMatrix3fv else @compileError("glProgramUniformMatrix3fv only available with GLES 3.1+");
        const glProgramUniformMatrix4fv = if (api.hasCompat(.V3_1)) Bindings.glProgramUniformMatrix4fv else @compileError("glProgramUniformMatrix4fv only available with GLES 3.1+");
        const glProgramUniformMatrix2x3fv = if (api.hasCompat(.V3_1)) Bindings.glProgramUniformMatrix2x3fv else @compileError("glProgramUniformMatrix2x3fv only available with GLES 3.1+");
        const glProgramUniformMatrix3x2fv = if (api.hasCompat(.V3_1)) Bindings.glProgramUniformMatrix3x2fv else @compileError("glProgramUniformMatrix3x2fv only available with GLES 3.1+");
        const glProgramUniformMatrix2x4fv = if (api.hasCompat(.V3_1)) Bindings.glProgramUniformMatrix2x4fv else @compileError("glProgramUniformMatrix2x4fv only available with GLES 3.1+");
        const glProgramUniformMatrix4x2fv = if (api.hasCompat(.V3_1)) Bindings.glProgramUniformMatrix4x2fv else @compileError("glProgramUniformMatrix4x2fv only available with GLES 3.1+");
        const glProgramUniformMatrix3x4fv = if (api.hasCompat(.V3_1)) Bindings.glProgramUniformMatrix3x4fv else @compileError("glProgramUniformMatrix3x4fv only available with GLES 3.1+");
        const glProgramUniformMatrix4x3fv = if (api.hasCompat(.V3_1)) Bindings.glProgramUniformMatrix4x3fv else @compileError("glProgramUniformMatrix4x3fv only available with GLES 3.1+");
        const glValidateProgramPipeline = if (api.hasCompat(.V3_1)) Externs.glValidateProgramPipeline else @compileError("glValidateProgramPipeline only available with GLES 3.1+");
        const glGetProgramPipelineInfoLog = if (api.hasCompat(.V3_1)) Bindings.glGetProgramPipelineInfoLog else @compileError("glGetProgramPipelineInfoLog only available with GLES 3.1+");
        const glBindImageTexture = if (api.hasCompat(.V3_1)) Externs.glBindImageTexture else @compileError("glBindImageTexture only available with GLES 3.1+");
        const glGetBooleani_v = if (api.hasCompat(.V3_1)) Bindings.glGetBooleani_v else @compileError("glGetBooleani_v only available with GLES 3.1+");
        const glMemoryBarrier = if (api.hasCompat(.V3_1)) Externs.glMemoryBarrier else @compileError("glMemoryBarrier only available with GLES 3.1+");
        const glMemoryBarrierByRegion = if (api.hasCompat(.V3_1)) Externs.glMemoryBarrierByRegion else @compileError("glMemoryBarrierByRegion only available with GLES 3.1+");
        const glTexStorage2DMultisample = if (api.hasCompat(.V3_1)) Externs.glTexStorage2DMultisample else @compileError("glTexStorage2DMultisample only available with GLES 3.1+");
        const glGetMultisamplefv = if (api.hasCompat(.V3_1)) Bindings.glGetMultisamplefv else @compileError("glGetMultisamplefv only available with GLES 3.1+");
        const glSampleMaski = if (api.hasCompat(.V3_1)) Externs.glSampleMaski else @compileError("glSampleMaski only available with GLES 3.1+");
        const glGetTexLevelParameteriv = if (api.hasCompat(.V3_1)) Bindings.glGetTexLevelParameteriv else @compileError("glGetTexLevelParameteriv only available with GLES 3.1+");
        const glGetTexLevelParameterfv = if (api.hasCompat(.V3_1)) Bindings.glGetTexLevelParameterfv else @compileError("glGetTexLevelParameterfv only available with GLES 3.1+");
        const glBindVertexBuffer = if (api.hasCompat(.V3_1)) Externs.glBindVertexBuffer else @compileError("glBindVertexBuffer only available with GLES 3.1+");
        const glVertexAttribFormat = if (api.hasCompat(.V3_1)) Externs.glVertexAttribFormat else @compileError("glVertexAttribFormat only available with GLES 3.1+");
        const glVertexAttribIFormat = if (api.hasCompat(.V3_1)) Externs.glVertexAttribIFormat else @compileError("glVertexAttribIFormat only available with GLES 3.1+");
        const glVertexAttribBinding = if (api.hasCompat(.V3_1)) Externs.glVertexAttribBinding else @compileError("glVertexAttribBinding only available with GLES 3.1+");
        const glVertexBindingDivisor = if (api.hasCompat(.V3_1)) Externs.glVertexBindingDivisor else @compileError("glVertexBindingDivisor only available with GLES 3.1+");
    };
}
