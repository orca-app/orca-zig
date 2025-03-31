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
// - flag enum types should be differentiated from normal enums
// - flag enum types should use the correct backing values (i.e. oc_file_open_flags_enum should use u16 not u32)

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

//------------------------------------------------------------------------------------------
// [I/O] File input/output.
//------------------------------------------------------------------------------------------

//------------------------------------------------------------------------------------------
// [File API] API for opening, reading and writing files.
//------------------------------------------------------------------------------------------

/// An opaque handle identifying an opened file.
pub const file = extern struct {
    /// Opaque file handle.
    h: u64,
};
/// The type of file open flags describing file open options.
pub const file_open_flags = u16;
/// Flags for the `oc_file_open()` function.
pub const file_open_flags_enum = enum(u32) {
    /// No options.
    FILE_OPEN_NONE = 0,
    /// Open the file in 'append' mode. All writes append data at the end of the file.
    FILE_OPEN_APPEND = 2,
    /// Truncate the file to 0 bytes when opening.
    FILE_OPEN_TRUNCATE = 4,
    /// Create the file if it does not exist.
    FILE_OPEN_CREATE = 8,
    /// If the file is a symlink, open the symlink itself instead of following it.
    FILE_OPEN_SYMLINK = 16,
    /// If the file is a symlink, the call to open will fail.
    FILE_OPEN_NO_FOLLOW = 32,
    /// Reserved.
    FILE_OPEN_RESTRICT = 64,
};
pub const file_access = u16;
/// This enum describes the access permissions of a file handle.
pub const file_access_enum = enum(u32) {
    /// The file handle has no access permissions.
    FILE_ACCESS_NONE = 0,
    /// The file handle can be used for reading from the file.
    FILE_ACCESS_READ = 2,
    /// The file handle can be used for writing to the file.
    FILE_ACCESS_WRITE = 4,
};
/// This enum is used in `oc_file_seek()` to specify the starting point of the seek operation.
pub const file_whence = enum(u32) {
    /// Set the file position relative to the beginning of the file.
    FILE_SEEK_SET = 0,
    /// Set the file position relative to the end of the file.
    FILE_SEEK_END = 1,
    /// Set the file position relative to the current position.
    FILE_SEEK_CURRENT = 2,
};
/// A type used to identify I/O requests.
pub const io_req_id = u64;
/// A type used to identify I/O operations.
pub const io_op = u32;
/// This enum declares all I/O operations.
pub const io_op_enum = enum(u32) {
    /// Open a file at a path relative to a given root directory.
    ///
    ///     - `handle` is the handle to the root directory. If it is nil, the application's default directory is used.
    ///     - `size` is the size of the path, in bytes.
    ///     - `buffer` points to an array containing the path of the file to open, relative to the directory identified by `handle`.
    ///     - `open` contains the permissions and flags for the open operation.
    IO_OPEN_AT = 0,
    /// Close a file handle.
    ///
    ///     - `handle` is the handle to close.
    IO_CLOSE = 1,
    /// Get status information for a file handle.
    ///
    ///     - `handle` is the handle to stat.
    ///     - `size` is the size of the result buffer. It should be at least `sizeof(oc_file_status)`.
    ///     - `buffer` is the result buffer.
    IO_FSTAT = 2,
    /// Move the file position in a file.
    ///
    ///     - `handle` is the handle of the file.
    ///     - `offset` specifies the offset of the new position, relative to the base position specified by `whence`.
    ///     - `whence` determines the base position for the seek operation.
    IO_SEEK = 3,
    /// Read data from a file.
    ///
    ///     - `handle` is the handle of the file.
    ///     - `size` is the number of bytes to read.
    ///     - `buffer` is the result buffer. It should be big enough to hold `size` bytes.
    IO_READ = 4,
    /// Write data to a file.
    ///
    ///     - `handle` is the handle of the file.
    ///     - `size` is the number of bytes to write.
    ///     - `buffer` contains the data to write to the file.
    IO_WRITE = 5,
    /// Get the error attached to a file handle.
    ///
    ///     - `handle` is the handle of the file.
    OC_IO_ERROR = 6,
};
/// A structure describing an I/O request.
pub const io_req = extern struct {
    /// An identifier for the request. You can set this to any value you want. It is passed back in the `oc_io_cmp` completion and can be used to match requests and completions.
    id: io_req_id,
    /// The requested operation.
    op: io_op,
    /// A file handle used by some operations.
    handle: file,
    /// An offset used by some operations.
    offset: i64,
    /// A size indicating the capacity of the buffer pointed to by `buffer`, in bytes.
    size: u64,
    unnamed_0: extern union {
        /// A buffer used to pass data to the request or get back results.
        buffer: [*c]u8,
        /// reserved
        unused: u64,
    },
    unnamed_1: extern union {
        /// Holds options for the open operations.
        open: extern struct {
            /// The access permissions requested on the file to open.
            rights: file_access,
            /// The options to use when opening the file.
            flags: file_open_flags,
        },
        /// The base position to use in seek operations.
        whence: file_whence,
    },
};
/// A type identifying an I/O error.
pub const io_error = i32;
/// This enum declares all I/O error values.
pub const io_error_enum = enum(u32) {
    /// No error.
    IO_OK = 0,
    /// An unexpected error happened.
    IO_ERR_UNKNOWN = 1,
    /// The request had an invalid operation.
    IO_ERR_OP = 2,
    /// The request had an invalid handle.
    IO_ERR_HANDLE = 3,
    /// The operation was not carried out because the file handle has previous errors.
    IO_ERR_PREV = 4,
    /// The request contained wrong arguments.
    IO_ERR_ARG = 5,
    /// The operation requires permissions that the file handle doesn't have.
    IO_ERR_PERM = 6,
    /// The operation couldn't complete due to a lack of space in the result buffer.
    IO_ERR_SPACE = 7,
    /// One of the directory in the path does not exist or couldn't be traversed.
    IO_ERR_NO_ENTRY = 8,
    /// The file already exists.
    IO_ERR_EXISTS = 9,
    /// The file is not a directory.
    IO_ERR_NOT_DIR = 10,
    /// The file is a directory.
    IO_ERR_DIR = 11,
    /// There are too many opened files.
    IO_ERR_MAX_FILES = 12,
    /// The path contains too many symbolic links (this may be indicative of a symlink loop).
    IO_ERR_MAX_LINKS = 13,
    /// The path is too long.
    IO_ERR_PATH_LENGTH = 14,
    /// The file is too large.
    IO_ERR_FILE_SIZE = 15,
    /// The file is too large to be opened.
    IO_ERR_OVERFLOW = 16,
    /// The file is locked or the device on which it is stored is not ready.
    IO_ERR_NOT_READY = 17,
    /// The system is out of memory.
    IO_ERR_MEM = 18,
    /// The operation was interrupted by a signal.
    IO_ERR_INTERRUPT = 19,
    /// A physical error happened.
    IO_ERR_PHYSICAL = 20,
    /// The device on which the file is stored was not found.
    IO_ERR_NO_DEVICE = 21,
    /// One element along the path is outside the root directory subtree.
    IO_ERR_WALKOUT = 22,
};
/// A structure describing the completion of an I/O operation.
pub const io_cmp = extern struct {
    /// The request ID as passed in the `oc_io_req` request that generated this completion.
    id: io_req_id,
    /// The error value for the operation.
    @"error": io_error,
    unnamed_0: extern union {
        /// This member is used to return integer results.
        result: i64,
        /// This member is used to return size results.
        size: u64,
        /// This member is used to return offset results.
        offset: i64,
        /// This member is used to return handle results.
        handle: file,
    },
};
/// Send a single I/O request and wait for its completion.
pub const ioWaitSingleReq = oc_io_wait_single_req;
extern fn oc_io_wait_single_req(
    /// The I/O request to send.
    req: [*c]io_req,
) callconv(.C) io_cmp;
/// Returns a `nil` file handle
pub const fileNil = oc_file_nil;
extern fn oc_file_nil() callconv(.C) file;
/// Test if a file handle is `nil`.
pub const fileIsNil = oc_file_is_nil;
extern fn oc_file_is_nil(
    /// The handle to test.
    handle: file,
) callconv(.C) bool;
/// Open a file in the applications' default directory subtree.
pub const fileOpen = oc_file_open;
extern fn oc_file_open(
    /// The path of the file, relative to the applications' default directory.
    path: strings.Str8,
    /// The request access rights for the file.
    rights: file_access,
    /// Flags controlling various options for the open operation. See `oc_file_open_flags`.
    flags: file_open_flags,
) callconv(.C) file;
/// Open a file in a given directory's subtree.
pub const fileOpenAt = oc_file_open_at;
extern fn oc_file_open_at(
    /// A directory handle identifying the root of the open operation.
    dir: file,
    /// The path of the file to open, relative to `dir`.
    path: strings.Str8,
    /// The request access rights for the file.
    rights: file_access,
    /// Flags controlling various options for the open operation. See `oc_file_open_flags`.
    flags: file_open_flags,
) callconv(.C) file;
/// Close a file.
pub const fileClose = oc_file_close;
extern fn oc_file_close(
    /// The file handle to close.
    file: file,
) callconv(.C) void;
/// Get the current position in a file.
pub const filePos = oc_file_pos;
extern fn oc_file_pos(
    /// A handle to the file.
    file: file,
) callconv(.C) i64;
/// Set the current position in a file.
pub const fileSeek = oc_file_seek;
extern fn oc_file_seek(
    /// A handle to the file.
    file: file,
    /// The offset at which to move the file position, relative to the base position indicated by `whence`.
    offset: i64,
    /// The base position for the seek operation.
    whence: file_whence,
) callconv(.C) i64;
/// Write data to a file.
pub const fileWrite = oc_file_write;
extern fn oc_file_write(
    /// A handle to the file.
    file: file,
    /// The number of bytes to write.
    size: u64,
    /// The buffer containing the data to write. It must be at least `size` long.
    buffer: [*c]u8,
) callconv(.C) u64;
/// Read from a file.
pub const fileRead = oc_file_read;
extern fn oc_file_read(
    /// A handle to the file.
    file: file,
    /// The number of bytes to read.
    size: u64,
    /// The buffer where to store the read data. It must be capable of holding at least `size` bytes.
    buffer: [*c]u8,
) callconv(.C) u64;
/// Get the last error on a file handle.
pub const fileLastError = oc_file_last_error;
extern fn oc_file_last_error(
    /// A handle to a file.
    handle: file,
) callconv(.C) io_error;
/// An enum identifying the type of a file.
pub const file_type = enum(u32) {
    /// The file is of unknown type.
    FILE_UNKNOWN = 0,
    /// The file is a regular file.
    FILE_REGULAR = 1,
    /// The file is a directory.
    FILE_DIRECTORY = 2,
    /// The file is a symbolic link.
    FILE_SYMLINK = 3,
    /// The file is a block device.
    FILE_BLOCK = 4,
    /// The file is a character device.
    FILE_CHARACTER = 5,
    /// The file is a FIFO pipe.
    FILE_FIFO = 6,
    /// The file is a socket.
    FILE_SOCKET = 7,
};
/// A type describing file permissions.
pub const file_perm = u16;
pub const file_perm_enum = enum(u32) {
    FILE_OTHER_EXEC = 1,
    FILE_OTHER_WRITE = 2,
    FILE_OTHER_READ = 4,
    FILE_GROUP_EXEC = 8,
    FILE_GROUP_WRITE = 16,
    FILE_GROUP_READ = 32,
    FILE_OWNER_EXEC = 64,
    FILE_OWNER_WRITE = 128,
    FILE_OWNER_READ = 256,
    FILE_STICKY_BIT = 512,
    FILE_SET_GID = 1024,
    FILE_SET_UID = 2048,
};
pub const datestamp = extern struct {
    seconds: i64,
    fraction: u64,
};
pub const file_status = extern struct {
    uid: u64,
    type: file_type,
    perm: file_perm,
    size: u64,
    creationDate: datestamp,
    accessDate: datestamp,
    modificationDate: datestamp,
};
pub const fileGetStatus = oc_file_get_status;
extern fn oc_file_get_status(
    file: file,
) callconv(.C) file_status;
pub const fileSize = oc_file_size;
extern fn oc_file_size(
    file: file,
) callconv(.C) u64;
pub const fileOpenWithRequest = oc_file_open_with_request;
extern fn oc_file_open_with_request(
    path: strings.Str8,
    rights: file_access,
    flags: file_open_flags,
) callconv(.C) file;

//------------------------------------------------------------------------------------------
// [Dialogs] API for obtaining file capabilities through open/save dialogs.
//------------------------------------------------------------------------------------------

/// An element of a list of file handles acquired through a file dialog.
pub const file_open_with_dialog_elt = extern struct {
    listElt: List.Elem,
    file: file,
};
/// A structure describing the result of a call to `oc_file_open_with_dialog()`.
pub const file_open_with_dialog_result = extern struct {
    /// The button of the file dialog clicked by the user.
    button: app.FileDialogButton,
    /// The file that was opened through the dialog. If the dialog had the `OC_FILE_DIALOG_MULTIPLE` flag set, this is equal to the first handle in the `selection` list.
    file: file,
    /// If the dialog had the `OC_FILE_DIALOG_MULTIPLE` flag set, this list of `oc_file_open_with_dialog_elt` contains the handles of the opened files.
    selection: List,
};
/// Open files through a file dialog. This allows the user to select files outside the root directories currently accessible to the applications, giving them a way to provide new file capabilities to the application.
pub const fileOpenWithDialog = oc_file_open_with_dialog;
extern fn oc_file_open_with_dialog(
    /// A memory arena on which to allocate elements of the result.
    arena: [*c]mem.Arena,
    /// The access rights requested on the files to open.
    rights: file_access,
    /// Flags controlling various options of the open operation. See `oc_file_open_flags`.
    flags: file_open_flags,
    /// A structure controlling the options of the file dialog window.
    desc: [*c]app.FileDialogDesc,
) callconv(.C) file_open_with_dialog_result;

//------------------------------------------------------------------------------------------
// [Paths] API for handling filesystem paths.
//------------------------------------------------------------------------------------------

/// Get a string slice of the directory part of a path.
pub const pathSliceDirectory = oc_path_slice_directory;
extern fn oc_path_slice_directory(
    /// The path to slice.
    path: strings.Str8,
) callconv(.C) strings.Str8;
/// Get a string slice of the file name part of a path.
pub const pathSliceFilename = oc_path_slice_filename;
extern fn oc_path_slice_filename(
    /// The path to slice
    path: strings.Str8,
) callconv(.C) strings.Str8;
/// Split a path into path elements.
pub const pathSplit = oc_path_split;
extern fn oc_path_split(
    /// An arena on which to allocate string list elements.
    arena: [*c]mem.Arena,
    /// The path to slice.
    path: strings.Str8,
) callconv(.C) strings.str8_list;
/// Join path elements to form a path.
pub const pathJoin = oc_path_join;
extern fn oc_path_join(
    /// An arena on which to allocate the resulting path.
    arena: [*c]mem.Arena,
    /// A string list of path elements.
    elements: strings.str8_list,
) callconv(.C) strings.Str8;
/// Append a path to another path.
pub const pathAppend = oc_path_append;
extern fn oc_path_append(
    /// An arena on which to allocate the resulting path.
    arena: [*c]mem.Arena,
    /// The first part of the path.
    parent: strings.Str8,
    /// The relative path to append.
    relPath: strings.Str8,
) callconv(.C) strings.Str8;
/// Test wether a path is an absolute path.
pub const pathIsAbsolute = oc_path_is_absolute;
extern fn oc_path_is_absolute(
    /// The path to test.
    path: strings.Str8,
) callconv(.C) bool;

pub const graphics = @import("graphics.zig"); // [Graphics]

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
