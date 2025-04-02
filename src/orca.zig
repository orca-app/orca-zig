const std = @import("std");

// @Api api.json wishlist (in order of importance):
// - format documentation
// - format and api versioning!!!
// - specify pointer types (single/multi-item, nullable, mutable, etc...)
// - change module brief to doc for consistency
// - remove unnamed enums, create a dedicated "constant" kind instead
// - missing OC_UNICODE_RANGE values
// - missing OC_UI_THEME values
// - missing oc_clock types
// - oc_pool and oc_window are missing typename entries
// - UI APIs missing documentation
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
pub const ui = @import("ui.zig"); // [UI]

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

// @Api api.json missing clock stuff
pub const clock = struct {
    const Kind = enum(c_int) {
        /// clock that increment monotonically
        monotonic,
        /// clock that increment monotonically during uptime
        uptime,
        /// clock that is driven by the platform time
        date,
    };

    pub const time = oc_clock_time;
    extern fn oc_clock_time(clock: Kind) f64;
};
