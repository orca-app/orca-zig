const std = @import("std");
const oc = @import("root"); // @Todo expose "orca" import instead
const canvas = oc.graphics.canvas;

var renderer: canvas.Renderer = undefined;
var surface: canvas.Surface = undefined;
var context: canvas.Context = undefined;
var font: canvas.Font = undefined;
var frameSize: oc.math.Vec2 = .{ .x = 100, .y = 100 };
var lastSeconds: f64 = 0;

pub fn onInit() void {
    oc.app.windowSetTitle(oc.toStr8("clock"));
    oc.app.windowSetSize(.{ .x = 400, .y = 400 });

    renderer = canvas.Renderer.create();
    surface = canvas.surfaceCreate(renderer);
    context = canvas.Context.create();

    const ranges = [5]oc.unicode_range{
        .{ .firstCodePoint = 0x0000, .count = 127 }, // BASIC_LATIN
        .{ .firstCodePoint = 0x0080, .count = 127 }, // C1_CONTROLS_AND_LATIN_1_SUPPLEMENT
        .{ .firstCodePoint = 0x0100, .count = 127 }, // LATIN_EXTENDED_A
        .{ .firstCodePoint = 0x0180, .count = 207 }, // LATIN_EXTENDED_B
        .{ .firstCodePoint = 0xfff0, .count = 15 }, //  SPECIALS
    };

    font = canvas.Font.createFromPath(oc.toStr8("/segoeui.ttf"), ranges.len, @constCast(&ranges));
}

pub fn onResize(width: u32, height: u32) void {
    frameSize.x = @floatFromInt(width);
    frameSize.y = @floatFromInt(height);
}

pub fn onFrameRefresh() void {
    _ = context.select();
    canvas.setColorRgba(0.05, 0.05, 0.05, 1);
    canvas.clear();

    const timestampSecs: f64 = oc.clock.time(.date);
    const secs: f64 = @mod(timestampSecs, 60);
    const minutes: f64 = @mod(timestampSecs, 60 * 60) / 60;
    const hours: f64 = @mod(timestampSecs, 60 * 60 * 24) / (60 * 60);
    const hoursAs12Format: f64 = @mod(hours, 12.0);

    if (lastSeconds != @floor(secs)) {
        lastSeconds = @floor(secs);
        oc.log.info(
            "current time: {d:.0}:{d:.0}:{d:.0}",
            .{ @floor(hours), @floor(minutes), @floor(secs) },
            @src(),
        );
    }

    const secondsRotation: f32 = @floatCast((std.math.pi * 2) * (secs / 60.0) - (std.math.pi / 2.0));
    const minutesRotation: f32 = @floatCast((std.math.pi * 2) * (minutes / 60.0) - (std.math.pi / 2.0));
    const hoursRotation: f32 = @floatCast((std.math.pi * 2) * (hoursAs12Format / 12.0) - (std.math.pi / 2.0));

    const centerX: f32 = frameSize.x / 2;
    const centerY: f32 = frameSize.y / 2;
    const clockRadius: f32 = @min(frameSize.x, frameSize.y) * 0.5 * 0.85;

    const DEFAULT_CLOCK_RADIUS: f32 = 260;
    const uiScale: f32 = clockRadius / DEFAULT_CLOCK_RADIUS;

    const fontSize: f32 = 26 * uiScale;
    canvas.setFont(font);
    canvas.setFontSize(fontSize);

    // clock backing
    canvas.setColorRgba(1, 1, 1, 1);
    canvas.circleFill(centerX, centerY, clockRadius);

    // clock face
    for (
        comptime [_]oc.strings.Str8{
            oc.toStr8("12"),
            oc.toStr8("1"),
            oc.toStr8("2"),
            oc.toStr8("3"),
            oc.toStr8("4"),
            oc.toStr8("5"),
            oc.toStr8("6"),
            oc.toStr8("7"),
            oc.toStr8("8"),
            oc.toStr8("9"),
            oc.toStr8("10"),
            oc.toStr8("11"),
        },
        0..,
    ) |num_txt, i| {
        const textRect = font.textMetrics(fontSize, num_txt).ink;

        const j: f32 = @floatFromInt(i);
        const angle: f32 = j * ((std.math.pi * 2) / 12.0) - (std.math.pi / 2.0);
        const transform = mat_transform(
            centerX - (textRect.w / 2) - textRect.x,
            centerY - (textRect.h / 2) - textRect.y,
            angle,
        );

        const pos = transform.mulVec(.{ .x = clockRadius * 0.8, .y = 0 });

        canvas.setColorSrgba(0.2, 0.2, 0.2, 1);
        canvas.textFill(pos.x, pos.y, num_txt);
    }

    // hours hand
    canvas.matrixMultiplyPush(mat_transform(centerX, centerY, hoursRotation));
    {
        canvas.setColorSrgba(0.2, 0.2, 0.2, 1);
        canvas.roundedRectangleFill(0, -7.5 * uiScale, clockRadius * 0.5, 15 * uiScale, 5 * uiScale);
    }
    canvas.matrixPop();

    // minutes hand
    canvas.matrixMultiplyPush(mat_transform(centerX, centerY, minutesRotation));
    {
        canvas.setColorSrgba(0.2, 0.2, 0.2, 1);
        canvas.roundedRectangleFill(0, -5 * uiScale, clockRadius * 0.7, 10 * uiScale, 5 * uiScale);
    }
    canvas.matrixPop();

    // seconds hand
    canvas.matrixMultiplyPush(mat_transform(centerX, centerY, secondsRotation));
    {
        canvas.setColorSrgba(1, 0.2, 0.2, 1);
        canvas.roundedRectangleFill(0, -2.5 * uiScale, clockRadius * 0.8, 5 * uiScale, 5 * uiScale);
    }
    canvas.matrixPop();

    canvas.setColorSrgba(0.2, 0.2, 0.2, 1);
    canvas.circleFill(centerX, centerY, 10 * uiScale);

    canvas.render(renderer, context, surface);
    canvas.present(renderer, surface);
}

fn mat_transform(x: f32, y: f32, radians: f32) oc.math.Mat2x3 {
    const rotation = oc.math.Mat2x3.rotation(radians);
    const translation = oc.math.Mat2x3.translation(x, y);
    return translation.mulMat(rotation);
}
