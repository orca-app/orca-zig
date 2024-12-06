///////////////////////////////////////////////////////////////////////////////
//
//  Orca
//  Copyright 2023 Martin Fouilleul and the Orca project contributors
//  See LICENSE.txt for licensing information
//
///////////////////////////////////////////////////////////////////////////////

const std = @import("std");
const builtin = @import("builtin");

//------------------------------------------------------------------------------------------
// [DEBUG] Logging
//------------------------------------------------------------------------------------------

pub const log = struct {
    pub const Level = enum(c_uint) {
        Error,
        Warning,
        Info,
    };

    pub const Output = opaque {
        extern var OC_LOG_DEFAULT_OUTPUT: ?*Output;
        extern fn oc_log_set_output(output: *Output) void;

        pub inline fn default() ?*Output {
            return OC_LOG_DEFAULT_OUTPUT;
        }

        const set = oc_log_set_output;
    };

    extern fn oc_log_set_level(level: Level) void;
    extern fn oc_log_ext(level: Level, function: [*]const u8, file: [*]const u8, line: c_int, fmt: [*]const u8, ...) void;

    const setLevel = oc_log_set_level;

    pub fn info(comptime fmt: []const u8, args: anytype, source: std.builtin.SourceLocation) void {
        ext(Level.Info, fmt, args, source);
    }

    pub fn warn(comptime fmt: []const u8, args: anytype, source: std.builtin.SourceLocation) void {
        ext(Level.Warning, fmt, args, source);
    }

    pub fn err(comptime fmt: []const u8, args: anytype, source: std.builtin.SourceLocation) void {
        ext(Level.Error, fmt, args, source);
    }

    pub fn ext(comptime level: Level, comptime fmt: []const u8, args: anytype, source: std.builtin.SourceLocation) void {
        var format_buf: [512:0]u8 = undefined;
        _ = std.fmt.bufPrintZ(&format_buf, fmt, args) catch 0; // just discard NoSpaceLeft error for now

        const line: c_int = @intCast(source.line);
        oc_log_ext(level, source.fn_name.ptr, source.file.ptr, line, format_buf[0..].ptr);
    }
};

//------------------------------------------------------------------------------------------
// [DEBUG] Assert/Abort
//------------------------------------------------------------------------------------------

extern fn oc_abort_ext(file: [*]const u8, function: [*]const u8, line: c_int, fmt: [*]const u8, ...) void;
extern fn oc_assert_fail(file: [*]const u8, function: [*]const u8, line: c_int, src: [*]const u8, fmt: [*]const u8, ...) void;

pub fn assert(condition: bool, comptime fmt: []const u8, args: anytype, source: std.builtin.SourceLocation) void {
    if (builtin.mode == .Debug and condition == false) {
        var format_buf: [512:0]u8 = undefined;
        _ = std.fmt.bufPrintZ(&format_buf, fmt, args) catch 0;

        const line: c_int = @intCast(source.line);
        oc_assert_fail(source.file.ptr, source.fn_name.ptr, line, "assertion failed", format_buf[0..].ptr);
    }
}

pub fn abort(comptime fmt: []const u8, args: anytype, source: std.builtin.SourceLocation) noreturn {
    var format_buf: [512:0]u8 = undefined;
    _ = std.fmt.bufPrintZ(&format_buf, fmt, args) catch 0;

    const line: c_int = @intCast(source.line);
    oc_abort_ext(source.file.ptr, source.fn_name.ptr, line, format_buf[0..].ptr);
    unreachable;
}
