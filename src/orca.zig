const std = @import("std");

// @Cleanup convert @Api tags into issues in the orca repository
// @Incomplete add doc comments for return values

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

const root = @import("root");

// @Incomplete: document hooks
/// Should only be called once in your application, and must be within a comptime block.
pub fn exportEventHandlers() void {
    exportHandler("onInit", "oc_on_init");
    exportHandler("onMouseDown", "oc_on_mouse_down");
    exportHandler("onMouseUp", "oc_on_mouse_up");
    exportHandler("onMouseEnter", "oc_on_mouse_enter");
    exportHandler("onMouseLeave", "oc_on_mouse_leave");
    exportHandler("onMouseMove", "oc_on_mouse_move");
    exportHandler("onMouseWheel", "oc_on_mouse_wheel");
    exportHandler("onKeyDown", "oc_on_key_down");
    exportHandler("onKeyUp", "oc_on_key_up");
    exportHandler("onFrameRefresh", "oc_on_frame_refresh");
    exportHandler("onResize", "oc_on_resize");
    exportHandler("onRawEvent", "oc_on_raw_event");
    exportHandler("onTerminate", "oc_on_terminate");
}

fn exportHandler(
    comptime zig_handler: []const u8,
    comptime c_wrapper: []const u8,
) void {
    if (@hasDecl(root, zig_handler)) {
        const func = &@field(@This(), c_wrapper);
        @export(func, .{ .name = c_wrapper });
    }
}

fn oc_on_init() callconv(.C) void {
    callHandler(root.onInit, .{}, @src());
}

fn oc_on_mouse_down(button: app.MouseButton) callconv(.C) void {
    callHandler(root.onMouseDown, .{button}, @src());
}

fn oc_on_mouse_up(button: app.MouseButton) callconv(.C) void {
    callHandler(root.onMouseUp, .{button}, @src());
}

fn oc_on_mouse_enter() callconv(.C) void {
    callHandler(root.onMouseEnter, .{}, @src());
}

fn oc_on_mouse_leave() callconv(.C) void {
    callHandler(root.onMouseLeave, .{}, @src());
}

fn oc_on_mouse_move(x: f32, y: f32, deltaX: f32, deltaY: f32) callconv(.C) void {
    callHandler(root.onMouseMove, .{ x, y, deltaX, deltaY }, @src());
}

fn oc_on_mouse_wheel(deltaX: f32, deltaY: f32) callconv(.C) void {
    callHandler(root.onMouseWheel, .{ deltaX, deltaY }, @src());
}

fn oc_on_key_down(scan: app.ScanCode, key: app.KeyCode) callconv(.C) void {
    callHandler(root.onKeyDown, .{ scan, key }, @src());
}

fn oc_on_key_up(scan: app.ScanCode, key: app.KeyCode) callconv(.C) void {
    callHandler(root.onKeyUp, .{ scan, key }, @src());
}

fn oc_on_frame_refresh() callconv(.C) void {
    callHandler(root.onFrameRefresh, .{}, @src());
}

fn oc_on_resize(width: u32, height: u32) callconv(.C) void {
    callHandler(root.onResize, .{ width, height }, @src());
}

fn oc_on_raw_event(c_event: *app.Event) callconv(.C) void {
    callHandler(root.onRawEvent, .{c_event}, @src());
}

fn oc_on_terminate() callconv(.C) void {
    callHandler(root.onTerminate, .{}, @src());
}

fn callHandler(func: anytype, params: anytype, source: std.builtin.SourceLocation) void {
    switch (@typeInfo(@typeInfo(@TypeOf(func)).@"fn".return_type.?)) {
        .void => @call(.auto, func, params),
        .error_union => @call(.auto, func, params) catch |e|
            debug.abort("Caught error: {}", .{e}, source), // @Incomplete error return trace
        else => @compileError("Orca event handler must have void return type"),
    }
}
