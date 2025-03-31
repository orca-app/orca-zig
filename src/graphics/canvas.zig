//! A 2D Vector Graphics API.

/// Render canvas commands onto a surface.
pub const render = oc_canvas_render;
extern fn oc_canvas_render(
    /// The canvas renderer.
    renderer: Renderer,
    /// The canvas context containing the drawing commands to render.
    context: Context,
    /// The destination surface.
    surface: Surface,
) callconv(.C) void;
/// Present a canvas surface to the display.
pub const present = oc_canvas_present;
extern fn oc_canvas_present(
    /// The canvas renderer.
    renderer: Renderer,
    /// The surface to present.
    surface: Surface,
) callconv(.C) void;
/// Create a surface for rendering vector graphics.
pub const surfaceCreate = oc_canvas_surface_create;
extern fn oc_canvas_surface_create(
    /// A canvas renderer.
    renderer: Renderer,
) callconv(.C) Surface;

// @Api @Cleanup should this be in graphics.zig?
/// An opaque handle to a graphics surface.
pub const Surface = enum(u64) {
    _,

    /// Returns a `nil` surface handle.
    pub const nil = oc_surface_nil;
    extern fn oc_surface_nil() callconv(.C) Surface;
    /// Check if a surface handle is `nil`.
    pub const isNil = oc_surface_is_nil;
    extern fn oc_surface_is_nil(surface: Surface) callconv(.C) bool;
    /// Destroy a graphics surface.
    pub const destroy = oc_surface_destroy;
    extern fn oc_surface_destroy(surface: Surface) callconv(.C) void;
    /// Get a surface's size. The size is returned in device-independent "points".
    /// To get the size in pixels, multiply the size in points by the scaling factor
    /// returned by `contentsScaling()`.
    pub const getSize = oc_surface_get_size;
    extern fn oc_surface_get_size(surface: Surface) callconv(.C) oc.math.Vec2;
    /// Get the scaling factor of a surface.
    pub const contentsScaling = oc_surface_contents_scaling;
    extern fn oc_surface_contents_scaling(surface: Surface) callconv(.C) oc.math.Vec2;
    /// Bring a surface to the foreground, rendering it on top of other surfaces.
    pub const bringToFront = oc_surface_bring_to_front;
    extern fn oc_surface_bring_to_front(surface: Surface) callconv(.C) void;
    /// Send a surface to the background, rendering it below other surfaces.
    pub const sendToBack = oc_surface_send_to_back;
    extern fn oc_surface_send_to_back(surface: Surface) callconv(.C) void;
    /// Checks if a surface is hidden.
    pub const getHidden = oc_surface_get_hidden;
    extern fn oc_surface_get_hidden(surface: Surface) callconv(.C) bool;
    /// Set the hidden status of a surface.
    pub const setHidden = oc_surface_set_hidden;
    extern fn oc_surface_set_hidden(surface: Surface, hidden: bool) callconv(.C) void;
};

/// An opaque handle representing a rendering engine for the canvas API.
pub const Renderer = enum(u64) {
    _,

    /// Returns a `nil` canvas renderer handle.
    pub const nil = oc_canvas_renderer_nil;
    extern fn oc_canvas_renderer_nil() callconv(.C) Renderer;
    /// Checks if a canvas renderer handle is `nil`.
    pub const isNil = oc_canvas_renderer_is_nil;
    extern fn oc_canvas_renderer_is_nil(renderer: Renderer) callconv(.C) bool;
    /// Create a canvas renderer.
    pub const create = oc_canvas_renderer_create;
    extern fn oc_canvas_renderer_create() callconv(.C) Renderer;
    /// Destroy a canvas renderer.
    pub const destroy = oc_canvas_renderer_destroy;
    extern fn oc_canvas_renderer_destroy(renderer: Renderer) callconv(.C) void;
};
/// An opaque handle to a canvas context. Canvas contexts are used to hold contextual state about drawing commands, such as the current color or the current line width, and to record drawing commands. Once commands have been recorded, they can be rendered to a surface using `oc_canvas_render()`.
pub const Context = enum(u64) {
    _,

    /// Returns a `nil` canvas context handle.
    pub const nil = oc_canvas_context_nil;
    extern fn oc_canvas_context_nil() callconv(.C) Context;
    /// Checks if a canvas context handle is `nil`.
    pub const isNil = oc_canvas_context_is_nil;
    extern fn oc_canvas_context_is_nil(context: Context) callconv(.C) bool;
    /// Create a canvas context.
    pub const create = oc_canvas_context_create;
    extern fn oc_canvas_context_create() callconv(.C) Context;
    /// Destroy a canvas context
    pub const destroy = oc_canvas_context_destroy;
    extern fn oc_canvas_context_destroy(context: Context) callconv(.C) void;
    /// Make a canvas context current in the calling thread. Subsequent canvas commands will refer to this context until another context is made current.
    pub const select = oc_canvas_context_select;
    extern fn oc_canvas_context_select(context: Context) callconv(.C) Context;
    /// Set the multisample anti-aliasing sample count for the commands of a context.
    pub const setMsaaSampleCount = oc_canvas_context_set_msaa_sample_count;
    extern fn oc_canvas_context_set_msaa_sample_count(
        /// The canvas context.
        context: Context,
        /// The number of samples to use for anti-aliasing when rendering commands from this context.
        sampleCount: u32,
    ) callconv(.C) void;
};

// @Api font and color types don't belong in the canvas namespace

/// An opaque font handle.
pub const Font = enum(u64) {
    _,

    /// Return a `nil` font handle.
    pub const nil = oc_font_nil;
    extern fn oc_font_nil() callconv(.C) Font;
    /// Check if a font handle is `nil`.
    pub const isNil = oc_font_is_nil;
    extern fn oc_font_is_nil(font: Font) callconv(.C) bool;
    /// Create a font from in-memory TrueType data.
    pub const createFromMemory = oc_font_create_from_memory;
    extern fn oc_font_create_from_memory(
        /// A block of memory containing TrueType data (e.g. as loaded from a ttf file).
        mem: oc.strings.Str8,
        /// The number of unicode ranges to load.
        rangeCount: u32,
        /// An array of unicode ranges to load.
        ranges: [*c]oc.unicode_range,
    ) callconv(.C) Font;
    /// Create a font from a TrueType font file.
    pub const createFromFile = oc_font_create_from_file;
    extern fn oc_font_create_from_file(
        /// A handle to a TrueType font file.
        file: oc.file,
        /// The number of unicode ranges to load.
        rangeCount: u32,
        /// An array of unicode ranges to load.
        ranges: [*c]oc.unicode_range,
    ) callconv(.C) Font;
    /// Create a font from a TrueType font file path.
    pub const createFromPath = oc_font_create_from_path;
    extern fn oc_font_create_from_path(
        /// The path of a ttf file.
        path: oc.strings.Str8,
        /// The number of unicode ranges to load.
        rangeCount: u32,
        /// An array of unicode ranges to load.
        ranges: [*c]oc.unicode_range,
    ) callconv(.C) Font;
    /// Destroy a font.
    pub const destroy = oc_font_destroy;
    extern fn oc_font_destroy(
        font: Font,
    ) callconv(.C) void;
    /// Get the glyph indices of a run of unicode code points in a given font.
    pub const getGlyphIndices = oc_font_get_glyph_indices;
    extern fn oc_font_get_glyph_indices(
        /// The font handle.
        font: Font,
        /// A slice of unicode code points.
        codePoints: oc.str32,
        /// Backing memory for the result indices.
        backing: oc.str32,
    ) callconv(.C) oc.str32;
    /// Get the glyph indices of a run of unicode code points in a given font and push them on an arena.
    pub const pushGlyphIndices = oc_font_push_glyph_indices;
    extern fn oc_font_push_glyph_indices(
        /// A memory arena on which to allocate the result indices.
        arena: [*c]oc.arena,
        /// The font handle
        font: Font,
        /// A slice of unicode code points.
        codePoints: oc.str32,
    ) callconv(.C) oc.str32;
    /// Get the glyp index of a single codepoint in a given font.
    pub const getGlyphIndex = oc_font_get_glyph_index;
    extern fn oc_font_get_glyph_index(
        /// The font handle.
        font: Font,
        /// A unicode codepoint.
        codePoint: oc.utf32,
    ) callconv(.C) u32;
    /// Get a font's metrics for a given font size.
    pub const getMetrics = oc_font_get_metrics;
    extern fn oc_font_get_metrics(
        /// The font handle
        font: Font,
        /// The desired size of an `m` character, in points.
        emSize: f32,
    ) callconv(.C) FontMetrics;
    /// Get a font's unscaled metrics.
    pub const getMetricsUnscaled = oc_font_get_metrics_unscaled;
    extern fn oc_font_get_metrics_unscaled(
        font: Font,
    ) callconv(.C) FontMetrics;
    /// Get a scale factor to apply to unscaled font metrics to obtain a given 'm' size.
    pub const getScaleForEmPixels = oc_font_get_scale_for_em_pixels;
    extern fn oc_font_get_scale_for_em_pixels(
        /// The font handle.
        font: Font,
        /// The desired size for the 'm' character.
        emSize: f32,
    ) callconv(.C) f32;
    /// Get text metrics for a run of unicode code points.
    pub const textMetricsUtf32 = oc_font_text_metrics_utf32;
    extern fn oc_font_text_metrics_utf32(
        /// The font handle.
        font: Font,
        /// The desired font size.
        fontSize: f32,
        /// A slice of unicode code points.
        codepoints: oc.str32,
    ) callconv(.C) TextMetrics;
    /// Get the text metrics for a utf8 string.
    pub const textMetrics = oc_font_text_metrics;
    extern fn oc_font_text_metrics(
        /// The font handle.
        font: Font,
        /// The desired font size.
        fontSize: f32,
        /// A utf8 encoded string.
        text: oc.strings.Str8,
    ) callconv(.C) TextMetrics;
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
    pub const nil = oc_image_nil;
    extern fn oc_image_nil() callconv(.C) Image;
    /// Check if an image handle is `nil`.
    pub const isNil = oc_image_is_nil;
    extern fn oc_image_is_nil(a: Image) callconv(.C) bool;
    /// Create an uninitialized image.
    pub const create = oc_image_create;
    extern fn oc_image_create(
        /// The canvas renderer.
        renderer: Renderer,
        /// Width of the Image, in pixels.
        width: u32,
        /// Height of the Image, in pixels.
        height: u32,
    ) callconv(.C) Image;
    /// Create an image from an array of 8 bit per channel rgba values.
    pub const createFromRgba8 = oc_image_create_from_rgba8;
    extern fn oc_image_create_from_rgba8(
        /// The canvas renderer.
        renderer: Renderer,
        /// Width of the Image, in pixels.
        width: u32,
        /// Height of the Image, in pixels.
        height: u32,
        /// An array of packed rgba color values, with 8 bits per channel.
        pixels: [*c]u8,
    ) callconv(.C) Image;
    /// Create an image from in-memory png, jpeg or bmp data.
    pub const createFromMemory = oc_image_create_from_memory;
    extern fn oc_image_create_from_memory(
        /// The canvas renderer.
        renderer: Renderer,
        /// A block of memory containing the image data.
        mem: oc.strings.Str8,
        /// If true, flip the y-axis of the image while loading.
        flip: bool,
    ) callconv(.C) Image;
    /// Create an image from an image file. Supported formats are: png, jpeg or bmp.
    pub const createFromFile = oc_image_create_from_file;
    extern fn oc_image_create_from_file(
        /// The canvas renderer.
        renderer: Renderer,
        /// A handle to the image file.
        file: oc.file,
        /// If true, flip the y-axis of the image while loading.
        flip: bool,
    ) callconv(.C) Image;
    /// Create an image from an image file path. Supported formats are: png, jpeg or bmp.
    pub const createFromPath = oc_image_create_from_path;
    extern fn oc_image_create_from_path(
        /// The canvas renderer
        renderer: Renderer,
        /// A path to the image file.
        path: oc.strings.Str8,
        /// If true, flip the y-axis of the image while loading.
        flip: bool,
    ) callconv(.C) Image;
    /// Destroy an image.
    pub const destroy = oc_image_destroy;
    extern fn oc_image_destroy(image: Image) callconv(.C) void;
    /// Upload pixels to an image.
    pub const uploadRegionRgba8 = oc_image_upload_region_rgba8;
    extern fn oc_image_upload_region_rgba8(
        /// The image handle.
        image: Image,
        /// The rectangular region of the image to update.
        region: oc.math.Rect,
        /// A buffer containing the pixel values to upload. Each pixel value is a packed 8-bit per channel RGBA color. The buffer must hold `region.w * region.h` pixel values.
        pixels: [*c]u8,
    ) callconv(.C) void;
    /// Get the size of an image.
    pub const size = oc_image_size;
    extern fn oc_image_size(image: Image) callconv(.C) oc.math.Vec2;
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
    pub const rgba = oc_color_rgba;
    extern fn oc_color_rgba(r: f32, g: f32, b: f32, a: f32) callconv(.C) Color;
    /// Create a current color using sRGBA values.
    pub const srgba = oc_color_srgba;
    extern fn oc_color_srgba(r: f32, g: f32, b: f32, a: f32) callconv(.C) Color;
    /// Convert a color from one color space to another.
    pub const convert = oc_color_convert;
    extern fn oc_color_convert(
        /// The color to convert
        color: Color,
        /// The color space of the new color.
        color_space: Space,
    ) callconv(.C) Color;
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

/// An opaque struct representing a rectangle atlas. This is used to allocate rectangular regions of an image to make texture atlases.
pub const rect_atlas = opaque {};
/// Create a rectangle atlas.
pub const rectAtlasCreate = oc_rect_atlas_create;
extern fn oc_rect_atlas_create(
    /// A memory arena on which to allocate the atlas.
    arena: [*c]oc.arena,
    /// The width of the atlas.
    width: i32,
    /// The height of the atlas.
    height: i32,
) callconv(.C) [*c]rect_atlas;
/// Allocate a rectangular region from an atlas.
pub const rectAtlasAlloc = oc_rect_atlas_alloc;
extern fn oc_rect_atlas_alloc(
    /// A pointer to the atlas.
    atlas: [*c]rect_atlas,
    /// The width of the rectangle to allocate.
    width: i32,
    /// The height of the rectangle to allocate.
    height: i32,
) callconv(.C) oc.math.Rect;
/// Recycle a rectangular region that was previously allocated from an atlas.
pub const rectAtlasRecycle = oc_rect_atlas_recycle;
extern fn oc_rect_atlas_recycle(
    /// A pointer to the atlas.
    atlas: [*c]rect_atlas,
    /// The rectangular region to recycle.
    rect: oc.math.Rect,
) callconv(.C) void;
/// A struct describing a rectangular sub-region of an image.
pub const image_region = extern struct {
    /// The image handle.
    image: Image,
    /// The rectangular region of the image.
    rect: oc.math.Rect,
};
/// Allocate an image region from an atlas and upload pixels to that region.
pub const imageAtlasAllocFromRgba8 = oc_image_atlas_alloc_from_rgba8;
extern fn oc_image_atlas_alloc_from_rgba8(
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
) callconv(.C) image_region;
/// Allocate an image region from an atlas and upload an image to it.
pub const imageAtlasAllocFromMemory = oc_image_atlas_alloc_from_memory;
extern fn oc_image_atlas_alloc_from_memory(
    /// A pointer to the atlas.
    atlas: [*c]rect_atlas,
    /// The backing image from which to allocate an image region.
    backingImage: Image,
    /// A block of memory containing the image data. Supported format are the same as `oc_image_create_from_memory()`.
    mem: oc.strings.Str8,
    /// If true, flip the y-axis of the image while loading.
    flip: bool,
) callconv(.C) image_region;
/// Allocate an image region from an atlas and upload an image to it.
pub const imageAtlasAllocFromFile = oc_image_atlas_alloc_from_file;
extern fn oc_image_atlas_alloc_from_file(
    /// A pointer to the atlas.
    atlas: [*c]rect_atlas,
    /// The backing image from which to allocate an image region.
    backingImage: Image,
    /// The image file.
    file: oc.file,
    /// If true, flip the y-axis of the image while loading.
    flip: bool,
) callconv(.C) image_region;
/// Allocate an image region from an atlas and upload an image to it.
pub const imageAtlasAllocFromPath = oc_image_atlas_alloc_from_path;
extern fn oc_image_atlas_alloc_from_path(
    /// A pointer to the atlas.
    atlas: [*c]rect_atlas,
    /// The backing image from which to allocate an image region.
    backingImage: Image,
    /// The path to the image file.
    path: oc.strings.Str8,
    /// If true, flip the y-axis of the image while loading.
    flip: bool,
) callconv(.C) image_region;
/// Recycle an image region allocated from an atlas.
pub const imageAtlasRecycle = oc_image_atlas_recycle;
extern fn oc_image_atlas_recycle(
    /// A pointer to the atlas.
    atlas: [*c]rect_atlas,
    /// The image region
    imageRgn: image_region,
) callconv(.C) void;
/// Push a matrix on the transform stack.
pub const matrixPush = oc_matrix_push;
extern fn oc_matrix_push(
    matrix: oc.math.Mat2x3,
) callconv(.C) void;
/// Multiply a matrix with the top of the transform stack, and push the result on the top of the stack.
pub const matrixMultiplyPush = oc_matrix_multiply_push;
extern fn oc_matrix_multiply_push(
    matrix: oc.math.Mat2x3,
) callconv(.C) void;
/// Pop a matrix from the transform stack.
pub const matrixPop = oc_matrix_pop;
extern fn oc_matrix_pop() callconv(.C) void;
/// Get the top matrix of the transform stack.
pub const matrixTop = oc_matrix_top;
extern fn oc_matrix_top() callconv(.C) oc.math.Mat2x3;
/// Push a clip rectangle to the clip stack.
pub const clipPush = oc_clip_push;
extern fn oc_clip_push(
    x: f32,
    y: f32,
    w: f32,
    h: f32,
) callconv(.C) void;
/// Pop from the clip stack.
pub const clipPop = oc_clip_pop;
extern fn oc_clip_pop() callconv(.C) void;
/// Get the clip rectangle from the top of the clip stack.
pub const clipTop = oc_clip_top;
extern fn oc_clip_top() callconv(.C) oc.math.Rect;
/// Set the current color.
pub const setColor = oc_set_color;
extern fn oc_set_color(
    color: Color,
) callconv(.C) void;
/// Set the current color using linear RGBA values.
pub const setColorRgba = oc_set_color_rgba;
extern fn oc_set_color_rgba(
    r: f32,
    g: f32,
    b: f32,
    a: f32,
) callconv(.C) void;
/// Set the current color using sRGBA values.
pub const setColorSrgba = oc_set_color_srgba;
extern fn oc_set_color_srgba(
    r: f32,
    g: f32,
    b: f32,
    a: f32,
) callconv(.C) void;
/// Set the current color gradient.
pub const setGradient = oc_set_gradient;
extern fn oc_set_gradient(
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
) callconv(.C) void;
/// Set the current line width.
pub const setWidth = oc_set_width;
extern fn oc_set_width(
    width: f32,
) callconv(.C) void;
/// Set the current tolerance for the line width. Bigger values increase performance but allow more inconsistent stroke widths along a path.
pub const setTolerance = oc_set_tolerance;
extern fn oc_set_tolerance(
    /// The width tolerance, in pixels.
    tolerance: f32,
) callconv(.C) void;
/// Set the current joint style.
pub const setJoint = oc_set_joint;
extern fn oc_set_joint(
    joint: JointType,
) callconv(.C) void;
/// Set the maximum joint excursion. If a joint would extend past this threshold, the renderer falls back to a bevel joint.
pub const setMaxJointExcursion = oc_set_max_joint_excursion;
extern fn oc_set_max_joint_excursion(
    maxJointExcursion: f32,
) callconv(.C) void;
/// Set the current cap style.
pub const setCap = oc_set_cap;
extern fn oc_set_cap(
    cap: CapType,
) callconv(.C) void;
/// The the current font.
pub const setFont = oc_set_font;
extern fn oc_set_font(
    font: Font,
) callconv(.C) void;
/// Set the current font size.
pub const setFontSize = oc_set_font_size;
extern fn oc_set_font_size(
    size: f32,
) callconv(.C) void;
/// Set the current text flip value. `true` flips the y-axis of text rendering commands.
pub const setTextFlip = oc_set_text_flip;
extern fn oc_set_text_flip(
    flip: bool,
) callconv(.C) void;
/// Set the current source image.
pub const setImage = oc_set_image;
extern fn oc_set_image(
    image: Image,
) callconv(.C) void;
/// Set the current source image region.
pub const setImageSourceRegion = oc_set_image_source_region;
extern fn oc_set_image_source_region(
    region: oc.math.Rect,
) callconv(.C) void;
/// Get the current color
pub const getColor = oc_get_color;
extern fn oc_get_color() callconv(.C) Color;
/// Get the current line width.
pub const getWidth = oc_get_width;
extern fn oc_get_width() callconv(.C) f32;
/// Get the current line width tolerance.
pub const getTolerance = oc_get_tolerance;
extern fn oc_get_tolerance() callconv(.C) f32;
/// Get the current joint style.
pub const getJoint = oc_get_joint;
extern fn oc_get_joint() callconv(.C) JointType;
/// Get the current max joint excursion.
pub const getMaxJointExcursion = oc_get_max_joint_excursion;
extern fn oc_get_max_joint_excursion() callconv(.C) f32;
/// Get the current cap style.
pub const getCap = oc_get_cap;
extern fn oc_get_cap() callconv(.C) CapType;
/// Get the current font.
pub const getFont = oc_get_font;
extern fn oc_get_font() callconv(.C) Font;
/// Get the current font size.
pub const getFontSize = oc_get_font_size;
extern fn oc_get_font_size() callconv(.C) f32;
/// Get the current text flip value.
pub const getTextFlip = oc_get_text_flip;
extern fn oc_get_text_flip() callconv(.C) bool;
/// Get the current source image.
pub const getImage = oc_get_image;
extern fn oc_get_image() callconv(.C) Image;
/// Get the current image source region.
pub const getImageSourceRegion = oc_get_image_source_region;
extern fn oc_get_image_source_region() callconv(.C) oc.math.Rect;
/// Get the current cursor position.
pub const getPosition = oc_get_position;
extern fn oc_get_position() callconv(.C) oc.math.Vec2;
/// Move the cursor to a given position.
pub const moveTo = oc_move_to;
extern fn oc_move_to(
    x: f32,
    y: f32,
) callconv(.C) void;
/// Add a line to the path from the current position to a new one.
pub const lineTo = oc_line_to;
extern fn oc_line_to(
    x: f32,
    y: f32,
) callconv(.C) void;
/// Add a quadratic Bézier curve to the path from the current position to a new one.
pub const quadraticTo = oc_quadratic_to;
extern fn oc_quadratic_to(
    x1: f32,
    y1: f32,
    x2: f32,
    y2: f32,
) callconv(.C) void;
/// Add a cubic Bézier curve to the path from the current position to a new one.
pub const cubicTo = oc_cubic_to;
extern fn oc_cubic_to(
    x1: f32,
    y1: f32,
    x2: f32,
    y2: f32,
    x3: f32,
    y3: f32,
) callconv(.C) void;
/// Close the current path with a line.
pub const closePath = oc_close_path;
extern fn oc_close_path() callconv(.C) void;
/// Add the outlines of a glyph run to the path, using glyph indices.
pub const glyphOutlines = oc_glyph_outlines;
extern fn oc_glyph_outlines(
    /// A slice of glyph indices.
    glyphIndices: oc.str32,
) callconv(.C) oc.math.Rect;
/// Add the outlines of a glyph run to the path, using unicode codepoints.
pub const codepointsOutlines = oc_codepoints_outlines;
extern fn oc_codepoints_outlines(
    /// A slice of unicode code points.
    string: oc.str32,
) callconv(.C) void;
/// Add the outlines of a glyph run to the path, using a utf8 string.
pub const textOutlines = oc_text_outlines;
extern fn oc_text_outlines(
    /// A utf8 string.
    string: oc.strings.Str8,
) callconv(.C) void;
/// Clear the canvas to the current color.
pub const clear = oc_clear;
extern fn oc_clear() callconv(.C) void;
/// Fill the current path.
pub const fill = oc_fill;
extern fn oc_fill() callconv(.C) void;
/// Stroke the current path.
pub const stroke = oc_stroke;
extern fn oc_stroke() callconv(.C) void;
/// Draw a filled rectangle.
pub const rectangleFill = oc_rectangle_fill;
extern fn oc_rectangle_fill(
    x: f32,
    y: f32,
    w: f32,
    h: f32,
) callconv(.C) void;
/// Draw a stroked rectangle.
pub const rectangleStroke = oc_rectangle_stroke;
extern fn oc_rectangle_stroke(
    x: f32,
    y: f32,
    w: f32,
    h: f32,
) callconv(.C) void;
/// Draw a filled rounded rectangle.
pub const roundedRectangleFill = oc_rounded_rectangle_fill;
extern fn oc_rounded_rectangle_fill(
    x: f32,
    y: f32,
    w: f32,
    h: f32,
    r: f32,
) callconv(.C) void;
/// Draw a stroked rounded rectangle.
pub const roundedRectangleStroke = oc_rounded_rectangle_stroke;
extern fn oc_rounded_rectangle_stroke(
    x: f32,
    y: f32,
    w: f32,
    h: f32,
    r: f32,
) callconv(.C) void;
/// Draw a filled ellipse.
pub const ellipseFill = oc_ellipse_fill;
extern fn oc_ellipse_fill(
    x: f32,
    y: f32,
    rx: f32,
    ry: f32,
) callconv(.C) void;
/// Draw a stroked ellipse.
pub const ellipseStroke = oc_ellipse_stroke;
extern fn oc_ellipse_stroke(
    x: f32,
    y: f32,
    rx: f32,
    ry: f32,
) callconv(.C) void;
/// Draw a filled circle.
pub const circleFill = oc_circle_fill;
extern fn oc_circle_fill(
    x: f32,
    y: f32,
    r: f32,
) callconv(.C) void;
/// Draw a stroked circle.
pub const circleStroke = oc_circle_stroke;
extern fn oc_circle_stroke(
    x: f32,
    y: f32,
    r: f32,
) callconv(.C) void;
/// Add an arc to the path.
pub const arc = oc_arc;
extern fn oc_arc(
    x: f32,
    y: f32,
    r: f32,
    arcAngle: f32,
    startAngle: f32,
) callconv(.C) void;
/// Draw a text line.
pub const textFill = oc_text_fill;
extern fn oc_text_fill(
    x: f32,
    y: f32,
    text: oc.strings.Str8,
) callconv(.C) void;
/// Draw an image.
pub const imageDraw = oc_image_draw;
extern fn oc_image_draw(
    image: Image,
    rect: oc.math.Rect,
) callconv(.C) void;
/// Draw a sub-region of an image.
pub const imageDrawRegion = oc_image_draw_region;
extern fn oc_image_draw_region(
    image: Image,
    srcRegion: oc.math.Rect,
    dstRegion: oc.math.Rect,
) callconv(.C) void;

const oc = @import("../orca.zig");
