//! Types and helpers for vectors and matrices.

/// A 2D vector type.
pub const Vec2 = extern struct {
    x: f32,
    y: f32,

    /// Check if two 2D vectors are equal.
    pub fn eql(v0: Vec2, v1: Vec2) bool {
        return v0.x == v1.x and v0.y == v1.y;
    }

    /// Multiply a 2D vector by a scalar.
    pub fn mul(v: Vec2, f: f32) Vec2 {
        return .{ .x = v.x * f, .y = v.y * f };
    }

    /// Add two 2D vectors
    pub fn add(v0: Vec2, v1: Vec2) Vec2 {
        return .{ .x = v0.x + v1.x, .y = v0.y + v1.y };
    }
};
/// A 3D vector type.
pub const Vec3 = extern struct {
    x: f32,
    y: f32,
    z: f32,
};
/// A 2D integer vector type.
pub const Vec2i = extern struct {
    x: i32,
    y: i32,
};
/// A 4D vector type.
pub const Vec4 = extern struct {
    x: f32,
    y: f32,
    z: f32,
    w: f32,
};
/// A 2-by-3 matrix.
pub const Mat2x3 = extern struct {
    /// The elements of the matrix, stored in row-major order.
    m: [6]f32,

    /// Transforms a vector by an affine transformation represented as a 2x3 matrix.
    pub const mulVec = oc_mat2x3_mul;
    extern fn oc_mat2x3_mul(
        /// The input matrix. `m` holds an affine transformation. It is treated as a 3x3 matrix with an implicit `(0, 0, 1)` bottom row.
        m: Mat2x3,
        /// The input vector. It is treated as a 3D homogeneous coordinate vector with an implicit z-coordinate equal to 1.
        p: Vec2,
    ) callconv(.C) Vec2;
    /// Multiply two affine transformations represented as 2x3 matrices. Both matrices are treated as 3x3 matrices with an implicit `(0, 0, 1)` bottom row
    pub const mulMat = oc_mat2x3_mul_m;
    extern fn oc_mat2x3_mul_m(
        /// The left-hand side matrix
        lhs: Mat2x3,
        /// The right-hand side matrix
        rhs: Mat2x3,
    ) callconv(.C) Mat2x3;
    /// Invert an affine transform represented as a 2x3 matrix.
    pub const invert = oc_mat2x3_inv;
    extern fn oc_mat2x3_inv(
        /// The input matrix. It is treated as a 3x3 matrix with an implicit `(0, 0, 1)` bottom row.
        x: Mat2x3,
    ) callconv(.C) Mat2x3;
    /// Return a 2x3 matrix representing a rotation.
    pub const rotation = oc_mat2x3_rotate;
    extern fn oc_mat2x3_rotate(
        /// The rotation angle, in radians.
        radians: f32,
    ) callconv(.C) Mat2x3;
    /// Return a 2x3 matrix representing a translation.
    pub const translation = oc_mat2x3_translate;
    extern fn oc_mat2x3_translate(
        /// The first component of the translation.
        x: f32,
        /// The second component of the translation.
        y: f32,
    ) callconv(.C) Mat2x3;
};
/// An axis-aligned rectangle.
pub const Rect = extern struct {
    /// The x-coordinate of the top-left corner.
    x: f32,
    /// The y-coordinate of the top-left corner.
    y: f32,
    /// The width of the rectangle.
    w: f32,
    /// The height of the rectangle.
    h: f32,
};
