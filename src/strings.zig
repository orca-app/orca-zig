//! String slices and string lists.

/// A type representing a string of bytes.
pub const Str8 = OrcaSlice(u8);
/// A type describing a string of 16-bits characters (typically used for UTF-16).
pub const Str16 = OrcaSlice(u16);
/// A type describing a string of 32-bits characters (typically used for UTF-32 codepoints).
pub const Str32 = OrcaSlice(u32);

pub const Str8List = StringList(Str8);
pub const Str16List = StringList(Str16);
pub const Str32List = StringList(Str32);

pub fn OrcaSlice(comptime T: type) type {
    return extern struct {
        /// A pointer to the underlying buffer.
        ptr: [*]T,
        /// The length of the buffer.
        len: usize,

        pub fn fromSlice(s: []T) @This() {
            return .{ .ptr = s.ptr, .len = s.len };
        }

        pub fn toSlice(s: @This()) []T {
            return s.ptr[0..s.len];
        }
    };
}

fn StringList(comptime Str: type) type {
    if (Str != Str8 and Str != Str16 and Str != Str32)
        @compileError("Expected Str to be of type Str8/16/32, found " ++ @typeName(Str));

    return extern struct {
        /// A linked-list of `StrElem`.
        list: oc.List,
        /// The number of elements in `list`.
        elt_count: u64,
        /// The total length of the string list, which is the sum of the lengths over all elements.
        len: u64,

        pub const StrElem = extern struct {
            /// The string element is linked into its parent string list through this field.
            list_elt: oc.List.Elem,
            /// The string for this element.
            string: Str,
        };

        pub const StrList = @This();

        pub const empty: StrList = .{ .list = .empty, .elt_count = 0, .len = 0 };

        /// Push a string element to the back of a string list. This creates a `StrElem` element referring to the contents of the input string, and links that element at the end of the string list.
        pub fn push(
            slist: *StrList,
            /// A memory arena on which to allocate the new string element.
            arena: *oc.mem.Arena,
            /// The string of the new element. Note that the contents of the string is not copied. The new string element refers to the same bytes as `str`.
            str: Str,
        ) void {
            const push_impl = switch (Str) {
                Str8 => oc_str8_list_push,
                Str16 => oc_str16_list_push,
                Str32 => oc_str32_list_push,
                else => unreachable,
            };
            // @Incomplete OOM error?
            push_impl(arena, @ptrCast(slist), str);
        }

        /// Build a string by joining the elements of a string list.
        pub fn join(
            // @Api typo
            /// A string list containing the elements of join.
            slist: StrList,
            /// The arena on which to allocate the new string.
            arena: *oc.mem.Arena,
        ) Str {
            const join_impl = switch (Str) {
                Str8 => oc_str8_list_join,
                Str16 => oc_str16_list_join,
                Str32 => oc_str32_list_join,
                else => unreachable,
            };
            // @Incomplete OOM error?
            return join_impl(arena, slist);
        }

        // @Improvement iterate strings instead of StrElems
        pub fn iterate(slist: StrList, options: oc.List.IterateOptions) oc.List.Iterator(StrElem) {
            return slist.list.iterate(StrElem, options);
        }

        // @Cleanup should this be removed in favor of mem.allocPrint?
        // (i.e. `list.push(arena, areana.allocPrint(fmt, args))`)
        pub fn pushf(
            slist: *StrList,
            /// A memory arena on which to allocate the new string element.
            arena: *oc.mem.Arena,
            comptime fmt: []const u8,
            args: anytype,
        ) void {
            if (Str != Str8) @compileError("pushf only available for " ++ @typeName(Str8List));

            const len: usize = @intCast(std.fmt.count(fmt, args));
            const buf: []u8 = arena.pushArray(u8, len) orelse @panic("OOM"); // @Incomplete return error
            slist.push(
                arena,
                .fromSlice(std.fmt.bufPrint(buf, fmt, args) catch unreachable),
            );
        }
    };
}

extern fn oc_str8_list_push(arena: [*c]oc.mem.Arena, list: [*c]Str8List, str: Str8) callconv(.C) void;
extern fn oc_str16_list_push(arena: [*c]oc.mem.Arena, list: [*c]Str16List, str: Str16) callconv(.C) void;
extern fn oc_str32_list_push(arena: [*c]oc.mem.Arena, list: [*c]Str32List, str: Str32) callconv(.C) void;
extern fn oc_str8_list_join(arena: [*c]oc.mem.Arena, list: Str8List) callconv(.C) Str8;
extern fn oc_str16_list_join(arena: [*c]oc.mem.Arena, list: Str16List) callconv(.C) Str16;
extern fn oc_str32_list_join(arena: [*c]oc.mem.Arena, list: Str32List) callconv(.C) Str32;

const oc = @import("orca.zig");
const std = @import("std");

// @Incomplete: forget all the string stuff, zig can do that better, just use tiny converters instead. The real star of the show are the list types! Focus on those instead.

// @Incomplete move str*Push* functions into orca.mem or make them redundant.

/// Pushes a copy of a buffer to an arena, and makes a string refering to that copy.
pub const str8PushBuffer = oc_str8_push_buffer;
extern fn oc_str8_push_buffer(
    arena: [*c]oc.mem.Arena,
    /// The length of the buffer.
    len: u64,
    /// The buffer to copy.
    buffer: [*c]u8,
) callconv(.C) Str8;
/// Pushes a copy of a C null-terminated string to an arena, and makes a string referring to that copy.
pub const str8PushCstring = oc_str8_push_cstring;
extern fn oc_str8_push_cstring(
    arena: [*c]oc.mem.Arena,
    /// A null-terminated string.
    str: [*c]u8,
) callconv(.C) Str8;
/// Copy the contents of a string on an arena and make a new string referring to the copied bytes.
pub const str8PushCopy = oc_str8_push_copy;
extern fn oc_str8_push_copy(
    /// The arena on which to copy the contents of the input string.
    arena: [*c]oc.mem.Arena,
    /// The input string.
    s: Str8,
) callconv(.C) Str8;
/// Make a copy of a string slice. This function copies a subsequence of the input string onto an arena, and returns a new string referring to the copied content.
pub const str8PushSlice = oc_str8_push_slice;
extern fn oc_str8_push_slice(
    /// The arena on which to copy the slice of the input string.
    arena: [*c]oc.mem.Arena,
    /// The input string.
    s: Str8,
    /// The inclusive start index of the slice.
    start: u64,
    /// The exclusive end index of the slice.
    end: u64,
) callconv(.C) Str8;
/// Build a string from a null-terminated format string and a variadic argument list, similar to `vasprintf()`.
pub const str8Pushfv = oc_str8_pushfv;
extern fn oc_str8_pushfv(
    /// The arena on which to allocate the contents of the string.
    arena: [*c]oc.mem.Arena,
    /// A null-terminated format string. The format of that string is the same as that of the C `sprintf()` family of functions.
    format: [*c]u8,
    /// A variadic argument list or arguments referenced by the format string.
    args: @compileError("TODO: handle va_list type"),
) callconv(.C) Str8;
/// Build a string from a null-terminated format string and variadic arguments, similar to `asprintf()`.
pub const str8Pushf = oc_str8_pushf;
extern fn oc_str8_pushf(
    /// The arena on which to allocate the contents of the string.
    arena: [*c]oc.mem.Arena,
    format: [*c]u8,
    /// Additional arguments referenced by the format string.
    ...,
) callconv(.C) Str8;
/// Lexicographically compare the contents of two strings.
/// This function returns `-1` if `s1` is less than `s2`, `+1` if `s1` is greater than `s2`, and `0` if `s1` and `s2` are equal.
pub const str8Cmp = oc_str8_cmp;
extern fn oc_str8_cmp(
    /// The first string to compare.
    s1: Str8,
    /// The second string to compare.
    s2: Str8,
) callconv(.C) i32;
/// Create a null-terminated C-string from an `oc_str8` string.
pub const str8ToCstring = oc_str8_to_cstring;
extern fn oc_str8_to_cstring(
    /// The arena on which to copy the contents of `string` and the null terminator.
    arena: [*c]oc.mem.Arena,
    /// The input string.
    string: Str8,
) callconv(.C) [*c]u8;

/// Build a string by combining the elements of a string list with a prefix, a suffix, and separators.
pub const str8ListCollate = oc_str8_list_collate;
extern fn oc_str8_list_collate(
    /// An arena on which to allocate the contents of the new string.
    arena: [*c]oc.mem.Arena,
    /// A string list containing the elements to combine
    list: Str8List,
    /// A prefix that is pasted at the beginning of the string.
    prefix: Str8,
    /// A separator that is pasted between each element of the input string list.
    separator: Str8,
    /// A suffix that is pasted at the end of the string.
    suffix: Str8,
) callconv(.C) Str8;
/// Split a list into a string list according to separators.
///
/// No string copies are made. The elements of the resulting string list refer to subsequences of the input string.
pub const str8Split = oc_str8_split;
extern fn oc_str8_split(
    /// The arena on which to allocate the elements of the string list.
    arena: [*c]oc.mem.Arena,
    /// The input string.
    str: Str8,
    /// A list of separators used to split the input string.
    separators: Str8List,
) callconv(.C) Str8List;

/// Copy the content of a 16-bit character buffer on an arena and make a new `oc_str16` referencing the copied contents.
pub const str16PushBuffer = oc_str16_push_buffer;
extern fn oc_str16_push_buffer(
    /// The arena on which to copy the input buffer.
    arena: [*c]oc.mem.Arena,
    /// The length of the buffer.
    len: u64,
    /// An input buffer of 16-bit characters.
    buffer: [*c]u16,
) callconv(.C) Str16;
/// Copy the contents of an `oc_str16` string and make a new string referencing the copied contents.
pub const str16PushCopy = oc_str16_push_copy;
extern fn oc_str16_push_copy(
    /// The arena on which to copy the contents of the input string.
    arena: [*c]oc.mem.Arena,
    /// The input string.
    s: Str16,
) callconv(.C) Str16;
/// Copy a slice of an `oc_str16` string an make a new string referencing the copies contents.
pub const str16PushSlice = oc_str16_push_slice;
extern fn oc_str16_push_slice(
    /// The arena on which to copy the slice of the input string's contents.
    arena: [*c]oc.mem.Arena,
    /// The input string.
    s: Str16,
    /// The inclusive start index of the slice.
    start: u64,
    /// The exclusive end index of the slice.
    end: u64,
) callconv(.C) Str16;
/// Split a list into a string list according to separators.
///
/// No string copies are made. The elements of the resulting string list refer to subsequences of the input string.
pub const str16Split = oc_str16_split;
extern fn oc_str16_split(
    /// The arena on which to allocate the elements of the string list.
    arena: [*c]oc.mem.Arena,
    /// The input string.
    str: Str16,
    /// A list of separators used to split the input string.
    separators: Str16List,
) callconv(.C) Str16List;

/// Copy the content of a 32-bit character buffer on an arena and make a new `oc_str32` referencing the copied contents.
pub const str32PushBuffer = oc_str32_push_buffer;
extern fn oc_str32_push_buffer(
    /// The arena on which to copy the input buffer.
    arena: [*c]oc.mem.Arena,
    /// The length of the buffer.
    len: u64,
    /// An input buffer of 32-bit characters.
    buffer: [*c]u32,
) callconv(.C) Str32;
/// Copy the contents of an `oc_str32` string and make a new string referencing the copied contents.
pub const str32PushCopy = oc_str32_push_copy;
extern fn oc_str32_push_copy(
    /// The arena on which to copy the contents of the input string.
    arena: [*c]oc.mem.Arena,
    /// The input string.
    s: Str32,
) callconv(.C) Str32;
/// Copy a slice of an `oc_str32` string an make a new string referencing the copies contents.
pub const str32PushSlice = oc_str32_push_slice;
extern fn oc_str32_push_slice(
    /// The arena on which to copy the slice of the input string's contents.
    arena: [*c]oc.mem.Arena,
    /// The input string.
    s: Str32,
    /// The inclusive start index of the slice.
    start: u64,
    /// The exclusive end index of the slice.
    end: u64,
) callconv(.C) Str32;
/// Split a list into a string list according to separators.
///
/// No string copies are made. The elements of the resulting string list refer to subsequences of the input string.
pub const str32Split = oc_str32_split;
extern fn oc_str32_split(
    /// The arena on which to allocate the elements of the string list.
    arena: [*c]oc.mem.Arena,
    /// The input string.
    str: Str32,
    /// A list of separators used to split the input string.
    separators: Str32List,
) callconv(.C) Str32List;
