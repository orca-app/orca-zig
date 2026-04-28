//! API for opening, reading and writing files.

const oc = @import("../orca.zig");
const std = @import("std");

/// An opaque handle identifying an opened file.
pub const File = enum(u64) {
    _,

    /// Returns a `nil` file handle
    pub fn nil() File {
        var out: File = undefined;
        oc_file_nil(&out);
        return out;
    }

    /// Test if a file handle is `nil`.
    pub const isNil = oc_file_is_nil;

    // @Api should be marked as a bitflags type
    /// The type of file open flags describing file open options.
    pub const OpenFlags = packed struct(u16) {
        _pad1: u1 = 0,

        /// Open the file in 'append' mode. All writes append data at the end of the file.
        append: bool = false,
        /// Truncate the file to 0 bytes when opening.
        truncate: bool = false,
        /// Create the file if it does not exist.
        create: bool = false,
        /// If the file is a symlink, open the symlink itself instead of following it.
        symlink: bool = false,
        /// If the file is a symlink, the call to open will fail.
        no_follow: bool = false,
        /// Reserved.
        restrict: bool = false,

        _pad2: u9 = 0,
    };

    // @Api should be marked as a bitflags type
    /// This type describes the access permissions of a file handle.
    pub const AccessFlags = packed struct(u16) {
        _pad1: u1 = 0,

        /// The file handle can be used for reading from the file.
        read: bool = true,
        /// The file handle can be used for writing to the file.
        write: bool = false,

        _pad2: u13 = 0,
    };

    /// Open a file in the applications' default directory subtree.
    pub fn open(
        /// The path of the file, relative to the applications' default directory.
        path: []const u8,
        /// The request access rights for the file.
        rights: AccessFlags,
        /// Flags controlling various options for the open operation. See `oc_file_open_flags`.
        flags: OpenFlags,
    ) oc.io.Error!File {
        var file: File = undefined;
        oc_file_open(&file, oc.toStr8(path), rights, flags);
        try file.lastError();
        return file;
    }

    pub fn openWithRequest(
        path: []const u8,
        rights: AccessFlags,
        flags: OpenFlags,
    ) oc.io.Error!File {
        var file: File = undefined;
        oc_file_open_with_request(&file, oc.toStr8(path), rights, flags);
        try file.lastError();
        return file;
    }

    /// Open a file in a given directory's subtree.
    pub fn openAt(
        /// A directory handle identifying the root of the open operation.
        dir: File,
        /// The path of the file to open, relative to `dir`.
        path: []const u8,
        /// The request access rights for the file.
        rights: AccessFlags,
        /// Flags controlling various options for the open operation. See `oc_file_open_flags`.
        flags: OpenFlags,
    ) oc.io.Error!File {
        var file: File = undefined;
        oc_file_open_at(&file, dir, oc.toStr8(path), rights, flags);
        try file.lastError();
        return file;
    }

    /// Close a file.
    pub const close = oc_file_close;

    /// Get the current position in a file.
    pub fn pos(file: File) oc.io.Error!i64 {
        const position = oc_file_pos(file);
        try file.lastError();
        return position;
    }

    /// This enum is used in `oc_file_seek()` to specify the starting point of the seek operation.
    pub const Whence = enum(u32) {
        /// Set the file position relative to the beginning of the file.
        set = 0,
        /// Set the file position relative to the end of the file.
        end = 1,
        /// Set the file position relative to the current position.
        current = 2,
    };

    /// Set the current position in a file.
    pub fn seek(
        /// A handle to the file.
        file: File,
        /// The offset at which to move the file position,
        /// relative to the base position indicated by `whence`.
        offset: i64,
        /// The base position for the seek operation.
        whence: Whence,
    ) oc.io.Error!i64 {
        const position = oc_file_seek(file, offset, whence);
        try file.lastError();
        return position;
    }

    /// Write data to a file.
    pub fn write(file: File, buffer: []const u8) oc.io.Error!usize {
        const n = oc_file_write(file, buffer.len, @constCast(buffer.ptr));
        try file.lastError();
        // while oc_file_write returns a u64, buffer.len is a usize, so n shouldn't be greater than a usize
        std.debug.assert(n <= std.math.maxInt(usize)); // if this fails it's a bug in the bindings!
        return @intCast(n);
    }

    /// Read from a file.
    pub fn read(file: File, buffer: []u8) oc.io.Error!usize {
        const n = oc_file_read(file, buffer.len, buffer.ptr);
        try file.lastError();
        // while oc_file_read returns a u64, buffer.len is a usize, so n shouldn't be greater than a usize
        std.debug.assert(n <= std.math.maxInt(usize)); // if this fails it's a bug in the bindings!
        return @intCast(n);
    }

    /// Adapts a `File` to `std.Io.Writer`. The last orca error from a failed
    /// write is preserved in `err` so callers can recover details after
    /// `error.WriteFailed`.
    pub const Writer = struct {
        file: File,
        err: ?oc.io.Error = null,
        interface: std.Io.Writer,

        pub fn init(file: File, buffer: []u8) Writer {
            return .{
                .file = file,
                .interface = .{
                    .vtable = &.{ .drain = drain },
                    .buffer = buffer,
                },
            };
        }

        fn drain(io_w: *std.Io.Writer, data: []const []const u8, splat: usize) std.Io.Writer.Error!usize {
            const w: *Writer = @alignCast(@fieldParentPtr("interface", io_w));
            const buffered = io_w.buffered();
            if (buffered.len > 0) {
                const n = w.file.write(buffered) catch |err| {
                    w.err = err;
                    return error.WriteFailed;
                };
                return io_w.consume(n);
            }
            var total: usize = 0;
            const last_idx = data.len - 1;
            for (data[0..last_idx]) |slice| {
                if (slice.len == 0) continue;
                const n = w.file.write(slice) catch |err| {
                    w.err = err;
                    return error.WriteFailed;
                };
                total += n;
                if (n < slice.len) return total;
            }
            const last = data[last_idx];
            if (last.len == 0) return total;
            var i: usize = 0;
            while (i < splat) : (i += 1) {
                const n = w.file.write(last) catch |err| {
                    w.err = err;
                    return error.WriteFailed;
                };
                total += n;
                if (n < last.len) return total;
            }
            return total;
        }
    };

    /// Adapts a `File` to `std.Io.Reader`. The last orca error from a failed
    /// read is preserved in `err` so callers can recover details after
    /// `error.ReadFailed`.
    pub const Reader = struct {
        file: File,
        err: ?oc.io.Error = null,
        interface: std.Io.Reader,

        pub fn init(file: File, buffer: []u8) Reader {
            return .{
                .file = file,
                .interface = .{
                    .vtable = &.{ .stream = stream },
                    .buffer = buffer,
                    .seek = 0,
                    .end = 0,
                },
            };
        }

        fn stream(io_r: *std.Io.Reader, w: *std.Io.Writer, limit: std.Io.Limit) std.Io.Reader.StreamError!usize {
            const r: *Reader = @alignCast(@fieldParentPtr("interface", io_r));
            const dest = limit.slice(try w.writableSliceGreedy(1));
            const n = r.file.read(dest) catch |err| {
                r.err = err;
                return error.ReadFailed;
            };
            if (n == 0) return error.EndOfStream;
            w.advance(n);
            return n;
        }
    };

    pub fn writer(file: File, buffer: []u8) Writer {
        return Writer.init(file, buffer);
    }

    pub fn reader(file: File, buffer: []u8) Reader {
        return Reader.init(file, buffer);
    }

    /// An enum identifying the type of a file.
    pub const Type = enum(u32) {
        /// The file is of unknown type.
        unknown = 0,
        /// The file is a regular file.
        regular = 1,
        /// The file is a directory.
        directory = 2,
        /// The file is a symbolic link.
        symlink = 3,
        /// The file is a block device.
        block = 4,
        /// The file is a character device.
        character = 5,
        /// The file is a FIFO pipe.
        fifo = 6,
        /// The file is a socket.
        socket = 7,
    };

    // @Api should be marked as a bitflags type
    /// A type describing file permissions.
    pub const Perm = packed struct(u16) {
        other_exec: bool = false,
        other_write: bool = false,
        other_read: bool = false,
        group_exec: bool = false,
        group_write: bool = false,
        group_read: bool = false,
        owner_exec: bool = false,
        owner_write: bool = false,
        owner_read: bool = false,
        sticky_bit: bool = false,
        set_gid: bool = false,
        set_uid: bool = false,

        _padding: u4 = 0,
    };

    pub const Stat = extern struct {
        uid: u64,
        type: Type,
        perm: Perm,
        size: u64,
        creationDate: Datestamp,
        accessDate: Datestamp,
        modificationDate: Datestamp,

        pub const Datestamp = extern struct {
            seconds: i64,
            fraction: u64,
        };
    };

    pub fn getStatus(file: File) oc.io.Error!Stat {
        const stat = oc_file_get_status(file);
        try file.lastError();
        return stat;
    }

    pub fn getSize(file: File) oc.io.Error!u64 {
        const size = oc_file_size(file);
        try file.lastError();
        return size;
    }

    /// Get the last error on a file handle.
    pub fn lastError(handle: File) oc.io.Error!void {
        return handle.oc_file_last_error().toError() orelse {};
    }

    // Functions that return `oc_file` (a C struct of one u64) use the wasm
    // sret ABI on the orca SDK side: the return slot is passed as a pointer
    // first parameter and the function returns void. Zig's `enum(u64)` would
    // otherwise be returned as a scalar i64, which mismatches the C ABI.
    extern fn oc_file_nil(out: *File) callconv(.c) void;
    extern fn oc_file_is_nil(handle: File) callconv(.c) bool;
    extern fn oc_file_open(out: *File, path: oc.strings.Str8, rights: AccessFlags, flags: OpenFlags) callconv(.c) void;
    extern fn oc_file_open_with_request(out: *File, path: oc.strings.Str8, rights: AccessFlags, flags: OpenFlags) callconv(.c) void;
    extern fn oc_file_open_at(out: *File, dir: File, path: oc.strings.Str8, rights: AccessFlags, flags: OpenFlags) callconv(.c) void;
    extern fn oc_file_close(file: File) callconv(.c) void;
    extern fn oc_file_pos(file: File) callconv(.c) i64;
    extern fn oc_file_seek(file: File, offset: i64, whence: Whence) callconv(.c) i64;
    extern fn oc_file_write(file: File, size: u64, buffer: [*c]u8) callconv(.c) u64;
    extern fn oc_file_read(file: File, size: u64, buffer: [*c]u8) callconv(.c) u64;
    extern fn oc_file_get_status(file: File) callconv(.c) Stat;
    extern fn oc_file_size(file: File) callconv(.c) u64;
    extern fn oc_file_last_error(handle: File) callconv(.c) oc.io.ErrorEnum;
};
