//! 2D/3D rendering APIs.

pub const canvas = @import("graphics/canvas.zig"); // [Canvas API]
pub const gles = @import("graphics/gles3.zig");

// @Api missing OpenGL, Metal, Cocoa, WGPU, and Win32 surface/graphics APIs.
// @Cleanup should this (and future APIs) be moved into the graphics subfolder? Should gles surface should be included in `graphics/gles.zig`?
//------------------------------------------------------------------------------------------
// [GLES Surface] A surface for rendering using the GLES API.
//------------------------------------------------------------------------------------------

/// Create a graphics surface for GLES rendering.
pub const glesSurfaceCreate = oc_gles_surface_create;
extern fn oc_gles_surface_create() callconv(.C) canvas.Surface;

/// Make the GL context of the surface current.
pub const glesSurfaceMakeCurrent = oc_gles_surface_make_current;
extern fn oc_gles_surface_make_current(
    surface: canvas.Surface,
) callconv(.C) void;

/// Swap the buffers of a GLES surface.
pub const glesSurfaceSwapBuffers = oc_gles_surface_swap_buffers;
extern fn oc_gles_surface_swap_buffers(
    surface: canvas.Surface,
) callconv(.C) void;
