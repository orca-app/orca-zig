//! API for handling filesystem paths.

const oc = @import("../orca.zig");

/// Get a string slice of the directory part of a path.
pub const dirname = @extern(*const fn (
    path: oc.strings.Str8,
) callconv(.c) oc.strings.Str8, .{ .name = "oc_path_slice_directory" });

/// Get a string slice of the file name part of a path.
pub const filename = @extern(*const fn (
    path: oc.strings.Str8,
) callconv(.c) oc.strings.Str8, .{ .name = "oc_path_slice_filename" });

/// Split a path into path elements.
pub const split = @extern(*const fn (
    /// An arena on which to allocate string list elements.
    arena: [*c]oc.mem.Arena,
    /// The path to slice.
    path: oc.strings.Str8,
) callconv(.c) oc.strings.Str8List, .{ .name = "oc_path_split" });

/// Join path elements to form a path.
pub const join = @extern(*const fn (
    /// An arena on which to allocate the resulting path.
    arena: [*c]oc.mem.Arena,
    /// A string list of path elements.
    elements: oc.strings.Str8List,
) callconv(.c) oc.strings.Str8, .{ .name = "oc_path_join" });

/// Append a path to another path.
pub const append = @extern(*const fn (
    /// An arena on which to allocate the resulting path.
    arena: [*c]oc.mem.Arena,
    /// The first part of the path.
    parent: oc.strings.Str8,
    /// The relative path to append.
    relPath: oc.strings.Str8,
) callconv(.c) oc.strings.Str8, .{ .name = "oc_path_append" });

/// Test wether a path is an absolute path.
pub const isAbsolute = @extern(*const fn (
    path: oc.strings.Str8,
) callconv(.c) bool, .{ .name = "oc_path_is_absolute" });
