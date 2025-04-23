//! 2D/3D rendering APIs.

pub const canvas = @import("graphics/canvas.zig"); // [Canvas API]

// These bindings are provided to interface with some versions of the GLES API.
// Your app should only target one of these versions.
pub const gles_1_1 = @import("graphics/gles1.1.zig");
pub const gles_2_0 = @import("graphics/gles2.0.zig");
pub const gles_3_0 = @import("graphics/gles3.0.zig");

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
