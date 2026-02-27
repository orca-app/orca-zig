//! Graphical User Interface API.

const oc = @import("orca.zig");

// @Api UI namespace contents (not Core or Widgets) should be moved under the Application namespace
// @Api missing documentation

pub const KeyState = extern struct {
    lastUpdate: u64,
    transitionCount: u32,
    repeatCount: u32,
    down: bool,
    sysClicked: bool,
    sysDoubleClicked: bool,
    sysTripleClicked: bool,
};

pub const KeyboardState = extern struct {
    keys: [349]KeyState,
    mods: oc.app.KeymodFlags,
};

pub const MouseState = extern struct {
    lastUpdate: u64,
    posValid: bool,
    pos: oc.math.Vec2,
    delta: oc.math.Vec2,
    wheel: oc.math.Vec2,
    buttons: extern struct {
        left: KeyState,
        right: KeyState,
        middle: KeyState,
        ext1: KeyState,
        ext2: KeyState,
    },
};

pub const INPUT_TEXT_BACKING_SIZE: u32 = 64;

pub const TextState = extern struct {
    lastUpdate: u64,
    backing: [64]oc.utf32,
    codePoints: oc.strings.Str32,
};

pub const ClipboardState = extern struct {
    lastUpdate: u64,
    pastedText: oc.strings.Str8,
};

pub const InputState = extern struct {
    frameCounter: u64,
    keyboard: KeyboardState,
    mouse: MouseState,
    text: TextState,
    clipboard: ClipboardState,
};

pub const inputProcessEvent = @extern(*const fn (
    arena: [*c]oc.mem.Arena,
    state: [*c]InputState,
    event: [*c]oc.app.Event,
) callconv(.c) void, .{ .name = "oc_input_process_event" });

pub const inputNextFrame = @extern(*const fn (
    state: [*c]InputState,
) callconv(.c) void, .{ .name = "oc_input_next_frame" });

pub const keyDown = @extern(*const fn (
    state: [*c]InputState,
    key: oc.app.KeyCode,
) callconv(.c) bool, .{ .name = "oc_key_down" });

pub const keyPressCount = @extern(*const fn (
    state: [*c]InputState,
    key: oc.app.KeyCode,
) callconv(.c) u8, .{ .name = "oc_key_press_count" });

pub const keyReleaseCount = @extern(*const fn (
    state: [*c]InputState,
    key: oc.app.KeyCode,
) callconv(.c) u8, .{ .name = "oc_key_release_count" });

pub const keyRepeatCount = @extern(*const fn (
    state: [*c]InputState,
    key: oc.app.KeyCode,
) callconv(.c) u8, .{ .name = "oc_key_repeat_count" });

pub const keyDownScancode = @extern(*const fn (
    state: [*c]InputState,
    key: oc.app.ScanCode,
) callconv(.c) bool, .{ .name = "oc_key_down_scancode" });

pub const keyPressCountScancode = @extern(*const fn (
    state: [*c]InputState,
    key: oc.app.ScanCode,
) callconv(.c) u8, .{ .name = "oc_key_press_count_scancode" });

pub const keyReleaseCountScancode = @extern(*const fn (
    state: [*c]InputState,
    key: oc.app.ScanCode,
) callconv(.c) u8, .{ .name = "oc_key_release_count_scancode" });

pub const keyRepeatCountScancode = @extern(*const fn (
    state: [*c]InputState,
    key: oc.app.ScanCode,
) callconv(.c) u8, .{ .name = "oc_key_repeat_count_scancode" });

pub const mouseDown = @extern(*const fn (
    state: [*c]InputState,
    button: oc.app.MouseButton,
) callconv(.c) bool, .{ .name = "oc_mouse_down" });

pub const mousePressed = @extern(*const fn (
    state: [*c]InputState,
    button: oc.app.MouseButton,
) callconv(.c) u8, .{ .name = "oc_mouse_pressed" });

pub const mouseReleased = @extern(*const fn (
    state: [*c]InputState,
    button: oc.app.MouseButton,
) callconv(.c) u8, .{ .name = "oc_mouse_released" });

pub const mouseClicked = @extern(*const fn (
    state: [*c]InputState,
    button: oc.app.MouseButton,
) callconv(.c) bool, .{ .name = "oc_mouse_clicked" });

pub const mouseDoubleClicked = @extern(*const fn (
    state: [*c]InputState,
    button: oc.app.MouseButton,
) callconv(.c) bool, .{ .name = "oc_mouse_double_clicked" });

pub const mousePosition = @extern(*const fn (
    state: [*c]InputState,
) callconv(.c) oc.math.Vec2, .{ .name = "oc_mouse_position" });

pub const mouseDelta = @extern(*const fn (
    state: [*c]InputState,
) callconv(.c) oc.math.Vec2, .{ .name = "oc_mouse_delta" });

pub const mouseWheel = @extern(*const fn (
    state: [*c]InputState,
) callconv(.c) oc.math.Vec2, .{ .name = "oc_mouse_wheel" });

pub const inputTextUtf32 = @extern(*const fn (
    arena: [*c]oc.mem.Arena,
    state: [*c]InputState,
) callconv(.c) oc.strings.Str32, .{ .name = "oc_input_text_utf32" });

pub const inputTextUtf8 = @extern(*const fn (
    arena: [*c]oc.mem.Arena,
    state: [*c]InputState,
) callconv(.c) oc.strings.Str8, .{ .name = "oc_input_text_utf8" });

pub const clipboardPasted = @extern(*const fn (
    state: [*c]InputState,
) callconv(.c) bool, .{ .name = "oc_clipboard_pasted" });

pub const clipboardPastedText = @extern(*const fn (
    state: [*c]InputState,
) callconv(.c) oc.strings.Str8, .{ .name = "oc_clipboard_pasted_text" });

pub const keyMods = @extern(*const fn (
    state: [*c]InputState,
) callconv(.c) oc.app.KeymodFlags, .{ .name = "oc_key_mods" });

//------------------------------------------------------------------------------------------
// [UI Core] Graphical User Interface Core API.
//------------------------------------------------------------------------------------------

pub const Axis = enum(u32) {
    x = 0,
    y = 1,
};

pub const Align = enum(u32) {
    start = 0,
    end = 1,
    center = 2,
};

pub const Size = extern struct {
    kind: Kind,
    value: f32,
    relax: f32 = 0,
    minSize: f32 = 0,

    pub const Kind = enum(u32) {
        children = 0,
        text = 1,
        pixels = 2,
        parent = 3,
        parent_minus_pixels = 4,
    };
};

pub const Overflow = enum(u32) {
    clip = 0,
    allow = 1,
    scroll = 2,
};

pub const Attribute = enum(u32) {
    width = 0,
    height = 1,
    axis = 2,
    margin_x = 3,
    margin_y = 4,
    spacing = 5,
    align_x = 6,
    align_y = 7,
    floating_x = 8,
    floating_y = 9,
    float_target_x = 10,
    float_target_y = 11,
    overflow_x = 12,
    overflow_y = 13,
    constrain_x = 14,
    constrain_y = 15,
    color = 16,
    bg_color = 17,
    border_color = 18,
    font = 19,
    font_size = 20,
    border_size = 21,
    roundness = 22,
    draw_mask = 23,
    animation_time = 24,
    animation_mask = 25,
    click_through = 26,

    // @Api should be marked as a bitflags type
    pub const Mask = packed struct(u32) {
        size_width: bool = false,
        size_height: bool = false,
        layout_axis: bool = false,
        layout_margin_x: bool = false,
        layout_margin_y: bool = false,
        layout_spacing: bool = false,
        layout_align_x: bool = false,
        layout_align_y: bool = false,
        floating_x: bool = false,
        floating_y: bool = false,
        float_target_x: bool = false,
        float_target_y: bool = false,
        overflow_x: bool = false,
        overflow_y: bool = false,
        constrain_x: bool = false,
        constrain_y: bool = false,
        color: bool = false,
        bg_color: bool = false,
        border_color: bool = false,
        font: bool = false,
        font_size: bool = false,
        border_size: bool = false,
        roundness: bool = false,
        draw_mask: bool = false,
        animation_time: bool = false,
        animation_mask: bool = false,
        click_through: bool = false,

        _padding: u5 = 0,
    };
};

pub const Layout = extern struct {
    axis: Axis,
    spacing: f32,
    margin: oc.math.Vec2,
    @"align": extern struct {
        x: Align,
        y: Align,
    },
    overflow: extern struct {
        x: Overflow,
        y: Overflow,
    },
    constrain: extern struct {
        x: bool,
        y: bool,
    },
};

pub const BoxSize = extern struct {
    width: Size,
    height: Size,
};

pub const BoxFloating = extern struct {
    x: bool,
    y: bool,
};

// @Api should be marked as a bitflags type
pub const DrawMask = packed struct(u32) {
    background: bool = false,
    border: bool = false,
    text: bool = false,
    proc: bool = false,

    _padding: u28 = 0,
};

pub const Style = extern struct {
    size: BoxSize,
    layout: Layout,
    floating: BoxFloating,
    floatTarget: oc.math.Vec2,
    color: oc.graphics.canvas.Color,
    bgColor: oc.graphics.canvas.Color,
    borderColor: oc.graphics.canvas.Color,
    font: oc.graphics.canvas.Font,
    fontSize: f32,
    borderSize: f32,
    roundness: f32,
    drawMask: u32,
    animationTime: f32,
    animationMask: Attribute.Mask,
    clickThrough: bool,
};

pub const Context = opaque {};

pub const Sig = extern struct {
    box: [*c]Box,
    mouse: oc.math.Vec2,
    delta: oc.math.Vec2,
    wheel: oc.math.Vec2,
    lastPressedMouse: oc.math.Vec2,
    pressed: bool,
    released: bool,
    clicked: bool,
    doubleClicked: bool,
    tripleClicked: bool,
    rightPressed: bool,
    closed: bool,
    active: bool,
    hover: bool,
    focus: bool,
    pasted: bool,
};

pub const BoxDrawProc = *const fn (
    arg0: [*c]Box,
    arg1: ?*anyopaque,
) callconv(.c) void;

pub const Key = extern struct {
    hash: u64,
};

pub const Box = extern struct {
    listElt: oc.List.Elem,
    children: oc.List,
    parent: [*c]Box,
    overlayElt: oc.List.Elem,
    overlay: bool,
    bucketElt: oc.List.Elem,
    key: Key,
    frameCounter: u64,
    keyString: oc.strings.Str8,
    text: oc.strings.Str8,
    tags: oc.List,
    drawProc: BoxDrawProc,
    drawData: ?*anyopaque,
    rules: oc.List,
    targetStyle: [*c]Style,
    style: Style,
    z: u32,
    floatPos: oc.math.Vec2,
    childrenSum: [2]f32,
    spacing: [2]f32,
    minSize: [2]f32,
    rect: oc.math.Rect,
    styleVariables: oc.List,
    sig: Sig,
    fresh: bool,
    closed: bool,
    parentClosed: bool,
    dragging: bool,
    hot: bool,
    active: bool,
    scroll: oc.math.Vec2,
    pressedMouse: oc.math.Vec2,
    hotTransition: f32,
    activeTransition: f32,
};

pub const contextCreate = @extern(*const fn (
    defaultFont: oc.graphics.canvas.Font,
) callconv(.c) ?*Context, .{ .name = "oc_ui_context_create" });

pub const contextDestroy = @extern(*const fn (
    context: ?*Context,
) callconv(.c) void, .{ .name = "oc_ui_context_destroy" });

pub const getContext = @extern(
    *const fn () callconv(.c) ?*Context,
    .{ .name = "oc_ui_get_context" },
);

pub const setContext = @extern(*const fn (
    context: ?*Context,
) callconv(.c) void, .{ .name = "oc_ui_set_context" });

pub const processEvent = @extern(*const fn (
    event: [*c]oc.app.Event,
) callconv(.c) void, .{ .name = "oc_ui_process_event" });

pub const frameBegin = @extern(*const fn (
    size: oc.math.Vec2,
) callconv(.c) void, .{ .name = "oc_ui_frame_begin" });

pub const frameEnd = @extern(
    *const fn () callconv(.c) void,
    .{ .name = "oc_ui_frame_end" },
);

pub const draw = @extern(
    *const fn () callconv(.c) void,
    .{ .name = "oc_ui_draw" },
);

pub const input = @extern(
    *const fn () callconv(.c) [*c]InputState,
    .{ .name = "oc_ui_input" },
);

pub const frameArena = @extern(
    *const fn () callconv(.c) [*c]oc.mem.Arena,
    .{ .name = "oc_ui_frame_arena" },
);

pub const frameTime = @extern(
    *const fn () callconv(.c) f64,
    .{ .name = "oc_ui_frame_time" },
);

pub const boxBeginStr8 = @extern(*const fn (
    string: oc.strings.Str8,
) callconv(.c) [*c]Box, .{ .name = "oc_ui_box_begin_str8" });

pub const boxEnd = @extern(
    *const fn () callconv(.c) [*c]Box,
    .{ .name = "oc_ui_box_end" },
);

pub const boxSetDrawProc = @extern(*const fn (
    box: [*c]Box,
    proc: BoxDrawProc,
    data: ?*anyopaque,
) callconv(.c) void, .{ .name = "oc_ui_box_set_draw_proc" });

pub const boxSetText = @extern(*const fn (
    box: [*c]Box,
    text: oc.strings.Str8,
) callconv(.c) void, .{ .name = "oc_ui_box_set_text" });

pub const boxSetOverlay = @extern(*const fn (
    box: [*c]Box,
    overlay: bool,
) callconv(.c) void, .{ .name = "oc_ui_box_set_overlay" });

pub const boxSetClosed = @extern(*const fn (
    box: [*c]Box,
    closed: bool,
) callconv(.c) void, .{ .name = "oc_ui_box_set_closed" });

pub const boxUserDataGet = @extern(*const fn (
    box: [*c]Box,
) callconv(.c) [*c]u8, .{ .name = "oc_ui_box_user_data_get" });

pub const boxUserDataPush = @extern(*const fn (
    box: [*c]Box,
    size: u64,
) callconv(.c) [*c]u8, .{ .name = "oc_ui_box_user_data_push" });

pub const boxRequestFocus = @extern(*const fn (
    box: [*c]Box,
) callconv(.c) void, .{ .name = "oc_ui_box_request_focus" });

pub const boxReleaseFocus = @extern(*const fn (
    box: [*c]Box,
) callconv(.c) void, .{ .name = "oc_ui_box_release_focus" });

pub const boxGetSig = @extern(*const fn (
    box: [*c]Box,
) callconv(.c) Sig, .{ .name = "oc_ui_box_get_sig" });

pub const setDrawProc = @extern(*const fn (
    proc: BoxDrawProc,
    data: ?*anyopaque,
) callconv(.c) void, .{ .name = "oc_ui_set_draw_proc" });

pub const setText = @extern(*const fn (
    text: oc.strings.Str8,
) callconv(.c) void, .{ .name = "oc_ui_set_text" });

pub const setOverlay = @extern(*const fn (
    overlay: bool,
) callconv(.c) void, .{ .name = "oc_ui_set_overlay" });

pub const setClosed = @extern(*const fn (
    closed: bool,
) callconv(.c) void, .{ .name = "oc_ui_set_closed" });

pub const userDataGet = @extern(
    *const fn () callconv(.c) [*c]u8,
    .{ .name = "oc_ui_user_data_get" },
);

pub const userDataPush = @extern(*const fn (
    size: u64,
) callconv(.c) [*c]u8, .{ .name = "oc_ui_user_data_push" });

pub const requestFocus = @extern(
    *const fn () callconv(.c) void,
    .{ .name = "oc_ui_request_focus" },
);

pub const releaseFocus = @extern(
    *const fn () callconv(.c) void,
    .{ .name = "oc_ui_release_focus" },
);

pub const getSig = @extern(
    *const fn () callconv(.c) Sig,
    .{ .name = "oc_ui_get_sig" },
);

pub const boxTagStr8 = @extern(*const fn (
    box: [*c]Box,
    string: oc.strings.Str8,
) callconv(.c) void, .{ .name = "oc_ui_box_tag_str8" });

pub const tagStr8 = @extern(*const fn (
    string: oc.strings.Str8,
) callconv(.c) void, .{ .name = "oc_ui_tag_str8" });

pub const tagNextStr8 = @extern(*const fn (
    string: oc.strings.Str8,
) callconv(.c) void, .{ .name = "oc_ui_tag_next_str8" });

pub const styleRuleBegin = @extern(*const fn (
    pattern: oc.strings.Str8,
) callconv(.c) void, .{ .name = "oc_ui_style_rule_begin" });

pub const styleRuleEnd = @extern(
    *const fn () callconv(.c) void,
    .{ .name = "oc_ui_style_rule_end" },
);

pub fn styleSetAxis(axis: Axis) void {
    styleSetI32(.axis, @intCast(@intFromEnum(axis)));
}

pub fn styleSetAlign(axis: Axis, alignment: Align) void {
    const attr: Attribute = switch (axis) {
        .x => .align_x,
        .y => .align_y,
    };
    styleSetI32(attr, @intCast(@intFromEnum(alignment)));
}

pub fn styleSetOverflow(axis: Axis, overflow: Overflow) void {
    const attr: Attribute = switch (axis) {
        .x => .overflow_x,
        .y => .overflow_y,
    };
    styleSetI32(attr, @intCast(@intFromEnum(overflow)));
}

pub const styleSetI32 = @extern(*const fn (
    attr: Attribute,
    i: i32,
) callconv(.c) void, .{ .name = "oc_ui_style_set_i32" });

pub const styleSetF32 = @extern(*const fn (
    attr: Attribute,
    f: f32,
) callconv(.c) void, .{ .name = "oc_ui_style_set_f32" });

pub const styleSetColor = @extern(*const fn (
    attr: Attribute,
    color: oc.graphics.canvas.Color,
) callconv(.c) void, .{ .name = "oc_ui_style_set_color" });

pub const styleSetFont = @extern(*const fn (
    attr: Attribute,
    font: oc.graphics.canvas.Font,
) callconv(.c) void, .{ .name = "oc_ui_style_set_font" });

pub const styleSetSize = @extern(*const fn (
    attr: Attribute,
    size: Size,
) callconv(.c) void, .{ .name = "oc_ui_style_set_size" });

pub const styleSetVarStr8 = @extern(*const fn (
    attr: Attribute,
    @"var": oc.strings.Str8,
) callconv(.c) void, .{ .name = "oc_ui_style_set_var_str8" });

pub const styleSetVar = @extern(*const fn (
    attr: Attribute,
    @"var": [*:0]const u8, // @Api assuming to be a cstring
) callconv(.c) void, .{ .name = "oc_ui_style_set_var" });

pub const varDefaultI32Str8 = @extern(*const fn (
    name: oc.strings.Str8,
    i: i32,
) callconv(.c) void, .{ .name = "oc_ui_var_default_i32_str8" });

pub const varDefaultF32Str8 = @extern(*const fn (
    name: oc.strings.Str8,
    f: f32,
) callconv(.c) void, .{ .name = "oc_ui_var_default_f32_str8" });

pub const varDefaultSizeStr8 = @extern(*const fn (
    name: oc.strings.Str8,
    size: Size,
) callconv(.c) void, .{ .name = "oc_ui_var_default_size_str8" });

pub const varDefaultColorStr8 = @extern(*const fn (
    name: oc.strings.Str8,
    color: oc.graphics.canvas.Color,
) callconv(.c) void, .{ .name = "oc_ui_var_default_color_str8" });

pub const varDefaultFontStr8 = @extern(*const fn (
    name: oc.strings.Str8,
    font: oc.graphics.canvas.Font,
) callconv(.c) void, .{ .name = "oc_ui_var_default_font_str8" });

pub const varDefaultStr8 = @extern(*const fn (
    name: oc.strings.Str8,
    src: oc.strings.Str8,
) callconv(.c) void, .{ .name = "oc_ui_var_default_str8" });

pub const varDefaultI32 = @extern(*const fn (
    name: [*c]u8,
    i: i32,
) callconv(.c) void, .{ .name = "oc_ui_var_default_i32" });

pub const varDefaultF32 = @extern(*const fn (
    name: [*c]u8,
    f: f32,
) callconv(.c) void, .{ .name = "oc_ui_var_default_f32" });

pub const varDefaultSize = @extern(*const fn (
    name: [*c]u8,
    size: Size,
) callconv(.c) void, .{ .name = "oc_ui_var_default_size" });

pub const varDefaultColor = @extern(*const fn (
    name: [*c]u8,
    color: oc.graphics.canvas.Color,
) callconv(.c) void, .{ .name = "oc_ui_var_default_color" });

pub const varDefaultFont = @extern(*const fn (
    name: [*c]u8,
    font: oc.graphics.canvas.Font,
) callconv(.c) void, .{ .name = "oc_ui_var_default_font" });

pub const varDefault = @extern(*const fn (
    name: [*c]u8,
    src: [*c]u8,
) callconv(.c) void, .{ .name = "oc_ui_var_default" });

pub const varSetI32Str8 = @extern(*const fn (
    name: oc.strings.Str8,
    i: i32,
) callconv(.c) void, .{ .name = "oc_ui_var_set_i32_str8" });

pub const varSetF32Str8 = @extern(*const fn (
    name: oc.strings.Str8,
    f: f32,
) callconv(.c) void, .{ .name = "oc_ui_var_set_f32_str8" });

pub const varSetSizeStr8 = @extern(*const fn (
    name: oc.strings.Str8,
    size: Size,
) callconv(.c) void, .{ .name = "oc_ui_var_set_size_str8" });

pub const varSetColorStr8 = @extern(*const fn (
    name: oc.strings.Str8,
    color: oc.graphics.canvas.Color,
) callconv(.c) void, .{ .name = "oc_ui_var_set_color_str8" });

pub const varSetFontStr8 = @extern(*const fn (
    name: oc.strings.Str8,
    font: oc.graphics.canvas.Font,
) callconv(.c) void, .{ .name = "oc_ui_var_set_font_str8" });

pub const varSetStr8 = @extern(*const fn (
    name: oc.strings.Str8,
    src: oc.strings.Str8,
) callconv(.c) void, .{ .name = "oc_ui_var_set_str8" });

pub const varSetI32 = @extern(*const fn (
    name: [*c]u8,
    i: i32,
) callconv(.c) void, .{ .name = "oc_ui_var_set_i32" });

pub const varSetF32 = @extern(*const fn (
    name: [*c]u8,
    f: f32,
) callconv(.c) void, .{ .name = "oc_ui_var_set_f32" });

pub const varSetSize = @extern(*const fn (
    name: [*c]u8,
    size: Size,
) callconv(.c) void, .{ .name = "oc_ui_var_set_size" });

pub const varSetColor = @extern(*const fn (
    name: [*c]u8,
    color: oc.graphics.canvas.Color,
) callconv(.c) void, .{ .name = "oc_ui_var_set_color" });

pub const varSetFont = @extern(*const fn (
    name: [*c]u8,
    font: oc.graphics.canvas.Font,
) callconv(.c) void, .{ .name = "oc_ui_var_set_font" });

pub const varSet = @extern(*const fn (
    name: [*c]u8,
    src: [*c]u8,
) callconv(.c) void, .{ .name = "oc_ui_var_set" });

pub const varGetI32Str8 = @extern(*const fn (
    name: oc.strings.Str8,
) callconv(.c) i32, .{ .name = "oc_ui_var_get_i32_str8" });

pub const varGetF32Str8 = @extern(*const fn (
    name: oc.strings.Str8,
) callconv(.c) f32, .{ .name = "oc_ui_var_get_f32_str8" });

pub const varGetSizeStr8 = @extern(*const fn (
    name: oc.strings.Str8,
) callconv(.c) Size, .{ .name = "oc_ui_var_get_size_str8" });

pub const varGetColorStr8 = @extern(*const fn (
    name: oc.strings.Str8,
) callconv(.c) oc.graphics.canvas.Color, .{ .name = "oc_ui_var_get_color_str8" });

pub const varGetFontStr8 = @extern(*const fn (
    name: oc.strings.Str8,
) callconv(.c) oc.graphics.canvas.Font, .{ .name = "oc_ui_var_get_font_str8" });

pub const varGetI32 = @extern(*const fn (
    name: [*c]u8,
) callconv(.c) i32, .{ .name = "oc_ui_var_get_i32" });

pub const varGetF32 = @extern(*const fn (
    name: [*c]u8,
) callconv(.c) f32, .{ .name = "oc_ui_var_get_f32" });

pub const varGetSize = @extern(*const fn (
    name: [*c]u8,
) callconv(.c) Size, .{ .name = "oc_ui_var_get_size" });

pub const varGetColor = @extern(*const fn (
    name: [*c]u8,
) callconv(.c) oc.graphics.canvas.Color, .{ .name = "oc_ui_var_get_color" });

pub const varGetFont = @extern(*const fn (
    name: [*c]u8,
) callconv(.c) oc.graphics.canvas.Font, .{ .name = "oc_ui_var_get_font" });

pub const setThemeDark = @extern(
    *const fn () callconv(.c) void,
    .{ .name = "oc_ui_theme_dark" },
);

pub const setThemeLight = @extern(
    *const fn () callconv(.c) void,
    .{ .name = "oc_ui_theme_light" },
);

//------------------------------------------------------------------------------------------
// [UI Widgets] Graphical User Interface Widgets.
//------------------------------------------------------------------------------------------

pub const label = @extern(*const fn (
    key: [*:0]const u8, // @Api assuming to be a cstring
    label: [*:0]const u8, // @Api assuming to be a cstring
) callconv(.c) Sig, .{ .name = "oc_ui_label" });

pub const labelStr8 = @extern(*const fn (
    key: oc.strings.Str8,
    label: oc.strings.Str8,
) callconv(.c) Sig, .{ .name = "oc_ui_label_str8" });

pub const button = @extern(*const fn (
    key: [*:0]const u8, // @Api assuming to be a cstring
    text: [*:0]const u8, // @Api assuming to be a cstring
) callconv(.c) Sig, .{ .name = "oc_ui_button" });

pub const buttonStr8 = @extern(*const fn (
    key: oc.strings.Str8,
    text: oc.strings.Str8,
) callconv(.c) Sig, .{ .name = "oc_ui_button_str8" });

pub const checkbox = @extern(*const fn (
    key: [*:0]const u8, // @Api assuming to be a cstring
    checked: [*c]bool,
) callconv(.c) Sig, .{ .name = "oc_ui_checkbox" });

pub const checkboxStr8 = @extern(*const fn (
    key: oc.strings.Str8,
    checked: [*c]bool,
) callconv(.c) Sig, .{ .name = "oc_ui_checkbox_str8" });

pub const slider = @extern(*const fn (
    name: [*:0]const u8, // @Api assuming to be a cstring
    value: [*c]f32,
) callconv(.c) [*c]Box, .{ .name = "oc_ui_slider" });

pub const sliderStr8 = @extern(*const fn (
    name: oc.strings.Str8,
    value: [*c]f32,
) callconv(.c) [*c]Box, .{ .name = "oc_ui_slider_str8" });

pub const tooltip = @extern(*const fn (
    key: [*:0]const u8, // @Api assuming to be a cstring
    text: [*:0]const u8, // @Api assuming to be a cstring
) callconv(.c) void, .{ .name = "oc_ui_tooltip" });

pub const tooltipStr8 = @extern(*const fn (
    key: oc.strings.Str8,
    text: oc.strings.Str8,
) callconv(.c) void, .{ .name = "oc_ui_tooltip_str8" });

pub const menuBarBegin = @extern(*const fn (
    key: [*c]u8,
) callconv(.c) void, .{ .name = "oc_ui_menu_bar_begin" });

pub const menuBarBeginStr8 = @extern(*const fn (
    key: oc.strings.Str8,
) callconv(.c) void, .{ .name = "oc_ui_menu_bar_begin_str8" });

pub const menuBarEnd = @extern(
    *const fn () callconv(.c) void,
    .{ .name = "oc_ui_menu_bar_end" },
);

pub const menuBegin = @extern(*const fn (
    key: [*c]u8,
    name: [*c]u8,
) callconv(.c) void, .{ .name = "oc_ui_menu_begin" });

pub const menuBeginStr8 = @extern(*const fn (
    key: oc.strings.Str8,
    name: oc.strings.Str8,
) callconv(.c) void, .{ .name = "oc_ui_menu_begin_str8" });

pub const menuEnd = @extern(
    *const fn () callconv(.c) void,
    .{ .name = "oc_ui_menu_end" },
);

pub const menuButton = @extern(*const fn (
    key: [*c]u8,
    text: [*c]u8,
) callconv(.c) Sig, .{ .name = "oc_ui_menu_button" });

pub const menuButtonStr8 = @extern(*const fn (
    key: oc.strings.Str8,
    text: oc.strings.Str8,
) callconv(.c) Sig, .{ .name = "oc_ui_menu_button_str8" });

pub const TextBoxResult = extern struct {
    changed: bool,
    accepted: bool,
    text: oc.strings.Str8,
    box: [*c]Box,
};

pub const EditMove = enum(u32) {
    none = 0,
    char = 1,
    word = 2,
    line = 3,
};

pub const TextBoxInfo = extern struct {
    text: oc.strings.Str8 = .fromSlice(@constCast("")),
    defaultText: oc.strings.Str8,
    cursor: i32 = 0,
    mark: i32 = 0,
    selectionMode: EditMove = .none,
    wordSelectionInitialCursor: i32 = 0,
    wordSelectionInitialMark: i32 = 0,
    firstDisplayedChar: i32 = 0,
    cursorBlinkStart: f64 = 0,
};

pub const textBox = @extern(*const fn (
    key: [*c]u8,
    arena: [*c]oc.mem.Arena,
    info: [*c]TextBoxInfo,
) callconv(.c) TextBoxResult, .{ .name = "oc_ui_text_box" });

pub const textBoxStr8 = @extern(*const fn (
    key: oc.strings.Str8,
    arena: [*c]oc.mem.Arena,
    info: [*c]TextBoxInfo,
) callconv(.c) TextBoxResult, .{ .name = "oc_ui_text_box_str8" });

pub const SelectPopupInfo = extern struct {
    changed: bool = false,
    selected_index: i32,
    option_count: i32,
    options: [*c]oc.strings.Str8,
    placeholder: oc.strings.Str8 = .fromSlice(@constCast("")),
};

pub const selectPopup = @extern(*const fn (
    key: [*:0]const u8, // @Api assuming to be a cstring
    info: [*c]SelectPopupInfo,
) callconv(.c) SelectPopupInfo, .{ .name = "oc_ui_select_popup" });

pub const selectPopupStr8 = @extern(*const fn (
    key: oc.strings.Str8,
    info: [*c]SelectPopupInfo,
) callconv(.c) SelectPopupInfo, .{ .name = "oc_ui_select_popup_str8" });

pub const RadioGroupInfo = extern struct {
    changed: bool = false,
    selected_index: i32,
    option_count: i32,
    options: [*c]oc.strings.Str8,
};

pub const radioGroup = @extern(*const fn (
    key: [*:0]const u8, // @Api assuming to be a cstring
    info: [*c]RadioGroupInfo,
) callconv(.c) RadioGroupInfo, .{ .name = "oc_ui_radio_group" });

pub const radioGroupStr8 = @extern(*const fn (
    key: oc.strings.Str8,
    info: [*c]RadioGroupInfo,
) callconv(.c) RadioGroupInfo, .{ .name = "oc_ui_radio_group_str8" });
