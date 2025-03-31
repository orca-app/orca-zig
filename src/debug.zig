//! Helpers for logging, asserting and aborting.

pub const log = struct {
    /// Constants allowing to specify the level of logging verbosity.
    pub const Level = enum(u32) {
        /// Only errors are logged.
        err = 0,
        /// Only warnings and errors are logged.
        warning = 1,
        /// All messages are logged.
        info = 2,
    };

    /// Set the logging verbosity.
    pub const setLevel = oc_log_set_level;
    extern fn oc_log_set_level(
        /// The desired logging level. Messages whose level is below this threshold will not be logged.
        level: Level,
    ) callconv(.C) void;

    /// Log a informative message to the console.
    pub fn info(comptime fmt: []const u8, args: anytype, source: SourceLocation) void {
        ext(.info, fmt, args, source);
    }

    /// Log a warning to the console.
    pub fn warn(comptime fmt: []const u8, args: anytype, source: SourceLocation) void {
        ext(.warning, fmt, args, source);
    }

    /// Log an error to the console.
    pub fn err(comptime fmt: []const u8, args: anytype, source: SourceLocation) void {
        ext(.err, fmt, args, source);
    }

    /// Log a message to the console.
    pub fn ext(comptime level: Level, comptime fmt: []const u8, args: anytype, source: SourceLocation) void {
        var format_buf: [512:0]u8 = undefined;
        _ = std.fmt.bufPrintZ(&format_buf, fmt, args) catch {}; // @Cleanup just discard NoSpaceLeft error for now
        oc_log_ext(
            level,
            @constCast(source.fn_name),
            @constCast(source.file),
            @intCast(source.line),
            format_buf[0..],
        );
    }
    // @Api params should be const
    extern fn oc_log_ext(
        /// The logging level of the message.
        level: Level,
        /// The name of the function the message originated from
        function: [*c]u8,
        /// The name of the source file the message originated from
        file: [*c]u8,
        /// The source line the message originated from
        line: i32,
        /// The format string of the message, similar to `printf()`.
        fmt: [*c]u8,
        /// Additional arguments of the message
        ...,
    ) callconv(.C) void;
};

/// Test a given condition, and abort the application if it is false.
pub fn assert(condition: bool, comptime fmt: []const u8, args: anytype, source: SourceLocation) void {
    if (builtin.mode == .Debug and !condition) {
        var format_buf: [512:0]u8 = undefined;
        _ = std.fmt.bufPrintZ(&format_buf, fmt, args) catch {}; // @Cleanup just discard NoSpaceLeft error for now
        oc_assert_fail(
            @constCast(source.file),
            @constCast(source.fn_name),
            @intCast(source.line),
            // @Improvement if the bindings are modified to not take over the root,
            // we can conditionally embed the source file and include the exact line here
            // since `source` is comptime known.
            @constCast(""),
            format_buf[0..],
        );
        unreachable;
    }
}

// @Api typo
// @Api should be noreturn
// @Api params should be const
/// Tigger a failed assertion. This aborts the application, showing the failed assertion and an error message.
extern fn oc_assert_fail(
    /// The name of the source file the failed assertion originates from.
    file: [*c]u8,
    /// The name of the function the failed assertion originates from.
    function: [*c]u8,
    /// The source line the failed assertion originates from.
    line: i32,
    /// The source code of the failed assert condition.
    src: [*c]u8,
    /// The format string of the error message, similar to `printf()`.
    fmt: [*c]u8,
    /// Additional arguments for the error message.
    ...,
) callconv(.C) void;

/// Abort the application, showing an error message.
pub fn abort(comptime fmt: []const u8, args: anytype, source: SourceLocation) noreturn {
    var format_buf: [512:0]u8 = undefined;
    _ = std.fmt.bufPrintZ(&format_buf, fmt, args) catch {}; // @Cleanup just discard NoSpaceLeft error for now
    oc_abort_ext(
        @constCast(source.file),
        @constCast(source.fn_name),
        @intCast(source.line),
        format_buf[0..],
    );
    unreachable;
}

// @Api should be noreturn
// @Api params should be const
/// Abort the application, showing an error message.
extern fn oc_abort_ext(
    /// The name of the source file the abort originates from.
    file: [*c]u8,
    /// The name of the function the abort originates from.
    function: [*c]u8,
    /// The source line the abort originates from.
    line: i32,
    /// The format string of the abort message similar to `printf()`.
    fmt: [*c]u8,
    /// Additional arguments for the abort message.
    ...,
) callconv(.C) void;

const std = @import("std");
const builtin = @import("builtin");
const SourceLocation = std.builtin.SourceLocation;
