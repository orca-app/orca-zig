//! String slices and string lists.

/// A type representing a string of bytes.
pub const Str8 = OrcaSlice(u8);
/// A type describing a string of 16-bits characters (typically used for UTF-16).
pub const Str16 = OrcaSlice(u16);
/// A type describing a string of 32-bits characters (typically used for UTF-32 codepoints).
pub const Str32 = OrcaSlice(u32);

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

pub fn StringList(comptime Str: type) type {
    return extern struct {
        /// A linked-list of `StrElem`.
        list: oc.List,
        /// The number of elements in `list`.
        elt_count: u64,
        /// The total length of the string list, which is the sum of the lengths over all elements.
        len: u64,

        pub const StrElem = struct {
            /// The string element is linked into its parent string list through this field.
            list_elt: oc.List.Elem,
            /// The string for this element.
            string: Str,
        };
    };
}

const oc = @import("orca.zig");

// @Incomplete: forget all the string stuff, zig can do that better, just use tiny converters instead. The real star of the show are the list types! Focus on those instead.

/// Make a string from a bytes buffer and a length.
pub const str8FromBuffer = oc_str8_from_buffer;
extern fn oc_str8_from_buffer(
    len: u64,
    /// A buffer of bytes.
    buffer: [*c]u8,
) callconv(.C) Str8;
/// Make a string from a slice of another string. The resulting string designates some subsequence of the input string.
pub const str8Slice = oc_str8_slice;
extern fn oc_str8_slice(
    s: Str8,
    /// The inclusive start index of the slice.
    start: u64,
    /// The exclusive end index of the slice.
    end: u64,
) callconv(.C) Str8;
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
/// A type representing an element of a string list.
pub const str8_elt = extern struct {
    /// The string element is linked into its parent string list through this field.
    listElt: oc.List.Elem,
    /// The string for this element.
    string: Str8,
};
/// A type representing a string list.
pub const str8_list = extern struct {
    /// A linked-list of `oc_str8_elt`.
    list: oc.List,
    /// The number of elements in `list`.
    eltCount: u64,
    /// The total length of the string list, which is the sum of the lengths over all elements.
    len: u64,
};
/// Push a string element to the back of a string list. This creates a `oc_str8_elt` element referring to the contents of the input string, and links that element at the end of the string list.
pub const str8ListPush = oc_str8_list_push;
extern fn oc_str8_list_push(
    /// A memory arena on which to allocate the new string element.
    arena: [*c]oc.mem.Arena,
    /// The string list to link the new element into.
    list: [*c]str8_list,
    /// The string of the new element. Note that the contents of the string is not copied. The new string element refers to the same bytes as `str`.
    str: Str8,
) callconv(.C) void;
/// Build a string from a null-terminated format string an variadic arguments, and append it to a string list.
pub const str8ListPushf = oc_str8_list_pushf;
extern fn oc_str8_list_pushf(
    /// The arena on which to allocate the contents of the string, as well as the string element.
    arena: [*c]oc.mem.Arena,
    /// The string list on which to append the new element.
    list: [*c]str8_list,
    /// A null-terminated format string. The format of that string is the same as that of the C `sprintf()` family of functions.
    format: [*c]u8,
    /// Additional arguments references by the format string.
    ...,
) callconv(.C) void;
/// Build a string by combining the elements of a string list with a prefix, a suffix, and separators.
pub const str8ListCollate = oc_str8_list_collate;
extern fn oc_str8_list_collate(
    /// An arena on which to allocate the contents of the new string.
    arena: [*c]oc.mem.Arena,
    /// A string list containing the elements to combine
    list: str8_list,
    /// A prefix that is pasted at the beginning of the string.
    prefix: Str8,
    /// A separator that is pasted between each element of the input string list.
    separator: Str8,
    /// A suffix that is pasted at the end of the string.
    suffix: Str8,
) callconv(.C) Str8;
/// Build a string by joining the elements of a string list.
pub const str8ListJoin = oc_str8_list_join;
extern fn oc_str8_list_join(
    /// The arena on which to allocate the new string.
    arena: [*c]oc.mem.Arena,
    /// A string list containing the elements of join.
    list: str8_list,
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
    separators: str8_list,
) callconv(.C) str8_list;
/// Get the first string of a string list.
pub const oc_str8_list_first = @compileError("TODO: translate macro");
/// Get the last string of a string list.
pub const oc_str8_list_last = @compileError("TODO: translate macro");
/// Iterate through the strings of a string list.
///
/// This macro creates a loop with an `oc_str8` iterator named after the `elt` macro parameter. You should follow it by the loop body, in which you can use the iterator to access each element.
pub const oc_str8_list_for = @compileError("TODO: translate macro");
/// Checks if a string list is empty.
pub const oc_str8_list_empty = @compileError("TODO: translate macro");

/// Make an `oc_str16` string from a buffer of 16-bit characters.
pub const str16FromBuffer = oc_str16_from_buffer;
extern fn oc_str16_from_buffer(
    /// The length of the input buffer, in characters.
    len: u64,
    /// The 16-bits characters buffer.
    buffer: [*c]u16,
) callconv(.C) Str16;
/// Make an `oc_str16` string from a slice of another `oc_str16` string.
pub const str16Slice = oc_str16_slice;
extern fn oc_str16_slice(
    /// The input string.
    s: Str16,
    /// The inclusive start index of the slice.
    start: u64,
    /// The exclusive end index of the slice.
    end: u64,
) callconv(.C) Str16;
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
/// A type representing an element of an `oc_str16` list.
pub const str16_elt = extern struct {
    /// The string element is linked into its parent string list through this field.
    listElt: oc.List.Elem,
    /// The string for this element.
    string: Str16,
};
pub const str16_list = extern struct {
    /// A linked-list of `oc_str16_elt`.
    list: oc.List,
    /// The number of elements in `list`.
    eltCount: u64,
    /// The total length of the string list, which is the sum of the lengths over all elements.
    len: u64,
};
/// Push a string element to the back of a string list. This creates a `oc_str16_elt` element referring to the contents of the input string, and links that element at the end of the string list.
pub const str16ListPush = oc_str16_list_push;
extern fn oc_str16_list_push(
    /// A memory arena on which to allocate the new string element.
    arena: [*c]oc.mem.Arena,
    /// The string list to link the new element into.
    list: [*c]str16_list,
    /// The string of the new element. Note that the contents of the string is not copied. The new string element refers to the same bytes as `str`.
    str: Str16,
) callconv(.C) void;
/// Build a string by joining the elements of a string list.
pub const str16ListJoin = oc_str16_list_join;
extern fn oc_str16_list_join(
    /// The arena on which to allocate the new string.
    arena: [*c]oc.mem.Arena,
    /// A string list containing the elements of join.
    list: str16_list,
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
    separators: str16_list,
) callconv(.C) str16_list;
/// Get the first string of a string list.
pub const oc_str16_list_first = @compileError("TODO: translate macro");
/// Get the last string of a string list.
pub const oc_str16_list_last = @compileError("TODO: translate macro");
/// Iterate through the strings of a string list.
///
/// This macro creates a loop with an `oc_str16` iterator named after the `elt` macro parameter. You should follow it by the loop body, in which you can use the iterator to access each element.
pub const oc_str16_list_for = @compileError("TODO: translate macro");
/// Checks if a string list is empty.
pub const oc_str16_list_empty = @compileError("TODO: translate macro");

/// Make an `oc_str32` string from a buffer of 32-bit characters.
pub const str32FromBuffer = oc_str32_from_buffer;
extern fn oc_str32_from_buffer(
    /// The length of the input buffer, in characters.
    len: u64,
    /// The 32-bits characters buffer.
    buffer: [*c]u32,
) callconv(.C) Str32;
/// Make an `oc_str32` string from a slice of another `oc_str32` string.
pub const str32Slice = oc_str32_slice;
extern fn oc_str32_slice(
    /// The input string.
    s: Str32,
    /// The inclusive start index of the slice.
    start: u64,
    /// The exclusive end index of the slice.
    end: u64,
) callconv(.C) Str32;
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
/// A type representing an element of an `oc_str32` list.
pub const str32_elt = extern struct {
    /// The string element is linked into its parent string list through this field.
    listElt: oc.List.Elem,
    /// The string for this element.
    string: Str32,
};
pub const str32_list = extern struct {
    /// A linked-list of `oc_str32_elt`.
    list: oc.List,
    /// The number of elements in `list`.
    eltCount: u64,
    /// The total length of the string list, which is the sum of the lengths over all elements.
    len: u64,
};
/// Push a string element to the back of a string list. This creates a `oc_str32_elt` element referring to the contents of the input string, and links that element at the end of the string list.
pub const str32ListPush = oc_str32_list_push;
extern fn oc_str32_list_push(
    /// A memory arena on which to allocate the new string element.
    arena: [*c]oc.mem.Arena,
    /// The string list to link the new element into.
    list: [*c]str32_list,
    /// The string of the new element. Note that the contents of the string is not copied. The new string element refers to the same bytes as `str`.
    str: Str32,
) callconv(.C) void;
/// Build a string by joining the elements of a string list.
pub const str32ListJoin = oc_str32_list_join;
extern fn oc_str32_list_join(
    /// The arena on which to allocate the new string.
    arena: [*c]oc.mem.Arena,
    /// A string list containing the elements of join.
    list: str32_list,
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
    separators: str32_list,
) callconv(.C) str32_list;
/// Get the first string of a string list.
pub const oc_str32_list_first = @compileError("TODO: translate macro");
/// Get the last string of a string list.
pub const oc_str32_list_last = @compileError("TODO: translate macro");
/// Iterate through the strings of a string list.
///
/// This macro creates a loop with an `oc_str32` iterator named after the `elt` macro parameter. You should follow it by the loop body, in which you can use the iterator to access each element.
pub const oc_str32_list_for = @compileError("TODO: translate macro");
/// Checks if a string list is empty.
pub const oc_str32_list_empty = @compileError("TODO: translate macro");
