//! File input/output.

const oc = @import("orca.zig");

pub const File = @import("io/file.zig").File; // [File API]
pub const path = @import("io/path.zig"); // [Paths]

/// A type used to identify I/O operations.
pub const Op = enum(u32) {
    /// Open a file at a path relative to a given root directory.
    ///
    ///     - `handle` is the handle to the root directory. If it is nil, the application's default directory is used.
    ///     - `size` is the size of the path, in bytes.
    ///     - `buffer` points to an array containing the path of the file to open, relative to the directory identified by `handle`.
    ///     - `open` contains the permissions and flags for the open operation.
    open_at = 0,
    /// Close a file handle.
    ///
    ///     - `handle` is the handle to close.
    close = 1,
    /// Get status information for a file handle.
    ///
    ///     - `handle` is the handle to stat.
    ///     - `size` is the size of the result buffer. It should be at least `sizeof(oc_file_status)`.
    ///     - `buffer` is the result buffer.
    fstat = 2,
    /// Move the file position in a file.
    ///
    ///     - `handle` is the handle of the file.
    ///     - `offset` specifies the offset of the new position, relative to the base position specified by `whence`.
    ///     - `whence` determines the base position for the seek operation.
    seek = 3,
    /// Read data from a file.
    ///
    ///     - `handle` is the handle of the file.
    ///     - `size` is the number of bytes to read.
    ///     - `buffer` is the result buffer. It should be big enough to hold `size` bytes.
    read = 4,
    /// Write data to a file.
    ///
    ///     - `handle` is the handle of the file.
    ///     - `size` is the number of bytes to write.
    ///     - `buffer` contains the data to write to the file.
    write = 5,
    /// Get the error attached to a file handle.
    ///
    ///     - `handle` is the handle of the file.
    err = 6,
};
/// A structure describing an I/O request.
pub const Request = extern struct {
    /// An identifier for the request. You can set this to any value you want. It is passed back in the `oc_io_cmp` completion and can be used to match requests and completions.
    id: Id,
    /// The requested operation.
    op: Op,
    /// A file handle used by some operations.
    handle: File,
    /// An offset used by some operations.
    offset: i64,
    /// A size indicating the capacity of the buffer pointed to by `buffer`, in bytes.
    size: u64,
    data: extern union {
        /// A buffer used to pass data to the request or get back results.
        buffer: [*c]u8,
        /// reserved
        unused: u64,
    },
    options: extern union {
        /// Holds options for the open operations.
        open: extern struct {
            /// The access permissions requested on the file to open.
            rights: File.AccessFlags,
            /// The options to use when opening the file.
            flags: File.OpenFlags,
        },
        /// The base position to use in seek operations.
        whence: File.Whence,
    },

    /// A type used to identify I/O requests.
    pub const Id = u64;
};

/// A type identifying an I/O error.
// @Incomplete: not sure what approach to take in porting the errors.
// I could "compress" them similarly to how std deals with OS errors,
// though their goal is to abstract over multiple platforms. Here we just
// have the one -- so maybe it should just be a direct mapping?
pub const Error = error{
    /// An unexpected error happened.
    Unknown,
    /// The request had an invalid operation.
    InvalidOperation,
    /// The request had an invalid handle.
    InvalidHandle,
    /// The operation was not carried out because the file handle has previous errors.
    HadPreviousError, // @Todo might be unreachable if we always check for errors in the api
    /// The request contained wrong arguments.
    InvalidArg,
    /// The operation requires permissions that the file handle doesn't have.
    PermissionDenied,
    /// The operation couldn't complete due to a lack of space in the result buffer.
    NoSpace, // @Todo this could be merged with OutOfMemory
    /// One of the directory in the path does not exist or couldn't be traversed.
    FileNotFound,
    /// The file already exists.
    PathAlreadyExists,
    /// The file is not a directory.
    NotDir,
    /// The file is a directory.
    IsDir,
    /// There are too many opened files.
    FdQuotaExceeded,
    /// The path contains too many symbolic links (this may be indicative of a symlink loop).
    SymLinkLoop,
    /// The path is too long.
    PathTooLong,
    /// The file is too large.
    FileTooBig,
    /// The file is too large to be opened.
    Overflow,
    /// The file is locked or the device on which it is stored is not ready.
    NotReady,
    /// The system is out of memory.
    OutOfMemory,
    /// The operation was interrupted by a signal.
    Interrupt,
    /// A physical error happened.
    Physical,
    /// The device on which the file is stored was not found.
    NoDevice,
    /// One element along the path is outside the root directory subtree.
    PathOutsideRoot,
};

/// A type identifying an I/O error.
pub const ErrorEnum = enum(i32) {
    /// No error.
    ok = 0,
    /// An unexpected error happened.
    unknown = 1,
    /// The request had an invalid operation.
    op = 2,
    /// The request had an invalid handle.
    handle = 3,
    /// The operation was not carried out because the file handle has previous errors.
    prev = 4,
    /// The request contained wrong arguments.
    arg = 5,
    /// The operation requires permissions that the file handle doesn't have.
    perm = 6,
    /// The operation couldn't complete due to a lack of space in the result buffer.
    space = 7,
    /// One of the directory in the path does not exist or couldn't be traversed.
    no_entry = 8,
    /// The file already exists.
    exists = 9,
    /// The file is not a directory.
    not_dir = 10,
    /// The file is a directory.
    dir = 11,
    /// There are too many opened files.
    max_files = 12,
    /// The path contains too many symbolic links (this may be indicative of a symlink loop).
    max_links = 13,
    /// The path is too long.
    path_length = 14,
    /// The file is too large.
    file_size = 15,
    /// The file is too large to be opened.
    overflow = 16,
    /// The file is locked or the device on which it is stored is not ready.
    not_ready = 17,
    /// The system is out of memory.
    mem = 18,
    /// The operation was interrupted by a signal.
    interrupt = 19,
    /// A physical error happened.
    physical = 20,
    /// The device on which the file is stored was not found.
    no_device = 21,
    /// One element along the path is outside the root directory subtree.
    walkout = 22,

    pub fn toError(err: ErrorEnum) ?Error {
        return switch (err) {
            .ok => null,
            .unknown => Error.Unknown,
            .op => Error.InvalidOperation,
            .handle => Error.InvalidHandle,
            .prev => Error.HadPreviousError,
            .arg => Error.InvalidArg,
            .perm => Error.PermissionDenied,
            .space => Error.NoSpace,
            .no_entry => Error.FileNotFound,
            .exists => Error.PathAlreadyExists,
            .not_dir => Error.NotDir,
            .dir => Error.IsDir,
            .max_files => Error.FdQuotaExceeded,
            .max_links => Error.SymLinkLoop,
            .path_length => Error.PathTooLong,
            .file_size => Error.FileTooBig,
            .overflow => Error.Overflow,
            .not_ready => Error.NotReady,
            .mem => Error.OutOfMemory,
            .interrupt => Error.Interrupt,
            .physical => Error.Physical,
            .no_device => Error.NoDevice,
            .walkout => Error.PathOutsideRoot,
        };
    }
};
/// A structure describing the completion of an I/O operation.
pub const Completion = extern struct {
    /// The request ID as passed in the `oc_io_req` request that generated this completion.
    id: Request.Id,
    /// The error value for the operation.
    err: ErrorEnum,
    result: extern union {
        /// This member is used to return integer results.
        int: i64,
        /// This member is used to return size results.
        size: u64,
        /// This member is used to return offset results.
        offset: i64,
        /// This member is used to return handle results.
        handle: File,
    },
};
/// Send a single I/O request and wait for its completion.
pub const ioWaitSingleReq = oc_io_wait_single_req;
extern fn oc_io_wait_single_req(
    /// The I/O request to send.
    req: [*c]Request,
) callconv(.C) Completion;

//------------------------------------------------------------------------------------------
// [Dialogs] API for obtaining file capabilities through open/save dialogs.
//------------------------------------------------------------------------------------------

/// An element of a list of file handles acquired through a file dialog.
pub const FileOpenWithDialogElem = extern struct {
    listElt: oc.List.Elem,
    file: File,
};
/// A structure describing the result of a call to `oc_file_open_with_dialog()`.
pub const FileOpenWithDialogResult = extern struct {
    /// The button of the file dialog clicked by the user.
    button: oc.app.FileDialogButton,
    /// The file that was opened through the dialog. If the dialog had the `OC_FILE_DIALOG_MULTIPLE` flag set, this is equal to the first handle in the `selection` list.
    file: File,
    /// If the dialog had the `OC_FILE_DIALOG_MULTIPLE` flag set, this list of `FileOpenWithDialogElem` contains the handles of the opened files.
    selection: oc.List,
};
// @Cleanup this could be moved into File. Not sure about the other structs (including those in app).
/// Open files through a file dialog. This allows the user to select files outside the root directories currently accessible to the applications, giving them a way to provide new file capabilities to the application.
pub const fileOpenWithDialog = oc_file_open_with_dialog;
extern fn oc_file_open_with_dialog(
    /// A memory arena on which to allocate elements of the result.
    arena: [*c]oc.mem.Arena,
    /// The access rights requested on the files to open.
    rights: File.AccessFlags,
    /// Flags controlling various options of the open operation. See `oc_file_open_flags`.
    flags: File.OpenFlags,
    /// A structure controlling the options of the file dialog window.
    desc: [*c]oc.app.FileDialogDesc,
) callconv(.C) FileOpenWithDialogResult;
