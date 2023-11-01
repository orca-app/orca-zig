//////////////////////////////////////////////////////////////////////////
//
//  Orca
//  Copyright 2023 Martin Fouilleul and the Orca project contributors
//  See LICENSE.txt for licensing information
//
//////////////////////////////////////////////////////////////////////////

const std = @import("std");
const oc = @import("root");
const gles = oc.gles.v3_1;

const lerp = std.math.lerp;

const Vec2 = oc.Vec2;
const Mat2x3 = oc.Mat2x3;
const Str8 = oc.Str8;

var frame_size: Vec2 = .{ .x = 0, .y = 0 };
var surface: oc.Surface = undefined;
var program: gles.GLuint = 0;

var allocator = std.heap.wasm_allocator;

const vshader_source: []const u8 =
    \\attribute vec4 vPosition;\n
    \\uniform mat4 transform;\n
    \\void main()\n
    \\{\n
    \\   gl_Position = transform*vPosition;\n
    \\}\n
;

const fshader_source: []const u8 =
    \\precision mediump float;\n
    \\void main()\n
    \\{\n
    \\    gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);\n
    \\}\n"
;

fn compileShader(shader: gles.GLuint, source: []const u8) void {
    gles.glShaderSource(shader, 1, source.ptr, 0);
    gles.glCompileShader(shader);

    const err = gles.glGetError();
    if (err) {
        oc.log.info("gl error: {}", .{err}, @src());
    }
}

pub fn onInit() void {
    oc.windowSetTitle("triangle");

    surface = oc.Surface.gles();
    surface.select();

    const extensions: [*]u8 = gles.glGetString(gles.GL_EXTENSIONS);
    oc.log.info("GLES extensions: {s}\n", .{extensions}, @src());

    var extensionCount: gles.GLint = 0;
    gles.glGetIntegerv(gles.GL_NUM_EXTENSIONS, &extensionCount);

    for (0..extensionCount) |i| {
        const extension: []const u8 = gles.glGetStringi(gles.GL_EXTENSIONS, i);
        oc.log.info("GLES extension {}: {s}\n", .{ i, extension }, @src());
    }

    const vshader = gles.glCreateShader(gles.GL_VERTEX_SHADER);
    const fshader = gles.glCreateShader(gles.GL_FRAGMENT_SHADER);
    program = gles.glCreateProgram();

    compileShader(vshader, vshader_source);
    compileShader(fshader, fshader_source);

    gles.glAttachShader(program, vshader);
    gles.glAttachShader(program, fshader);
    gles.glLinkProgram(program);
    gles.glUseProgram(program);

    //zigfmt off
    const vertices = [_]f32{ -0.866 / 2.0, -0.5 / 2.0, 0.0, 
                              0.866 / 2.0, -0.5 / 2.0, 0.0, 
                                      0.0,        0.5, 0.0 };
    //zigfmt on

    var buffer: gles.GLuint = undefined;
    gles.glGenBuffers(1, &buffer);
    gles.glBindBuffer(gles.GL_ARRAY_BUFFER, buffer);
    gles.glBufferData(gles.GL_ARRAY_BUFFER, 9 * @sizeOf(gles.GLfloat), (&vertices).ptr, gles.GL_STATIC_DRAW);

    gles.glVertexAttribPointer(0, 3, gles.GL_FLOAT, gles.GL_FALSE, 0, 0);
    gles.glEnableVertexAttribArray(0);
}
