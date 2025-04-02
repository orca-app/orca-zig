const std = @import("std");

// @Api api.json wishlist (in order of importance):
// - format documentation
// - format and api versioning!!!
// - specify pointer types (single/multi-item, nullable, mutable, etc...)
// - change module brief to doc for consistency
// - remove unnamed enums, create a dedicated "constant" kind instead
// - missing OC_UNICODE_RANGE values
// - missing oc_clock types
// - make OC_UI_STYLE a proper enum
// - oc_pool and oc_window are missing typename entries
// - oc_ui_box is duplicated
// - OC_OC_IO_ERROR typo?
// - is io_error intended to be signed?
// - flag enum types should be differentiated from normal enums
// - flag enum types should use the correct backing values (i.e. oc_file_open_flags_enum should use u16 not u32)
// - io api should document what errors can be returned per function

pub const panic = std.debug.FullPanic(panicImpl);
fn panicImpl(msg: []const u8, first_trace_addr: ?usize) noreturn {
    @branchHint(.cold);
    _ = first_trace_addr; // @Incomplete: stack traces
    debug.abort("panic: {s}", .{msg}, @src());
}

// shortcuts
pub const log = debug.log;
pub const assert = debug.assert;
pub const abort = debug.abort;

/// **WARNING** Erases const type info! This function only accepts const
/// pointers to avoid excessive casting when passing string literals.
/// Be careful when passing the result to API's which may modify the buffer.
pub fn toStr8(buf: []const u8) strings.Str8 {
    return strings.Str8.fromSlice(@constCast(buf));
}

//------------------------------------------------------------------------------------------
// [Orca hooks]
//------------------------------------------------------------------------------------------

const user_root = @import("app");

// TODO: document callbacks
comptime {
    exportCallback("onInit", "oc_on_init");
    exportCallback("onMouseDown", "oc_on_mouse_down");
    exportCallback("onMouseUp", "oc_on_mouse_up");
    exportCallback("onMouseEnter", "oc_on_mouse_enter");
    exportCallback("onMouseLeave", "oc_on_mouse_leave");
    exportCallback("onMouseMove", "oc_on_mouse_move");
    exportCallback("onMouseWheel", "oc_on_mouse_wheel");
    exportCallback("onKeyDown", "oc_on_key_down");
    exportCallback("onKeyUp", "oc_on_key_up");
    exportCallback("onFrameRefresh", "oc_on_frame_refresh");
    exportCallback("onResize", "oc_on_resize");
    exportCallback("onRawEvent", "oc_on_raw_event");
    exportCallback("onTerminate", "oc_on_terminate");
}

fn exportCallback(comptime handler: []const u8, comptime callback: []const u8) void {
    if (@hasDecl(user_root, handler)) {
        const func = &@field(@This(), callback);
        @export(func, .{ .name = callback });
    }
}

fn oc_on_init() callconv(.C) void {
    callHandler(user_root.onInit, .{}, @src());
}

fn oc_on_mouse_down(button: app.MouseButton) callconv(.C) void {
    callHandler(user_root.onMouseDown, .{button}, @src());
}

fn oc_on_mouse_up(button: app.MouseButton) callconv(.C) void {
    callHandler(user_root.onMouseUp, .{button}, @src());
}

fn oc_on_mouse_enter() callconv(.C) void {
    callHandler(user_root.onMouseEnter, .{}, @src());
}

fn oc_on_mouse_leave() callconv(.C) void {
    callHandler(user_root.onMouseLeave, .{}, @src());
}

fn oc_on_mouse_move(x: f32, y: f32, deltaX: f32, deltaY: f32) callconv(.C) void {
    callHandler(user_root.onMouseMove, .{ x, y, deltaX, deltaY }, @src());
}

fn oc_on_mouse_wheel(deltaX: f32, deltaY: f32) callconv(.C) void {
    callHandler(user_root.onMouseWheel, .{ deltaX, deltaY }, @src());
}

fn oc_on_key_down(scan: app.ScanCode, key: app.KeyCode) callconv(.C) void {
    callHandler(user_root.onKeyDown, .{ scan, key }, @src());
}

fn oc_on_key_up(scan: app.ScanCode, key: app.KeyCode) callconv(.C) void {
    callHandler(user_root.onKeyUp, .{ scan, key }, @src());
}

fn oc_on_frame_refresh() callconv(.C) void {
    callHandler(user_root.onFrameRefresh, .{}, @src());
}

fn oc_on_resize(width: u32, height: u32) callconv(.C) void {
    callHandler(user_root.onResize, .{ width, height }, @src());
}

fn oc_on_raw_event(c_event: *app.Event) callconv(.C) void {
    callHandler(user_root.onRawEvent, .{c_event}, @src());
}

fn oc_on_terminate() callconv(.C) void {
    callHandler(user_root.onTerminate, .{}, @src());
}

fn fatal(err: anyerror, source: std.builtin.SourceLocation) noreturn {
    debug.abort("Caught fatal {}", .{err}, source);
}

fn callHandler(func: anytype, params: anytype, source: std.builtin.SourceLocation) void {
    switch (@typeInfo(@typeInfo(@TypeOf(func)).@"fn".return_type.?)) {
        .void => @call(.auto, func, params),
        .error_union => @call(.auto, func, params) catch |e| fatal(e, source),
        else => @compileError("Orca event handler must have void return type"),
    }
}

// @Api utility is a meaningless name and the namespace should be removed, relocating it's children into the root.
//------------------------------------------------------------------------------------------
// [Utility] Utility data structures and helpers used throughout the Orca API.
//------------------------------------------------------------------------------------------

pub const math = @import("math.zig"); // [Algebra]
pub const debug = @import("debug.zig"); // [Debug]
pub const mem = @import("mem.zig"); // [Memory]
pub const List = @import("list.zig").List; // [Lists]
pub const strings = @import("strings.zig"); // [Strings]
pub const app = @import("app.zig"); // [Application]
pub const io = @import("io.zig"); // [I/O]
pub const graphics = @import("graphics.zig"); // [Graphics]

//------------------------------------------------------------------------------------------
// [UTF8] UTF8 encoding/decoding.
//------------------------------------------------------------------------------------------

/// A unicode codepoint.
pub const utf32 = u32;
/// This enum declares the possible return status of UTF8 decoding/encoding operations.
pub const utf8_status = enum(u32) {
    /// The operation was successful.
    UTF8_OK = 0,
    /// The operation unexpectedly encountered the end of the utf8 sequence.
    UTF8_OUT_OF_BOUNDS = 1,
    /// A continuation byte was encountered where a leading byte was expected.
    UTF8_UNEXPECTED_CONTINUATION_BYTE = 3,
    /// A leading byte was encountered in the middle of the encoding of utf8 codepoint.
    UTF8_UNEXPECTED_LEADING_BYTE = 4,
    /// The utf8 sequence contains an invalid byte.
    UTF8_INVALID_BYTE = 5,
    /// The operation encountered an invalid utf8 codepoint.
    UTF8_INVALID_CODEPOINT = 6,
    /// The utf8 sequence contains an overlong encoding of a utf8 codepoint.
    UTF8_OVERLONG_ENCODING = 7,
};
/// Get the size of a utf8-encoded codepoint for the first byte of the encoded sequence.
pub const utf8SizeFromLeadingChar = oc_utf8_size_from_leading_char;
extern fn oc_utf8_size_from_leading_char(
    /// The first byte of utf8 sequence.
    leadingChar: u8,
) callconv(.C) u32;
/// Get the size of the utf8 encoding of a codepoint.
pub const utf8CodepointSize = oc_utf8_codepoint_size;
extern fn oc_utf8_codepoint_size(
    /// A unicode codepoint.
    codePoint: utf32,
) callconv(.C) u32;
pub const utf8CodepointCountForString = oc_utf8_codepoint_count_for_string;
extern fn oc_utf8_codepoint_count_for_string(
    /// A utf8 encoded string.
    string: strings.Str8,
) callconv(.C) u64;
/// Get the length of the utf8 encoding of a sequence of unicode codepoints.
pub const utf8ByteCountForCodepoints = oc_utf8_byte_count_for_codepoints;
extern fn oc_utf8_byte_count_for_codepoints(
    /// A sequence of unicode codepoints.
    codePoints: strings.Str32,
) callconv(.C) u64;
/// Get the offset of the next codepoint after a given offset, in a utf8 encoded string.
pub const utf8NextOffset = oc_utf8_next_offset;
extern fn oc_utf8_next_offset(
    /// A utf8 encoded string.
    string: strings.Str8,
    /// The offset after which to look for the next codepoint, in bytes.
    byteOffset: u64,
) callconv(.C) u64;
/// Get the offset of the previous codepoint before a given offset, in a utf8 encoded string.
pub const utf8PrevOffset = oc_utf8_prev_offset;
extern fn oc_utf8_prev_offset(
    /// A utf8 encoded string.
    string: strings.Str8,
    /// The offset before which to look for the previous codepoint, in bytes.
    byteOffset: u64,
) callconv(.C) u64;
/// A type representing the result of decoding of utf8-encoded codepoint.
pub const utf8_dec = extern struct {
    /// The status of the decoding operation. If not `OC_UTF8_OK`, it describes the error that was encountered during decoding.
    status: utf8_status,
    /// The decoded codepoint.
    codepoint: utf32,
    /// The size of the utf8 sequence encoding that codepoint.
    size: u32,
};
/// Decode a utf8 encoded codepoint.
pub const utf8Decode = oc_utf8_decode;
extern fn oc_utf8_decode(
    /// A utf8-encoded codepoint.
    string: strings.Str8,
) callconv(.C) utf8_dec;
/// Decode a codepoint at a given offset in a utf8 encoded string.
pub const utf8DecodeAt = oc_utf8_decode_at;
extern fn oc_utf8_decode_at(
    /// A utf8 encoded string.
    string: strings.Str8,
    /// The offset at which to decode a codepoint.
    offset: u64,
) callconv(.C) utf8_dec;
/// Encode a unicode codepoint into a utf8 sequence.
pub const utf8Encode = oc_utf8_encode;
extern fn oc_utf8_encode(
    /// A pointer to the backing memory for the encoded sequence. This must point to a buffer big enough to encode the codepoint.
    dst: [*c]u8,
    /// The unicode codepoint to encode.
    codePoint: utf32,
) callconv(.C) strings.Str8;
/// Decode a utf8 string to a string of unicode codepoints using memory passed by the caller.
pub const utf8ToCodepoints = oc_utf8_to_codepoints;
extern fn oc_utf8_to_codepoints(
    /// The maximum number of codepoints that the backing memory can contain.
    maxCount: u64,
    /// A pointer to the backing memory for the result. This must point to a buffer capable of holding `maxCount` codepoints.
    backing: [*c]utf32,
    /// A utf8 encoded string.
    string: strings.Str8,
) callconv(.C) strings.Str32;
/// Encode a string of unicode codepoints into a utf8 string using memory passed by the caller.
pub const utf8FromCodepoints = oc_utf8_from_codepoints;
extern fn oc_utf8_from_codepoints(
    /// The maximum number of bytes that the backing memory can contain.
    maxBytes: u64,
    /// A pointer to the backing memory for the result. This must point to a buffer capable of holding `maxBytes` bytes.
    backing: [*c]u8,
    /// A string of unicode codepoints.
    codePoints: strings.Str32,
) callconv(.C) strings.Str8;
/// Decode a utf8 encoded string to a string of unicode codepoints using an arena.
pub const utf8PushToCodepoints = oc_utf8_push_to_codepoints;
extern fn oc_utf8_push_to_codepoints(
    /// The arena on which to allocate the codepoints.
    arena: [*c]mem.Arena,
    /// A utf8 encoded string.
    string: strings.Str8,
) callconv(.C) strings.Str32;
/// Encode a string of unicode codepoints into a utf8 string using an arena.
pub const utf8PushFromCodepoints = oc_utf8_push_from_codepoints;
extern fn oc_utf8_push_from_codepoints(
    /// The arena on which to allocate the utf8 encoded string.
    arena: [*c]mem.Arena,
    /// A string of unicode codepoints.
    codePoints: strings.Str32,
) callconv(.C) strings.Str8;
/// A type representing a contiguous range of unicode codepoints.
pub const unicode_range = extern struct {
    /// The first codepoint of the range.
    firstCodePoint: utf32,
    /// The number of codepoints in the range.
    count: u32,
};

// @Api UI Core & Widgets should be moved under the UI namespace
//------------------------------------------------------------------------------------------
// [UI] Graphical User Interface API.
//------------------------------------------------------------------------------------------

pub const key_state = extern struct {
    lastUpdate: u64,
    transitionCount: u32,
    repeatCount: u32,
    down: bool,
    sysClicked: bool,
    sysDoubleClicked: bool,
    sysTripleClicked: bool,
};
pub const keyboard_state = extern struct {
    keys: [349]key_state,
    mods: app.KeymodFlags,
};
pub const mouse_state = extern struct {
    lastUpdate: u64,
    posValid: bool,
    pos: math.Vec2,
    delta: math.Vec2,
    wheel: math.Vec2,
    unnamed_0: extern union {
        buttons: [5]key_state,
        unnamed_0: extern struct {
            left: key_state,
            right: key_state,
            middle: key_state,
            ext1: key_state,
            ext2: key_state,
        },
    },
};
pub const INPUT_TEXT_BACKING_SIZE: u32 = 64;
pub const text_state = extern struct {
    lastUpdate: u64,
    backing: [64]utf32,
    codePoints: strings.Str32,
};
pub const clipboard_state = extern struct {
    lastUpdate: u64,
    pastedText: strings.Str8,
};
pub const input_state = extern struct {
    frameCounter: u64,
    keyboard: keyboard_state,
    mouse: mouse_state,
    text: text_state,
    clipboard: clipboard_state,
};
pub const inputProcessEvent = oc_input_process_event;
extern fn oc_input_process_event(
    arena: [*c]mem.Arena,
    state: [*c]input_state,
    event: [*c]app.Event,
) callconv(.C) void;
pub const inputNextFrame = oc_input_next_frame;
extern fn oc_input_next_frame(
    state: [*c]input_state,
) callconv(.C) void;
pub const keyDown = oc_key_down;
extern fn oc_key_down(
    state: [*c]input_state,
    key: app.KeyCode,
) callconv(.C) bool;
pub const keyPressCount = oc_key_press_count;
extern fn oc_key_press_count(
    state: [*c]input_state,
    key: app.KeyCode,
) callconv(.C) u8;
pub const keyReleaseCount = oc_key_release_count;
extern fn oc_key_release_count(
    state: [*c]input_state,
    key: app.KeyCode,
) callconv(.C) u8;
pub const keyRepeatCount = oc_key_repeat_count;
extern fn oc_key_repeat_count(
    state: [*c]input_state,
    key: app.KeyCode,
) callconv(.C) u8;
pub const keyDownScancode = oc_key_down_scancode;
extern fn oc_key_down_scancode(
    state: [*c]input_state,
    key: app.ScanCode,
) callconv(.C) bool;
pub const keyPressCountScancode = oc_key_press_count_scancode;
extern fn oc_key_press_count_scancode(
    state: [*c]input_state,
    key: app.ScanCode,
) callconv(.C) u8;
pub const keyReleaseCountScancode = oc_key_release_count_scancode;
extern fn oc_key_release_count_scancode(
    state: [*c]input_state,
    key: app.ScanCode,
) callconv(.C) u8;
pub const keyRepeatCountScancode = oc_key_repeat_count_scancode;
extern fn oc_key_repeat_count_scancode(
    state: [*c]input_state,
    key: app.ScanCode,
) callconv(.C) u8;
pub const mouseDown = oc_mouse_down;
extern fn oc_mouse_down(
    state: [*c]input_state,
    button: app.MouseButton,
) callconv(.C) bool;
pub const mousePressed = oc_mouse_pressed;
extern fn oc_mouse_pressed(
    state: [*c]input_state,
    button: app.MouseButton,
) callconv(.C) u8;
pub const mouseReleased = oc_mouse_released;
extern fn oc_mouse_released(
    state: [*c]input_state,
    button: app.MouseButton,
) callconv(.C) u8;
pub const mouseClicked = oc_mouse_clicked;
extern fn oc_mouse_clicked(
    state: [*c]input_state,
    button: app.MouseButton,
) callconv(.C) bool;
pub const mouseDoubleClicked = oc_mouse_double_clicked;
extern fn oc_mouse_double_clicked(
    state: [*c]input_state,
    button: app.MouseButton,
) callconv(.C) bool;
pub const mousePosition = oc_mouse_position;
extern fn oc_mouse_position(
    state: [*c]input_state,
) callconv(.C) math.Vec2;
pub const mouseDelta = oc_mouse_delta;
extern fn oc_mouse_delta(
    state: [*c]input_state,
) callconv(.C) math.Vec2;
pub const mouseWheel = oc_mouse_wheel;
extern fn oc_mouse_wheel(
    state: [*c]input_state,
) callconv(.C) math.Vec2;
pub const inputTextUtf32 = oc_input_text_utf32;
extern fn oc_input_text_utf32(
    arena: [*c]mem.Arena,
    state: [*c]input_state,
) callconv(.C) strings.Str32;
pub const inputTextUtf8 = oc_input_text_utf8;
extern fn oc_input_text_utf8(
    arena: [*c]mem.Arena,
    state: [*c]input_state,
) callconv(.C) strings.Str8;
pub const clipboardPasted = oc_clipboard_pasted;
extern fn oc_clipboard_pasted(
    state: [*c]input_state,
) callconv(.C) bool;
pub const clipboardPastedText = oc_clipboard_pasted_text;
extern fn oc_clipboard_pasted_text(
    state: [*c]input_state,
) callconv(.C) strings.Str8;
pub const keyMods = oc_key_mods;
extern fn oc_key_mods(
    state: [*c]input_state,
) callconv(.C) app.KeymodFlags;

//------------------------------------------------------------------------------------------
// [UI Core] Graphical User Interface Core API.
//------------------------------------------------------------------------------------------

pub const ui_axis = enum(u32) {
    UI_AXIS_X = 0,
    UI_AXIS_Y = 1,
    UI_AXIS_COUNT = 2,
};
pub const ui_align = enum(u32) {
    UI_ALIGN_START = 0,
    UI_ALIGN_END = 1,
    UI_ALIGN_CENTER = 2,
};
pub const ui_size_kind = enum(u32) {
    UI_SIZE_CHILDREN = 0,
    UI_SIZE_TEXT = 1,
    UI_SIZE_PIXELS = 2,
    UI_SIZE_PARENT = 3,
    UI_SIZE_PARENT_MINUS_PIXELS = 4,
};
pub const ui_size = extern struct {
    kind: ui_size_kind,
    value: f32,
    relax: f32,
    minSize: f32,
};
pub const ui_overflow = enum(u32) {
    UI_OVERFLOW_CLIP = 0,
    UI_OVERFLOW_ALLOW = 1,
    UI_OVERFLOW_SCROLL = 2,
};
pub const ui_attribute = enum(u32) {
    UI_WIDTH = 0,
    UI_HEIGHT = 1,
    UI_AXIS = 2,
    UI_MARGIN_X = 3,
    UI_MARGIN_Y = 4,
    UI_SPACING = 5,
    UI_ALIGN_X = 6,
    UI_ALIGN_Y = 7,
    UI_FLOATING_X = 8,
    UI_FLOATING_Y = 9,
    UI_FLOAT_TARGET_X = 10,
    UI_FLOAT_TARGET_Y = 11,
    UI_OVERFLOW_X = 12,
    UI_OVERFLOW_Y = 13,
    UI_CONSTRAIN_X = 14,
    UI_CONSTRAIN_Y = 15,
    UI_COLOR = 16,
    UI_BG_COLOR = 17,
    UI_BORDER_COLOR = 18,
    UI_FONT = 19,
    UI_TEXT_SIZE = 20,
    UI_BORDER_SIZE = 21,
    UI_ROUNDNESS = 22,
    UI_DRAW_MASK = 23,
    UI_ANIMATION_TIME = 24,
    UI_ANIMATION_MASK = 25,
    UI_CLICK_THROUGH = 26,
    UI_ATTRIBUTE_COUNT = 27,
};
pub const ui_attribute_mask = enum(u32) {
    UI_MASK_NONE = 0,
    UI_MASK_SIZE_WIDTH = 1,
    UI_MASK_SIZE_HEIGHT = 2,
    UI_MASK_LAYOUT_AXIS = 4,
    UI_MASK_LAYOUT_ALIGN_X = 64,
    UI_MASK_LAYOUT_ALIGN_Y = 128,
    UI_MASK_LAYOUT_SPACING = 32,
    UI_MASK_LAYOUT_MARGIN_X = 8,
    UI_MASK_LAYOUT_MARGIN_Y = 16,
    UI_MASK_FLOATING_X = 256,
    UI_MASK_FLOATING_Y = 512,
    UI_MASK_FLOAT_TARGET_X = 1024,
    UI_MASK_FLOAT_TARGET_Y = 2048,
    UI_MASK_OVERFLOW_X = 4096,
    UI_MASK_OVERFLOW_Y = 8192,
    UI_MASK_CONSTRAIN_X = 16384,
    UI_MASK_CONSTRAIN_Y = 32768,
    UI_MASK_COLOR = 65536,
    UI_MASK_BG_COLOR = 131072,
    UI_MASK_BORDER_COLOR = 262144,
    UI_MASK_BORDER_SIZE = 2097152,
    UI_MASK_ROUNDNESS = 4194304,
    UI_MASK_FONT = 524288,
    UI_MASK_FONT_SIZE = 1048576,
    UI_MASK_DRAW_MASK = 8388608,
    UI_MASK_ANIMATION_TIME = 16777216,
    UI_MASK_ANIMATION_MASK = 33554432,
    UI_MASK_CLICK_THROUGH = 67108864,
};
pub const ui_layout_align = extern union {
    unnamed_0: extern struct {
        x: ui_align,
        y: ui_align,
    },
    c: [2]ui_align,
};
pub const ui_layout = extern struct {
    axis: ui_axis,
    spacing: f32,
    margin: extern union {
        unnamed_0: extern struct {
            x: f32,
            y: f32,
        },
        c: [2]f32,
    },
    @"align": ui_layout_align,
    overflow: extern union {
        unnamed_0: extern struct {
            x: ui_overflow,
            y: ui_overflow,
        },
        c: [2]ui_overflow,
    },
    constrain: extern union {
        unnamed_0: extern struct {
            x: bool,
            y: bool,
        },
        c: [2]bool,
    },
};
pub const ui_box_size = extern union {
    unnamed_0: extern struct {
        width: ui_size,
        height: ui_size,
    },
    c: [2]ui_size,
};
pub const ui_box_floating = extern union {
    unnamed_0: extern struct {
        x: bool,
        y: bool,
    },
    c: [2]bool,
};
pub const ui_draw_mask = enum(u32) {
    UI_DRAW_MASK_BACKGROUND = 1,
    UI_DRAW_MASK_BORDER = 2,
    UI_DRAW_MASK_TEXT = 4,
    UI_DRAW_MASK_PROC = 8,
};
pub const ui_style = extern struct {
    size: ui_box_size,
    layout: ui_layout,
    floating: ui_box_floating,
    floatTarget: math.Vec2,
    color: graphics.canvas.Color,
    bgColor: graphics.canvas.Color,
    borderColor: graphics.canvas.Color,
    font: graphics.canvas.Font,
    fontSize: f32,
    borderSize: f32,
    roundness: f32,
    drawMask: u32,
    animationTime: f32,
    animationMask: ui_attribute_mask,
    clickThrough: bool,
};

pub const ui_context = opaque {};
pub const ui_sig = extern struct {
    box: [*c]ui_box,
    mouse: math.Vec2,
    delta: math.Vec2,
    wheel: math.Vec2,
    lastPressedMouse: math.Vec2,
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
pub const ui_box_draw_proc = *const fn (
    arg0: [*c]ui_box,
    arg1: ?*anyopaque,
) callconv(.C) void;
pub const ui_key = extern struct {
    hash: u64,
};
pub const ui_box = extern struct {
    listElt: List.Elem,
    children: List,
    parent: [*c]ui_box,
    overlayElt: List.Elem,
    overlay: bool,
    bucketElt: List.Elem,
    key: ui_key,
    frameCounter: u64,
    keyString: strings.Str8,
    text: strings.Str8,
    tags: List,
    drawProc: ui_box_draw_proc,
    drawData: ?*anyopaque,
    rules: List,
    targetStyle: [*c]ui_style,
    style: ui_style,
    z: u32,
    floatPos: math.Vec2,
    childrenSum: [2]f32,
    spacing: [2]f32,
    minSize: [2]f32,
    rect: math.Rect,
    styleVariables: List,
    sig: ui_sig,
    fresh: bool,
    closed: bool,
    parentClosed: bool,
    dragging: bool,
    hot: bool,
    active: bool,
    scroll: math.Vec2,
    pressedMouse: math.Vec2,
    hotTransition: f32,
    activeTransition: f32,
};
pub const uiContextCreate = oc_ui_context_create;
extern fn oc_ui_context_create(
    defaultFont: graphics.canvas.Font,
) callconv(.C) ?*ui_context;
pub const uiContextDestroy = oc_ui_context_destroy;
extern fn oc_ui_context_destroy(
    context: ?*ui_context,
) callconv(.C) void;
pub const uiGetContext = oc_ui_get_context;
extern fn oc_ui_get_context() callconv(.C) ?*ui_context;
pub const uiSetContext = oc_ui_set_context;
extern fn oc_ui_set_context(
    context: ?*ui_context,
) callconv(.C) void;
pub const uiProcessEvent = oc_ui_process_event;
extern fn oc_ui_process_event(
    event: [*c]app.Event,
) callconv(.C) void;
pub const uiFrameBegin = oc_ui_frame_begin;
extern fn oc_ui_frame_begin(
    size: math.Vec2,
) callconv(.C) void;
pub const uiFrameEnd = oc_ui_frame_end;
extern fn oc_ui_frame_end() callconv(.C) void;
pub const uiDraw = oc_ui_draw;
extern fn oc_ui_draw() callconv(.C) void;
pub const uiInput = oc_ui_input;
extern fn oc_ui_input() callconv(.C) [*c]input_state;
pub const uiFrameArena = oc_ui_frame_arena;
extern fn oc_ui_frame_arena() callconv(.C) [*c]mem.Arena;
pub const uiFrameTime = oc_ui_frame_time;
extern fn oc_ui_frame_time() callconv(.C) f64;
pub const uiBoxBeginStr8 = oc_ui_box_begin_str8;
extern fn oc_ui_box_begin_str8(
    string: strings.Str8,
) callconv(.C) [*c]ui_box;
pub const uiBoxEnd = oc_ui_box_end;
extern fn oc_ui_box_end() callconv(.C) [*c]ui_box;
pub const uiBoxSetDrawProc = oc_ui_box_set_draw_proc;
extern fn oc_ui_box_set_draw_proc(
    box: [*c]ui_box,
    proc: ui_box_draw_proc,
    data: ?*anyopaque,
) callconv(.C) void;
pub const uiBoxSetText = oc_ui_box_set_text;
extern fn oc_ui_box_set_text(
    box: [*c]ui_box,
    text: strings.Str8,
) callconv(.C) void;
pub const uiBoxSetOverlay = oc_ui_box_set_overlay;
extern fn oc_ui_box_set_overlay(
    box: [*c]ui_box,
    overlay: bool,
) callconv(.C) void;
pub const uiBoxSetClosed = oc_ui_box_set_closed;
extern fn oc_ui_box_set_closed(
    box: [*c]ui_box,
    closed: bool,
) callconv(.C) void;
pub const uiBoxUserDataGet = oc_ui_box_user_data_get;
extern fn oc_ui_box_user_data_get(
    box: [*c]ui_box,
) callconv(.C) [*c]u8;
pub const uiBoxUserDataPush = oc_ui_box_user_data_push;
extern fn oc_ui_box_user_data_push(
    box: [*c]ui_box,
    size: u64,
) callconv(.C) [*c]u8;
pub const uiBoxRequestFocus = oc_ui_box_request_focus;
extern fn oc_ui_box_request_focus(
    box: [*c]ui_box,
) callconv(.C) void;
pub const uiBoxReleaseFocus = oc_ui_box_release_focus;
extern fn oc_ui_box_release_focus(
    box: [*c]ui_box,
) callconv(.C) void;
pub const uiBoxGetSig = oc_ui_box_get_sig;
extern fn oc_ui_box_get_sig(
    box: [*c]ui_box,
) callconv(.C) ui_sig;
pub const uiSetDrawProc = oc_ui_set_draw_proc;
extern fn oc_ui_set_draw_proc(
    proc: ui_box_draw_proc,
    data: ?*anyopaque,
) callconv(.C) void;
pub const uiSetText = oc_ui_set_text;
extern fn oc_ui_set_text(
    text: strings.Str8,
) callconv(.C) void;
pub const uiSetOverlay = oc_ui_set_overlay;
extern fn oc_ui_set_overlay(
    overlay: bool,
) callconv(.C) void;
pub const uiSetClosed = oc_ui_set_closed;
extern fn oc_ui_set_closed(
    closed: bool,
) callconv(.C) void;
pub const uiUserDataGet = oc_ui_user_data_get;
extern fn oc_ui_user_data_get() callconv(.C) [*c]u8;
pub const uiUserDataPush = oc_ui_user_data_push;
extern fn oc_ui_user_data_push(
    size: u64,
) callconv(.C) [*c]u8;
pub const uiRequestFocus = oc_ui_request_focus;
extern fn oc_ui_request_focus() callconv(.C) void;
pub const uiReleaseFocus = oc_ui_release_focus;
extern fn oc_ui_release_focus() callconv(.C) void;
pub const uiGetSig = oc_ui_get_sig;
extern fn oc_ui_get_sig() callconv(.C) ui_sig;
pub const uiBoxTagStr8 = oc_ui_box_tag_str8;
extern fn oc_ui_box_tag_str8(
    box: [*c]ui_box,
    string: strings.Str8,
) callconv(.C) void;
pub const uiTagStr8 = oc_ui_tag_str8;
extern fn oc_ui_tag_str8(
    string: strings.Str8,
) callconv(.C) void;
pub const uiTagNextStr8 = oc_ui_tag_next_str8;
extern fn oc_ui_tag_next_str8(
    string: strings.Str8,
) callconv(.C) void;
pub const uiStyleRuleBegin = oc_ui_style_rule_begin;
extern fn oc_ui_style_rule_begin(
    pattern: strings.Str8,
) callconv(.C) void;
pub const uiStyleRuleEnd = oc_ui_style_rule_end;
extern fn oc_ui_style_rule_end() callconv(.C) void;
pub const uiStyleSetI32 = oc_ui_style_set_i32;
extern fn oc_ui_style_set_i32(
    attr: ui_attribute,
    i: i32,
) callconv(.C) void;
pub const uiStyleSetF32 = oc_ui_style_set_f32;
extern fn oc_ui_style_set_f32(
    attr: ui_attribute,
    f: f32,
) callconv(.C) void;
pub const uiStyleSetColor = oc_ui_style_set_color;
extern fn oc_ui_style_set_color(
    attr: ui_attribute,
    color: graphics.canvas.Color,
) callconv(.C) void;
pub const uiStyleSetFont = oc_ui_style_set_font;
extern fn oc_ui_style_set_font(
    attr: ui_attribute,
    font: graphics.canvas.Font,
) callconv(.C) void;
pub const uiStyleSetSize = oc_ui_style_set_size;
extern fn oc_ui_style_set_size(
    attr: ui_attribute,
    size: ui_size,
) callconv(.C) void;
pub const uiStyleSetVarStr8 = oc_ui_style_set_var_str8;
extern fn oc_ui_style_set_var_str8(
    attr: ui_attribute,
    @"var": strings.Str8,
) callconv(.C) void;
pub const uiStyleSetVar = oc_ui_style_set_var;
extern fn oc_ui_style_set_var(
    attr: ui_attribute,
    @"var": [*c]u8,
) callconv(.C) void;
pub const uiVarDefaultI32Str8 = oc_ui_var_default_i32_str8;
extern fn oc_ui_var_default_i32_str8(
    name: strings.Str8,
    i: i32,
) callconv(.C) void;
pub const uiVarDefaultF32Str8 = oc_ui_var_default_f32_str8;
extern fn oc_ui_var_default_f32_str8(
    name: strings.Str8,
    f: f32,
) callconv(.C) void;
pub const uiVarDefaultSizeStr8 = oc_ui_var_default_size_str8;
extern fn oc_ui_var_default_size_str8(
    name: strings.Str8,
    size: ui_size,
) callconv(.C) void;
pub const uiVarDefaultColorStr8 = oc_ui_var_default_color_str8;
extern fn oc_ui_var_default_color_str8(
    name: strings.Str8,
    color: graphics.canvas.Color,
) callconv(.C) void;
pub const uiVarDefaultFontStr8 = oc_ui_var_default_font_str8;
extern fn oc_ui_var_default_font_str8(
    name: strings.Str8,
    font: graphics.canvas.Font,
) callconv(.C) void;
pub const uiVarDefaultStr8 = oc_ui_var_default_str8;
extern fn oc_ui_var_default_str8(
    name: strings.Str8,
    src: strings.Str8,
) callconv(.C) void;
pub const uiVarDefaultI32 = oc_ui_var_default_i32;
extern fn oc_ui_var_default_i32(
    name: [*c]u8,
    i: i32,
) callconv(.C) void;
pub const uiVarDefaultF32 = oc_ui_var_default_f32;
extern fn oc_ui_var_default_f32(
    name: [*c]u8,
    f: f32,
) callconv(.C) void;
pub const uiVarDefaultSize = oc_ui_var_default_size;
extern fn oc_ui_var_default_size(
    name: [*c]u8,
    size: ui_size,
) callconv(.C) void;
pub const uiVarDefaultColor = oc_ui_var_default_color;
extern fn oc_ui_var_default_color(
    name: [*c]u8,
    color: graphics.canvas.Color,
) callconv(.C) void;
pub const uiVarDefaultFont = oc_ui_var_default_font;
extern fn oc_ui_var_default_font(
    name: [*c]u8,
    font: graphics.canvas.Font,
) callconv(.C) void;
pub const uiVarDefault = oc_ui_var_default;
extern fn oc_ui_var_default(
    name: [*c]u8,
    src: [*c]u8,
) callconv(.C) void;
pub const uiVarSetI32Str8 = oc_ui_var_set_i32_str8;
extern fn oc_ui_var_set_i32_str8(
    name: strings.Str8,
    i: i32,
) callconv(.C) void;
pub const uiVarSetF32Str8 = oc_ui_var_set_f32_str8;
extern fn oc_ui_var_set_f32_str8(
    name: strings.Str8,
    f: f32,
) callconv(.C) void;
pub const uiVarSetSizeStr8 = oc_ui_var_set_size_str8;
extern fn oc_ui_var_set_size_str8(
    name: strings.Str8,
    size: ui_size,
) callconv(.C) void;
pub const uiVarSetColorStr8 = oc_ui_var_set_color_str8;
extern fn oc_ui_var_set_color_str8(
    name: strings.Str8,
    color: graphics.canvas.Color,
) callconv(.C) void;
pub const uiVarSetFontStr8 = oc_ui_var_set_font_str8;
extern fn oc_ui_var_set_font_str8(
    name: strings.Str8,
    font: graphics.canvas.Font,
) callconv(.C) void;
pub const uiVarSetStr8 = oc_ui_var_set_str8;
extern fn oc_ui_var_set_str8(
    name: strings.Str8,
    src: strings.Str8,
) callconv(.C) void;
pub const uiVarSetI32 = oc_ui_var_set_i32;
extern fn oc_ui_var_set_i32(
    name: [*c]u8,
    i: i32,
) callconv(.C) void;
pub const uiVarSetF32 = oc_ui_var_set_f32;
extern fn oc_ui_var_set_f32(
    name: [*c]u8,
    f: f32,
) callconv(.C) void;
pub const uiVarSetSize = oc_ui_var_set_size;
extern fn oc_ui_var_set_size(
    name: [*c]u8,
    size: ui_size,
) callconv(.C) void;
pub const uiVarSetColor = oc_ui_var_set_color;
extern fn oc_ui_var_set_color(
    name: [*c]u8,
    color: graphics.canvas.Color,
) callconv(.C) void;
pub const uiVarSetFont = oc_ui_var_set_font;
extern fn oc_ui_var_set_font(
    name: [*c]u8,
    font: graphics.canvas.Font,
) callconv(.C) void;
pub const uiVarSet = oc_ui_var_set;
extern fn oc_ui_var_set(
    name: [*c]u8,
    src: [*c]u8,
) callconv(.C) void;
pub const uiVarGetI32Str8 = oc_ui_var_get_i32_str8;
extern fn oc_ui_var_get_i32_str8(
    name: strings.Str8,
) callconv(.C) i32;
pub const uiVarGetF32Str8 = oc_ui_var_get_f32_str8;
extern fn oc_ui_var_get_f32_str8(
    name: strings.Str8,
) callconv(.C) f32;
pub const uiVarGetSizeStr8 = oc_ui_var_get_size_str8;
extern fn oc_ui_var_get_size_str8(
    name: strings.Str8,
) callconv(.C) ui_size;
pub const uiVarGetColorStr8 = oc_ui_var_get_color_str8;
extern fn oc_ui_var_get_color_str8(
    name: strings.Str8,
) callconv(.C) graphics.canvas.Color;
pub const uiVarGetFontStr8 = oc_ui_var_get_font_str8;
extern fn oc_ui_var_get_font_str8(
    name: strings.Str8,
) callconv(.C) graphics.canvas.Font;
pub const uiVarGetI32 = oc_ui_var_get_i32;
extern fn oc_ui_var_get_i32(
    name: [*c]u8,
) callconv(.C) i32;
pub const uiVarGetF32 = oc_ui_var_get_f32;
extern fn oc_ui_var_get_f32(
    name: [*c]u8,
) callconv(.C) f32;
pub const uiVarGetSize = oc_ui_var_get_size;
extern fn oc_ui_var_get_size(
    name: [*c]u8,
) callconv(.C) ui_size;
pub const uiVarGetColor = oc_ui_var_get_color;
extern fn oc_ui_var_get_color(
    name: [*c]u8,
) callconv(.C) graphics.canvas.Color;
pub const uiVarGetFont = oc_ui_var_get_font;
extern fn oc_ui_var_get_font(
    name: [*c]u8,
) callconv(.C) graphics.canvas.Font;
pub const uiThemeDark = oc_ui_theme_dark;
extern fn oc_ui_theme_dark() callconv(.C) void;
pub const uiThemeLight = oc_ui_theme_light;
extern fn oc_ui_theme_light() callconv(.C) void;

//------------------------------------------------------------------------------------------
// [UI Widgets] Graphical User Interface Widgets.
//------------------------------------------------------------------------------------------

pub const uiLabel = oc_ui_label;
extern fn oc_ui_label(
    key: [*c]u8,
    label: [*c]u8,
) callconv(.C) ui_sig;
pub const uiLabelStr8 = oc_ui_label_str8;
extern fn oc_ui_label_str8(
    key: strings.Str8,
    label: strings.Str8,
) callconv(.C) ui_sig;
pub const uiButton = oc_ui_button;
extern fn oc_ui_button(
    key: [*c]u8,
    text: [*c]u8,
) callconv(.C) ui_sig;
pub const uiButtonStr8 = oc_ui_button_str8;
extern fn oc_ui_button_str8(
    key: strings.Str8,
    text: strings.Str8,
) callconv(.C) ui_sig;
pub const uiCheckbox = oc_ui_checkbox;
extern fn oc_ui_checkbox(
    key: [*c]u8,
    checked: [*c]bool,
) callconv(.C) ui_sig;
pub const uiCheckboxStr8 = oc_ui_checkbox_str8;
extern fn oc_ui_checkbox_str8(
    key: strings.Str8,
    checked: [*c]bool,
) callconv(.C) ui_sig;
pub const uiSlider = oc_ui_slider;
extern fn oc_ui_slider(
    name: [*c]u8,
    value: [*c]f32,
) callconv(.C) [*c]ui_box;
pub const uiSliderStr8 = oc_ui_slider_str8;
extern fn oc_ui_slider_str8(
    name: strings.Str8,
    value: [*c]f32,
) callconv(.C) [*c]ui_box;
pub const uiTooltip = oc_ui_tooltip;
extern fn oc_ui_tooltip(
    key: [*c]u8,
    text: [*c]u8,
) callconv(.C) void;
pub const uiTooltipStr8 = oc_ui_tooltip_str8;
extern fn oc_ui_tooltip_str8(
    key: strings.Str8,
    text: strings.Str8,
) callconv(.C) void;
pub const uiMenuBarBegin = oc_ui_menu_bar_begin;
extern fn oc_ui_menu_bar_begin(
    key: [*c]u8,
) callconv(.C) void;
pub const uiMenuBarBeginStr8 = oc_ui_menu_bar_begin_str8;
extern fn oc_ui_menu_bar_begin_str8(
    key: strings.Str8,
) callconv(.C) void;
pub const uiMenuBarEnd = oc_ui_menu_bar_end;
extern fn oc_ui_menu_bar_end() callconv(.C) void;
pub const uiMenuBegin = oc_ui_menu_begin;
extern fn oc_ui_menu_begin(
    key: [*c]u8,
    name: [*c]u8,
) callconv(.C) void;
pub const uiMenuBeginStr8 = oc_ui_menu_begin_str8;
extern fn oc_ui_menu_begin_str8(
    key: strings.Str8,
    name: strings.Str8,
) callconv(.C) void;
pub const uiMenuEnd = oc_ui_menu_end;
extern fn oc_ui_menu_end() callconv(.C) void;
pub const uiMenuButton = oc_ui_menu_button;
extern fn oc_ui_menu_button(
    key: [*c]u8,
    text: [*c]u8,
) callconv(.C) ui_sig;
pub const uiMenuButtonStr8 = oc_ui_menu_button_str8;
extern fn oc_ui_menu_button_str8(
    key: strings.Str8,
    text: strings.Str8,
) callconv(.C) ui_sig;
pub const ui_text_box_result = extern struct {
    changed: bool,
    accepted: bool,
    text: strings.Str8,
    box: [*c]ui_box,
};
pub const ui_edit_move = enum(u32) {
    UI_EDIT_MOVE_NONE = 0,
    UI_EDIT_MOVE_CHAR = 1,
    UI_EDIT_MOVE_WORD = 2,
    UI_EDIT_MOVE_LINE = 3,
};
pub const ui_text_box_info = extern struct {
    text: strings.Str8,
    defaultText: strings.Str8,
    cursor: i32,
    mark: i32,
    selectionMode: ui_edit_move,
    wordSelectionInitialCursor: i32,
    wordSelectionInitialMark: i32,
    firstDisplayedChar: i32,
    cursorBlinkStart: f64,
};
pub const uiTextBox = oc_ui_text_box;
extern fn oc_ui_text_box(
    key: [*c]u8,
    arena: [*c]mem.Arena,
    info: [*c]ui_text_box_info,
) callconv(.C) ui_text_box_result;
pub const uiTextBoxStr8 = oc_ui_text_box_str8;
extern fn oc_ui_text_box_str8(
    key: strings.Str8,
    arena: [*c]mem.Arena,
    info: [*c]ui_text_box_info,
) callconv(.C) ui_text_box_result;
pub const ui_select_popup_info = extern struct {
    changed: bool,
    selectedIndex: i32,
    optionCount: i32,
    options: [*c]strings.Str8,
    placeholder: strings.Str8,
};
pub const uiSelectPopup = oc_ui_select_popup;
extern fn oc_ui_select_popup(
    key: [*c]u8,
    info: [*c]ui_select_popup_info,
) callconv(.C) ui_select_popup_info;
pub const uiSelectPopupStr8 = oc_ui_select_popup_str8;
extern fn oc_ui_select_popup_str8(
    key: strings.Str8,
    info: [*c]ui_select_popup_info,
) callconv(.C) ui_select_popup_info;
pub const ui_radio_group_info = extern struct {
    changed: bool,
    selectedIndex: i32,
    optionCount: i32,
    options: [*c]strings.Str8,
};
pub const uiRadioGroup = oc_ui_radio_group;
extern fn oc_ui_radio_group(
    key: [*c]u8,
    info: [*c]ui_radio_group_info,
) callconv(.C) ui_radio_group_info;
pub const uiRadioGroupStr8 = oc_ui_radio_group_str8;
extern fn oc_ui_radio_group_str8(
    key: strings.Str8,
    info: [*c]ui_radio_group_info,
) callconv(.C) ui_radio_group_info;
