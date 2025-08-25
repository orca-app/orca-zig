//! API for handling filesystem paths.

const oc = @import("../orca.zig");

/// Get a string slice of the directory part of a path.
pub const dirname = oc_path_slice_directory;
extern fn oc_path_slice_directory(path: oc.strings.Str8) callconv(.c) oc.strings.Str8;

/// Get a string slice of the file name part of a path.
pub const filename = oc_path_slice_filename;
extern fn oc_path_slice_filename(path: oc.strings.Str8) callconv(.c) oc.strings.Str8;

/// Split a path into path elements.
pub const split = oc_path_split;
extern fn oc_path_split(
    /// An arena on which to allocate string list elements.
    arena: [*c]oc.mem.Arena,
    /// The path to slice.
    path: oc.strings.Str8,
) callconv(.c) oc.strings.Str8List;

/// Join path elements to form a path.
pub const join = oc_path_join;
extern fn oc_path_join(
    /// An arena on which to allocate the resulting path.
    arena: [*c]oc.mem.Arena,
    /// A string list of path elements.
    elements: oc.strings.Str8List,
) callconv(.c) oc.strings.Str8;

/// Append a path to another path.
pub const append = oc_path_append;
extern fn oc_path_append(
    /// An arena on which to allocate the resulting path.
    arena: [*c]oc.mem.Arena,
    /// The first part of the path.
    parent: oc.strings.Str8,
    /// The relative path to append.
    relPath: oc.strings.Str8,
) callconv(.c) oc.strings.Str8;

/// Test wether a path is an absolute path.
pub const isAbsolute = oc_path_is_absolute;
extern fn oc_path_is_absolute(path: oc.strings.Str8) callconv(.c) bool;
