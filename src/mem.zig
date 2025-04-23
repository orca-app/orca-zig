//! Base allocator and memory arenas.

const oc = @import("orca.zig");
const std = @import("std");
const Allocator = std.mem.Allocator;
const Alignment = std.mem.Alignment;

/// A structure that defines how to allocate memory from the system.
pub const BaseAllocator = extern struct {
    /// A procedure to reserve memory from the system.
    reserve: MemReserveProc,
    /// A procedure to commit memory from the system.
    commit: MemModifyProc,
    /// A procedure to decommit memory from the system.
    decommit: MemModifyProc,
    /// A procedure to release memory previously reserved from the system.
    release: MemModifyProc,

    /// The prototype of a procedure to reserve memory from the system.
    pub const MemReserveProc = *const fn (context: [*c]BaseAllocator, size: u64) callconv(.C) ?*anyopaque;
    /// The prototype of a procedure to modify a memory reservation.
    pub const MemModifyProc = *const fn (context: [*c]BaseAllocator, ptr: ?*anyopaque, size: u64) callconv(.C) void;
};

/// A memory arena, allowing to allocate memory in a linear or stack-like fashion.
pub const Arena = extern struct {
    /// An allocator providing memory pages from the system
    base: [*c]BaseAllocator,
    /// A list of `oc_arena_chunk` chunks.
    chunks: oc.List,
    /// The chunk new memory allocations are pulled from.
    currentChunk: [*c]Chunk,

    /// Options for arena creation.
    pub const ArenaOptions = extern struct {
        /// The base allocator to use with this arena
        base: [*c]BaseAllocator,
        /// The amount of memory to reserve up-front when creating the arena.
        reserve: u64,
    };

    /// A contiguous chunk of memory managed by a memory arena.
    pub const Chunk = extern struct {
        listElt: oc.List.Elem,
        ptr: [*c]u8,
        offset: u64,
        committed: u64,
        cap: u64,
    };

    /// This struct provides a way to store the current offset in a given arena, in order to reset the arena to that offset later. This allows using arenas in a stack-like fashion, e.g. to create temporary "scratch" allocations
    pub const Scope = extern struct {
        /// The arena which offset is stored.
        arena: *Arena,
        /// The arena chunk to which the offset belongs.
        chunk: [*c]Chunk,
        /// The offset to rewind the arena to.
        offset: u64,

        /// End a memory scope. This resets an arena to the offset it had when the scope was created. All memory allocated within the scope is released back to the arena.
        pub const end = oc_arena_scope_end;
        extern fn oc_arena_scope_end(
            /// An `oc_arena_scope` object that was created by a call to `oc_arena_scope_begin()`.
            scope: Scope,
        ) callconv(.C) void;
    };

    pub const Error = error{OutOfMemory};

    /// Initialize a memory arena.
    pub fn init() Arena {
        var arena: Arena = undefined;
        oc_arena_init(&arena);
        return arena;
    }
    extern fn oc_arena_init(arena: *Arena) callconv(.C) void;

    /// Initialize a memory arena with additional options.
    pub const initWithOptions = oc_arena_init_with_options;
    extern fn oc_arena_init_with_options(
        /// The arena to initialize.
        arena: *Arena,
        /// The options to use to initialize the arena.
        options: *ArenaOptions,
    ) callconv(.C) void;

    /// Release all resources allocated to a memory arena.
    pub const cleanup = oc_arena_cleanup;
    extern fn oc_arena_cleanup(arena: *Arena) callconv(.C) void;

    /// Allocate a block of memory from an arena.
    pub fn push(
        /// An arena to allocate memory from.
        arena: *Arena,
        /// The size of the memory to allocate, in bytes.
        size: usize,
    ) Error![]u8 {
        const ptr = oc_arena_push(arena, @intCast(size)) orelse return Error.OutOfMemory;
        return @as([*]u8, @ptrCast(@alignCast(ptr)))[0..size];
    }

    /// Allocate an aligned block of memory from an arena.
    pub fn pushAligned(
        /// An arena to allocate memory from.
        arena: *Arena,
        /// The size of the memory to allocate, in bytes.
        size: usize,
        /// The desired alignment of the memory block, in bytes
        alignment: u32,
    ) Error![]u8 {
        const ptr = oc_arena_push_aligned(arena, @intCast(size), alignment) orelse return Error.OutOfMemory;
        return @as([*]u8, @ptrCast(@alignCast(ptr)))[0..size];
    }

    extern fn oc_arena_push(arena: *Arena, size: u64) callconv(.C) ?*anyopaque;
    extern fn oc_arena_push_aligned(arena: *Arena, size: u64, alignment: u32) callconv(.C) ?*anyopaque;

    /// Allocate a type from an arena. This macro takes care of the memory alignment and type cast.
    pub fn pushType(arena: *Arena, comptime T: type) Error!*T {
        const ptr = try arena.pushAligned(@sizeOf(T), @alignOf(T));
        return std.mem.bytesAsValue(T, ptr);
    }

    /// Allocate an array from an arena. This macro takes care of the size calculation, memory alignment and type cast.
    pub fn pushArray(arena: *Arena, comptime T: type, count: usize) Error![]T {
        const ptr = try arena.pushAligned(@sizeOf(T) * count, @alignOf(T));
        return std.mem.bytesAsSlice(T, ptr);
    }

    /// Copies `m` to newly allocated memory.
    pub fn pushCopy(arena: *Arena, comptime T: type, m: []const T) Error![]T {
        const result = try arena.pushArray(T, m.len);
        @memcpy(result, m);
        return result;
    }

    /// Reset an arena. All memory that was previously allocated from this arena is released to the arena, and can be reallocated by later calls to `oc_arena_push` and similar functions. No memory is actually released _to the system_.
    pub const clear = oc_arena_clear;
    extern fn oc_arena_clear(arena: *Arena) callconv(.C) void;

    /// Begin a memory scope. This creates an `oc_arena_scope` object that stores the current offset of the arena. The arena can later be reset to that offset by calling `oc_arena_scope_end`, releasing all memory that was allocated within the scope to the arena.
    pub const scopeBegin = oc_arena_scope_begin;
    extern fn oc_arena_scope_begin(
        /// The arena for which the scope is created.
        arena: *Arena,
    ) callconv(.C) Scope;

    pub fn allocator(arena: *Arena) Allocator {
        return .{
            .ptr = arena,
            .vtable = &.{
                .alloc = &alloc,
                .resize = &Allocator.noResize, // Arenas cannot resize allocations in place.
                .remap = &Allocator.noRemap, // Cannot remap without copying. See Allocator.remap.
                .free = &Allocator.noFree, // Arenas cannot free individual allocations. See clear() and cleanup().
            },
        };
    }
    fn alloc(ctx: *anyopaque, len: usize, alignment: Alignment, ret_addr: usize) ?[*]u8 {
        _ = ret_addr;
        const arena: *Arena = @ptrCast(@alignCast(ctx));
        const ptr = arena.pushAligned(@intCast(len), @intCast(alignment.toByteUnits())) catch return null;
        return @ptrCast(ptr);
    }
};

/// Begin a scratch scope. This creates a memory scope on a per-thread, global "scratch" arena. This allows easily creating temporary memory for scratch computations or intermediate results, in a stack-like fashion.
///
/// If you must return results in an arena passed by the caller, and you also use a scratch arena to do intermediate computations, beware that the results arena could itself be a scatch arena. In this case, you have to be careful not to intermingle your scratch computations with the final result, or clear your result entirely. You can either:
///
/// - Allocate memory for the result upfront and call `oc_scratch_begin` afterwards, if possible.
/// - Use `oc_scratch_begin_next()` and pass it the result arena, to get a scratch arena that does not conflict with it.
pub const scratchBegin = oc_scratch_begin;
extern fn oc_scratch_begin() callconv(.C) Arena.Scope;
/// Begin a scratch scope that does not conflict with a given arena. See `oc_scratch_begin()` for more details about when to use this function.
pub const scratchBeginNext = oc_scratch_begin_next;
extern fn oc_scratch_begin_next(
    /// A pointer to a memory arena that the scratch scope shouldn't interfere with.
    used: *Arena,
) callconv(.C) Arena.Scope;
