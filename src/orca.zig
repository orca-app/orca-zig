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
    debug.abortMsg("{s}", .{msg}, @src());
    _ = first_trace_addr;
}

// shortcuts
pub const log = debug.log;
pub const assert = debug.assert;
pub const abort = debug.abort;

pub fn toStr8(str: []const u8) str8 {
    return .{ .ptr = @constCast(@ptrCast(str.ptr)), .len = str.len };
}

//------------------------------------------------------------------------------------------
// [Orca hooks]
//------------------------------------------------------------------------------------------

const app = @import("app");

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
    if (@hasDecl(app, handler)) {
        const func = &@field(@This(), callback);
        @export(func, .{ .name = callback });
    }
}

fn oc_on_init() callconv(.C) void {
    callHandler(app.onInit, .{}, @src());
}

fn oc_on_mouse_down(button: mouse_button) callconv(.C) void {
    callHandler(app.onMouseDown, .{button}, @src());
}

fn oc_on_mouse_up(button: mouse_button) callconv(.C) void {
    callHandler(app.onMouseUp, .{button}, @src());
}

fn oc_on_mouse_enter() callconv(.C) void {
    callHandler(app.onMouseEnter, .{}, @src());
}

fn oc_on_mouse_leave() callconv(.C) void {
    callHandler(app.onMouseLeave, .{}, @src());
}

fn oc_on_mouse_move(x: f32, y: f32, deltaX: f32, deltaY: f32) callconv(.C) void {
    callHandler(app.onMouseMove, .{ x, y, deltaX, deltaY }, @src());
}

fn oc_on_mouse_wheel(deltaX: f32, deltaY: f32) callconv(.C) void {
    callHandler(app.onMouseWheel, .{ deltaX, deltaY }, @src());
}

fn oc_on_key_down(scan: scan_code, key: key_code) callconv(.C) void {
    callHandler(app.onKeyDown, .{ scan, key }, @src());
}

fn oc_on_key_up(scan: scan_code, key: key_code) callconv(.C) void {
    callHandler(app.onKeyUp, .{ scan, key }, @src());
}

fn oc_on_frame_refresh() callconv(.C) void {
    callHandler(app.onFrameRefresh, .{}, @src());
}

fn oc_on_resize(width: u32, height: u32) callconv(.C) void {
    callHandler(app.onResize, .{ width, height }, @src());
}

fn oc_on_raw_event(c_event: *event) callconv(.C) void {
    callHandler(app.onRawEvent, .{c_event}, @src());
}

fn oc_on_terminate() callconv(.C) void {
    callHandler(app.onTerminate, .{}, @src());
}

fn fatal(err: anyerror, source: std.builtin.SourceLocation) noreturn {
    debug.abortMsg("Caught fatal {}", .{err}, source);
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

//------------------------------------------------------------------------------------------
// [Lists] Types and helpers for doubly-linked lists.
//------------------------------------------------------------------------------------------

/// Get the first element of a list.
pub const oc_list_begin = @compileError("TODO: translate macro");
/// Returns the last element of a list.
pub const oc_list_last = @compileError("TODO: translate macro");
/// Get the next element in a list.
pub const oc_list_next = @compileError("TODO: translate macro");
/// Get the previous element in a list.
pub const oc_list_prev = @compileError("TODO: translate macro");
/// Get the entry for a given list element.
pub const oc_list_entry = @compileError("TODO: translate macro");
/// Get the next entry in a list.
pub const oc_list_next_entry = @compileError("TODO: translate macro");
/// Get the previous entry in a list.
pub const oc_list_prev_entry = @compileError("TODO: translate macro");
/// Same as `oc_list_entry`, but `elt` might be null.
pub const oc_list_checked_entry = @compileError("TODO: translate macro");
/// Get the first entry of a list.
pub const oc_list_first_entry = @compileError("TODO: translate macro");
/// Get the last entry of a list.
pub const oc_list_last_entry = @compileError("TODO: translate macro");
/// Loop through a linked list.
///
/// This macro creates a loop with an iterator named after the `elt` macro parameter. The iterator is of the type specified by the `type` macro parameter, which must be the type of the entries linked in the list.
///
/// You should follow this macro with the loop body, where you can use the iterator.
pub const oc_list_for = @compileError("TODO: translate macro");
/// Loop through a linked list from last to first. See `oc_list_for` for details.
pub const oc_list_for_reverse = @compileError("TODO: translate macro");
/// Loop through a linked list in a way that allows adding or removing elements from it in the loop body. See `oc_list_for` for more details.
pub const oc_list_for_safe = @compileError("TODO: translate macro");
/// Remove the first entry from a list and return it.
pub const oc_list_pop_front_entry = @compileError("TODO: translate macro");
/// Remove the last entry from a list and return it.
pub const oc_list_pop_back_entry = @compileError("TODO: translate macro");
/// An element of an intrusive doubly-linked list.
pub const list_elt = extern struct {
    /// Points to the previous element in the list.
    prev: [*c]list_elt,
    /// Points to the next element in the list.
    next: [*c]list_elt,
};
/// A doubly-linked list.
pub const list = extern struct {
    /// Points to the first element in the list.
    first: [*c]list_elt,
    /// Points to the last element in the list.
    last: [*c]list_elt,
};
/// Check if a list is empty.
pub const listEmpty = oc_list_empty;
extern fn oc_list_empty(
    /// A linked list.
    list: list,
) callconv(.C) bool;
/// Zero-initializes a linked list.
pub const listInit = oc_list_init;
extern fn oc_list_init(
    /// A pointer to the list to initialize.
    list: [*c]list,
) callconv(.C) void;
/// Insert an element in a list after a given element.
pub const listInsert = oc_list_insert;
extern fn oc_list_insert(
    list: [*c]list,
    afterElt: [*c]list_elt,
    /// The element to insert in the list.
    elt: [*c]list_elt,
) callconv(.C) void;
/// Insert an element in a list before a given element.
pub const listInsertBefore = oc_list_insert_before;
extern fn oc_list_insert_before(
    /// The list to insert in.
    list: [*c]list,
    /// The element before which to insert.
    beforeElt: [*c]list_elt,
    /// The element to insert in the list.
    elt: [*c]list_elt,
) callconv(.C) void;
/// Remove an element from a list.
pub const listRemove = oc_list_remove;
extern fn oc_list_remove(
    /// The list to remove from.
    list: [*c]list,
    /// The element to remove from the list.
    elt: [*c]list_elt,
) callconv(.C) void;
/// Add an element at the end of a list.
pub const listPushBack = oc_list_push_back;
extern fn oc_list_push_back(
    /// The list to add an element to.
    list: [*c]list,
    /// The element to add to the list.
    elt: [*c]list_elt,
) callconv(.C) void;
/// Remove the last element from a list.
pub const listPopBack = oc_list_pop_back;
extern fn oc_list_pop_back(
    /// The list to remove an element from.
    list: [*c]list,
) callconv(.C) [*c]list_elt;
/// Add an element at the beginning of a list.
pub const listPushFront = oc_list_push_front;
extern fn oc_list_push_front(
    /// The list to add an element to.
    list: [*c]list,
    /// The element to add to the list.
    elt: [*c]list_elt,
) callconv(.C) void;
/// Remove the first element from a list.
pub const listPopFront = oc_list_pop_front;
extern fn oc_list_pop_front(
    /// The list to remove an element from.
    list: [*c]list,
) callconv(.C) [*c]list_elt;

//------------------------------------------------------------------------------------------
// [Memory] Base allocator and memory arenas.
//------------------------------------------------------------------------------------------

pub const pool = extern struct {
    arena: arena,
    freeList: list,
    blockSize: u64,
};
/// The prototype of a procedure to reserve memory from the system.
pub const mem_reserve_proc = *const fn (
    context: [*c]base_allocator,
    size: u64,
) callconv(.C) ?*anyopaque;
/// The prototype of a procedure to modify a memory reservation.
pub const mem_modify_proc = *const fn (
    context: [*c]base_allocator,
    ptr: ?*anyopaque,
    size: u64,
) callconv(.C) void;
/// A structure that defines how to allocate memory from the system.
pub const base_allocator = extern struct {
    /// A procedure to reserve memory from the system.
    reserve: mem_reserve_proc,
    /// A procedure to commit memory from the system.
    commit: mem_modify_proc,
    /// A procedure to decommit memory from the system.
    decommit: mem_modify_proc,
    /// A procedure to release memory previously reserved from the system.
    release: mem_modify_proc,
};
/// A contiguous chunk of memory managed by a memory arena.
pub const arena_chunk = extern struct {
    listElt: list_elt,
    ptr: [*c]u8,
    offset: u64,
    committed: u64,
    cap: u64,
};
/// A memory arena, allowing to allocate memory in a linear or stack-like fashion.
pub const arena = extern struct {
    /// An allocator providing memory pages from the system
    base: [*c]base_allocator,
    /// A list of `oc_arena_chunk` chunks.
    chunks: list,
    /// The chunk new memory allocations are pulled from.
    currentChunk: [*c]arena_chunk,
};
/// This struct provides a way to store the current offset in a given arena, in order to reset the arena to that offset later. This allows using arenas in a stack-like fashion, e.g. to create temporary "scratch" allocations
pub const arena_scope = extern struct {
    /// The arena which offset is stored.
    arena: [*c]arena,
    /// The arena chunk to which the offset belongs.
    chunk: [*c]arena_chunk,
    /// The offset to rewind the arena to.
    offset: u64,
};
/// Options for arena creation.
pub const arena_options = extern struct {
    /// The base allocator to use with this arena
    base: [*c]base_allocator,
    /// The amount of memory to reserve up-front when creating the arena.
    reserve: u64,
};
/// Initialize a memory arena.
pub const arenaInit = oc_arena_init;
extern fn oc_arena_init(
    /// The arena to initialize.
    arena: [*c]arena,
) callconv(.C) void;
/// Initialize a memory arena with additional options.
pub const arenaInitWithOptions = oc_arena_init_with_options;
extern fn oc_arena_init_with_options(
    /// The arena to initialize.
    arena: [*c]arena,
    /// The options to use to initialize the arena.
    options: [*c]arena_options,
) callconv(.C) void;
/// Release all resources allocated to a memory arena.
pub const arenaCleanup = oc_arena_cleanup;
extern fn oc_arena_cleanup(
    /// The arena to cleanup.
    arena: [*c]arena,
) callconv(.C) void;
/// Allocate a block of memory from an arena.
pub const arenaPush = oc_arena_push;
extern fn oc_arena_push(
    /// An arena to allocate memory from.
    arena: [*c]arena,
    /// The size of the memory to allocate, in bytes.
    size: u64,
) callconv(.C) ?*anyopaque;
/// Allocate an aligned block of memory from an arena.
pub const arenaPushAligned = oc_arena_push_aligned;
extern fn oc_arena_push_aligned(
    /// An arena to allocate memory from.
    arena: [*c]arena,
    /// The size of the memory to allocate, in bytes.
    size: u64,
    /// The desired alignment of the memory block, in bytes
    alignment: u32,
) callconv(.C) ?*anyopaque;
/// Reset an arena. All memory that was previously allocated from this arena is released to the arena, and can be reallocated by later calls to `oc_arena_push` and similar functions. No memory is actually released _to the system_.
pub const arenaClear = oc_arena_clear;
extern fn oc_arena_clear(
    /// The arena to clear.
    arena: [*c]arena,
) callconv(.C) void;
/// Begin a memory scope. This creates an `oc_arena_scope` object that stores the current offset of the arena. The arena can later be reset to that offset by calling `oc_arena_scope_end`, releasing all memory that was allocated within the scope to the arena.
pub const arenaScopeBegin = oc_arena_scope_begin;
extern fn oc_arena_scope_begin(
    /// The arena for which the scope is created.
    arena: [*c]arena,
) callconv(.C) arena_scope;
/// End a memory scope. This resets an arena to the offset it had when the scope was created. All memory allocated within the scope is released back to the arena.
pub const arenaScopeEnd = oc_arena_scope_end;
extern fn oc_arena_scope_end(
    /// An `oc_arena_scope` object that was created by a call to `oc_arena_scope_begin()`.
    scope: arena_scope,
) callconv(.C) void;
/// Begin a scratch scope. This creates a memory scope on a per-thread, global "scratch" arena. This allows easily creating temporary memory for scratch computations or intermediate results, in a stack-like fashion.
///
/// If you must return results in an arena passed by the caller, and you also use a scratch arena to do intermediate computations, beware that the results arena could itself be a scatch arena. In this case, you have to be careful not to intermingle your scratch computations with the final result, or clear your result entirely. You can either:
///
/// - Allocate memory for the result upfront and call `oc_scratch_begin` afterwards, if possible.
/// - Use `oc_scratch_begin_next()` and pass it the result arena, to get a scratch arena that does not conflict with it.
pub const scratchBegin = oc_scratch_begin;
extern fn oc_scratch_begin() callconv(.C) arena_scope;
/// Begin a scratch scope that does not conflict with a given arena. See `oc_scratch_begin()` for more details about when to use this function.
pub const scratchBeginNext = oc_scratch_begin_next;
extern fn oc_scratch_begin_next(
    /// A pointer to a memory arena that the scratch scope shouldn't interfere with.
    used: [*c]arena,
) callconv(.C) arena_scope;
/// Allocate a type from an arena. This macro takes care of the memory alignment and type cast.
pub const oc_arena_push_type = @compileError("TODO: translate macro");
/// Allocate an array from an arena. This macro takes care of the size calculation, memory alignment and type cast.
pub const oc_arena_push_array = @compileError("TODO: translate macro");
/// End a scratch scope.
pub const oc_scratch_end = @compileError("TODO: translate macro");

//------------------------------------------------------------------------------------------
// [Strings] String slices and string lists.
//------------------------------------------------------------------------------------------

/// A type representing a string of bytes.
pub const str8 = extern struct {
    /// A pointer to the string's bytes.
    ptr: [*c]u8,
    /// The length of the string.
    len: usize,
};
/// Makes an `oc_str8` string from a C null-terminated string.
pub const OC_STR8 = @compileError("TODO: translate macro");
/// Expands a string `s` to `s.len, s.ptr`
///
/// You can use this macro when calling functions that expect a `size_t` length and pointer arguments.
pub const oc_str8_lp = @compileError("TODO: translate macro");
/// Expands a string `s` to `(int)s.len, s.ptr`.
///
/// You can use this macro when calling functions that expect an `i32` length and pointer arguments, for example:
///
/// ```
/// printf(".*s", oc_str8_lp(s));
/// ```
pub const oc_str8_ip = @compileError("TODO: translate macro");
/// Make a string from a bytes buffer and a length.
pub const str8FromBuffer = oc_str8_from_buffer;
extern fn oc_str8_from_buffer(
    len: u64,
    /// A buffer of bytes.
    buffer: [*c]u8,
) callconv(.C) str8;
/// Make a string from a slice of another string. The resulting string designates some subsequence of the input string.
pub const str8Slice = oc_str8_slice;
extern fn oc_str8_slice(
    s: str8,
    /// The inclusive start index of the slice.
    start: u64,
    /// The exclusive end index of the slice.
    end: u64,
) callconv(.C) str8;
/// Pushes a copy of a buffer to an arena, and makes a string refering to that copy.
pub const str8PushBuffer = oc_str8_push_buffer;
extern fn oc_str8_push_buffer(
    arena: [*c]arena,
    /// The length of the buffer.
    len: u64,
    /// The buffer to copy.
    buffer: [*c]u8,
) callconv(.C) str8;
/// Pushes a copy of a C null-terminated string to an arena, and makes a string referring to that copy.
pub const str8PushCstring = oc_str8_push_cstring;
extern fn oc_str8_push_cstring(
    arena: [*c]arena,
    /// A null-terminated string.
    str: [*c]u8,
) callconv(.C) str8;
/// Copy the contents of a string on an arena and make a new string referring to the copied bytes.
pub const str8PushCopy = oc_str8_push_copy;
extern fn oc_str8_push_copy(
    /// The arena on which to copy the contents of the input string.
    arena: [*c]arena,
    /// The input string.
    s: str8,
) callconv(.C) str8;
/// Make a copy of a string slice. This function copies a subsequence of the input string onto an arena, and returns a new string referring to the copied content.
pub const str8PushSlice = oc_str8_push_slice;
extern fn oc_str8_push_slice(
    /// The arena on which to copy the slice of the input string.
    arena: [*c]arena,
    /// The input string.
    s: str8,
    /// The inclusive start index of the slice.
    start: u64,
    /// The exclusive end index of the slice.
    end: u64,
) callconv(.C) str8;
/// Build a string from a null-terminated format string and a variadic argument list, similar to `vasprintf()`.
pub const str8Pushfv = oc_str8_pushfv;
extern fn oc_str8_pushfv(
    /// The arena on which to allocate the contents of the string.
    arena: [*c]arena,
    /// A null-terminated format string. The format of that string is the same as that of the C `sprintf()` family of functions.
    format: [*c]u8,
    /// A variadic argument list or arguments referenced by the format string.
    args: @compileError("TODO: handle va_list type"),
) callconv(.C) str8;
/// Build a string from a null-terminated format string and variadic arguments, similar to `asprintf()`.
pub const str8Pushf = oc_str8_pushf;
extern fn oc_str8_pushf(
    /// The arena on which to allocate the contents of the string.
    arena: [*c]arena,
    format: [*c]u8,
    /// Additional arguments referenced by the format string.
    ...,
) callconv(.C) str8;
/// Lexicographically compare the contents of two strings.
pub const str8Cmp = oc_str8_cmp;
extern fn oc_str8_cmp(
    /// The first string to compare.
    s1: str8,
    /// The second string to compare.
    s2: str8,
) callconv(.C) i32;
/// Create a null-terminated C-string from an `oc_str8` string.
pub const str8ToCstring = oc_str8_to_cstring;
extern fn oc_str8_to_cstring(
    /// The arena on which to copy the contents of `string` and the null terminator.
    arena: [*c]arena,
    /// The input string.
    string: str8,
) callconv(.C) [*c]u8;
/// A type representing an element of a string list.
pub const str8_elt = extern struct {
    /// The string element is linked into its parent string list through this field.
    listElt: list_elt,
    /// The string for this element.
    string: str8,
};
/// A type representing a string list.
pub const str8_list = extern struct {
    /// A linked-list of `oc_str8_elt`.
    list: list,
    /// The number of elements in `list`.
    eltCount: u64,
    /// The total length of the string list, which is the sum of the lengths over all elements.
    len: u64,
};
/// Push a string element to the back of a string list. This creates a `oc_str8_elt` element referring to the contents of the input string, and links that element at the end of the string list.
pub const str8ListPush = oc_str8_list_push;
extern fn oc_str8_list_push(
    /// A memory arena on which to allocate the new string element.
    arena: [*c]arena,
    /// The string list to link the new element into.
    list: [*c]str8_list,
    /// The string of the new element. Note that the contents of the string is not copied. The new string element refers to the same bytes as `str`.
    str: str8,
) callconv(.C) void;
/// Build a string from a null-terminated format string an variadic arguments, and append it to a string list.
pub const str8ListPushf = oc_str8_list_pushf;
extern fn oc_str8_list_pushf(
    /// The arena on which to allocate the contents of the string, as well as the string element.
    arena: [*c]arena,
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
    arena: [*c]arena,
    /// A string list containing the elements to combine
    list: str8_list,
    /// A prefix that is pasted at the beginning of the string.
    prefix: str8,
    /// A separator that is pasted between each element of the input string list.
    separator: str8,
    /// A suffix that is pasted at the end of the string.
    suffix: str8,
) callconv(.C) str8;
/// Build a string by joining the elements of a string list.
pub const str8ListJoin = oc_str8_list_join;
extern fn oc_str8_list_join(
    /// The arena on which to allocate the new string.
    arena: [*c]arena,
    /// A string list containing the elements of join.
    list: str8_list,
) callconv(.C) str8;
/// Split a list into a string list according to separators.
///
/// No string copies are made. The elements of the resulting string list refer to subsequences of the input string.
pub const str8Split = oc_str8_split;
extern fn oc_str8_split(
    /// The arena on which to allocate the elements of the string list.
    arena: [*c]arena,
    /// The input string.
    str: str8,
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
/// A type describing a string of 16-bits characters (typically used for UTF-16).
pub const str16 = extern struct {
    /// A pointer to the underlying 16-bits character array.
    ptr: [*c]u16,
    /// The length of the string, in 16-bits characters.
    len: usize,
};
/// Make an `oc_str16` string from a buffer of 16-bit characters.
pub const str16FromBuffer = oc_str16_from_buffer;
extern fn oc_str16_from_buffer(
    /// The length of the input buffer, in characters.
    len: u64,
    /// The 16-bits characters buffer.
    buffer: [*c]u16,
) callconv(.C) str16;
/// Make an `oc_str16` string from a slice of another `oc_str16` string.
pub const str16Slice = oc_str16_slice;
extern fn oc_str16_slice(
    /// The input string.
    s: str16,
    /// The inclusive start index of the slice.
    start: u64,
    /// The exclusive end index of the slice.
    end: u64,
) callconv(.C) str16;
/// Copy the content of a 16-bit character buffer on an arena and make a new `oc_str16` referencing the copied contents.
pub const str16PushBuffer = oc_str16_push_buffer;
extern fn oc_str16_push_buffer(
    /// The arena on which to copy the input buffer.
    arena: [*c]arena,
    /// The length of the buffer.
    len: u64,
    /// An input buffer of 16-bit characters.
    buffer: [*c]u16,
) callconv(.C) str16;
/// Copy the contents of an `oc_str16` string and make a new string referencing the copied contents.
pub const str16PushCopy = oc_str16_push_copy;
extern fn oc_str16_push_copy(
    /// The arena on which to copy the contents of the input string.
    arena: [*c]arena,
    /// The input string.
    s: str16,
) callconv(.C) str16;
/// Copy a slice of an `oc_str16` string an make a new string referencing the copies contents.
pub const str16PushSlice = oc_str16_push_slice;
extern fn oc_str16_push_slice(
    /// The arena on which to copy the slice of the input string's contents.
    arena: [*c]arena,
    /// The input string.
    s: str16,
    /// The inclusive start index of the slice.
    start: u64,
    /// The exclusive end index of the slice.
    end: u64,
) callconv(.C) str16;
/// A type representing an element of an `oc_str16` list.
pub const str16_elt = extern struct {
    /// The string element is linked into its parent string list through this field.
    listElt: list_elt,
    /// The string for this element.
    string: str16,
};
pub const str16_list = extern struct {
    /// A linked-list of `oc_str16_elt`.
    list: list,
    /// The number of elements in `list`.
    eltCount: u64,
    /// The total length of the string list, which is the sum of the lengths over all elements.
    len: u64,
};
/// Push a string element to the back of a string list. This creates a `oc_str16_elt` element referring to the contents of the input string, and links that element at the end of the string list.
pub const str16ListPush = oc_str16_list_push;
extern fn oc_str16_list_push(
    /// A memory arena on which to allocate the new string element.
    arena: [*c]arena,
    /// The string list to link the new element into.
    list: [*c]str16_list,
    /// The string of the new element. Note that the contents of the string is not copied. The new string element refers to the same bytes as `str`.
    str: str16,
) callconv(.C) void;
/// Build a string by joining the elements of a string list.
pub const str16ListJoin = oc_str16_list_join;
extern fn oc_str16_list_join(
    /// The arena on which to allocate the new string.
    arena: [*c]arena,
    /// A string list containing the elements of join.
    list: str16_list,
) callconv(.C) str16;
/// Split a list into a string list according to separators.
///
/// No string copies are made. The elements of the resulting string list refer to subsequences of the input string.
pub const str16Split = oc_str16_split;
extern fn oc_str16_split(
    /// The arena on which to allocate the elements of the string list.
    arena: [*c]arena,
    /// The input string.
    str: str16,
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
/// A type describing a string of 32-bits characters (typically used for UTF-32 codepoints).
pub const str32 = extern struct {
    /// A pointer to the underlying 32-bits character array.
    ptr: [*c]u32,
    /// The length of the string, in 32-bits characters.
    len: usize,
};
/// Make an `oc_str32` string from a buffer of 32-bit characters.
pub const str32FromBuffer = oc_str32_from_buffer;
extern fn oc_str32_from_buffer(
    /// The length of the input buffer, in characters.
    len: u64,
    /// The 32-bits characters buffer.
    buffer: [*c]u32,
) callconv(.C) str32;
/// Make an `oc_str32` string from a slice of another `oc_str32` string.
pub const str32Slice = oc_str32_slice;
extern fn oc_str32_slice(
    /// The input string.
    s: str32,
    /// The inclusive start index of the slice.
    start: u64,
    /// The exclusive end index of the slice.
    end: u64,
) callconv(.C) str32;
/// Copy the content of a 32-bit character buffer on an arena and make a new `oc_str32` referencing the copied contents.
pub const str32PushBuffer = oc_str32_push_buffer;
extern fn oc_str32_push_buffer(
    /// The arena on which to copy the input buffer.
    arena: [*c]arena,
    /// The length of the buffer.
    len: u64,
    /// An input buffer of 32-bit characters.
    buffer: [*c]u32,
) callconv(.C) str32;
/// Copy the contents of an `oc_str32` string and make a new string referencing the copied contents.
pub const str32PushCopy = oc_str32_push_copy;
extern fn oc_str32_push_copy(
    /// The arena on which to copy the contents of the input string.
    arena: [*c]arena,
    /// The input string.
    s: str32,
) callconv(.C) str32;
/// Copy a slice of an `oc_str32` string an make a new string referencing the copies contents.
pub const str32PushSlice = oc_str32_push_slice;
extern fn oc_str32_push_slice(
    /// The arena on which to copy the slice of the input string's contents.
    arena: [*c]arena,
    /// The input string.
    s: str32,
    /// The inclusive start index of the slice.
    start: u64,
    /// The exclusive end index of the slice.
    end: u64,
) callconv(.C) str32;
/// A type representing an element of an `oc_str32` list.
pub const str32_elt = extern struct {
    /// The string element is linked into its parent string list through this field.
    listElt: list_elt,
    /// The string for this element.
    string: str32,
};
pub const str32_list = extern struct {
    /// A linked-list of `oc_str32_elt`.
    list: list,
    /// The number of elements in `list`.
    eltCount: u64,
    /// The total length of the string list, which is the sum of the lengths over all elements.
    len: u64,
};
/// Push a string element to the back of a string list. This creates a `oc_str32_elt` element referring to the contents of the input string, and links that element at the end of the string list.
pub const str32ListPush = oc_str32_list_push;
extern fn oc_str32_list_push(
    /// A memory arena on which to allocate the new string element.
    arena: [*c]arena,
    /// The string list to link the new element into.
    list: [*c]str32_list,
    /// The string of the new element. Note that the contents of the string is not copied. The new string element refers to the same bytes as `str`.
    str: str32,
) callconv(.C) void;
/// Build a string by joining the elements of a string list.
pub const str32ListJoin = oc_str32_list_join;
extern fn oc_str32_list_join(
    /// The arena on which to allocate the new string.
    arena: [*c]arena,
    /// A string list containing the elements of join.
    list: str32_list,
) callconv(.C) str32;
/// Split a list into a string list according to separators.
///
/// No string copies are made. The elements of the resulting string list refer to subsequences of the input string.
pub const str32Split = oc_str32_split;
extern fn oc_str32_split(
    /// The arena on which to allocate the elements of the string list.
    arena: [*c]arena,
    /// The input string.
    str: str32,
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
    string: str8,
) callconv(.C) u64;
/// Get the length of the utf8 encoding of a sequence of unicode codepoints.
pub const utf8ByteCountForCodepoints = oc_utf8_byte_count_for_codepoints;
extern fn oc_utf8_byte_count_for_codepoints(
    /// A sequence of unicode codepoints.
    codePoints: str32,
) callconv(.C) u64;
/// Get the offset of the next codepoint after a given offset, in a utf8 encoded string.
pub const utf8NextOffset = oc_utf8_next_offset;
extern fn oc_utf8_next_offset(
    /// A utf8 encoded string.
    string: str8,
    /// The offset after which to look for the next codepoint, in bytes.
    byteOffset: u64,
) callconv(.C) u64;
/// Get the offset of the previous codepoint before a given offset, in a utf8 encoded string.
pub const utf8PrevOffset = oc_utf8_prev_offset;
extern fn oc_utf8_prev_offset(
    /// A utf8 encoded string.
    string: str8,
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
    string: str8,
) callconv(.C) utf8_dec;
/// Decode a codepoint at a given offset in a utf8 encoded string.
pub const utf8DecodeAt = oc_utf8_decode_at;
extern fn oc_utf8_decode_at(
    /// A utf8 encoded string.
    string: str8,
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
) callconv(.C) str8;
/// Decode a utf8 string to a string of unicode codepoints using memory passed by the caller.
pub const utf8ToCodepoints = oc_utf8_to_codepoints;
extern fn oc_utf8_to_codepoints(
    /// The maximum number of codepoints that the backing memory can contain.
    maxCount: u64,
    /// A pointer to the backing memory for the result. This must point to a buffer capable of holding `maxCount` codepoints.
    backing: [*c]utf32,
    /// A utf8 encoded string.
    string: str8,
) callconv(.C) str32;
/// Encode a string of unicode codepoints into a utf8 string using memory passed by the caller.
pub const utf8FromCodepoints = oc_utf8_from_codepoints;
extern fn oc_utf8_from_codepoints(
    /// The maximum number of bytes that the backing memory can contain.
    maxBytes: u64,
    /// A pointer to the backing memory for the result. This must point to a buffer capable of holding `maxBytes` bytes.
    backing: [*c]u8,
    /// A string of unicode codepoints.
    codePoints: str32,
) callconv(.C) str8;
/// Decode a utf8 encoded string to a string of unicode codepoints using an arena.
pub const utf8PushToCodepoints = oc_utf8_push_to_codepoints;
extern fn oc_utf8_push_to_codepoints(
    /// The arena on which to allocate the codepoints.
    arena: [*c]arena,
    /// A utf8 encoded string.
    string: str8,
) callconv(.C) str32;
/// Encode a string of unicode codepoints into a utf8 string using an arena.
pub const utf8PushFromCodepoints = oc_utf8_push_from_codepoints;
extern fn oc_utf8_push_from_codepoints(
    /// The arena on which to allocate the utf8 encoded string.
    arena: [*c]arena,
    /// A string of unicode codepoints.
    codePoints: str32,
) callconv(.C) str8;
/// A type representing a contiguous range of unicode codepoints.
pub const unicode_range = extern struct {
    /// The first codepoint of the range.
    firstCodePoint: utf32,
    /// The number of codepoints in the range.
    count: u32,
};

//------------------------------------------------------------------------------------------
// [Application] Input, windowing, dialogs.
//------------------------------------------------------------------------------------------

pub const window = u64;

//------------------------------------------------------------------------------------------
// [Events] Application events.
//------------------------------------------------------------------------------------------

/// This enum defines the type events that can be sent to the application by the runtime. This determines which member of the `oc_event` union field is active.
pub const event_type = enum(u32) {
    /// No event. That could be used simply to wake up the application.
    EVENT_NONE = 0,
    /// A modifier key event. This event is sent when a key such as <kbd>Alt</kbd>, <kbd>Control</kbd>, <kbd>Command</kbd> or <kbd>Shift</kbd> are pressed, released, or repeated. The `key` field contains the event's details.
    EVENT_KEYBOARD_MODS = 1,
    /// A key event. This event is sent when a normal key is pressed, released, or repeated. The `key` field contains the event's details.
    EVENT_KEYBOARD_KEY = 2,
    /// A character input event. This event is sent when an input character is produced by the keyboard. The `character` field contains the event's details.
    EVENT_KEYBOARD_CHAR = 3,
    /// A mouse button event. This is event sent when one of the mouse buttons is pressed, released, or clicked. The `key` field contains the event's details.
    EVENT_MOUSE_BUTTON = 4,
    /// A mouse move event. This is event sent when the mouse is moved. The `mouse` field contains the event's details.
    EVENT_MOUSE_MOVE = 5,
    /// A mouse wheel event. This is event sent when the mouse wheel is moved (or when a trackpad is scrolled). The `mouse` field contains the event's details.
    EVENT_MOUSE_WHEEL = 6,
    /// A mouse enter event. This event is sent when the mouse enters the application's window. The `mouse` field contains the event's details.
    EVENT_MOUSE_ENTER = 7,
    /// A mouse leave event. This event is sent when the mouse leaves the application's window.
    EVENT_MOUSE_LEAVE = 8,
    /// A clipboard paste event. This event is sent when the user uses the paste shortcut while the application window has focus.
    EVENT_CLIPBOARD_PASTE = 9,
    /// A resize event. This event is sent when the application's window is resized. The `move` field contains the event's details.
    EVENT_WINDOW_RESIZE = 10,
    /// A move event. This event is sent when the window is moved. The `move` field contains the event's details.
    EVENT_WINDOW_MOVE = 11,
    /// A focus event. This event is sent when the application gains focus.
    EVENT_WINDOW_FOCUS = 12,
    /// An unfocus event. This event is sent when the application looses focus.
    EVENT_WINDOW_UNFOCUS = 13,
    /// A hide event. This event is sent when the application's window is hidden or minimized.
    EVENT_WINDOW_HIDE = 14,
    /// A show event. This event is sent when the application's window is shown or de-minimized.
    EVENT_WINDOW_SHOW = 15,
    /// A close event. This event is sent when the window is about to be closed.
    EVENT_WINDOW_CLOSE = 16,
    /// A path drop event. This event is sent when the user drops files onto the application's window. The `paths` field contains the event's details.
    EVENT_PATHDROP = 17,
    /// A frame event. This event is sent when the application should render a frame.
    EVENT_FRAME = 18,
    /// A quit event. This event is sent when the application has been requested to quit.
    EVENT_QUIT = 19,
};
/// This enum describes the actions that can happen to a key.
pub const key_action = enum(u32) {
    /// No action happened on that key.
    KEY_NO_ACTION = 0,
    /// The key was pressed.
    KEY_PRESS = 1,
    /// The key was released.
    KEY_RELEASE = 2,
    /// The key was maintained pressed at least for the system's key repeat period.
    KEY_REPEAT = 3,
};
/// A code representing a key's physical location. This is independent of the system's keyboard layout.
pub const scan_code = enum(u32) {
    SCANCODE_UNKNOWN = 0,
    SCANCODE_SPACE = 32,
    SCANCODE_APOSTROPHE = 39,
    SCANCODE_COMMA = 44,
    SCANCODE_MINUS = 45,
    SCANCODE_PERIOD = 46,
    SCANCODE_SLASH = 47,
    SCANCODE_0 = 48,
    SCANCODE_1 = 49,
    SCANCODE_2 = 50,
    SCANCODE_3 = 51,
    SCANCODE_4 = 52,
    SCANCODE_5 = 53,
    SCANCODE_6 = 54,
    SCANCODE_7 = 55,
    SCANCODE_8 = 56,
    SCANCODE_9 = 57,
    SCANCODE_SEMICOLON = 59,
    SCANCODE_EQUAL = 61,
    SCANCODE_LEFT_BRACKET = 91,
    SCANCODE_BACKSLASH = 92,
    SCANCODE_RIGHT_BRACKET = 93,
    SCANCODE_GRAVE_ACCENT = 96,
    SCANCODE_A = 97,
    SCANCODE_B = 98,
    SCANCODE_C = 99,
    SCANCODE_D = 100,
    SCANCODE_E = 101,
    SCANCODE_F = 102,
    SCANCODE_G = 103,
    SCANCODE_H = 104,
    SCANCODE_I = 105,
    SCANCODE_J = 106,
    SCANCODE_K = 107,
    SCANCODE_L = 108,
    SCANCODE_M = 109,
    SCANCODE_N = 110,
    SCANCODE_O = 111,
    SCANCODE_P = 112,
    SCANCODE_Q = 113,
    SCANCODE_R = 114,
    SCANCODE_S = 115,
    SCANCODE_T = 116,
    SCANCODE_U = 117,
    SCANCODE_V = 118,
    SCANCODE_W = 119,
    SCANCODE_X = 120,
    SCANCODE_Y = 121,
    SCANCODE_Z = 122,
    SCANCODE_WORLD_1 = 161,
    SCANCODE_WORLD_2 = 162,
    SCANCODE_ESCAPE = 256,
    SCANCODE_ENTER = 257,
    SCANCODE_TAB = 258,
    SCANCODE_BACKSPACE = 259,
    SCANCODE_INSERT = 260,
    SCANCODE_DELETE = 261,
    SCANCODE_RIGHT = 262,
    SCANCODE_LEFT = 263,
    SCANCODE_DOWN = 264,
    SCANCODE_UP = 265,
    SCANCODE_PAGE_UP = 266,
    SCANCODE_PAGE_DOWN = 267,
    SCANCODE_HOME = 268,
    SCANCODE_END = 269,
    SCANCODE_CAPS_LOCK = 280,
    SCANCODE_SCROLL_LOCK = 281,
    SCANCODE_NUM_LOCK = 282,
    SCANCODE_PRINT_SCREEN = 283,
    SCANCODE_PAUSE = 284,
    SCANCODE_F1 = 290,
    SCANCODE_F2 = 291,
    SCANCODE_F3 = 292,
    SCANCODE_F4 = 293,
    SCANCODE_F5 = 294,
    SCANCODE_F6 = 295,
    SCANCODE_F7 = 296,
    SCANCODE_F8 = 297,
    SCANCODE_F9 = 298,
    SCANCODE_F10 = 299,
    SCANCODE_F11 = 300,
    SCANCODE_F12 = 301,
    SCANCODE_F13 = 302,
    SCANCODE_F14 = 303,
    SCANCODE_F15 = 304,
    SCANCODE_F16 = 305,
    SCANCODE_F17 = 306,
    SCANCODE_F18 = 307,
    SCANCODE_F19 = 308,
    SCANCODE_F20 = 309,
    SCANCODE_F21 = 310,
    SCANCODE_F22 = 311,
    SCANCODE_F23 = 312,
    SCANCODE_F24 = 313,
    SCANCODE_F25 = 314,
    SCANCODE_KP_0 = 320,
    SCANCODE_KP_1 = 321,
    SCANCODE_KP_2 = 322,
    SCANCODE_KP_3 = 323,
    SCANCODE_KP_4 = 324,
    SCANCODE_KP_5 = 325,
    SCANCODE_KP_6 = 326,
    SCANCODE_KP_7 = 327,
    SCANCODE_KP_8 = 328,
    SCANCODE_KP_9 = 329,
    SCANCODE_KP_DECIMAL = 330,
    SCANCODE_KP_DIVIDE = 331,
    SCANCODE_KP_MULTIPLY = 332,
    SCANCODE_KP_SUBTRACT = 333,
    SCANCODE_KP_ADD = 334,
    SCANCODE_KP_ENTER = 335,
    SCANCODE_KP_EQUAL = 336,
    SCANCODE_LEFT_SHIFT = 340,
    SCANCODE_LEFT_CONTROL = 341,
    SCANCODE_LEFT_ALT = 342,
    SCANCODE_LEFT_SUPER = 343,
    SCANCODE_RIGHT_SHIFT = 344,
    SCANCODE_RIGHT_CONTROL = 345,
    SCANCODE_RIGHT_ALT = 346,
    SCANCODE_RIGHT_SUPER = 347,
    SCANCODE_MENU = 348,
    SCANCODE_COUNT = 349,
};
/// A code identifying a key. The physical location of the key corresponding to a given key code depends on the system's keyboard layout.
pub const key_code = enum(u32) {
    KEY_UNKNOWN = 0,
    KEY_SPACE = 32,
    KEY_APOSTROPHE = 39,
    KEY_COMMA = 44,
    KEY_MINUS = 45,
    KEY_PERIOD = 46,
    KEY_SLASH = 47,
    KEY_0 = 48,
    KEY_1 = 49,
    KEY_2 = 50,
    KEY_3 = 51,
    KEY_4 = 52,
    KEY_5 = 53,
    KEY_6 = 54,
    KEY_7 = 55,
    KEY_8 = 56,
    KEY_9 = 57,
    KEY_SEMICOLON = 59,
    KEY_EQUAL = 61,
    KEY_LEFT_BRACKET = 91,
    KEY_BACKSLASH = 92,
    KEY_RIGHT_BRACKET = 93,
    KEY_GRAVE_ACCENT = 96,
    KEY_A = 97,
    KEY_B = 98,
    KEY_C = 99,
    KEY_D = 100,
    KEY_E = 101,
    KEY_F = 102,
    KEY_G = 103,
    KEY_H = 104,
    KEY_I = 105,
    KEY_J = 106,
    KEY_K = 107,
    KEY_L = 108,
    KEY_M = 109,
    KEY_N = 110,
    KEY_O = 111,
    KEY_P = 112,
    KEY_Q = 113,
    KEY_R = 114,
    KEY_S = 115,
    KEY_T = 116,
    KEY_U = 117,
    KEY_V = 118,
    KEY_W = 119,
    KEY_X = 120,
    KEY_Y = 121,
    KEY_Z = 122,
    KEY_WORLD_1 = 161,
    KEY_WORLD_2 = 162,
    KEY_ESCAPE = 256,
    KEY_ENTER = 257,
    KEY_TAB = 258,
    KEY_BACKSPACE = 259,
    KEY_INSERT = 260,
    KEY_DELETE = 261,
    KEY_RIGHT = 262,
    KEY_LEFT = 263,
    KEY_DOWN = 264,
    KEY_UP = 265,
    KEY_PAGE_UP = 266,
    KEY_PAGE_DOWN = 267,
    KEY_HOME = 268,
    KEY_END = 269,
    KEY_CAPS_LOCK = 280,
    KEY_SCROLL_LOCK = 281,
    KEY_NUM_LOCK = 282,
    KEY_PRINT_SCREEN = 283,
    KEY_PAUSE = 284,
    KEY_F1 = 290,
    KEY_F2 = 291,
    KEY_F3 = 292,
    KEY_F4 = 293,
    KEY_F5 = 294,
    KEY_F6 = 295,
    KEY_F7 = 296,
    KEY_F8 = 297,
    KEY_F9 = 298,
    KEY_F10 = 299,
    KEY_F11 = 300,
    KEY_F12 = 301,
    KEY_F13 = 302,
    KEY_F14 = 303,
    KEY_F15 = 304,
    KEY_F16 = 305,
    KEY_F17 = 306,
    KEY_F18 = 307,
    KEY_F19 = 308,
    KEY_F20 = 309,
    KEY_F21 = 310,
    KEY_F22 = 311,
    KEY_F23 = 312,
    KEY_F24 = 313,
    KEY_F25 = 314,
    KEY_KP_0 = 320,
    KEY_KP_1 = 321,
    KEY_KP_2 = 322,
    KEY_KP_3 = 323,
    KEY_KP_4 = 324,
    KEY_KP_5 = 325,
    KEY_KP_6 = 326,
    KEY_KP_7 = 327,
    KEY_KP_8 = 328,
    KEY_KP_9 = 329,
    KEY_KP_DECIMAL = 330,
    KEY_KP_DIVIDE = 331,
    KEY_KP_MULTIPLY = 332,
    KEY_KP_SUBTRACT = 333,
    KEY_KP_ADD = 334,
    KEY_KP_ENTER = 335,
    KEY_KP_EQUAL = 336,
    KEY_LEFT_SHIFT = 340,
    KEY_LEFT_CONTROL = 341,
    KEY_LEFT_ALT = 342,
    KEY_LEFT_SUPER = 343,
    KEY_RIGHT_SHIFT = 344,
    KEY_RIGHT_CONTROL = 345,
    KEY_RIGHT_ALT = 346,
    KEY_RIGHT_SUPER = 347,
    KEY_MENU = 348,
    KEY_COUNT = 349,
};
pub const keymod_flags = enum(u32) {
    KEYMOD_NONE = 0,
    KEYMOD_ALT = 1,
    KEYMOD_SHIFT = 2,
    KEYMOD_CTRL = 4,
    KEYMOD_CMD = 8,
    KEYMOD_MAIN_MODIFIER = 16,
};
/// A code identifying a mouse button.
pub const mouse_button = enum(u32) {
    MOUSE_LEFT = 0,
    MOUSE_RIGHT = 1,
    MOUSE_MIDDLE = 2,
    MOUSE_EXT1 = 3,
    MOUSE_EXT2 = 4,
    MOUSE_BUTTON_COUNT = 5,
};
/// A structure describing a key event or a mouse button event.
pub const key_event = extern struct {
    /// The action that was done on the key.
    action: key_action,
    /// The scan code of the key. Only valid for key events.
    scanCode: scan_code,
    /// The key code of the key. Only valid for key events.
    keyCode: key_code,
    /// The button of the mouse. Only valid for mouse button events.
    button: mouse_button,
    /// Modifier flags indicating which modifier keys where pressed at the time of the event.
    mods: keymod_flags,
    /// The number of clicks that where detected for the button. Only valid for mouse button events.
    clickCount: u8,
};
/// A structure describing a character input event.
pub const char_event = extern struct {
    /// The unicode codepoint of the character.
    codepoint: utf32,
    /// The utf8 sequence of the character.
    sequence: [8]u8,
    /// The utf8 sequence length.
    seqLen: u8,
};
/// A structure describing a mouse move or a mouse wheel event. Mouse coordinates have their origin at the top-left corner of the window, with the y axis going down.
pub const mouse_event = extern struct {
    /// The x coordinate of the mouse.
    x: f32,
    /// The y coordinate of the mouse.
    y: f32,
    /// The delta from the last x coordinate of the mouse, or the scroll value along the x coordinate.
    deltaX: f32,
    /// The delta from the last y coordinate of the mouse, or the scoll value along the y  coordinate.
    deltaY: f32,
    /// Modifier flags indicating which modifier keys where pressed at the time of the event.
    mods: keymod_flags,
};
/// A structure describing a window move or resize event.
pub const move_event = extern struct {
    /// The position and dimension of the frame rectangle, i.e. including the window title bar and border.
    frame: math.Rect,
    /// The position and dimension of the content rectangle, relative to the frame rectangle.
    content: math.Rect,
};
/// A structure describing an event sent to the application.
pub const event = extern struct {
    /// The window in which this event happened.
    window: window,
    /// The type of the event. This determines which member of the event union is active.
    type: event_type,
    unnamed_0: extern union {
        /// Details for a key or mouse button event.
        key: key_event,
        /// Details for a character input event.
        character: char_event,
        /// Details for a mouse move or mouse wheel event.
        mouse: mouse_event,
        /// Details for a window move or resize event.
        move: move_event,
        /// Details for a drag and drop event.
        paths: str8_list,
    },
};
/// This enum describes the kinds of possible file dialogs.
pub const file_dialog_kind = enum(u32) {
    /// The file dialog is a save dialog.
    FILE_DIALOG_SAVE = 0,
    /// The file dialog is an open dialog.
    FILE_DIALOG_OPEN = 1,
};
/// A type for flags describing various file dialog options.
pub const file_dialog_flags = u32;
/// File dialog flags.
pub const _oc_file_dialog_flags = enum(u32) {
    /// This dialog allows selecting files.
    FILE_DIALOG_FILES = 1,
    /// This dialog allows selecting directories.
    FILE_DIALOG_DIRECTORIES = 2,
    /// This dialog allows selecting multiple items.
    FILE_DIALOG_MULTIPLE = 4,
    /// This dialog allows creating directories.
    FILE_DIALOG_CREATE_DIRECTORIES = 8,
};
/// A structure describing a file dialog.
pub const file_dialog_desc = extern struct {
    /// The kind of file dialog, see `oc_file_dialog_kind`.
    kind: file_dialog_kind,
    /// A combination of file dialog flags used to enable file dialog options.
    flags: file_dialog_flags,
    /// The title of the dialog, displayed in the dialog title bar.
    title: str8,
    /// Optional. The label of the OK button, e.g. "Save" or "Open".
    okLabel: str8,
    /// Optional. A file handle to the root directory for the dialog. If set to zero, the root directory is the application's default data directory.
    startAt: file,
    /// Optional. The path of the starting directory of the dialog, relative to its root directory. If set to nil, the dialog starts at its root directory.
    startPath: str8,
    /// A list of file extensions used to restrict which files can be selected in this dialog. An empty list allows all files to be selected. Extensions should be provided without a leading dot.
    filters: str8_list,
};
/// An enum identifying the button clicked by the user when a file dialog returns.
pub const file_dialog_button = enum(u32) {
    /// The user clicked the "Cancel" button, or closed the dialog box.
    FILE_DIALOG_CANCEL = 0,
    /// The user clicked the "OK" button.
    FILE_DIALOG_OK = 1,
};
/// A structure describing the result of a file dialog.
pub const file_dialog_result = extern struct {
    /// The button clicked by the user.
    button: file_dialog_button,
    /// The path that was selected when the user clicked the OK button. If the dialog box had the `OC_FILE_DIALOG_MULTIPLE` flag set, this is the first file of the list of selected paths.
    path: str8,
    /// If the dialog box had the `OC_FILE_DIALOG_MULTIPLE` flag set and the user clicked the OK button, this list contains the selected paths.
    selection: str8_list,
};
/// Set the title of the application's window.
pub const windowSetTitle = oc_window_set_title;
extern fn oc_window_set_title(
    /// The title to display in the title bar of the application.
    title: str8,
) callconv(.C) void;
/// Set the size of the application's window.
pub const windowSetSize = oc_window_set_size;
extern fn oc_window_set_size(
    /// The new size of the application's window.
    size: math.Vec2,
) callconv(.C) void;
/// Request the system to quit the application.
pub const requestQuit = oc_request_quit;
extern fn oc_request_quit() callconv(.C) void;
/// Convert a scancode to a keycode, according to current keyboard layout.
pub const scancodeToKeycode = oc_scancode_to_keycode;
extern fn oc_scancode_to_keycode(
    /// The scan code to convert.
    scanCode: scan_code,
) callconv(.C) key_code;
/// Put a string in the clipboard.
pub const clipboardSetString = oc_clipboard_set_string;
extern fn oc_clipboard_set_string(
    /// A string to put in the clipboard.
    string: str8,
) callconv(.C) void;

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
    path: str8,
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
    path: str8,
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
    path: str8,
    rights: file_access,
    flags: file_open_flags,
) callconv(.C) file;

//------------------------------------------------------------------------------------------
// [Dialogs] API for obtaining file capabilities through open/save dialogs.
//------------------------------------------------------------------------------------------

/// An element of a list of file handles acquired through a file dialog.
pub const file_open_with_dialog_elt = extern struct {
    listElt: list_elt,
    file: file,
};
/// A structure describing the result of a call to `oc_file_open_with_dialog()`.
pub const file_open_with_dialog_result = extern struct {
    /// The button of the file dialog clicked by the user.
    button: file_dialog_button,
    /// The file that was opened through the dialog. If the dialog had the `OC_FILE_DIALOG_MULTIPLE` flag set, this is equal to the first handle in the `selection` list.
    file: file,
    /// If the dialog had the `OC_FILE_DIALOG_MULTIPLE` flag set, this list of `oc_file_open_with_dialog_elt` contains the handles of the opened files.
    selection: list,
};
/// Open files through a file dialog. This allows the user to select files outside the root directories currently accessible to the applications, giving them a way to provide new file capabilities to the application.
pub const fileOpenWithDialog = oc_file_open_with_dialog;
extern fn oc_file_open_with_dialog(
    /// A memory arena on which to allocate elements of the result.
    arena: [*c]arena,
    /// The access rights requested on the files to open.
    rights: file_access,
    /// Flags controlling various options of the open operation. See `oc_file_open_flags`.
    flags: file_open_flags,
    /// A structure controlling the options of the file dialog window.
    desc: [*c]file_dialog_desc,
) callconv(.C) file_open_with_dialog_result;

//------------------------------------------------------------------------------------------
// [Paths] API for handling filesystem paths.
//------------------------------------------------------------------------------------------

/// Get a string slice of the directory part of a path.
pub const pathSliceDirectory = oc_path_slice_directory;
extern fn oc_path_slice_directory(
    /// The path to slice.
    path: str8,
) callconv(.C) str8;
/// Get a string slice of the file name part of a path.
pub const pathSliceFilename = oc_path_slice_filename;
extern fn oc_path_slice_filename(
    /// The path to slice
    path: str8,
) callconv(.C) str8;
/// Split a path into path elements.
pub const pathSplit = oc_path_split;
extern fn oc_path_split(
    /// An arena on which to allocate string list elements.
    arena: [*c]arena,
    /// The path to slice.
    path: str8,
) callconv(.C) str8_list;
/// Join path elements to form a path.
pub const pathJoin = oc_path_join;
extern fn oc_path_join(
    /// An arena on which to allocate the resulting path.
    arena: [*c]arena,
    /// A string list of path elements.
    elements: str8_list,
) callconv(.C) str8;
/// Append a path to another path.
pub const pathAppend = oc_path_append;
extern fn oc_path_append(
    /// An arena on which to allocate the resulting path.
    arena: [*c]arena,
    /// The first part of the path.
    parent: str8,
    /// The relative path to append.
    relPath: str8,
) callconv(.C) str8;
/// Test wether a path is an absolute path.
pub const pathIsAbsolute = oc_path_is_absolute;
extern fn oc_path_is_absolute(
    /// The path to test.
    path: str8,
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
    mods: keymod_flags,
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
    codePoints: str32,
};
pub const clipboard_state = extern struct {
    lastUpdate: u64,
    pastedText: str8,
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
    arena: [*c]arena,
    state: [*c]input_state,
    event: [*c]event,
) callconv(.C) void;
pub const inputNextFrame = oc_input_next_frame;
extern fn oc_input_next_frame(
    state: [*c]input_state,
) callconv(.C) void;
pub const keyDown = oc_key_down;
extern fn oc_key_down(
    state: [*c]input_state,
    key: key_code,
) callconv(.C) bool;
pub const keyPressCount = oc_key_press_count;
extern fn oc_key_press_count(
    state: [*c]input_state,
    key: key_code,
) callconv(.C) u8;
pub const keyReleaseCount = oc_key_release_count;
extern fn oc_key_release_count(
    state: [*c]input_state,
    key: key_code,
) callconv(.C) u8;
pub const keyRepeatCount = oc_key_repeat_count;
extern fn oc_key_repeat_count(
    state: [*c]input_state,
    key: key_code,
) callconv(.C) u8;
pub const keyDownScancode = oc_key_down_scancode;
extern fn oc_key_down_scancode(
    state: [*c]input_state,
    key: scan_code,
) callconv(.C) bool;
pub const keyPressCountScancode = oc_key_press_count_scancode;
extern fn oc_key_press_count_scancode(
    state: [*c]input_state,
    key: scan_code,
) callconv(.C) u8;
pub const keyReleaseCountScancode = oc_key_release_count_scancode;
extern fn oc_key_release_count_scancode(
    state: [*c]input_state,
    key: scan_code,
) callconv(.C) u8;
pub const keyRepeatCountScancode = oc_key_repeat_count_scancode;
extern fn oc_key_repeat_count_scancode(
    state: [*c]input_state,
    key: scan_code,
) callconv(.C) u8;
pub const mouseDown = oc_mouse_down;
extern fn oc_mouse_down(
    state: [*c]input_state,
    button: mouse_button,
) callconv(.C) bool;
pub const mousePressed = oc_mouse_pressed;
extern fn oc_mouse_pressed(
    state: [*c]input_state,
    button: mouse_button,
) callconv(.C) u8;
pub const mouseReleased = oc_mouse_released;
extern fn oc_mouse_released(
    state: [*c]input_state,
    button: mouse_button,
) callconv(.C) u8;
pub const mouseClicked = oc_mouse_clicked;
extern fn oc_mouse_clicked(
    state: [*c]input_state,
    button: mouse_button,
) callconv(.C) bool;
pub const mouseDoubleClicked = oc_mouse_double_clicked;
extern fn oc_mouse_double_clicked(
    state: [*c]input_state,
    button: mouse_button,
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
    arena: [*c]arena,
    state: [*c]input_state,
) callconv(.C) str32;
pub const inputTextUtf8 = oc_input_text_utf8;
extern fn oc_input_text_utf8(
    arena: [*c]arena,
    state: [*c]input_state,
) callconv(.C) str8;
pub const clipboardPasted = oc_clipboard_pasted;
extern fn oc_clipboard_pasted(
    state: [*c]input_state,
) callconv(.C) bool;
pub const clipboardPastedText = oc_clipboard_pasted_text;
extern fn oc_clipboard_pasted_text(
    state: [*c]input_state,
) callconv(.C) str8;
pub const keyMods = oc_key_mods;
extern fn oc_key_mods(
    state: [*c]input_state,
) callconv(.C) keymod_flags;

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
    color: graphics.canvas.color,
    bgColor: graphics.canvas.color,
    borderColor: graphics.canvas.color,
    font: graphics.canvas.font,
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
    listElt: list_elt,
    children: list,
    parent: [*c]ui_box,
    overlayElt: list_elt,
    overlay: bool,
    bucketElt: list_elt,
    key: ui_key,
    frameCounter: u64,
    keyString: str8,
    text: str8,
    tags: list,
    drawProc: ui_box_draw_proc,
    drawData: ?*anyopaque,
    rules: list,
    targetStyle: [*c]ui_style,
    style: ui_style,
    z: u32,
    floatPos: math.Vec2,
    childrenSum: [2]f32,
    spacing: [2]f32,
    minSize: [2]f32,
    rect: math.Rect,
    styleVariables: list,
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
    defaultFont: graphics.canvas.font,
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
    event: [*c]event,
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
extern fn oc_ui_frame_arena() callconv(.C) [*c]arena;
pub const uiFrameTime = oc_ui_frame_time;
extern fn oc_ui_frame_time() callconv(.C) f64;
pub const uiBoxBeginStr8 = oc_ui_box_begin_str8;
extern fn oc_ui_box_begin_str8(
    string: str8,
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
    text: str8,
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
    text: str8,
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
    string: str8,
) callconv(.C) void;
pub const uiTagStr8 = oc_ui_tag_str8;
extern fn oc_ui_tag_str8(
    string: str8,
) callconv(.C) void;
pub const uiTagNextStr8 = oc_ui_tag_next_str8;
extern fn oc_ui_tag_next_str8(
    string: str8,
) callconv(.C) void;
pub const uiStyleRuleBegin = oc_ui_style_rule_begin;
extern fn oc_ui_style_rule_begin(
    pattern: str8,
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
    color: graphics.canvas.color,
) callconv(.C) void;
pub const uiStyleSetFont = oc_ui_style_set_font;
extern fn oc_ui_style_set_font(
    attr: ui_attribute,
    font: graphics.canvas.font,
) callconv(.C) void;
pub const uiStyleSetSize = oc_ui_style_set_size;
extern fn oc_ui_style_set_size(
    attr: ui_attribute,
    size: ui_size,
) callconv(.C) void;
pub const uiStyleSetVarStr8 = oc_ui_style_set_var_str8;
extern fn oc_ui_style_set_var_str8(
    attr: ui_attribute,
    @"var": str8,
) callconv(.C) void;
pub const uiStyleSetVar = oc_ui_style_set_var;
extern fn oc_ui_style_set_var(
    attr: ui_attribute,
    @"var": [*c]u8,
) callconv(.C) void;
pub const uiVarDefaultI32Str8 = oc_ui_var_default_i32_str8;
extern fn oc_ui_var_default_i32_str8(
    name: str8,
    i: i32,
) callconv(.C) void;
pub const uiVarDefaultF32Str8 = oc_ui_var_default_f32_str8;
extern fn oc_ui_var_default_f32_str8(
    name: str8,
    f: f32,
) callconv(.C) void;
pub const uiVarDefaultSizeStr8 = oc_ui_var_default_size_str8;
extern fn oc_ui_var_default_size_str8(
    name: str8,
    size: ui_size,
) callconv(.C) void;
pub const uiVarDefaultColorStr8 = oc_ui_var_default_color_str8;
extern fn oc_ui_var_default_color_str8(
    name: str8,
    color: graphics.canvas.color,
) callconv(.C) void;
pub const uiVarDefaultFontStr8 = oc_ui_var_default_font_str8;
extern fn oc_ui_var_default_font_str8(
    name: str8,
    font: graphics.canvas.font,
) callconv(.C) void;
pub const uiVarDefaultStr8 = oc_ui_var_default_str8;
extern fn oc_ui_var_default_str8(
    name: str8,
    src: str8,
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
    color: graphics.canvas.color,
) callconv(.C) void;
pub const uiVarDefaultFont = oc_ui_var_default_font;
extern fn oc_ui_var_default_font(
    name: [*c]u8,
    font: graphics.canvas.font,
) callconv(.C) void;
pub const uiVarDefault = oc_ui_var_default;
extern fn oc_ui_var_default(
    name: [*c]u8,
    src: [*c]u8,
) callconv(.C) void;
pub const uiVarSetI32Str8 = oc_ui_var_set_i32_str8;
extern fn oc_ui_var_set_i32_str8(
    name: str8,
    i: i32,
) callconv(.C) void;
pub const uiVarSetF32Str8 = oc_ui_var_set_f32_str8;
extern fn oc_ui_var_set_f32_str8(
    name: str8,
    f: f32,
) callconv(.C) void;
pub const uiVarSetSizeStr8 = oc_ui_var_set_size_str8;
extern fn oc_ui_var_set_size_str8(
    name: str8,
    size: ui_size,
) callconv(.C) void;
pub const uiVarSetColorStr8 = oc_ui_var_set_color_str8;
extern fn oc_ui_var_set_color_str8(
    name: str8,
    color: graphics.canvas.color,
) callconv(.C) void;
pub const uiVarSetFontStr8 = oc_ui_var_set_font_str8;
extern fn oc_ui_var_set_font_str8(
    name: str8,
    font: graphics.canvas.font,
) callconv(.C) void;
pub const uiVarSetStr8 = oc_ui_var_set_str8;
extern fn oc_ui_var_set_str8(
    name: str8,
    src: str8,
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
    color: graphics.canvas.color,
) callconv(.C) void;
pub const uiVarSetFont = oc_ui_var_set_font;
extern fn oc_ui_var_set_font(
    name: [*c]u8,
    font: graphics.canvas.font,
) callconv(.C) void;
pub const uiVarSet = oc_ui_var_set;
extern fn oc_ui_var_set(
    name: [*c]u8,
    src: [*c]u8,
) callconv(.C) void;
pub const uiVarGetI32Str8 = oc_ui_var_get_i32_str8;
extern fn oc_ui_var_get_i32_str8(
    name: str8,
) callconv(.C) i32;
pub const uiVarGetF32Str8 = oc_ui_var_get_f32_str8;
extern fn oc_ui_var_get_f32_str8(
    name: str8,
) callconv(.C) f32;
pub const uiVarGetSizeStr8 = oc_ui_var_get_size_str8;
extern fn oc_ui_var_get_size_str8(
    name: str8,
) callconv(.C) ui_size;
pub const uiVarGetColorStr8 = oc_ui_var_get_color_str8;
extern fn oc_ui_var_get_color_str8(
    name: str8,
) callconv(.C) graphics.canvas.color;
pub const uiVarGetFontStr8 = oc_ui_var_get_font_str8;
extern fn oc_ui_var_get_font_str8(
    name: str8,
) callconv(.C) graphics.canvas.font;
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
) callconv(.C) graphics.canvas.color;
pub const uiVarGetFont = oc_ui_var_get_font;
extern fn oc_ui_var_get_font(
    name: [*c]u8,
) callconv(.C) graphics.canvas.font;
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
    key: str8,
    label: str8,
) callconv(.C) ui_sig;
pub const uiButton = oc_ui_button;
extern fn oc_ui_button(
    key: [*c]u8,
    text: [*c]u8,
) callconv(.C) ui_sig;
pub const uiButtonStr8 = oc_ui_button_str8;
extern fn oc_ui_button_str8(
    key: str8,
    text: str8,
) callconv(.C) ui_sig;
pub const uiCheckbox = oc_ui_checkbox;
extern fn oc_ui_checkbox(
    key: [*c]u8,
    checked: [*c]bool,
) callconv(.C) ui_sig;
pub const uiCheckboxStr8 = oc_ui_checkbox_str8;
extern fn oc_ui_checkbox_str8(
    key: str8,
    checked: [*c]bool,
) callconv(.C) ui_sig;
pub const uiSlider = oc_ui_slider;
extern fn oc_ui_slider(
    name: [*c]u8,
    value: [*c]f32,
) callconv(.C) [*c]ui_box;
pub const uiSliderStr8 = oc_ui_slider_str8;
extern fn oc_ui_slider_str8(
    name: str8,
    value: [*c]f32,
) callconv(.C) [*c]ui_box;
pub const uiTooltip = oc_ui_tooltip;
extern fn oc_ui_tooltip(
    key: [*c]u8,
    text: [*c]u8,
) callconv(.C) void;
pub const uiTooltipStr8 = oc_ui_tooltip_str8;
extern fn oc_ui_tooltip_str8(
    key: str8,
    text: str8,
) callconv(.C) void;
pub const uiMenuBarBegin = oc_ui_menu_bar_begin;
extern fn oc_ui_menu_bar_begin(
    key: [*c]u8,
) callconv(.C) void;
pub const uiMenuBarBeginStr8 = oc_ui_menu_bar_begin_str8;
extern fn oc_ui_menu_bar_begin_str8(
    key: str8,
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
    key: str8,
    name: str8,
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
    key: str8,
    text: str8,
) callconv(.C) ui_sig;
pub const ui_text_box_result = extern struct {
    changed: bool,
    accepted: bool,
    text: str8,
    box: [*c]ui_box,
};
pub const ui_edit_move = enum(u32) {
    UI_EDIT_MOVE_NONE = 0,
    UI_EDIT_MOVE_CHAR = 1,
    UI_EDIT_MOVE_WORD = 2,
    UI_EDIT_MOVE_LINE = 3,
};
pub const ui_text_box_info = extern struct {
    text: str8,
    defaultText: str8,
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
    arena: [*c]arena,
    info: [*c]ui_text_box_info,
) callconv(.C) ui_text_box_result;
pub const uiTextBoxStr8 = oc_ui_text_box_str8;
extern fn oc_ui_text_box_str8(
    key: str8,
    arena: [*c]arena,
    info: [*c]ui_text_box_info,
) callconv(.C) ui_text_box_result;
pub const ui_select_popup_info = extern struct {
    changed: bool,
    selectedIndex: i32,
    optionCount: i32,
    options: [*c]str8,
    placeholder: str8,
};
pub const uiSelectPopup = oc_ui_select_popup;
extern fn oc_ui_select_popup(
    key: [*c]u8,
    info: [*c]ui_select_popup_info,
) callconv(.C) ui_select_popup_info;
pub const uiSelectPopupStr8 = oc_ui_select_popup_str8;
extern fn oc_ui_select_popup_str8(
    key: str8,
    info: [*c]ui_select_popup_info,
) callconv(.C) ui_select_popup_info;
pub const ui_radio_group_info = extern struct {
    changed: bool,
    selectedIndex: i32,
    optionCount: i32,
    options: [*c]str8,
};
pub const uiRadioGroup = oc_ui_radio_group;
extern fn oc_ui_radio_group(
    key: [*c]u8,
    info: [*c]ui_radio_group_info,
) callconv(.C) ui_radio_group_info;
pub const uiRadioGroupStr8 = oc_ui_radio_group_str8;
extern fn oc_ui_radio_group_str8(
    key: str8,
    info: [*c]ui_radio_group_info,
) callconv(.C) ui_radio_group_info;
