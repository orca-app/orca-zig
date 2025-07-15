const std = @import("std");
const oc = @import("orca");
const canvas = oc.graphics.canvas;

pub const panic = oc.panic;
comptime {
    oc.exportEventHandlers();
}

const Vec2 = oc.math.Vec2;
const Mat2x3 = oc.math.Mat2x3;
const Str8 = oc.strings.Str8;

var allocator = std.heap.wasm_allocator;

var surface: canvas.Surface = undefined;
var context: canvas.Context = undefined;
var renderer: canvas.Renderer = undefined;

var font: canvas.Font = undefined;
var orca_image: canvas.Image = undefined;
var gradient_image: canvas.Image = undefined;

var counter: u32 = 0;
var last_seconds: f64 = 0;
var frame_size: Vec2 = .{};

var rotation_demo: f32 = 0;

pub fn onInit() !void {
    oc.app.windowSetTitle(oc.toStr8("general sample"));
    oc.app.windowSetSize(.{ .x = 480, .y = 640 });

    renderer = canvas.Renderer.create();
    surface = canvas.surfaceCreate(renderer);
    context = canvas.Context.create();

    const surface_scaling = surface.contentsScaling();
    oc.log.info("surface scaling: {d:.2} {d:.2}", .{ surface_scaling.x, surface_scaling.y }, @src());

    oc.assert(canvas.Context.nil().isNil(), "nil context should be nil", .{}, @src());
    oc.assert(!context.isNil(), "created context should not be nil", .{}, @src());
    oc.assert(canvas.Renderer.nil().isNil(), "nil renderer should be nil", .{}, @src());
    oc.assert(!renderer.isNil(), "created renderer should not be nil", .{}, @src());

    const ranges = [5]oc.utf8.Range{
        .{ .firstCodePoint = 0x0000, .count = 127 }, // BASIC_LATIN
        .{ .firstCodePoint = 0x0080, .count = 127 }, // C1_CONTROLS_AND_LATIN_1_SUPPLEMENT
        .{ .firstCodePoint = 0x0100, .count = 127 }, // LATIN_EXTENDED_A
        .{ .firstCodePoint = 0x0180, .count = 207 }, // LATIN_EXTENDED_B
        .{ .firstCodePoint = 0xfff0, .count = 15 }, //  SPECIALS
    };
    font = canvas.Font.createFromPath(oc.toStr8("/zig.ttf"), ranges.len, @constCast(&ranges));
    oc.assert(canvas.Font.nil().isNil(), "nil font should be nil", .{}, @src());
    oc.assert(!font.isNil(), "created font should not be nil", .{}, @src());

    orca_image = canvas.Image.createFromPath(renderer, oc.toStr8("/orca_jumping.jpg"), false);
    oc.assert(canvas.Image.nil().isNil(), "nil image should be nil", .{}, @src());
    oc.assert(!orca_image.isNil(), "created image should not be nil", .{}, @src());

    // generate a gradient and upload it to an image
    {
        const width = 256;
        const height = 128;

        const tl: canvas.Color = .{ .r = 70.0 / 255.0, .g = 13.0 / 255.0, .b = 108.0 / 255.0 };
        const bl: canvas.Color = .{ .r = 251.0 / 255.0, .g = 167.0 / 255.0, .b = 87.0 / 255.0 };
        const tr: canvas.Color = .{ .r = 48.0 / 255.0, .g = 164.0 / 255.0, .b = 219.0 / 255.0 };
        const br: canvas.Color = .{ .r = 151.0 / 255.0, .g = 222.0 / 255.0, .b = 150.0 / 255.0 };

        var pixels: [width * height]u32 = undefined;
        for (0..height) |y| {
            for (0..width) |x| {
                const h: f32 = @floatFromInt(height - 1);
                const w: f32 = @floatFromInt(width - 1);
                const y_norm: f32 = @as(f32, @floatFromInt(y)) / h;
                const x_norm: f32 = @as(f32, @floatFromInt(x)) / w;

                const tl_weight = (1 - x_norm) * (1 - y_norm);
                const bl_weight = (1 - x_norm) * y_norm;
                const tr_weight = x_norm * (1 - y_norm);
                const br_weight = x_norm * y_norm;

                const color: canvas.Color = .{
                    .r = tl_weight * tl.r + bl_weight * bl.r + tr_weight * tr.r + br_weight * br.r,
                    .g = tl_weight * tl.g + bl_weight * bl.g + tr_weight * tr.g + br_weight * br.g,
                    .b = tl_weight * tl.b + bl_weight * bl.b + tr_weight * tr.b + br_weight * br.b,
                };
                pixels[y * width + x] = toRgba8(color);
            }
        }

        gradient_image = canvas.Image.create(renderer, width, height);
        gradient_image.uploadRegionRgba8(.{ .w = width, .h = height }, @ptrCast(&pixels));

        var tmp_image = canvas.Image.create(renderer, width, height);
        tmp_image.uploadRegionRgba8(.{ .w = width, .h = height }, @ptrCast(&pixels));
        tmp_image.destroy();
        tmp_image = canvas.Image.nil();
    }

    try testFileApis();
}

fn toRgba8(c: canvas.Color) u32 {
    var res: u32 = 0;
    res |= @as(u32, @intFromFloat(c.r * 255.0));
    res |= @as(u32, @intFromFloat(c.g * 255.0)) << 8;
    res |= @as(u32, @intFromFloat(c.b * 255.0)) << 16;
    res |= @as(u32, @intFromFloat(c.a * 255.0)) << 24;
    return res;
}

pub fn onResize(width: u32, height: u32) void {
    frame_size = .{ .x = @floatFromInt(width), .y = @floatFromInt(height) };
    const surface_size = surface.getSize();
    oc.log.info(
        "frame resize: {d:.2}, {d:.2}, surface size: {d:.2} {d:.2}",
        .{ frame_size.x, frame_size.y, surface_size.x, surface_size.y },
        @src(),
    );
}

pub fn onMouseDown(button: oc.app.MouseButton) void {
    oc.log.info("mouse down! {}", .{button}, @src());
}

pub fn onMouseUp(button: oc.app.MouseButton) void {
    oc.log.info("mouse up! {}", .{button}, @src());
}

pub fn onMouseWheel(dx: f32, dy: f32) void {
    oc.log.info("mouse wheel! dx: {d:.2}, dy: {d:.2}", .{ dx, dy }, @src());
}

pub fn onKeyDown(scan: oc.app.ScanCode, key: oc.app.KeyCode) void {
    oc.log.info("key down: {} {}", .{ scan, key }, @src());
}

pub fn onKeyUp(scan: oc.app.ScanCode, key: oc.app.KeyCode) void {
    oc.log.info("key up: {} {}", .{ scan, key }, @src());

    switch (key) {
        .escape => oc.app.requestQuit(),
        .b => oc.abort("aborting", .{}, @src()),
        .a => oc.assert(false, "Thank you for pressing the Stalemate Resolution Button", .{}, @src()),
        .w => oc.log.warn("logging a test warning", .{}, @src()),
        .e => oc.log.err("logging a test error", .{}, @src()),
        else => {},
    }
}

pub fn onFrameRefresh() !void {
    counter += 1;

    const secs: f64 = oc.clock.time(.date);

    if (last_seconds != @floor(secs)) {
        last_seconds = @floor(secs);
        oc.log.info("seconds since Jan 1, 1970: {d:.0}", .{secs}, @src());
    }

    _ = context.select();

    {
        const c1: canvas.Color = .{ .r = 0.05, .g = 0.05, .b = 0.05, .a = 1.0 };
        const c2: canvas.Color = .{ .r = 0.05, .g = 0.05, .b = 0.05, .a = 1.0 };
        canvas.setColorRgba(c1.r, c1.g, c1.b, c1.a);
        oc.assert(std.meta.eql(canvas.getColor(), c1), "color should be what we set", .{}, @src());
        canvas.setColor(c2);
        oc.assert(std.meta.eql(canvas.getColor(), c2), "color should be what we set", .{}, @src());
        canvas.clear();

        canvas.setTolerance(1);
        oc.assert(canvas.getTolerance() == 1, "tolerance should be 1", .{}, @src());
        canvas.setJoint(.bevel);
        oc.assert(canvas.getJoint() == .bevel, "joint should be what we set", .{}, @src());
        canvas.setCap(.square);
        oc.assert(canvas.getCap() == .square, "cap should be what we set", .{}, @src());
    }

    {
        const translation: Mat2x3 = .{
            .m = [_]f32{
                1, 0, 50,
                0, 1, 50,
            },
        };
        canvas.matrixPush(translation);
        defer canvas.matrixPop();

        oc.assert(std.meta.eql(canvas.matrixTop(), translation), "top of matrix stack should be what we pushed", .{}, @src());
        canvas.setWidth(1);
        oc.assert(canvas.getWidth() == 1, "width should be 1", .{}, @src());
        canvas.rectangleFill(50, 0, 10, 10);
        canvas.rectangleStroke(70, 0, 10, 10);
        canvas.roundedRectangleFill(90, 0, 10, 10, 3);
        canvas.roundedRectangleStroke(110, 0, 10, 10, 3);

        const green: canvas.Color = .{ .r = 0.05, .g = 1, .b = 0.05, .a = 1 };
        canvas.setColor(green);
        oc.assert(std.meta.eql(canvas.getColor(), green), "color should be green", .{}, @src());

        canvas.ellipseFill(140, 5, 10, 5);
        canvas.ellipseStroke(170, 5, 10, 5);
        canvas.circleFill(195, 5, 5);
        canvas.circleStroke(215, 5, 5);

        canvas.arc(235, 5, 5, std.math.pi, 0);
        canvas.stroke();

        canvas.arc(260, 5, 5, std.math.pi, 0);
        canvas.fill();

        canvas.moveTo(0, 0);
        oc.assert(std.meta.eql(canvas.getPosition(), .{}), "pos should be zero after moving there", .{}, @src());
    }

    {
        rotation_demo += 0.03;

        const rot = Mat2x3.rotation(rotation_demo);
        const trans = Mat2x3.translation(335, 55);
        canvas.matrixPush(trans.mulMat(rot));
        defer canvas.matrixPop();

        canvas.rectangleFill(-5, -5, 10, 10);
    }

    {
        var scratch_scope = oc.mem.scratchBegin();
        defer scratch_scope.end();

        const scratch: *oc.mem.Arena = scratch_scope.arena;

        const str1 = oc.toStr8(">> Hello from Zig! <<"); // @Incomplete collate with zig std

        var str2_list: oc.strings.Str8List = .empty;
        str2_list.push(scratch, oc.toStr8("All"));
        try str2_list.pushf(scratch, "{s}", .{"your"});
        str2_list.push(scratch, oc.toStr8("base!!"));

        // @Incomplete oc.assert(str2_list.contains("All"), "str2_list should have the string we just pushed", .{}, @src());

        {
            const elt_first = str2_list.list.first;
            const elt_last = str2_list.list.last;
            oc.assert(elt_first != null, "list checks", .{}, @src());
            oc.assert(elt_last != null, "list checks", .{}, @src());
            oc.assert(elt_first != elt_last, "list checks", .{}, @src());
            oc.assert(elt_first.?.next != null, "list checks", .{}, @src());
            oc.assert(elt_first.?.prev == null, "list checks", .{}, @src());
            oc.assert(elt_last.?.next == null, "list checks", .{}, @src());
            oc.assert(elt_last.?.prev != null, "list checks", .{}, @src());
            oc.assert(elt_first.?.next != elt_last, "list checks", .{}, @src());
            oc.assert(elt_last.?.prev != elt_first, "list checks", .{}, @src());
        }

        const str2: Str8 = oc.strings.str8ListCollate(
            scratch,
            str2_list,
            oc.toStr8("<< "),
            oc.toStr8("-"),
            oc.toStr8(" >>"),
        );

        const font_size = 18;
        const text_metrics = font.textMetrics(font_size, str1);
        const text_rect = text_metrics.ink;

        const center_x = frame_size.x / 2;
        const text_begin_x = center_x - text_rect.w / 2;

        canvas.matrixPush(Mat2x3.translation(text_begin_x, 100));
        defer canvas.matrixPop();

        canvas.setColorRgba(1.0, 0.05, 0.05, 1.0);
        canvas.setFont(font);
        canvas.setFontSize(font_size);
        canvas.moveTo(0, 0);
        canvas.textOutlines(str1);
        canvas.moveTo(0, 35);
        canvas.textOutlines(str2);
        canvas.fill();
    }

    {
        var scratch_scope = oc.mem.scratchBegin();
        defer scratch_scope.end();

        const scratch = scratch_scope.arena.allocator();

        var strings_array = std.ArrayList([]const u8).init(scratch);
        defer strings_array.deinit();
        try strings_array.append("This ");
        try strings_array.append("is");
        try strings_array.append(" |a");
        try strings_array.append("one-word string that ");
        try strings_array.append(" |  has");
        try strings_array.append(" no ");
        try strings_array.append("    spaces i");
        try strings_array.append("n it");

        var single_string: std.ArrayListUnmanaged(u8) = .empty;
        for (strings_array.items) |str| {
            try single_string.appendSlice(scratch, str);
        }

        const separators = [_]u8{ ' ', '|', '-' };
        const collated: Str8 = blk: {
            var size: usize = 0;
            var iter = std.mem.tokenizeAny(u8, single_string.items, &separators);
            while (iter.next()) |tok| {
                size += tok.len;
            }

            var array: std.ArrayListUnmanaged(u8) = try .initCapacity(scratch, size);
            iter.reset();

            while (iter.next()) |tok| {
                array.appendSliceAssumeCapacity(tok);
            }

            break :blk Str8.fromSlice(array.items);
        };

        canvas.setFontSize(12);
        canvas.moveTo(0, 170);
        canvas.textOutlines(collated);
        canvas.fill();
    }

    {
        const orca_size = orca_image.size();

        {
            const trans = Mat2x3.translation(0, 200);
            // const scale = Mat2x3.scaleUniform(0.25); // @Api a scale operator should really be included
            const scale: Mat2x3 = .{ .m = .{
                0.25, 0,    0,
                0,    0.25, 0,
            } };
            canvas.matrixPush(trans.mulMat(scale));
            defer canvas.matrixPop();

            canvas.imageDraw(orca_image, .{ .w = orca_size.x, .h = orca_size.y });

            var half_size = orca_size;
            half_size.x /= 2;

            canvas.imageDrawRegion(
                orca_image,
                .{ .w = half_size.x, .h = half_size.y },
                .{ .x = orca_size.x + 10, .w = half_size.x, .h = half_size.y },
            );
        }

        {
            const x_offset = orca_size.x * 0.25 + orca_size.x * 0.25 * 0.5 + 5;
            const gradient_size = gradient_image.size();

            const trans = Mat2x3.translation(x_offset, 200);
            // const scale = Mat2x3.scaleUniform((orca_size.y * 0.25) / gradient_size.y); // @Api see above
            const scale_val = (orca_size.y * 0.25) / gradient_size.y;
            const scale: Mat2x3 = .{ .m = .{
                scale_val, 0,         0,
                0,         scale_val, 0,
            } };
            canvas.matrixPush(trans.mulMat(scale));
            defer canvas.matrixPop();

            canvas.imageDraw(gradient_image, .{ .w = gradient_size.x, .h = gradient_size.y });
        }
    }

    canvas.render(renderer, context, surface);
    canvas.present(renderer, surface);
}

pub fn onTerminate() void {
    font.destroy();
    context.destroy();

    oc.log.info("byebye {}", .{counter}, @src());
}

fn testFileApis() !void {
    const File = oc.io.File;

    var cwd = try File.open("/", .{}, .{});
    oc.assert(!cwd.isNil(), "file should be valid", .{}, @src());
    defer cwd.close();

    var orca_jumping_file = try File.open("/orca_jumping.jpg", .{}, .{});
    oc.assert(!orca_jumping_file.isNil(), "file should be valid", .{}, @src());
    orca_jumping_file.close();

    orca_jumping_file = try File.openAt(cwd, "orca_jumping.jpg", .{}, .{});
    oc.assert((try orca_jumping_file.getStatus()).type == .regular, "status API works", .{}, @src());
    oc.assert(try orca_jumping_file.getSize() > 0, "size API works", .{}, @src());
    oc.assert(!orca_jumping_file.isNil(), "file should be valid", .{}, @src());

    var tmp_image = canvas.Image.createFromFile(renderer, orca_jumping_file, false);
    oc.assert(!tmp_image.isNil(), "image loaded from file should not be nil", .{}, @src());
    tmp_image.destroy();
    orca_jumping_file.close();

    const temp_file_contents = "hello world!";
    const temp_file_path = "/temp_file.txt";
    {
        var tmp_file = try File.open(temp_file_path, .{ .write = true }, .{ .create = true });
        defer tmp_file.close();

        oc.assert(!tmp_file.isNil(), "file should be valid", .{}, @src());
        oc.assert(try tmp_file.pos() == 0, "new file shouldn't have anything in it yet", .{}, @src());

        var writer = tmp_file.writer();
        const written = try writer.write(temp_file_contents);
        oc.assert(written == temp_file_contents.len, "should have written some bytes.", .{}, @src());
    }

    {
        var tmp_file = try File.open(temp_file_path, .{ .write = true }, .{ .create = true });
        defer tmp_file.close();

        _ = try tmp_file.seek(0, .set);
        oc.assert(try tmp_file.pos() == 0, "should be back at the beginning of the file", .{}, @src());

        var buffer: [temp_file_contents.len]u8 = undefined;
        var reader = tmp_file.reader();
        _ = try reader.read(&buffer);
        oc.assert(
            std.mem.eql(u8, temp_file_contents, &buffer),
            "should have read what was in the original buffer",
            .{},
            @src(),
        );
    }
}
