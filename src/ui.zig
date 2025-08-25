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

pub const inputProcessEvent = oc_input_process_event;
extern fn oc_input_process_event(
    arena: [*c]oc.mem.Arena,
    state: [*c]InputState,
    event: [*c]oc.app.Event,
) callconv(.c) void;

pub const inputNextFrame = oc_input_next_frame;
extern fn oc_input_next_frame(
    state: [*c]InputState,
) callconv(.c) void;

pub const keyDown = oc_key_down;
extern fn oc_key_down(
    state: [*c]InputState,
    key: oc.app.KeyCode,
) callconv(.c) bool;

pub const keyPressCount = oc_key_press_count;
extern fn oc_key_press_count(
    state: [*c]InputState,
    key: oc.app.KeyCode,
) callconv(.c) u8;

pub const keyReleaseCount = oc_key_release_count;
extern fn oc_key_release_count(
    state: [*c]InputState,
    key: oc.app.KeyCode,
) callconv(.c) u8;

pub const keyRepeatCount = oc_key_repeat_count;
extern fn oc_key_repeat_count(
    state: [*c]InputState,
    key: oc.app.KeyCode,
) callconv(.c) u8;

pub const keyDownScancode = oc_key_down_scancode;
extern fn oc_key_down_scancode(
    state: [*c]InputState,
    key: oc.app.ScanCode,
) callconv(.c) bool;

pub const keyPressCountScancode = oc_key_press_count_scancode;
extern fn oc_key_press_count_scancode(
    state: [*c]InputState,
    key: oc.app.ScanCode,
) callconv(.c) u8;

pub const keyReleaseCountScancode = oc_key_release_count_scancode;
extern fn oc_key_release_count_scancode(
    state: [*c]InputState,
    key: oc.app.ScanCode,
) callconv(.c) u8;

pub const keyRepeatCountScancode = oc_key_repeat_count_scancode;
extern fn oc_key_repeat_count_scancode(
    state: [*c]InputState,
    key: oc.app.ScanCode,
) callconv(.c) u8;

pub const mouseDown = oc_mouse_down;
extern fn oc_mouse_down(
    state: [*c]InputState,
    button: oc.app.MouseButton,
) callconv(.c) bool;

pub const mousePressed = oc_mouse_pressed;
extern fn oc_mouse_pressed(
    state: [*c]InputState,
    button: oc.app.MouseButton,
) callconv(.c) u8;

pub const mouseReleased = oc_mouse_released;
extern fn oc_mouse_released(
    state: [*c]InputState,
    button: oc.app.MouseButton,
) callconv(.c) u8;

pub const mouseClicked = oc_mouse_clicked;
extern fn oc_mouse_clicked(
    state: [*c]InputState,
    button: oc.app.MouseButton,
) callconv(.c) bool;

pub const mouseDoubleClicked = oc_mouse_double_clicked;
extern fn oc_mouse_double_clicked(
    state: [*c]InputState,
    button: oc.app.MouseButton,
) callconv(.c) bool;

pub const mousePosition = oc_mouse_position;
extern fn oc_mouse_position(
    state: [*c]InputState,
) callconv(.c) oc.math.Vec2;

pub const mouseDelta = oc_mouse_delta;
extern fn oc_mouse_delta(
    state: [*c]InputState,
) callconv(.c) oc.math.Vec2;

pub const mouseWheel = oc_mouse_wheel;
extern fn oc_mouse_wheel(
    state: [*c]InputState,
) callconv(.c) oc.math.Vec2;

pub const inputTextUtf32 = oc_input_text_utf32;
extern fn oc_input_text_utf32(
    arena: [*c]oc.mem.Arena,
    state: [*c]InputState,
) callconv(.c) oc.strings.Str32;

pub const inputTextUtf8 = oc_input_text_utf8;
extern fn oc_input_text_utf8(
    arena: [*c]oc.mem.Arena,
    state: [*c]InputState,
) callconv(.c) oc.strings.Str8;

pub const clipboardPasted = oc_clipboard_pasted;
extern fn oc_clipboard_pasted(
    state: [*c]InputState,
) callconv(.c) bool;

pub const clipboardPastedText = oc_clipboard_pasted_text;
extern fn oc_clipboard_pasted_text(
    state: [*c]InputState,
) callconv(.c) oc.strings.Str8;

pub const keyMods = oc_key_mods;
extern fn oc_key_mods(
    state: [*c]InputState,
) callconv(.c) oc.app.KeymodFlags;

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

pub const contextCreate = oc_ui_context_create;
extern fn oc_ui_context_create(
    defaultFont: oc.graphics.canvas.Font,
) callconv(.c) ?*Context;

pub const contextDestroy = oc_ui_context_destroy;
extern fn oc_ui_context_destroy(
    context: ?*Context,
) callconv(.c) void;

pub const getContext = oc_ui_get_context;
extern fn oc_ui_get_context() callconv(.c) ?*Context;

pub const setContext = oc_ui_set_context;
extern fn oc_ui_set_context(
    context: ?*Context,
) callconv(.c) void;

pub const processEvent = oc_ui_process_event;
extern fn oc_ui_process_event(
    event: [*c]oc.app.Event,
) callconv(.c) void;

pub const frameBegin = oc_ui_frame_begin;
extern fn oc_ui_frame_begin(
    size: oc.math.Vec2,
) callconv(.c) void;

pub const frameEnd = oc_ui_frame_end;
extern fn oc_ui_frame_end() callconv(.c) void;

pub const draw = oc_ui_draw;
extern fn oc_ui_draw() callconv(.c) void;

pub const input = oc_ui_input;
extern fn oc_ui_input() callconv(.c) [*c]InputState;

pub const frameArena = oc_ui_frame_arena;
extern fn oc_ui_frame_arena() callconv(.c) [*c]oc.mem.Arena;

pub const frameTime = oc_ui_frame_time;
extern fn oc_ui_frame_time() callconv(.c) f64;

pub const boxBeginStr8 = oc_ui_box_begin_str8;
extern fn oc_ui_box_begin_str8(
    string: oc.strings.Str8,
) callconv(.c) [*c]Box;

pub const boxEnd = oc_ui_box_end;
extern fn oc_ui_box_end() callconv(.c) [*c]Box;

pub const boxSetDrawProc = oc_ui_box_set_draw_proc;
extern fn oc_ui_box_set_draw_proc(
    box: [*c]Box,
    proc: BoxDrawProc,
    data: ?*anyopaque,
) callconv(.c) void;

pub const boxSetText = oc_ui_box_set_text;
extern fn oc_ui_box_set_text(
    box: [*c]Box,
    text: oc.strings.Str8,
) callconv(.c) void;

pub const boxSetOverlay = oc_ui_box_set_overlay;
extern fn oc_ui_box_set_overlay(
    box: [*c]Box,
    overlay: bool,
) callconv(.c) void;

pub const boxSetClosed = oc_ui_box_set_closed;
extern fn oc_ui_box_set_closed(
    box: [*c]Box,
    closed: bool,
) callconv(.c) void;

pub const boxUserDataGet = oc_ui_box_user_data_get;
extern fn oc_ui_box_user_data_get(
    box: [*c]Box,
) callconv(.c) [*c]u8;

pub const boxUserDataPush = oc_ui_box_user_data_push;
extern fn oc_ui_box_user_data_push(
    box: [*c]Box,
    size: u64,
) callconv(.c) [*c]u8;

pub const boxRequestFocus = oc_ui_box_request_focus;
extern fn oc_ui_box_request_focus(
    box: [*c]Box,
) callconv(.c) void;

pub const boxReleaseFocus = oc_ui_box_release_focus;
extern fn oc_ui_box_release_focus(
    box: [*c]Box,
) callconv(.c) void;

pub const boxGetSig = oc_ui_box_get_sig;
extern fn oc_ui_box_get_sig(
    box: [*c]Box,
) callconv(.c) Sig;

pub const setDrawProc = oc_ui_set_draw_proc;
extern fn oc_ui_set_draw_proc(
    proc: BoxDrawProc,
    data: ?*anyopaque,
) callconv(.c) void;

pub const setText = oc_ui_set_text;
extern fn oc_ui_set_text(
    text: oc.strings.Str8,
) callconv(.c) void;

pub const setOverlay = oc_ui_set_overlay;
extern fn oc_ui_set_overlay(
    overlay: bool,
) callconv(.c) void;

pub const setClosed = oc_ui_set_closed;
extern fn oc_ui_set_closed(
    closed: bool,
) callconv(.c) void;

pub const userDataGet = oc_ui_user_data_get;
extern fn oc_ui_user_data_get() callconv(.c) [*c]u8;

pub const userDataPush = oc_ui_user_data_push;
extern fn oc_ui_user_data_push(
    size: u64,
) callconv(.c) [*c]u8;

pub const requestFocus = oc_ui_request_focus;
extern fn oc_ui_request_focus() callconv(.c) void;

pub const releaseFocus = oc_ui_release_focus;
extern fn oc_ui_release_focus() callconv(.c) void;

pub const getSig = oc_ui_get_sig;
extern fn oc_ui_get_sig() callconv(.c) Sig;

pub const boxTagStr8 = oc_ui_box_tag_str8;
extern fn oc_ui_box_tag_str8(
    box: [*c]Box,
    string: oc.strings.Str8,
) callconv(.c) void;

pub const tagStr8 = oc_ui_tag_str8;
extern fn oc_ui_tag_str8(
    string: oc.strings.Str8,
) callconv(.c) void;

pub const tagNextStr8 = oc_ui_tag_next_str8;
extern fn oc_ui_tag_next_str8(
    string: oc.strings.Str8,
) callconv(.c) void;

pub const styleRuleBegin = oc_ui_style_rule_begin;
extern fn oc_ui_style_rule_begin(
    pattern: oc.strings.Str8,
) callconv(.c) void;

pub const styleRuleEnd = oc_ui_style_rule_end;
extern fn oc_ui_style_rule_end() callconv(.c) void;

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

pub const styleSetI32 = oc_ui_style_set_i32;
extern fn oc_ui_style_set_i32(
    attr: Attribute,
    i: i32,
) callconv(.c) void;

pub const styleSetF32 = oc_ui_style_set_f32;
extern fn oc_ui_style_set_f32(
    attr: Attribute,
    f: f32,
) callconv(.c) void;

pub const styleSetColor = oc_ui_style_set_color;
extern fn oc_ui_style_set_color(
    attr: Attribute,
    color: oc.graphics.canvas.Color,
) callconv(.c) void;

pub const styleSetFont = oc_ui_style_set_font;
extern fn oc_ui_style_set_font(
    attr: Attribute,
    font: oc.graphics.canvas.Font,
) callconv(.c) void;

pub const styleSetSize = oc_ui_style_set_size;
extern fn oc_ui_style_set_size(
    attr: Attribute,
    size: Size,
) callconv(.c) void;

pub const styleSetVarStr8 = oc_ui_style_set_var_str8;
extern fn oc_ui_style_set_var_str8(
    attr: Attribute,
    @"var": oc.strings.Str8,
) callconv(.c) void;

pub const styleSetVar = oc_ui_style_set_var;
extern fn oc_ui_style_set_var(
    attr: Attribute,
    @"var": [*:0]const u8, // @Api assuming to be a cstring
) callconv(.c) void;

pub const varDefaultI32Str8 = oc_ui_var_default_i32_str8;
extern fn oc_ui_var_default_i32_str8(
    name: oc.strings.Str8,
    i: i32,
) callconv(.c) void;

pub const varDefaultF32Str8 = oc_ui_var_default_f32_str8;
extern fn oc_ui_var_default_f32_str8(
    name: oc.strings.Str8,
    f: f32,
) callconv(.c) void;

pub const varDefaultSizeStr8 = oc_ui_var_default_size_str8;
extern fn oc_ui_var_default_size_str8(
    name: oc.strings.Str8,
    size: Size,
) callconv(.c) void;

pub const varDefaultColorStr8 = oc_ui_var_default_color_str8;
extern fn oc_ui_var_default_color_str8(
    name: oc.strings.Str8,
    color: oc.graphics.canvas.Color,
) callconv(.c) void;

pub const varDefaultFontStr8 = oc_ui_var_default_font_str8;
extern fn oc_ui_var_default_font_str8(
    name: oc.strings.Str8,
    font: oc.graphics.canvas.Font,
) callconv(.c) void;

pub const varDefaultStr8 = oc_ui_var_default_str8;
extern fn oc_ui_var_default_str8(
    name: oc.strings.Str8,
    src: oc.strings.Str8,
) callconv(.c) void;

pub const varDefaultI32 = oc_ui_var_default_i32;
extern fn oc_ui_var_default_i32(
    name: [*c]u8,
    i: i32,
) callconv(.c) void;

pub const varDefaultF32 = oc_ui_var_default_f32;
extern fn oc_ui_var_default_f32(
    name: [*c]u8,
    f: f32,
) callconv(.c) void;

pub const varDefaultSize = oc_ui_var_default_size;
extern fn oc_ui_var_default_size(
    name: [*c]u8,
    size: Size,
) callconv(.c) void;

pub const varDefaultColor = oc_ui_var_default_color;
extern fn oc_ui_var_default_color(
    name: [*c]u8,
    color: oc.graphics.canvas.Color,
) callconv(.c) void;

pub const varDefaultFont = oc_ui_var_default_font;
extern fn oc_ui_var_default_font(
    name: [*c]u8,
    font: oc.graphics.canvas.Font,
) callconv(.c) void;

pub const varDefault = oc_ui_var_default;
extern fn oc_ui_var_default(
    name: [*c]u8,
    src: [*c]u8,
) callconv(.c) void;

pub const varSetI32Str8 = oc_ui_var_set_i32_str8;
extern fn oc_ui_var_set_i32_str8(
    name: oc.strings.Str8,
    i: i32,
) callconv(.c) void;

pub const varSetF32Str8 = oc_ui_var_set_f32_str8;
extern fn oc_ui_var_set_f32_str8(
    name: oc.strings.Str8,
    f: f32,
) callconv(.c) void;

pub const varSetSizeStr8 = oc_ui_var_set_size_str8;
extern fn oc_ui_var_set_size_str8(
    name: oc.strings.Str8,
    size: Size,
) callconv(.c) void;

pub const varSetColorStr8 = oc_ui_var_set_color_str8;
extern fn oc_ui_var_set_color_str8(
    name: oc.strings.Str8,
    color: oc.graphics.canvas.Color,
) callconv(.c) void;

pub const varSetFontStr8 = oc_ui_var_set_font_str8;
extern fn oc_ui_var_set_font_str8(
    name: oc.strings.Str8,
    font: oc.graphics.canvas.Font,
) callconv(.c) void;

pub const varSetStr8 = oc_ui_var_set_str8;
extern fn oc_ui_var_set_str8(
    name: oc.strings.Str8,
    src: oc.strings.Str8,
) callconv(.c) void;

pub const varSetI32 = oc_ui_var_set_i32;
extern fn oc_ui_var_set_i32(
    name: [*c]u8,
    i: i32,
) callconv(.c) void;

pub const varSetF32 = oc_ui_var_set_f32;
extern fn oc_ui_var_set_f32(
    name: [*c]u8,
    f: f32,
) callconv(.c) void;

pub const varSetSize = oc_ui_var_set_size;
extern fn oc_ui_var_set_size(
    name: [*c]u8,
    size: Size,
) callconv(.c) void;

pub const varSetColor = oc_ui_var_set_color;
extern fn oc_ui_var_set_color(
    name: [*c]u8,
    color: oc.graphics.canvas.Color,
) callconv(.c) void;

pub const varSetFont = oc_ui_var_set_font;
extern fn oc_ui_var_set_font(
    name: [*c]u8,
    font: oc.graphics.canvas.Font,
) callconv(.c) void;

pub const varSet = oc_ui_var_set;
extern fn oc_ui_var_set(
    name: [*c]u8,
    src: [*c]u8,
) callconv(.c) void;

pub const varGetI32Str8 = oc_ui_var_get_i32_str8;
extern fn oc_ui_var_get_i32_str8(
    name: oc.strings.Str8,
) callconv(.c) i32;

pub const varGetF32Str8 = oc_ui_var_get_f32_str8;
extern fn oc_ui_var_get_f32_str8(
    name: oc.strings.Str8,
) callconv(.c) f32;

pub const varGetSizeStr8 = oc_ui_var_get_size_str8;
extern fn oc_ui_var_get_size_str8(
    name: oc.strings.Str8,
) callconv(.c) Size;

pub const varGetColorStr8 = oc_ui_var_get_color_str8;
extern fn oc_ui_var_get_color_str8(
    name: oc.strings.Str8,
) callconv(.c) oc.graphics.canvas.Color;

pub const varGetFontStr8 = oc_ui_var_get_font_str8;
extern fn oc_ui_var_get_font_str8(
    name: oc.strings.Str8,
) callconv(.c) oc.graphics.canvas.Font;

pub const varGetI32 = oc_ui_var_get_i32;
extern fn oc_ui_var_get_i32(
    name: [*c]u8,
) callconv(.c) i32;

pub const varGetF32 = oc_ui_var_get_f32;
extern fn oc_ui_var_get_f32(
    name: [*c]u8,
) callconv(.c) f32;

pub const varGetSize = oc_ui_var_get_size;
extern fn oc_ui_var_get_size(
    name: [*c]u8,
) callconv(.c) Size;

pub const varGetColor = oc_ui_var_get_color;
extern fn oc_ui_var_get_color(
    name: [*c]u8,
) callconv(.c) oc.graphics.canvas.Color;

pub const varGetFont = oc_ui_var_get_font;
extern fn oc_ui_var_get_font(
    name: [*c]u8,
) callconv(.c) oc.graphics.canvas.Font;

pub const setThemeDark = oc_ui_theme_dark;
extern fn oc_ui_theme_dark() callconv(.c) void;

pub const setThemeLight = oc_ui_theme_light;
extern fn oc_ui_theme_light() callconv(.c) void;

//------------------------------------------------------------------------------------------
// [UI Widgets] Graphical User Interface Widgets.
//------------------------------------------------------------------------------------------

pub const label = oc_ui_label;
extern fn oc_ui_label(
    key: [*:0]const u8, // @Api assuming to be a cstring
    label: [*:0]const u8, // @Api assuming to be a cstring
) callconv(.c) Sig;

pub const labelStr8 = oc_ui_label_str8;
extern fn oc_ui_label_str8(
    key: oc.strings.Str8,
    label: oc.strings.Str8,
) callconv(.c) Sig;

pub const button = oc_ui_button;
extern fn oc_ui_button(
    key: [*:0]const u8, // @Api assuming to be a cstring
    text: [*:0]const u8, // @Api assuming to be a cstring
) callconv(.c) Sig;

pub const buttonStr8 = oc_ui_button_str8;
extern fn oc_ui_button_str8(
    key: oc.strings.Str8,
    text: oc.strings.Str8,
) callconv(.c) Sig;

pub const checkbox = oc_ui_checkbox;
extern fn oc_ui_checkbox(
    key: [*:0]const u8, // @Api assuming to be a cstring
    checked: [*c]bool,
) callconv(.c) Sig;

pub const checkboxStr8 = oc_ui_checkbox_str8;
extern fn oc_ui_checkbox_str8(
    key: oc.strings.Str8,
    checked: [*c]bool,
) callconv(.c) Sig;

pub const slider = oc_ui_slider;
extern fn oc_ui_slider(
    name: [*:0]const u8, // @Api assuming to be a cstring
    value: [*c]f32,
) callconv(.c) [*c]Box;

pub const sliderStr8 = oc_ui_slider_str8;
extern fn oc_ui_slider_str8(
    name: oc.strings.Str8,
    value: [*c]f32,
) callconv(.c) [*c]Box;

pub const tooltip = oc_ui_tooltip;
extern fn oc_ui_tooltip(
    key: [*:0]const u8, // @Api assuming to be a cstring
    text: [*:0]const u8, // @Api assuming to be a cstring
) callconv(.c) void;

pub const tooltipStr8 = oc_ui_tooltip_str8;
extern fn oc_ui_tooltip_str8(
    key: oc.strings.Str8,
    text: oc.strings.Str8,
) callconv(.c) void;

pub const menuBarBegin = oc_ui_menu_bar_begin;
extern fn oc_ui_menu_bar_begin(
    key: [*c]u8,
) callconv(.c) void;

pub const menuBarBeginStr8 = oc_ui_menu_bar_begin_str8;
extern fn oc_ui_menu_bar_begin_str8(
    key: oc.strings.Str8,
) callconv(.c) void;

pub const menuBarEnd = oc_ui_menu_bar_end;
extern fn oc_ui_menu_bar_end() callconv(.c) void;

pub const menuBegin = oc_ui_menu_begin;
extern fn oc_ui_menu_begin(
    key: [*c]u8,
    name: [*c]u8,
) callconv(.c) void;

pub const menuBeginStr8 = oc_ui_menu_begin_str8;
extern fn oc_ui_menu_begin_str8(
    key: oc.strings.Str8,
    name: oc.strings.Str8,
) callconv(.c) void;

pub const menuEnd = oc_ui_menu_end;
extern fn oc_ui_menu_end() callconv(.c) void;

pub const menuButton = oc_ui_menu_button;
extern fn oc_ui_menu_button(
    key: [*c]u8,
    text: [*c]u8,
) callconv(.c) Sig;

pub const menuButtonStr8 = oc_ui_menu_button_str8;
extern fn oc_ui_menu_button_str8(
    key: oc.strings.Str8,
    text: oc.strings.Str8,
) callconv(.c) Sig;

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

pub const textBox = oc_ui_text_box;
extern fn oc_ui_text_box(
    key: [*c]u8,
    arena: [*c]oc.mem.Arena,
    info: [*c]TextBoxInfo,
) callconv(.c) TextBoxResult;

pub const textBoxStr8 = oc_ui_text_box_str8;
extern fn oc_ui_text_box_str8(
    key: oc.strings.Str8,
    arena: [*c]oc.mem.Arena,
    info: [*c]TextBoxInfo,
) callconv(.c) TextBoxResult;

pub const SelectPopupInfo = extern struct {
    changed: bool = false,
    selected_index: i32,
    option_count: i32,
    options: [*c]oc.strings.Str8,
    placeholder: oc.strings.Str8 = .fromSlice(@constCast("")),
};

pub const selectPopup = oc_ui_select_popup;
extern fn oc_ui_select_popup(
    key: [*:0]const u8, // @Api assuming to be a cstring
    info: [*c]SelectPopupInfo,
) callconv(.c) SelectPopupInfo;

pub const selectPopupStr8 = oc_ui_select_popup_str8;
extern fn oc_ui_select_popup_str8(
    key: oc.strings.Str8,
    info: [*c]SelectPopupInfo,
) callconv(.c) SelectPopupInfo;

pub const RadioGroupInfo = extern struct {
    changed: bool = false,
    selected_index: i32,
    option_count: i32,
    options: [*c]oc.strings.Str8,
};

pub const radioGroup = oc_ui_radio_group;
extern fn oc_ui_radio_group(
    key: [*:0]const u8, // @Api assuming to be a cstring
    info: [*c]RadioGroupInfo,
) callconv(.c) RadioGroupInfo;

pub const radioGroupStr8 = oc_ui_radio_group_str8;
extern fn oc_ui_radio_group_str8(
    key: oc.strings.Str8,
    info: [*c]RadioGroupInfo,
) callconv(.c) RadioGroupInfo;
