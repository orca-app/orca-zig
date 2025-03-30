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
const gles = oc.graphics.gles.getApi(.V3_0);

var frame_size: oc.math.Vec2 = .{ .x = 100, .y = 100 };
var surface: oc.graphics.canvas.Surface = undefined;
var program: gles.GLuint = 0;

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
        oc.log.err("gl error compiling shader: 0x{X}\n{s}", .{ err, source }, @src());
        var buf: [1024]u8 = undefined;
        oc.log.warn("shader info: {s}", .{gles.glGetShaderInfoLog(shader, &buf)}, @src());
    }
}

pub fn onInit() void {
    oc.windowSetTitle(oc.toStr8("triangle"));

    surface = oc.graphics.glesSurfaceCreate();
    oc.graphics.glesSurfaceMakeCurrent(surface);

    {
        var major: gles.GLint = undefined;
        var minor: gles.GLint = undefined;
        gles.glGetIntegerv(gles.GL_MAJOR_VERSION, @ptrCast(&major));
        gles.glGetIntegerv(gles.GL_MINOR_VERSION, @ptrCast(&minor));
        oc.log.info("GLES version: {d}.{d}", .{ major, minor }, @src());
    }

    // @Bug figure out why glGetString(i) is failing with GL_INVALID_ENUM.
    // if (gles.glGetString(gles.GL_EXTENSIONS)) |extensions|
    //     oc.log.info("GLES extensions: {s}", .{extensions}, @src())
    // else
    //     oc.log.err("glError: 0x{X}", .{gles.glGetError().?}, @src());

    // var extensionCount = [_]gles.GLint{0};
    // gles.glGetIntegerv(gles.GL_NUM_EXTENSIONS, &extensionCount);

    // for (0..@intCast(extensionCount[0])) |i| {
    //     if (gles.glGetStringi(gles.GL_EXTENSIONS, i)) |extension|
    //         oc.log.info("GLES extension {d}: {s}", .{ i, extension }, @src())
    //     else
    //         oc.log.err("glError: 0x{X}", .{gles.glGetError().?}, @src());
    // }

    const vshader = gles.glCreateShader(gles.GL_VERTEX_SHADER);
    const fshader = gles.glCreateShader(gles.GL_FRAGMENT_SHADER);
    program = gles.glCreateProgram();

    compileShader(vshader, vshader_source);
    compileShader(fshader, fshader_source);

    gles.glAttachShader(program, vshader);
    gles.glAttachShader(program, fshader);
    gles.glLinkProgram(program);
    gles.glUseProgram(program);

    const vertices = [_]f32{
        -0.866 / 2.0, -0.5 / 2.0, 0.0,
        0.866 / 2.0,  -0.5 / 2.0, 0.0,
        0.0,          0.5,        0.0,
    };

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

    oc.graphics.glesSurfaceMakeCurrent(surface);

    gles.glClearColor(0, 1, 1, 1);
    gles.glClear(gles.GL_COLOR_BUFFER_BIT);

    const S = struct {
        var alpha: f32 = 0;
    };

    const scaling: oc.math.Vec2 = surface.contentsScaling();

    gles.glViewport(
        0,
        0,
        @intFromFloat(frame_size.x * scaling.x),
        @intFromFloat(frame_size.y * scaling.y),
    );

    const matrix = [_]f32{
        math.cos(S.alpha) / aspect,  math.sin(S.alpha), 0, 0,
        -math.sin(S.alpha) / aspect, math.cos(S.alpha), 0, 0,
        0,                           0,                 1, 0,
        0,                           0,                 0, 1,
    };
    S.alpha += 2 * math.pi / 120.0;

    gles.glUniformMatrix4fv(0, 1, false, &matrix);

    gles.glDrawArrays(gles.GL_TRIANGLES, 0, 3);

    oc.graphics.glesSurfaceSwapBuffers(surface);
}
