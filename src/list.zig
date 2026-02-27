//! Types and helpers for doubly-linked lists.

/// A doubly-linked list.
pub const List = extern struct {
    // @Api while there's no extra type info on these pointers,
    // it's pretty obvious they're supposed to be optional.

    /// Points to the first element in the list.
    first: ?*Elem,
    /// Points to the last element in the list.
    last: ?*Elem,

    /// An element of the doubly-linked list. Doesn't contain any payload data.
    /// Intended to be embedded intrusively into another data structure which can be accessed with `@fieldParentPtr()`
    pub const Elem = extern struct {
        /// Points to the previous element in the list.
        prev: ?*Elem,
        /// Points to the next element in the list.
        next: ?*Elem,

        pub const init: Elem = .{ .prev = null, .next = null };

        /// Get the entry for a given list element. This only works if `ParentElem` has one `Elem` field.
        /// For more complex cases use `@fieldParentPtr()` directly.
        pub fn entry(elt: *Elem, comptime ParentElem: type) *ParentElem {
            const info = @typeInfo(ParentElem);
            if (info != .@"struct")
                @compileError("expected " ++ @typeName(ParentElem) ++ " to be of type struct, found " ++ @tagName(info));

            const member = inline for (info.@"struct".fields) |field| {
                if (field.type == Elem) break field.name;
            } else @compileError("expected " ++ @typeName(ParentElem) ++ " to have a field of type " ++ @typeName(Elem));

            return @fieldParentPtr(member, elt);
        }
    };

    pub const empty: List = .{ .first = null, .last = null };

    /// Check if a list is empty.
    pub const isEmpty = @extern(*const fn (
        list: List,
    ) callconv(.c) bool, .{ .name = "oc_list_empty" }).*;

    /// Zero-initializes a linked list.
    pub const init = @extern(*const fn (
        /// A pointer to the list to initialize.
        list: [*c]List,
    ) callconv(.c) void, .{ .name = "oc_list_init" }).*;

    /// Insert an element in a list after a given element.
    pub const insert = @extern(*const fn (
        list: [*c]List,
        afterElt: [*c]Elem,
        /// The element to insert in the list.
        elt: [*c]Elem,
    ) callconv(.c) void, .{ .name = "oc_list_insert" }).*;

    /// Insert an element in a list before a given element.
    pub const insertBefore = @extern(*const fn (
        /// The list to insert in.
        list: [*c]List,
        /// The element before which to insert.
        beforeElt: [*c]Elem,
        /// The element to insert in the list.
        elt: [*c]Elem,
    ) callconv(.c) void, .{ .name = "oc_list_insert_before" }).*;

    /// Remove an element from a list.
    pub const remove = @extern(*const fn (
        /// The list to remove from.
        list: [*c]List,
        /// The element to remove from the list.
        elt: [*c]Elem,
    ) callconv(.c) void, .{ .name = "oc_list_remove" }).*;

    /// Add an element at the end of a list.
    pub const pushBack = @extern(*const fn (
        /// The list to add an element to.
        list: [*c]List,
        /// The element to add to the list.
        elt: [*c]Elem,
    ) callconv(.c) void, .{ .name = "oc_list_push_back" }).*;

    /// Remove the last element from a list.
    pub const popBack = @extern(*const fn (
        /// The list to remove an element from.
        list: [*c]List,
    ) callconv(.c) [*c]Elem, .{ .name = "oc_list_pop_back" }).*;

    /// Add an element at the beginning of a list.
    pub const pushFront = @extern(*const fn (
        /// The list to add an element to.
        list: [*c]List,
        /// The element to add to the list.
        elt: [*c]Elem,
    ) callconv(.c) void, .{ .name = "oc_list_push_front" }).*;

    /// Remove the first element from a list.
    pub const popFront = @extern(*const fn (
        /// The list to remove an element from.
        list: [*c]List,
    ) callconv(.c) [*c]Elem, .{ .name = "oc_list_pop_front" }).*;

    pub const IterateOptions = struct {
        reversed: bool = false,
    };

    /// Loop through a linked list.
    pub fn iterate(list: List, comptime ParentElem: type, options: IterateOptions) Iterator(ParentElem) {
        return .{
            .elem = if (options.reversed) list.last else list.first,
            .reversed = options.reversed,
        };
    }

    pub fn Iterator(comptime ParentElem: type) type {
        return struct {
            elem: ?*Elem,
            reversed: bool,

            // @Incomplete support safely modifying the list while iterating
            pub fn next(it: *@This()) ?*ParentElem {
                const elt = it.elem orelse return null;
                it.elem = if (it.reversed) elt.prev else elt.next;
                return elt.entry(ParentElem);
            }

            pub fn peek(it: *@This()) ?*ParentElem {
                const elt = it.elem orelse return null;
                return elt.entry(ParentElem);
            }
        };
    }

    test Iterator {
        const list: List = .empty;
        var iter = list.iterate(u32);
        while (iter.next()) |entry| {
            _ = entry;
            // ...
        }
    }

    test "manual iteration" {
        const list: List = .empty;
        var iter: ?*Elem = list.first;
        while (iter) |elem| : (iter = elem.next) {
            const entry = elem.entry(u32);
            _ = entry;
            // ...
        }
    }
};
