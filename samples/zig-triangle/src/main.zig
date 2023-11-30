//////////////////////////////////////////////////////////////////////////
//
//  Orca
//  Copyright 2023 Martin Fouilleul and the Orca project contributors
//  See LICENSE.txt for licensing information
//
//////////////////////////////////////////////////////////////////////////

const std = @import("std");
const math = std.math;

const oc = @import("root");
const gles = oc.gles.getApi(.V3_0);

const Vec2 = oc.Vec2;

var frame_size: Vec2 = .{ .x = 0, .y = 0 };
var surface: oc.Surface = undefined;
var program: gles.GLuint = 0;
var alpha: f32 = 0;

const vshader_source: [:0]const u8 =
    \\attribute vec4 vPosition;
    \\uniform mat4 transform;
    \\void main()
    \\{
    \\   gl_Position = transform*vPosition;
    \\}
;

const fshader_source: [:0]const u8 =
    \\precision mediump float;
    \\void main()
    \\{
    \\    gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);
    \\}
;

fn compileShader(shader: gles.GLuint, source: [:0]const u8) void {
    var sources = [_][:0]const u8{source};
    gles.glShaderSource(shader, &sources);
    gles.glCompileShader(shader);

    if (gles.glGetError()) |err| {
        oc.log.info("gl error compiling shader: {}", .{err}, @src());
    }
}

pub fn onInit() void {
    oc.windowSetTitle("triangle");

    surface = oc.Surface.gles();
    surface.select();

    const extensions: []const u8 = gles.glGetString(gles.GL_EXTENSIONS);
    oc.log.info("GLES extensions: {s}\n", .{extensions}, @src());

    var extensionCount = [_]gles.GLint{0};
    gles.glGetIntegerv(gles.GL_NUM_EXTENSIONS, &extensionCount);

    for (0..@intCast(extensionCount[0])) |i| {
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

    // zig fmt: off
    const vertices = [_]f32{ 
        -0.866 / 2.0, -0.5 / 2.0, 0.0, 
         0.866 / 2.0, -0.5 / 2.0, 0.0, 
                 0.0,        0.5, 0.0 };
    // zig fmt: on

    var buffer: [1]gles.GLuint = undefined;
    gles.glGenBuffers(&buffer);
    gles.glBindBuffer(gles.GL_ARRAY_BUFFER, buffer[0]);
    gles.glBufferData(gles.GL_ARRAY_BUFFER, std.mem.sliceAsBytes(&vertices), gles.GL_STATIC_DRAW);

    gles.glVertexAttribPointer(0, 3, gles.GL_FLOAT, gles.GL_FALSE, 0, null);
    gles.glEnableVertexAttribArray(0);
}

pub fn onResize(width: u32, height: u32) void {
    oc.log.info("frame resize {}, {}", .{ width, height }, @src());
    frame_size.x = @floatFromInt(width);
    frame_size.y = @floatFromInt(height);
}

pub fn onFrameRefresh() void {
    const aspect: f32 = frame_size.x / frame_size.y;

    surface.select();

    gles.glClearColor(0, 1, 1, 1);
    gles.glClear(gles.GL_COLOR_BUFFER_BIT);

    const scaling: Vec2 = surface.contentsScaling();

    gles.glViewport(0, 0, @intFromFloat(frame_size.x * scaling.x), @intFromFloat(frame_size.y * scaling.y));

    gles.glUseProgram(program);

    const matrix = [_]f32{ math.cos(alpha) / aspect, math.sin(alpha), 0, 0, -math.sin(alpha) / aspect, math.cos(alpha), 0, 0, 0, 0, 1, 0, 0, 0, 0, 1 };
    alpha += 2 * math.pi / 120.0;

    gles.glUniformMatrix4fv(0, 1, false, &matrix);

    gles.glDrawArrays(gles.GL_TRIANGLES, 0, 3);

    surface.present();
}
