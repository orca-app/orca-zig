const std = @import("std");

// @Cleanup convert @Api tags into issues in the orca repository
// @Incomplete add doc comments for return values

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
    _ = first_trace_addr; // @Incomplete: stack trace
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

// @Api utility is a meaningless name and the namespace should be removed, relocating it's children into the root.
//------------------------------------------------------------------------------------------
// [Utility] Utility data structures and helpers used throughout the Orca API.
//------------------------------------------------------------------------------------------

pub const math = @import("math.zig"); // [Algebra]
pub const debug = @import("debug.zig"); // [Debug]
pub const mem = @import("mem.zig"); // [Memory]
pub const List = @import("list.zig").List; // [Lists]
pub const strings = @import("strings.zig"); // [Strings]
pub const utf8 = @import("utf8.zig"); // [UTF8]

pub const app = @import("app.zig"); // [Application]
pub const io = @import("io.zig"); // [I/O]
pub const graphics = @import("graphics.zig"); // [Graphics]
pub const ui = @import("ui.zig"); // [UI]

// @Api missing clock stuff
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

//------------------------------------------------------------------------------------------
// [Orca hooks]
//------------------------------------------------------------------------------------------

const user_root = @import("user_root");

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

fn callHandler(func: anytype, params: anytype, source: std.builtin.SourceLocation) void {
    switch (@typeInfo(@typeInfo(@TypeOf(func)).@"fn".return_type.?)) {
        .void => @call(.auto, func, params),
        .error_union => @call(.auto, func, params) catch |e|
            debug.abort("Caught error: {}", .{e}, source), // @Incomplete error return trace
        else => @compileError("Orca event handler must have void return type"),
    }
}
