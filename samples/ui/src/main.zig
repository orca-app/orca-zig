const std = @import("std");
const oc = @import("orca");
const ui = oc.ui;
const canvas = oc.graphics.canvas;

pub const panic = oc.panic;
comptime {
    oc.exportEventHandlers();
}

var frame_size: oc.math.Vec2 = .{ .x = 1200, .y = 838 };

var surface: canvas.Surface = undefined;
var context: canvas.Context = undefined;
var renderer: canvas.Renderer = undefined;

var ui_ctx: ?*ui.Context = undefined;

var font_regular: canvas.Font = undefined;
var font_bold: canvas.Font = undefined;

var text_arena: oc.mem.Arena = undefined;
var log_arena: oc.mem.Arena = undefined;
var log_lines: oc.strings.Str8List = undefined;

var theme: enum { dark, light } = .dark;

pub fn onInit() !void {
    oc.app.windowSetTitle(oc.toStr8("Orca Zig UI Demo"));
    oc.app.windowSetSize(frame_size);

    renderer = canvas.Renderer.create();
    surface = canvas.surfaceCreate(renderer);
    context = canvas.Context.create();

    const fonts = [_]*canvas.Font{ &font_regular, &font_bold };
    const font_names = [_][]const u8{ "/OpenSans-Regular.ttf", "/OpenSans-Bold.ttf" };
    for (fonts, font_names) |font, name| {
        var scratch = oc.mem.scratchBegin();
        defer scratch.end();

        const file = oc.io.File.open(name, .{}, .{}) catch |e| {
            oc.log.err("Couldn't open file {s}", .{name}, @src());
            return e;
        };

        const size: usize = @intCast(try file.getSize());
        const buffer = try scratch.arena.push(size);
        _ = try file.read(buffer);
        file.close();

        const ranges = [5]oc.utf8.Range{
            .{ .firstCodePoint = 0x0000, .count = 127 }, // BASIC_LATIN
            .{ .firstCodePoint = 0x0080, .count = 127 }, // C1_CONTROLS_AND_LATIN_1_SUPPLEMENT
            .{ .firstCodePoint = 0x0100, .count = 127 }, // LATIN_EXTENDED_A
            .{ .firstCodePoint = 0x0180, .count = 207 }, // LATIN_EXTENDED_B
            .{ .firstCodePoint = 0xfff0, .count = 15 }, //  SPECIALS
        };

        font.* = canvas.Font.createFromMemory(oc.toStr8(buffer), ranges.len, @constCast(&ranges)); // @Cleanup
    }

    ui_ctx = ui.contextCreate(font_regular);

    text_arena = .init();
    log_arena = .init();
    log_lines = .empty;
}

pub fn onRawEvent(event: *oc.app.Event) void {
    ui.setContext(ui_ctx);
    ui.processEvent(event);
}

pub fn onResize(width: u32, height: u32) void {
    frame_size.x = @floatFromInt(width);
    frame_size.y = @floatFromInt(height);
}

pub fn onFrameRefresh() !void {
    var scratch = oc.mem.scratchBegin();
    defer scratch.end();

    {
        ui.frameBegin(frame_size);
        defer ui.frameEnd();

        switch (theme) {
            .dark => ui.setThemeDark(),
            .light => ui.setThemeLight(),
        }

        ui.styleSetVar(.bg_color, "bg-0"); // @Api missing theme strings
        ui.styleSetI32(.constrain_y, 1);

        //--------------------------------------------------------------------------------------------
        // Menu bar
        //--------------------------------------------------------------------------------------------
        {
            ui.menuBarBegin(@constCast("menu_bar"));
            defer ui.menuBarEnd();

            {
                ui.menuBegin(@constCast("file-menu"), @constCast("File"));
                defer ui.menuEnd();

                if (ui.menuButton(@constCast("quit"), @constCast("Quit")).pressed) {
                    oc.app.requestQuit();
                }
            }

            {
                ui.menuBegin(@constCast("theme-menu"), @constCast("Theme"));
                defer ui.menuEnd();

                if (ui.menuButton(@constCast("dark"), @constCast("Dark theme")).pressed) {
                    theme = .dark;
                }
                if (ui.menuButton(@constCast("light"), @constCast("Light theme")).pressed) {
                    theme = .light;
                }
            }
        }

        {
            _ = ui.boxBeginStr8(oc.toStr8("main panel"));
            defer _ = ui.boxEnd();

            ui.styleSetSize(.width, .{ .kind = .parent, .value = 1 });
            ui.styleSetSize(.height, .{ .kind = .parent, .value = 1, .relax = 1 });

            {
                _ = ui.boxBeginStr8(oc.toStr8("background"));
                defer _ = ui.boxEnd();

                ui.styleSetSize(.width, .{ .kind = .parent, .value = 1 });
                ui.styleSetSize(.height, .{ .kind = .parent, .value = 1, .relax = 1 });
                ui.styleSetAxis(.x);
                ui.styleSetF32(.margin_x, 16);
                ui.styleSetF32(.margin_y, 16);
                ui.styleSetF32(.spacing, 16);

                try widgets(scratch.arena);

                styling(scratch.arena);
            }
        }
    }

    _ = context.select();

    ui.draw();
    canvas.render(renderer, context, surface);
    canvas.present(renderer, surface);
}

var checkbox_checked: bool = false;
var v_slider_value: f32 = 0;
var v_slider_logged_value: f32 = 0;
var v_slider_log_time: f64 = 0;
var radio_selected: i32 = 0;
var h_slider_value: f32 = 0;
var h_slider_logged_value: f32 = 0;
var h_slider_log_time: f64 = 0;
var text_info: ui.TextBoxInfo = .{ .defaultText = oc.toStr8("Type here") };
var selected: i32 = 0;

fn widgets(arena: *oc.mem.Arena) !void {
    columnBegin("Widgets", 1.0 / 3.0);
    defer columnEnd();

    {
        _ = ui.boxBeginStr8(oc.toStr8("top"));
        defer _ = ui.boxEnd();

        ui.styleSetSize(.width, .{ .kind = .parent, .value = 1 });
        ui.styleSetAxis(.x);
        ui.styleSetF32(.spacing, 32);

        {
            _ = ui.boxBeginStr8(oc.toStr8("top_left"));
            defer _ = ui.boxEnd();

            ui.styleSetAxis(.y);
            ui.styleSetF32(.spacing, 24);

            //-----------------------------------------------------------------------------
            // Label
            //-----------------------------------------------------------------------------
            _ = ui.label("label", "Label");

            //-----------------------------------------------------------------------------
            // Button
            //-----------------------------------------------------------------------------
            if (ui.button("button", "Button").clicked) {
                logPush("Button clicked");
            }

            {
                _ = ui.boxBeginStr8(oc.toStr8("checkbox"));
                defer _ = ui.boxEnd();

                ui.styleSetAxis(.x);
                ui.styleSetAlign(.y, .center);
                ui.styleSetF32(.spacing, 8);
                ui.styleSetF32(.margin_x, 2);

                //-------------------------------------------------------------------------
                // Checkbox
                //-------------------------------------------------------------------------
                if (ui.checkbox("checkbox", &checkbox_checked).clicked) {
                    if (checkbox_checked) {
                        logPush("Checkbox checked");
                    } else {
                        logPush("Checkbox unhecked");
                    }
                }

                _ = ui.label("label", "Checkbox");
            }
        }

        //---------------------------------------------------------------------------------
        // Vertical slider
        //---------------------------------------------------------------------------------

        {
            ui.styleRuleBegin(oc.toStr8("v_slider"));
            defer ui.styleRuleEnd();
            ui.styleSetSize(.width, .{ .kind = .pixels, .value = 24 });
            ui.styleSetSize(.height, .{ .kind = .pixels, .value = 130 });
        }

        _ = ui.slider("v_slider", &v_slider_value);

        const now = oc.clock.time(.monotonic);
        if ((now - v_slider_log_time) >= 0.2 and v_slider_value != v_slider_logged_value) {
            try logPushf("Vertical slider moved to {d:.3}", .{v_slider_value});
            v_slider_logged_value = v_slider_value;
            v_slider_log_time = now;
        }

        {
            _ = ui.boxBeginStr8(oc.toStr8("top right"));
            defer _ = ui.boxEnd();

            ui.styleSetAxis(.y);
            ui.styleSetF32(.spacing, 24);

            //-----------------------------------------------------------------------------
            // Tooltip
            //-----------------------------------------------------------------------------
            if (ui.label("label", "Tooltip").hover) {
                ui.tooltip("tooltip", "Hi");
            }

            //-----------------------------------------------------------------------------
            // Radio group
            //-----------------------------------------------------------------------------
            var options = [_]oc.strings.Str8{
                oc.toStr8("Radio 1"),
                oc.toStr8("Radio 2"),
            };
            var radio_group_info = ui.RadioGroupInfo{
                .selected_index = radio_selected,
                .option_count = @intCast(options.len),
                .options = &options,
            };
            const result = ui.radioGroup("radio_group", &radio_group_info);
            radio_selected = result.selected_index;
            if (result.changed) {
                try logPushf("Selected {s}", .{options[@intCast(radio_selected)].toSlice()});
            }

            //-----------------------------------------------------------------------------
            // Horizontal slider
            //-----------------------------------------------------------------------------

            {
                ui.styleRuleBegin(oc.toStr8("h_slider"));
                defer ui.styleRuleEnd();

                ui.styleSetSize(.width, .{ .kind = .pixels, .value = 130 });
                ui.styleSetSize(.height, .{ .kind = .pixels, .value = 24 });
            }
            _ = ui.slider("h_slider", &h_slider_value);

            if ((now - h_slider_log_time) >= 0.2 and h_slider_value != h_slider_logged_value) {
                try logPushf("Slider moved to {d:.3}", .{h_slider_value});
                h_slider_logged_value = h_slider_value;
                h_slider_log_time = now;
            }
        }
    }

    //-------------------------------------------------------------------------------------
    // Text box
    //-------------------------------------------------------------------------------------
    {
        {
            ui.styleRuleBegin(oc.toStr8("text"));
            defer ui.styleRuleEnd();
            ui.styleSetSize(.width, .{ .kind = .pixels, .value = 305 });
        }

        const result = ui.textBoxStr8(oc.toStr8("text"), arena, &text_info);
        if (result.changed) {
            text_arena.clear();
            text_info.text = try result.text.pushCopy(&text_arena);
        }
        if (result.accepted) {
            // @Bug this code never seems to run?
            try logPushf("Entered text {s}", .{text_info.text.toSlice()});
        }
    }

    //-------------------------------------------------------------------------------------
    // Select
    //-------------------------------------------------------------------------------------
    {
        var options = [_]oc.strings.Str8{
            oc.toStr8("Option 1"),
            oc.toStr8("Option 2"),
        };
        var info = ui.SelectPopupInfo{
            .selected_index = selected,
            .option_count = @intCast(options.len),
            .options = &options,
            .placeholder = oc.toStr8("Select"),
        };
        const result = ui.selectPopup("select", &info);
        if (result.selected_index != selected) {
            try logPushf("Selected {s}", .{options[@intCast(result.selected_index)].toSlice()});
        }
        selected = result.selected_index;
    }

    //-------------------------------------------------------------------------------------
    // Scrollable panel
    //-------------------------------------------------------------------------------------
    {
        _ = ui.boxBeginStr8(oc.toStr8("log"));
        defer _ = ui.boxEnd();

        ui.styleSetSize(.width, .{ .kind = .parent, .value = 1 });
        ui.styleSetSize(.height, .{ .kind = .parent, .value = 1, .relax = 1, .minSize = 200 });
        ui.styleSetVar(.bg_color, "bg-2"); // @Api missing themes
        ui.styleSetVar(.border_color, "border"); // @Api missing themes
        ui.styleSetF32(.border_size, 1);
        ui.styleSetVar(.roundness, "roundness-small"); // @Api missing themes

        ui.styleSetOverflow(.y, .scroll);

        {
            _ = ui.boxBeginStr8(oc.toStr8("contents"));
            defer _ = ui.boxEnd();

            ui.styleSetF32(.margin_x, 16);
            ui.styleSetF32(.margin_y, 16);
            ui.styleSetAxis(.y);

            if (log_lines.list.isEmpty()) {
                {
                    ui.styleRuleBegin(oc.toStr8("label"));
                    defer ui.styleRuleEnd();
                    ui.styleSetVar(.color, "text-2"); // @Api missing themes
                }
                _ = ui.label("label", "Log");
            }

            var i: u32 = 0;
            var id: [15]u8 = undefined;
            std.debug.assert(log_lines.elt_count < 100000000000000); // 15 digits
            var iter = log_lines.iterate(.{});
            while (iter.next()) |log_line| : (i += 1) {
                _ = ui.labelStr8(
                    oc.toStr8(std.fmt.bufPrintIntToSlice(&id, i, 10, .lower, .{})),
                    log_line.string,
                );
            }
        }
    }
}

var styling_selected_radio: i32 = 0;
var unselected_width: f32 = 16;
var unselected_height: f32 = 16;
var unselected_roundness: f32 = 8;
var unselected_bg_color: canvas.Color = canvas.Color.rgba(0.086, 0.086, 0.102, 1);
var unselected_border_color: canvas.Color = canvas.Color.rgba(0.976, 0.976, 0.976, 0.35);
var unselected_border_size: f32 = 1;
var unselected_when_status: oc.strings.Str8 = oc.toStr8("");
var unselected_status_index: i32 = 0;
var selected_width: f32 = 16;
var selected_height: f32 = 16;
var selected_roundness: f32 = 8;
var selected_center_color: canvas.Color = canvas.Color.rgba(1, 1, 1, 1);
var selected_bg_color: canvas.Color = canvas.Color.rgba(0.33, 0.66, 1, 1);
var selected_when_status: oc.strings.Str8 = oc.toStr8("");
var selected_status_index: i32 = 0;
var label_font_color: canvas.Color = canvas.Color.rgba(0.976, 0.976, 0.976, 1);
var label_font_color_selected: i32 = 0;
var label_font: *canvas.Font = &font_regular;
var label_font_selected: i32 = 0;
var label_font_size: f32 = 14;

fn styling(arena: *oc.mem.Arena) void {
    columnBegin("Styling", 2.0 / 3.0);
    defer columnEnd();

    {
        _ = ui.boxBeginStr8(oc.toStr8("styled_radios"));
        defer _ = ui.boxEnd();

        ui.styleSetSize(.width, .{ .kind = .parent, .value = 1 });
        ui.styleSetSize(.height, .{ .kind = .pixels, .value = 152 });
        ui.styleSetColor(.bg_color, .{ .r = 0.086, .g = 0.086, .b = 0.102 });
        ui.styleSetVar(.roundness, "roundness-small"); // @Api missing themes

        ui.styleSetAlign(.x, .center);
        ui.styleSetAlign(.y, .center);

        {
            var list: oc.strings.Str8List = .empty;
            list.push(arena, oc.toStr8("radio_group .radio-row"));
            list.push(arena, unselected_when_status);
            list.push(arena, oc.toStr8(" .radio"));
            const unselected_pattern = list.join(arena);

            {
                ui.styleRuleBegin(unselected_pattern);
                defer ui.styleRuleEnd();

                ui.styleSetSize(.width, .{ .kind = .pixels, .value = unselected_width });
                ui.styleSetSize(.height, .{ .kind = .pixels, .value = unselected_height });
                ui.styleSetColor(.bg_color, unselected_bg_color);
                ui.styleSetColor(.border_color, unselected_border_color);
                ui.styleSetF32(.border_size, unselected_border_size);
                ui.styleSetF32(.roundness, unselected_roundness);
            }
        }

        {
            var list: oc.strings.Str8List = .empty;
            list.push(arena, oc.toStr8("radio_group .radio-row"));
            list.push(arena, selected_when_status);
            list.push(arena, oc.toStr8(" .radio_selected"));
            const selected_pattern = list.join(arena);

            {
                ui.styleRuleBegin(selected_pattern);
                defer ui.styleRuleEnd();

                ui.styleSetSize(.width, .{ .kind = .pixels, .value = selected_width });
                ui.styleSetSize(.height, .{ .kind = .pixels, .value = selected_height });
                ui.styleSetColor(.bg_color, selected_bg_color);
                ui.styleSetColor(.color, selected_center_color);
                ui.styleSetF32(.roundness, selected_roundness);
            }
        }

        {
            ui.styleRuleBegin(oc.toStr8("radio_group label"));
            defer ui.styleRuleEnd();

            ui.styleSetColor(.color, label_font_color);
            ui.styleSetFont(.font, label_font.*);
            ui.styleSetF32(.font_size, label_font_size);
        }

        var options = [_]oc.strings.Str8{
            oc.toStr8("I"),
            oc.toStr8("Am"),
            oc.toStr8("Stylish"),
        };
        var radio_group_info = ui.RadioGroupInfo{
            .selected_index = styling_selected_radio,
            .option_count = @intCast(options.len),
            .options = &options,
        };
        const result = ui.radioGroup("radio_group", &radio_group_info);
        styling_selected_radio = result.selected_index;
    }

    {
        _ = ui.boxBeginStr8(oc.toStr8("controls"));
        defer _ = ui.boxEnd();

        ui.styleSetAxis(.x);
        ui.styleSetF32(.spacing, 32);

        {
            _ = ui.boxBeginStr8(oc.toStr8("unselected"));
            defer _ = ui.boxEnd();

            ui.styleSetAxis(.y);
            ui.styleSetF32(.spacing, 16);

            {
                ui.styleRuleBegin(oc.toStr8("radio-label"));
                defer ui.styleRuleEnd();

                ui.styleSetF32(.font_size, 16);
            }
            _ = ui.label("radio-label", "Radio style");

            {
                _ = ui.boxBeginStr8(oc.toStr8("size"));
                defer _ = ui.boxEnd();

                ui.styleSetAxis(.y);
                ui.styleSetF32(.spacing, 4);

                var width_slider = (unselected_width - 8) / 16;
                labeledSlider("Width", &width_slider);
                unselected_width = 8 + width_slider * 16;

                var height_slider = (unselected_height - 8) / 16;
                labeledSlider("Height", &height_slider);
                unselected_height = 8 + height_slider * 16;

                var roundness_slider = (unselected_roundness - 4) / 8;
                labeledSlider("Roundness", &roundness_slider);
                unselected_roundness = 4 + roundness_slider * 8;
            }

            {
                _ = ui.boxBeginStr8(oc.toStr8("background"));
                defer _ = ui.boxEnd();

                ui.styleSetAxis(.y);
                ui.styleSetF32(.spacing, 4);
                labeledSlider("Background R", &unselected_bg_color.r);
                labeledSlider("Background G", &unselected_bg_color.g);
                labeledSlider("Background B", &unselected_bg_color.b);
                labeledSlider("Background A", &unselected_bg_color.a);
            }

            {
                _ = ui.boxBeginStr8(oc.toStr8("border"));
                defer _ = ui.boxEnd();

                ui.styleSetAxis(.y);
                ui.styleSetF32(.spacing, 4);
                labeledSlider("Border R", &unselected_border_color.r);
                labeledSlider("Border G", &unselected_border_color.g);
                labeledSlider("Border B", &unselected_border_color.b);
                labeledSlider("Border A", &unselected_border_color.a);
            }

            var border_size_slider = unselected_border_size / 5;
            labeledSlider("Border size", &border_size_slider);
            unselected_border_size = border_size_slider * 5;

            {
                _ = ui.boxBeginStr8(oc.toStr8("status_override"));
                defer _ = ui.boxEnd();

                ui.styleSetAxis(.y);
                ui.styleSetF32(.spacing, 10);
                _ = ui.label("label", "Override");

                var status_options = [_]oc.strings.Str8{
                    oc.toStr8("Always"),
                    oc.toStr8("When hovering"),
                    oc.toStr8("When active"),
                };
                var status_info = ui.RadioGroupInfo{
                    .selected_index = unselected_status_index,
                    .option_count = @intCast(status_options.len),
                    .options = &status_options,
                };
                const result = ui.radioGroup("status", &status_info);
                unselected_status_index = result.selected_index;
                unselected_when_status = switch (unselected_status_index) {
                    0 => oc.toStr8(""),
                    1 => oc.toStr8(".hover"),
                    2 => oc.toStr8(".active"),
                    else => unreachable,
                };
            }
        }

        {
            _ = ui.boxBeginStr8(oc.toStr8("selected"));
            defer _ = ui.boxEnd();

            ui.styleSetAxis(.y);
            ui.styleSetF32(.spacing, 16);

            {
                ui.styleRuleBegin(oc.toStr8("radio-label"));
                defer ui.styleRuleEnd();

                ui.styleSetF32(.font_size, 16);
            }
            _ = ui.label("radio-label", "Radio style");

            {
                _ = ui.boxBeginStr8(oc.toStr8("size"));
                defer _ = ui.boxEnd();

                ui.styleSetAxis(.y);
                ui.styleSetF32(.spacing, 4);

                var width_slider = (selected_width - 8) / 16;
                labeledSlider("Width", &width_slider);
                selected_width = 8 + width_slider * 16;

                var height_slider = (selected_height - 8) / 16;
                labeledSlider("Height", &height_slider);
                selected_height = 8 + height_slider * 16;

                var roundness_slider = (selected_roundness - 4) / 8;
                labeledSlider("Roundness", &roundness_slider);
                selected_roundness = 4 + roundness_slider * 8;
            }

            {
                _ = ui.boxBeginStr8(oc.toStr8("background"));
                defer _ = ui.boxEnd();

                ui.styleSetAxis(.y);
                ui.styleSetF32(.spacing, 4);
                labeledSlider("Background R", &selected_bg_color.r);
                labeledSlider("Background G", &selected_bg_color.g);
                labeledSlider("Background B", &selected_bg_color.b);
                labeledSlider("Background A", &selected_bg_color.a);
            }

            {
                _ = ui.boxBeginStr8(oc.toStr8("center"));
                defer _ = ui.boxEnd();

                ui.styleSetAxis(.y);
                ui.styleSetF32(.spacing, 4);
                labeledSlider("Center R", &selected_center_color.r);
                labeledSlider("Center G", &selected_center_color.g);
                labeledSlider("Center B", &selected_center_color.b);
                labeledSlider("Center A", &selected_center_color.a);
            }

            {
                _ = ui.boxBeginStr8(oc.toStr8("spacer"));
                defer _ = ui.boxEnd();

                ui.styleSetSize(.height, .{ .kind = .pixels, .value = 24 });
            }

            {
                _ = ui.boxBeginStr8(oc.toStr8("status_override"));
                defer _ = ui.boxEnd();

                ui.styleSetAxis(.y);
                ui.styleSetF32(.spacing, 10);
                _ = ui.label("label", "Override");

                var status_options = [_]oc.strings.Str8{
                    oc.toStr8("Always"),
                    oc.toStr8("When hovering"),
                    oc.toStr8("When active"),
                };
                var status_info = ui.RadioGroupInfo{
                    .selected_index = selected_status_index,
                    .option_count = @intCast(status_options.len),
                    .options = &status_options,
                };
                const status_result = ui.radioGroup("status", &status_info);
                selected_status_index = status_result.selected_index;
                selected_when_status = switch (selected_status_index) {
                    0 => oc.toStr8(""),
                    1 => oc.toStr8(".hover"),
                    2 => oc.toStr8(".active"),
                    else => unreachable,
                };
            }
        }

        {
            _ = ui.boxBeginStr8(oc.toStr8("label"));
            defer _ = ui.boxEnd();

            ui.styleSetAxis(.y);
            ui.styleSetF32(.spacing, 16);

            {
                ui.styleRuleBegin(oc.toStr8("label-style"));
                defer ui.styleRuleEnd();

                ui.styleSetF32(.font_size, 16);
            }
            _ = ui.label("label-style", "Label style");

            {
                _ = ui.boxBeginStr8(oc.toStr8("font_color"));
                defer _ = ui.boxEnd();

                ui.styleSetF32(.spacing, 8);

                {
                    ui.styleRuleBegin(oc.toStr8("font-color"));
                    defer ui.styleRuleEnd();

                    ui.styleSetSize(.width, .{ .kind = .pixels, .value = 100 });
                }
                _ = ui.label("font-color", "Font color");

                var color_names = [_]oc.strings.Str8{
                    oc.toStr8("Default"),
                    oc.toStr8("Red"),
                    oc.toStr8("Orange"),
                    oc.toStr8("Amber"),
                    oc.toStr8("Yellow"),
                    oc.toStr8("Lime"),
                    oc.toStr8("Light green"),
                    oc.toStr8("Green"),
                };
                const colors = [_]canvas.Color{
                    .srgba(1, 1, 1, 1), // Default
                    .srgba(0.988, 0.447, 0.353, 1), // Red
                    .srgba(1.000, 0.682, 0.263, 1), // Orange
                    .srgba(0.961, 0.792, 0.314, 1), // Amber
                    .srgba(0.992, 0.871, 0.263, 1), // Yellow
                    .srgba(0.682, 0.863, 0.227, 1), // Lime
                    .srgba(0.592, 0.776, 0.373, 1), // Light green
                    .srgba(0.365, 0.761, 0.392, 1), // Green
                };
                var color_info = ui.SelectPopupInfo{
                    .selected_index = label_font_color_selected,
                    .option_count = @intCast(color_names.len),
                    .options = &color_names,
                };
                const color_result = ui.selectPopup("color", &color_info);
                label_font_color_selected = color_result.selected_index;
                label_font_color = colors[@intCast(label_font_color_selected)];
            }

            {
                _ = ui.boxBeginStr8(oc.toStr8("font"));
                defer _ = ui.boxEnd();

                ui.styleSetF32(.spacing, 8);

                {
                    ui.styleRuleBegin(oc.toStr8("font-label"));
                    defer ui.styleRuleEnd();

                    ui.styleSetSize(.width, .{ .kind = .pixels, .value = 100 });
                }
                _ = ui.label("font-label", "Font");

                var font_names = [_]oc.strings.Str8{
                    oc.toStr8("Regular"),
                    oc.toStr8("Bold"),
                };
                const fonts = [_]*canvas.Font{
                    &font_regular,
                    &font_bold,
                };
                var font_info = ui.SelectPopupInfo{
                    .selected_index = label_font_selected,
                    .option_count = @intCast(font_names.len),
                    .options = &font_names,
                };
                const font_result = ui.selectPopup("font_style", &font_info);
                label_font_selected = font_result.selected_index;
                label_font = fonts[@intCast(label_font_selected)];
            }

            var font_size_slider = (label_font_size - 8) / 16;
            labeledSlider("Font size", &font_size_slider);
            label_font_size = 8 + font_size_slider * 16;
        }
    }
}

fn columnBegin(header: []const u8, widthFraction: f32) void {
    _ = ui.boxBeginStr8(oc.toStr8(header));

    ui.styleSetSize(.width, .{ .kind = .parent, .value = widthFraction, .relax = 1 });
    ui.styleSetSize(.height, .{ .kind = .parent, .value = 1 });
    ui.styleSetAxis(.y);
    ui.styleSetF32(.margin_y, 8);
    ui.styleSetF32(.spacing, 24);
    ui.styleSetVar(.bg_color, "bg-1"); // @Api missing themes
    ui.styleSetVar(.border_color, "border"); // @Api missing themes
    ui.styleSetF32(.border_size, 1);
    ui.styleSetVar(.roundness, "roundness-small"); // @Api missing themes
    ui.styleSetI32(.constrain_y, 1);

    {
        _ = ui.boxBeginStr8(oc.toStr8("header"));
        defer _ = ui.boxEnd();

        ui.styleSetSize(.width, .{ .kind = .parent, .value = 1 });
        ui.styleSetAlign(.x, .center);

        {
            ui.styleRuleBegin(oc.toStr8(".label"));
            defer ui.styleRuleEnd();
            ui.styleSetF32(.font_size, 18);
        }
        _ = ui.labelStr8(oc.toStr8("label"), oc.toStr8(header));
    }

    _ = ui.boxBeginStr8(oc.toStr8("contents"));
    ui.styleSetSize(.width, .{ .kind = .parent, .value = 1 });
    ui.styleSetSize(.height, .{ .kind = .parent, .value = 1, .relax = 1 });
    ui.styleSetAxis(.y);
    ui.styleSetAlign(.x, .start);
    ui.styleSetF32(.margin_x, 16);
    ui.styleSetF32(.spacing, 24);
    ui.styleSetI32(.constrain_y, 1);
}

fn columnEnd() void {
    _ = ui.boxEnd(); // contents
    _ = ui.boxEnd(); // column
}

fn labeledSlider(label: []const u8, value: *f32) void {
    const s8_label = oc.toStr8(label);

    _ = ui.boxBeginStr8(s8_label);
    defer _ = ui.boxEnd();

    {
        ui.styleRuleBegin(oc.toStr8("label"));
        defer ui.styleRuleEnd();

        ui.styleSetSize(.width, .{ .kind = .pixels, .value = 100 });
    }
    _ = ui.labelStr8(oc.toStr8("label"), s8_label);

    {
        ui.styleRuleBegin(oc.toStr8("slider"));
        defer ui.styleRuleEnd();

        ui.styleSetSize(.width, .{ .kind = .pixels, .value = 100 });
    }
    _ = ui.slider("slider", value);
}

fn logPush(line: []const u8) void {
    log_lines.push(&log_arena, oc.toStr8(line));
}

fn logPushf(comptime fmt: []const u8, args: anytype) oc.mem.Arena.Error!void {
    const size: usize = @intCast(std.fmt.count(fmt, args));
    const str = oc.toStr8(try log_arena.push(size));
    log_lines.push(&log_arena, str);
}
