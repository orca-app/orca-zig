//////////////////////////////////////////////////////////////////////////
//
//  Orca
//  Copyright 2023 Martin Fouilleul and the Orca project contributors
//  See LICENSE.txt for licensing information
//
//////////////////////////////////////////////////////////////////////////

const std = @import("std");
const math = std.math;

const oc = @import("orca");
const gl = oc.graphics.gles;

var frame_size: oc.math.Vec2 = .{ .x = 100, .y = 100 };
var surface: oc.graphics.canvas.Surface = undefined;
var program: gl.uint = 0;

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

fn compileShader(shader: gl.uint, source: [:0]const u8) void {
    var sources = [_][*:0]const u8{source};
    gl.ShaderSource(shader, 1, &sources, null);
    gl.CompileShader(shader);

    const err = gl.GetError();
    if (err != gl.NO_ERROR) {
        oc.log.err("gl error compiling shader: 0x{X}\n{s}", .{ err, source }, @src());
        var buf: [1024]u8 = undefined;
        var len: gl.sizei = undefined;
        gl.GetShaderInfoLog(shader, buf.len, &len, &buf);
        oc.log.warn("shader info: {s}", .{buf[0..@intCast(len)]}, @src());
    }
}

pub fn onInit() void {
    oc.app.windowSetTitle(oc.toStr8("triangle"));

    surface = oc.graphics.glesSurfaceCreate();
    oc.graphics.glesSurfaceMakeCurrent(surface);

    {
        var major: gl.int = undefined;
        var minor: gl.int = undefined;
        gl.GetIntegerv(gl.MAJOR_VERSION, @ptrCast(&major));
        gl.GetIntegerv(gl.MINOR_VERSION, @ptrCast(&minor));
        oc.log.info("GLES version: {d}.{d}", .{ major, minor }, @src());
    }

    var extensionCount: gl.int = 0;
    gl.GetIntegerv(gl.NUM_EXTENSIONS, @ptrCast(&extensionCount));
    oc.log.info("GLES extensions: {d}", .{extensionCount}, @src());

    // @Bug figure out why glGetString(i) is failing with GL_INVALID_ENUM.
    // for (0..@intCast(extensionCount)) |i| {
    //     if (gl.GetStringi(gl.EXTENSIONS, i)) |extension|
    //         oc.log.info("Extension {d}: {s}", .{ i, extension }, @src())
    //     else
    //         oc.log.err("Extension {d}: failed (0x{X})", .{ i, gl.GetError() }, @src());
    // }

    const vshader = gl.CreateShader(gl.VERTEX_SHADER);
    const fshader = gl.CreateShader(gl.FRAGMENT_SHADER);
    program = gl.CreateProgram();

    compileShader(vshader, vshader_source);
    compileShader(fshader, fshader_source);

    gl.AttachShader(program, vshader);
    gl.AttachShader(program, fshader);
    gl.LinkProgram(program);
    gl.UseProgram(program);

    const vertices = [_]f32{
        -0.866 / 2.0, -0.5 / 2.0, 0.0,
        0.866 / 2.0,  -0.5 / 2.0, 0.0,
        0.0,          0.5,        0.0,
    };

    var buffer: [1]gl.uint = undefined;
    gl.GenBuffers(1, &buffer);
    gl.BindBuffer(gl.ARRAY_BUFFER, buffer[0]);
    const data = std.mem.sliceAsBytes(&vertices);
    gl.BufferData(gl.ARRAY_BUFFER, @intCast(data.len), @ptrCast(data), gl.STATIC_DRAW);

    gl.VertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, 0, 0);
    gl.EnableVertexAttribArray(0);
}

pub fn onResize(width: u32, height: u32) void {
    oc.log.info("frame resize {}, {}", .{ width, height }, @src());
    frame_size.x = @floatFromInt(width);
    frame_size.y = @floatFromInt(height);
}

pub fn onFrameRefresh() void {
    const aspect: f32 = frame_size.x / frame_size.y;

    oc.graphics.glesSurfaceMakeCurrent(surface);

    gl.ClearColor(0, 1, 1, 1);
    gl.Clear(gl.COLOR_BUFFER_BIT);

    const S = struct {
        var alpha: f32 = 0;
    };

    const scaling: oc.math.Vec2 = surface.contentsScaling();

    gl.Viewport(
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

    gl.UniformMatrix4fv(0, 1, @intFromBool(false), &matrix);

    gl.DrawArrays(gl.TRIANGLES, 0, 3);

    oc.graphics.glesSurfaceSwapBuffers(surface);
}
