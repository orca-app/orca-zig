//! A 2D Vector Graphics API.

const oc = @import("../orca.zig");

/// Render canvas commands onto a surface.
pub const render = @extern(*const fn (
    /// The canvas renderer.
    renderer: Renderer,
    /// The canvas context containing the drawing commands to render.
    context: Context,
    /// The destination surface.
    surface: Surface,
) callconv(.c) void, .{ .name = "oc_canvas_render" });

/// Present a canvas surface to the display.
pub const present = @extern(*const fn (
    /// The canvas renderer.
    renderer: Renderer,
    /// The surface to present.
    surface: Surface,
) callconv(.c) void, .{ .name = "oc_canvas_present" });

/// Create a surface for rendering vector graphics.
pub const surfaceCreate = @extern(*const fn (
    /// A canvas renderer.
    renderer: Renderer,
) callconv(.c) Surface, .{ .name = "oc_canvas_surface_create" });

// @Api @Cleanup should this be in graphics.zig?
/// An opaque handle to a graphics surface.
pub const Surface = enum(u64) {
    _,

    /// Returns a `nil` surface handle.
    pub const nil = @extern(
        *const fn () callconv(.c) Surface,
        .{ .name = "oc_surface_nil" },
    );

    /// Check if a surface handle is `nil`.
    pub const isNil = @extern(*const fn (
        surface: Surface,
    ) callconv(.c) bool, .{ .name = "oc_surface_is_nil" }).*;

    /// Destroy a graphics surface.
    pub const destroy = @extern(*const fn (
        surface: Surface,
    ) callconv(.c) void, .{ .name = "oc_surface_destroy" }).*;

    /// Get a surface's size. The size is returned in device-independent "points".
    /// To get the size in pixels, multiply the size in points by the scaling factor
    /// returned by `contentsScaling()`.
    pub const getSize = @extern(*const fn (
        surface: Surface,
    ) callconv(.c) oc.math.Vec2, .{ .name = "oc_surface_get_size" }).*;

    /// Get the scaling factor of a surface.
    pub const contentsScaling = @extern(*const fn (
        surface: Surface,
    ) callconv(.c) oc.math.Vec2, .{ .name = "oc_surface_contents_scaling" }).*;

    /// Bring a surface to the foreground, rendering it on top of other surfaces.
    pub const bringToFront = @extern(*const fn (
        surface: Surface,
    ) callconv(.c) void, .{ .name = "oc_surface_bring_to_front" }).*;

    /// Send a surface to the background, rendering it below other surfaces.
    pub const sendToBack = @extern(*const fn (
        surface: Surface,
    ) callconv(.c) void, .{ .name = "oc_surface_send_to_back" }).*;

    /// Checks if a surface is hidden.
    pub const getHidden = @extern(*const fn (
        surface: Surface,
    ) callconv(.c) bool, .{ .name = "oc_surface_get_hidden" }).*;

    /// Set the hidden status of a surface.
    pub const setHidden = @extern(*const fn (
        surface: Surface,
        hidden: bool,
    ) callconv(.c) void, .{ .name = "oc_surface_set_hidden" }).*;
};

/// An opaque handle representing a rendering engine for the canvas API.
pub const Renderer = enum(u64) {
    _,

    /// Returns a `nil` canvas renderer handle.
    pub const nil = @extern(
        *const fn () callconv(.c) Renderer,
        .{ .name = "oc_canvas_renderer_nil" },
    );

    /// Checks if a canvas renderer handle is `nil`.
    pub const isNil = @extern(*const fn (
        renderer: Renderer,
    ) callconv(.c) bool, .{ .name = "oc_canvas_renderer_is_nil" }).*;

    /// Create a canvas renderer.
    pub const create = @extern(
        *const fn () callconv(.c) Renderer,
        .{ .name = "oc_canvas_renderer_create" },
    );

    /// Destroy a canvas renderer.
    pub const destroy = @extern(*const fn (
        renderer: Renderer,
    ) callconv(.c) void, .{ .name = "oc_canvas_renderer_destroy" }).*;
};

/// An opaque handle to a canvas context. Canvas contexts are used to hold contextual state about drawing commands, such as the current color or the current line width, and to record drawing commands. Once commands have been recorded, they can be rendered to a surface using `oc_canvas_render()`.
pub const Context = enum(u64) {
    _,

    /// Returns a `nil` canvas context handle.
    pub const nil = @extern(
        *const fn () callconv(.c) Context,
        .{ .name = "oc_canvas_context_nil" },
    );

    /// Checks if a canvas context handle is `nil`.
    pub const isNil = @extern(*const fn (
        context: Context,
    ) callconv(.c) bool, .{ .name = "oc_canvas_context_is_nil" }).*;

    /// Create a canvas context.
    pub const create = @extern(
        *const fn () callconv(.c) Context,
        .{ .name = "oc_canvas_context_create" },
    );

    /// Destroy a canvas context
    pub const destroy = @extern(*const fn (
        context: Context,
    ) callconv(.c) void, .{ .name = "oc_canvas_context_destroy" }).*;

    /// Make a canvas context current in the calling thread. Subsequent canvas commands will refer to this context until another context is made current.
    pub const select = @extern(*const fn (
        context: Context,
    ) callconv(.c) Context, .{ .name = "oc_canvas_context_select" }).*;

    /// Set the multisample anti-aliasing sample count for the commands of a context.
    pub const setMsaaSampleCount = @extern(*const fn (
        /// The canvas context.
        context: Context,
        /// The number of samples to use for anti-aliasing when rendering commands from this context.
        sampleCount: u32,
    ) callconv(.c) void, .{ .name = "oc_canvas_context_set_msaa_sample_count" }).*;
};

// @Api font and color types don't belong in the canvas namespace

/// An opaque font handle.
pub const Font = enum(u64) {
    _,

    /// Return a `nil` font handle.
    pub const nil = @extern(
        *const fn () callconv(.c) Font,
        .{ .name = "oc_font_nil" },
    );

    /// Check if a font handle is `nil`.
    pub const isNil = @extern(*const fn (
        font: Font,
    ) callconv(.c) bool, .{ .name = "oc_font_is_nil" }).*;

    /// Create a font from in-memory TrueType data.
    pub const createFromMemory = @extern(*const fn (
        /// A block of memory containing TrueType data (e.g. as loaded from a ttf file).
        mem: oc.strings.Str8,
        /// The number of unicode ranges to load.
        rangeCount: u32,
        /// An array of unicode ranges to load.
        ranges: [*c]oc.utf8.Range,
    ) callconv(.c) Font, .{ .name = "oc_font_create_from_memory" });

    /// Create a font from a TrueType font file.
    pub const createFromFile = @extern(*const fn (
        /// A handle to a TrueType font file.
        file: oc.io.File,
        /// The number of unicode ranges to load.
        rangeCount: u32,
        /// An array of unicode ranges to load.
        ranges: [*c]oc.utf8.Range,
    ) callconv(.c) Font, .{ .name = "oc_font_create_from_file" });

    /// Create a font from a TrueType font file path.
    pub const createFromPath = @extern(*const fn (
        /// The path of a ttf file.
        path: oc.strings.Str8,
        /// The number of unicode ranges to load.
        rangeCount: u32,
        /// An array of unicode ranges to load.
        ranges: [*c]oc.utf8.Range,
    ) callconv(.c) Font, .{ .name = "oc_font_create_from_path" });

    /// Destroy a font.
    pub const destroy = @extern(*const fn (
        font: Font,
    ) callconv(.c) void, .{ .name = "oc_font_destroy" }).*;

    /// Get the glyph indices of a run of unicode code points in a given font.
    pub const getGlyphIndices = @extern(*const fn (
        /// The font handle.
        font: Font,
        /// A slice of unicode code points.
        codePoints: oc.str32,
        /// Backing memory for the result indices.
        backing: oc.str32,
    ) callconv(.c) oc.str32, .{ .name = "oc_font_get_glyph_indices" }).*;

    /// Get the glyph indices of a run of unicode code points in a given font and push them on an arena.
    pub const pushGlyphIndices = @extern(*const fn (
        /// A memory arena on which to allocate the result indices.
        arena: [*c]oc.arena,
        /// The font handle
        font: Font,
        /// A slice of unicode code points.
        codePoints: oc.str32,
    ) callconv(.c) oc.str32, .{ .name = "oc_font_push_glyph_indices" });

    /// Get the glyp index of a single codepoint in a given font.
    pub const getGlyphIndex = @extern(*const fn (
        /// The font handle.
        font: Font,
        /// A unicode codepoint.
        codePoint: oc.utf32,
    ) callconv(.c) u32, .{ .name = "oc_font_get_glyph_index" }).*;

    /// Get a font's metrics for a given font size.
    pub const getMetrics = @extern(*const fn (
        /// The font handle
        font: Font,
        /// The desired size of an `m` character, in points.
        emSize: f32,
    ) callconv(.c) FontMetrics, .{ .name = "oc_font_get_metrics" }).*;

    /// Get a font's unscaled metrics.
    pub const getMetricsUnscaled = @extern(*const fn (
        font: Font,
    ) callconv(.c) FontMetrics, .{ .name = "oc_font_get_metrics_unscaled" }).*;

    /// Get a scale factor to apply to unscaled font metrics to obtain a given 'm' size.
    pub const getScaleForEmPixels = @extern(*const fn (
        /// The font handle.
        font: Font,
        /// The desired size for the 'm' character.
        emSize: f32,
    ) callconv(.c) f32, .{ .name = "oc_font_get_scale_for_em_pixels" }).*;

    /// Get text metrics for a run of unicode code points.
    pub const textMetricsUtf32 = @extern(*const fn (
        /// The font handle.
        font: Font,
        /// The desired font size.
        fontSize: f32,
        /// A slice of unicode code points.
        codepoints: oc.str32,
    ) callconv(.c) TextMetrics, .{ .name = "oc_font_text_metrics_utf32" }).*;

    /// Get the text metrics for a utf8 string.
    pub const textMetrics = @extern(*const fn (
        /// The font handle.
        font: Font,
        /// The desired font size.
        fontSize: f32,
        /// A utf8 encoded string.
        text: oc.strings.Str8,
    ) callconv(.c) TextMetrics, .{ .name = "oc_font_text_metrics" }).*;
};

/// A struct describing the metrics of a font.
pub const FontMetrics = extern struct {
    /// The ascent from the baseline to the top of the line (a positive value means the top line is above the baseline).
    ascent: f32,
    /// The descent from the baseline to the bottom line (a positive value means the bottom line is below the baseline).
    descent: f32,
    /// The gap between two lines of text.
    lineGap: f32,
    /// The height of the lowercase character 'x'.
    xHeight: f32,
    /// The height of capital letters.
    capHeight: f32,
    /// The maximum character width.
    width: f32,
};

/// A struct describing the metrics of a single glyph.
pub const GlyphMetrics = extern struct {
    ink: oc.math.Rect,
    /// The default amount from which to advance the cursor after drawing this glyph.
    advance: oc.math.Vec2,
};

/// A struct describing the metrics of a run of glyphs.
pub const TextMetrics = extern struct {
    /// The bounding box of the inked portion of the text.
    ink: oc.math.Rect,
    /// The logical bounding box of the text (including ascents, descents, and line gaps).
    logical: oc.math.Rect,
    /// The amount from which to advance the cursor after drawing the text.
    advance: oc.math.Vec2,
};

/// An opaque image handle.
pub const Image = enum(u64) {
    _,
    /// Returns a `nil` image handle.
    pub const nil = @extern(
        *const fn () callconv(.c) Image,
        .{ .name = "oc_image_nil" },
    );

    /// Check if an image handle is `nil`.
    pub const isNil = @extern(*const fn (
        a: Image,
    ) callconv(.c) bool, .{ .name = "oc_image_is_nil" }).*;

    /// Create an uninitialized image.
    pub const create = @extern(*const fn (
        /// The canvas renderer.
        renderer: Renderer,
        /// Width of the Image, in pixels.
        width: u32,
        /// Height of the Image, in pixels.
        height: u32,
    ) callconv(.c) Image, .{ .name = "oc_image_create" });

    /// Create an image from an array of 8 bit per channel rgba values.
    pub const createFromRgba8 = @extern(*const fn (
        /// The canvas renderer.
        renderer: Renderer,
        /// Width of the Image, in pixels.
        width: u32,
        /// Height of the Image, in pixels.
        height: u32,
        /// An array of packed rgba color values, with 8 bits per channel.
        pixels: [*c]u8,
    ) callconv(.c) Image, .{ .name = "oc_image_create_from_rgba8" });

    /// Create an image from in-memory png, jpeg or bmp data.
    pub const createFromMemory = @extern(*const fn (
        /// The canvas renderer.
        renderer: Renderer,
        /// A block of memory containing the image data.
        mem: oc.strings.Str8,
        /// If true, flip the y-axis of the image while loading.
        flip: bool,
    ) callconv(.c) Image, .{ .name = "oc_image_create_from_memory" });

    /// Create an image from an image file. Supported formats are: png, jpeg or bmp.
    pub const createFromFile = @extern(*const fn (
        /// The canvas renderer.
        renderer: Renderer,
        /// A handle to the image file.
        file: oc.io.File,
        /// If true, flip the y-axis of the image while loading.
        flip: bool,
    ) callconv(.c) Image, .{ .name = "oc_image_create_from_file" });

    /// Create an image from an image file path. Supported formats are: png, jpeg or bmp.
    pub const createFromPath = @extern(*const fn (
        /// The canvas renderer
        renderer: Renderer,
        /// A path to the image file.
        path: oc.strings.Str8,
        /// If true, flip the y-axis of the image while loading.
        flip: bool,
    ) callconv(.c) Image, .{ .name = "oc_image_create_from_path" });

    /// Destroy an image.
    pub const destroy = @extern(*const fn (
        image: Image,
    ) callconv(.c) void, .{ .name = "oc_image_destroy" }).*;

    /// Upload pixels to an image.
    pub const uploadRegionRgba8 = @extern(*const fn (
        /// The image handle.
        image: Image,
        /// The rectangular region of the image to update.
        region: oc.math.Rect,
        /// A buffer containing the pixel values to upload. Each pixel value is a packed 8-bit per channel RGBA color. The buffer must hold `region.w * region.h` pixel values.
        pixels: [*c]u8,
    ) callconv(.c) void, .{ .name = "oc_image_upload_region_rgba8" }).*;

    /// Get the size of an image.
    pub const size = @extern(*const fn (
        image: Image,
    ) callconv(.c) oc.math.Vec2, .{ .name = "oc_image_size" }).*;
};

/// This enum describes possible blending modes for color gradient.
pub const gradient_blend_space = enum(u32) {
    /// The gradient colors are interpolated in linear space.
    GRADIENT_BLEND_LINEAR = 0,
    /// The gradient colors are interpolated in sRGB space.
    GRADIENT_BLEND_SRGB = 1,
};

/// A struct representing a color.
pub const Color = extern struct {
    /// The red component of the color.
    r: f32 = 0,
    /// The green component of the color.
    g: f32 = 0,
    /// The blue component of the color.
    b: f32 = 0,
    /// The alpha component of the color.
    a: f32 = 1,
    /// The color space of that color.
    color_space: Space = .rgb,

    /// An enum identifying possible color spaces.
    pub const Space = enum(u32) {
        /// A linear RGB color space.
        rgb = 0,
        /// An sRGB color space.
        srgb = 1,
    };

    /// Create a color using RGBA values.
    pub fn rgba(r: f32, g: f32, b: f32, a: f32) Color {
        return .{ .r = r, .g = g, .b = b, .a = a, .color_space = .rgb };
    }
    /// Create a current color using sRGBA values.
    pub fn srgba(r: f32, g: f32, b: f32, a: f32) Color {
        return .{ .r = r, .g = g, .b = b, .a = a, .color_space = .srgb };
    }
    /// Convert a color from one color space to another.
    pub const convert = @extern(*const fn (
        /// The color to convert
        color: Color,
        /// The color space of the new color.
        color_space: Space,
    ) callconv(.c) Color, .{ .name = "oc_color_convert" }).*;
};

/// Stroke joint types.
pub const JointType = enum(u32) {
    /// Miter joint.
    miter = 0,
    /// Bevel joint.
    bevel = 1,
    /// Don't join path segments.
    none = 2,
};

/// Cap types.
pub const CapType = enum(u32) {
    /// Don't draw caps.
    none = 0,
    /// Square caps.
    square = 1,
};

// @Incomplete
/// An opaque struct representing a rectangle atlas. This is used to allocate rectangular regions of an image to make texture atlases.
pub const rect_atlas = opaque {};

/// Create a rectangle atlas.
pub const rectAtlasCreate = @extern(*const fn (
    /// A memory arena on which to allocate the atlas.
    arena: [*c]oc.arena,
    /// The width of the atlas.
    width: i32,
    /// The height of the atlas.
    height: i32,
) callconv(.c) [*c]rect_atlas, .{ .name = "oc_rect_atlas_create" });

/// Allocate a rectangular region from an atlas.
pub const rectAtlasAlloc = @extern(*const fn (
    /// A pointer to the atlas.
    atlas: [*c]rect_atlas,
    /// The width of the rectangle to allocate.
    width: i32,
    /// The height of the rectangle to allocate.
    height: i32,
) callconv(.c) oc.math.Rect, .{ .name = "oc_rect_atlas_alloc" });

/// Recycle a rectangular region that was previously allocated from an atlas.
pub const rectAtlasRecycle = @extern(*const fn (
    /// A pointer to the atlas.
    atlas: [*c]rect_atlas,
    /// The rectangular region to recycle.
    rect: oc.math.Rect,
) callconv(.c) void, .{ .name = "oc_rect_atlas_recycle" });

/// A struct describing a rectangular sub-region of an image.
pub const image_region = extern struct {
    /// The image handle.
    image: Image,
    /// The rectangular region of the image.
    rect: oc.math.Rect,
};

/// Allocate an image region from an atlas and upload pixels to that region.
pub const imageAtlasAllocFromRgba8 = @extern(*const fn (
    /// A pointer to the texture atlas.
    atlas: [*c]rect_atlas,
    /// The backing image from which to allocate a region.
    backingImage: Image,
    /// The width of the region to allocate.
    width: u32,
    /// The height of the region to allocate.
    height: u32,
    /// A buffer containing pixels values to upload to the allocated region. Each pixel value is a packed 8-bit per channel RGBA color. The buffer must hold `region.w * region.h` pixel values.
    pixels: [*c]u8,
) callconv(.c) image_region, .{ .name = "oc_image_atlas_alloc_from_rgba8" });

/// Allocate an image region from an atlas and upload an image to it.
pub const imageAtlasAllocFromMemory = @extern(*const fn (
    /// A pointer to the atlas.
    atlas: [*c]rect_atlas,
    /// The backing image from which to allocate an image region.
    backingImage: Image,
    /// A block of memory containing the image data. Supported format are the same as `oc_image_create_from_memory()`.
    mem: oc.strings.Str8,
    /// If true, flip the y-axis of the image while loading.
    flip: bool,
) callconv(.c) image_region, .{ .name = "oc_image_atlas_alloc_from_memory" });

/// Allocate an image region from an atlas and upload an image to it.
pub const imageAtlasAllocFromFile = @extern(*const fn (
    /// A pointer to the atlas.
    atlas: [*c]rect_atlas,
    /// The backing image from which to allocate an image region.
    backingImage: Image,
    /// The image file.
    file: oc.io.File,
    /// If true, flip the y-axis of the image while loading.
    flip: bool,
) callconv(.c) image_region, .{ .name = "oc_image_atlas_alloc_from_file" });

/// Allocate an image region from an atlas and upload an image to it.
pub const imageAtlasAllocFromPath = @extern(*const fn (
    /// A pointer to the atlas.
    atlas: [*c]rect_atlas,
    /// The backing image from which to allocate an image region.
    backingImage: Image,
    /// The path to the image file.
    path: oc.strings.Str8,
    /// If true, flip the y-axis of the image while loading.
    flip: bool,
) callconv(.c) image_region, .{ .name = "oc_image_atlas_alloc_from_path" });

/// Recycle an image region allocated from an atlas.
pub const imageAtlasRecycle = @extern(*const fn (
    /// A pointer to the atlas.
    atlas: [*c]rect_atlas,
    /// The image region
    imageRgn: image_region,
) callconv(.c) void, .{ .name = "oc_image_atlas_recycle" });

/// Push a matrix on the transform stack.
pub const matrixPush = @extern(*const fn (
    matrix: oc.math.Mat2x3,
) callconv(.c) void, .{ .name = "oc_matrix_push" });

/// Multiply a matrix with the top of the transform stack, and push the result on the top of the stack.
pub const matrixMultiplyPush = @extern(*const fn (
    matrix: oc.math.Mat2x3,
) callconv(.c) void, .{ .name = "oc_matrix_multiply_push" });

/// Pop a matrix from the transform stack.
pub const matrixPop = @extern(
    *const fn () callconv(.c) void,
    .{ .name = "oc_matrix_pop" },
);

/// Get the top matrix of the transform stack.
pub const matrixTop = @extern(
    *const fn () callconv(.c) oc.math.Mat2x3,
    .{ .name = "oc_matrix_top" },
);

/// Push a clip rectangle to the clip stack.
pub const clipPush = @extern(*const fn (
    x: f32,
    y: f32,
    w: f32,
    h: f32,
) callconv(.c) void, .{ .name = "oc_clip_push" });

/// Pop from the clip stack.
pub const clipPop = @extern(
    *const fn () callconv(.c) void,
    .{ .name = "oc_clip_pop" },
);

/// Get the clip rectangle from the top of the clip stack.
pub const clipTop = @extern(
    *const fn () callconv(.c) oc.math.Rect,
    .{ .name = "oc_clip_top" },
);

/// Set the current color.
pub const setColor = @extern(*const fn (
    color: Color,
) callconv(.c) void, .{ .name = "oc_set_color" });

/// Set the current color using linear RGBA values.
pub const setColorRgba = @extern(*const fn (
    r: f32,
    g: f32,
    b: f32,
    a: f32,
) callconv(.c) void, .{ .name = "oc_set_color_rgba" });

/// Set the current color using sRGBA values.
pub const setColorSrgba = @extern(*const fn (
    r: f32,
    g: f32,
    b: f32,
    a: f32,
) callconv(.c) void, .{ .name = "oc_set_color_srgba" });

/// Set the current color gradient.
pub const setGradient = @extern(*const fn (
    /// The color space in the gradient's colors are blended.
    blendSpace: gradient_blend_space,
    /// Color at the bottom left of the fill region.
    bottomLeft: Color,
    /// Color at the bottom right of the fill region.
    bottomRight: Color,
    /// Color at the top right of the fill region.
    topRight: Color,
    /// Color at the top left of the fill region.
    topLeft: Color,
) callconv(.c) void, .{ .name = "oc_set_gradient" });

/// Set the current line width.
pub const setWidth = @extern(*const fn (
    width: f32,
) callconv(.c) void, .{ .name = "oc_set_width" });

/// Set the current tolerance for the line width. Bigger values increase performance but allow more inconsistent stroke widths along a path.
pub const setTolerance = @extern(*const fn (
    /// The width tolerance, in pixels.
    tolerance: f32,
) callconv(.c) void, .{ .name = "oc_set_tolerance" });

/// Set the current joint style.
pub const setJoint = @extern(*const fn (
    joint: JointType,
) callconv(.c) void, .{ .name = "oc_set_joint" });

/// Set the maximum joint excursion. If a joint would extend past this threshold, the renderer falls back to a bevel joint.
pub const setMaxJointExcursion = @extern(*const fn (
    maxJointExcursion: f32,
) callconv(.c) void, .{ .name = "oc_set_max_joint_excursion" });

/// Set the current cap style.
pub const setCap = @extern(*const fn (
    cap: CapType,
) callconv(.c) void, .{ .name = "oc_set_cap" });

/// The the current font.
pub const setFont = @extern(*const fn (
    font: Font,
) callconv(.c) void, .{ .name = "oc_set_font" });

/// Set the current font size.
pub const setFontSize = @extern(*const fn (
    size: f32,
) callconv(.c) void, .{ .name = "oc_set_font_size" });

/// Set the current text flip value. `true` flips the y-axis of text rendering commands.
pub const setTextFlip = @extern(*const fn (
    flip: bool,
) callconv(.c) void, .{ .name = "oc_set_text_flip" });

/// Set the current source image.
pub const setImage = @extern(*const fn (
    image: Image,
) callconv(.c) void, .{ .name = "oc_set_image" });

/// Set the current source image region.
pub const setImageSourceRegion = @extern(*const fn (
    region: oc.math.Rect,
) callconv(.c) void, .{ .name = "oc_set_image_source_region" });

/// Get the current color
pub const getColor = @extern(
    *const fn () callconv(.c) Color,
    .{ .name = "oc_get_color" },
);

/// Get the current line width.
pub const getWidth = @extern(
    *const fn () callconv(.c) f32,
    .{ .name = "oc_get_width" },
);

/// Get the current line width tolerance.
pub const getTolerance = @extern(
    *const fn () callconv(.c) f32,
    .{ .name = "oc_get_tolerance" },
);

/// Get the current joint style.
pub const getJoint = @extern(
    *const fn () callconv(.c) JointType,
    .{ .name = "oc_get_joint" },
);

/// Get the current max joint excursion.
pub const getMaxJointExcursion = @extern(
    *const fn () callconv(.c) f32,
    .{ .name = "oc_get_max_joint_excursion" },
);

/// Get the current cap style.
pub const getCap = @extern(
    *const fn () callconv(.c) CapType,
    .{ .name = "oc_get_cap" },
);

/// Get the current font.
pub const getFont = @extern(
    *const fn () callconv(.c) Font,
    .{ .name = "oc_get_font" },
);

/// Get the current font size.
pub const getFontSize = @extern(
    *const fn () callconv(.c) f32,
    .{ .name = "oc_get_font_size" },
);

/// Get the current text flip value.
pub const getTextFlip = @extern(
    *const fn () callconv(.c) bool,
    .{ .name = "oc_get_text_flip" },
);

/// Get the current source image.
pub const getImage = @extern(
    *const fn () callconv(.c) Image,
    .{ .name = "oc_get_image" },
);

/// Get the current image source region.
pub const getImageSourceRegion = @extern(
    *const fn () callconv(.c) oc.math.Rect,
    .{ .name = "oc_get_image_source_region" },
);

/// Get the current cursor position.
pub const getPosition = @extern(
    *const fn () callconv(.c) oc.math.Vec2,
    .{ .name = "oc_get_position" },
);

/// Move the cursor to a given position.
pub const moveTo = @extern(*const fn (
    x: f32,
    y: f32,
) callconv(.c) void, .{ .name = "oc_move_to" });

/// Add a line to the path from the current position to a new one.
pub const lineTo = @extern(*const fn (
    x: f32,
    y: f32,
) callconv(.c) void, .{ .name = "oc_line_to" });

/// Add a quadratic Bézier curve to the path from the current position to a new one.
pub const quadraticTo = @extern(*const fn (
    x1: f32,
    y1: f32,
    x2: f32,
    y2: f32,
) callconv(.c) void, .{ .name = "oc_quadratic_to" });

/// Add a cubic Bézier curve to the path from the current position to a new one.
pub const cubicTo = @extern(*const fn (
    x1: f32,
    y1: f32,
    x2: f32,
    y2: f32,
    x3: f32,
    y3: f32,
) callconv(.c) void, .{ .name = "oc_cubic_to" });

/// Close the current path with a line.
pub const closePath = @extern(
    *const fn () callconv(.c) void,
    .{ .name = "oc_close_path" },
);

/// Add the outlines of a glyph run to the path, using glyph indices.
pub const glyphOutlines = @extern(*const fn (
    /// A slice of glyph indices.
    glyphIndices: oc.str32,
) callconv(.c) oc.math.Rect, .{ .name = "oc_glyph_outlines" });

/// Add the outlines of a glyph run to the path, using unicode codepoints.
pub const codepointsOutlines = @extern(*const fn (
    /// A slice of unicode code points.
    string: oc.str32,
) callconv(.c) void, .{ .name = "oc_codepoints_outlines" });

/// Add the outlines of a glyph run to the path, using a utf8 string.
pub const textOutlines = @extern(*const fn (
    /// A utf8 string.
    string: oc.strings.Str8,
) callconv(.c) void, .{ .name = "oc_text_outlines" });

/// Clear the canvas to the current color.
pub const clear = @extern(
    *const fn () callconv(.c) void,
    .{ .name = "oc_clear" },
);

/// Fill the current path.
pub const fill = @extern(
    *const fn () callconv(.c) void,
    .{ .name = "oc_fill" },
);

/// Stroke the current path.
pub const stroke = @extern(
    *const fn () callconv(.c) void,
    .{ .name = "oc_stroke" },
);

/// Draw a filled rectangle.
pub const rectangleFill = @extern(*const fn (
    x: f32,
    y: f32,
    w: f32,
    h: f32,
) callconv(.c) void, .{ .name = "oc_rectangle_fill" });

/// Draw a stroked rectangle.
pub const rectangleStroke = @extern(*const fn (
    x: f32,
    y: f32,
    w: f32,
    h: f32,
) callconv(.c) void, .{ .name = "oc_rectangle_stroke" });

/// Draw a filled rounded rectangle.
pub const roundedRectangleFill = @extern(*const fn (
    x: f32,
    y: f32,
    w: f32,
    h: f32,
    r: f32,
) callconv(.c) void, .{ .name = "oc_rounded_rectangle_fill" });

/// Draw a stroked rounded rectangle.
pub const roundedRectangleStroke = @extern(*const fn (
    x: f32,
    y: f32,
    w: f32,
    h: f32,
    r: f32,
) callconv(.c) void, .{ .name = "oc_rounded_rectangle_stroke" });

/// Draw a filled ellipse.
pub const ellipseFill = @extern(*const fn (
    x: f32,
    y: f32,
    rx: f32,
    ry: f32,
) callconv(.c) void, .{ .name = "oc_ellipse_fill" });

/// Draw a stroked ellipse.
pub const ellipseStroke = @extern(*const fn (
    x: f32,
    y: f32,
    rx: f32,
    ry: f32,
) callconv(.c) void, .{ .name = "oc_ellipse_stroke" });

/// Draw a filled circle.
pub const circleFill = @extern(*const fn (
    x: f32,
    y: f32,
    r: f32,
) callconv(.c) void, .{ .name = "oc_circle_fill" });

/// Draw a stroked circle.
pub const circleStroke = @extern(*const fn (
    x: f32,
    y: f32,
    r: f32,
) callconv(.c) void, .{ .name = "oc_circle_stroke" });

/// Add an arc to the path.
pub const arc = @extern(*const fn (
    x: f32,
    y: f32,
    r: f32,
    arcAngle: f32,
    startAngle: f32,
) callconv(.c) void, .{ .name = "oc_arc" });

/// Draw a text line.
pub const textFill = @extern(*const fn (
    x: f32,
    y: f32,
    text: oc.strings.Str8,
) callconv(.c) void, .{ .name = "oc_text_fill" });

/// Draw an image.
pub const imageDraw = @extern(*const fn (
    image: Image,
    rect: oc.math.Rect,
) callconv(.c) void, .{ .name = "oc_image_draw" });

/// Draw a sub-region of an image.
pub const imageDrawRegion = @extern(*const fn (
    image: Image,
    srcRegion: oc.math.Rect,
    dstRegion: oc.math.Rect,
) callconv(.c) void, .{ .name = "oc_image_draw_region" });
