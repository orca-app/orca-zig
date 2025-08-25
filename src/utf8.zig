// @Incomplete
//! UTF8 encoding/decoding.

const oc = @import("orca.zig");

/// A unicode codepoint.
pub const Utf32 = u32;

/// This enum declares the possible return status of UTF8 decoding/encoding operations.
pub const Status = enum(u32) {
    /// The operation was successful.
    ok = 0,
    /// The operation unexpectedly encountered the end of the utf8 sequence.
    out_of_bounds = 1,
    /// A continuation byte was encountered where a leading byte was expected.
    unexpected_continuation_byte = 3,
    /// A leading byte was encountered in the middle of the encoding of utf8 codepoint.
    unexpected_leading_byte = 4,
    /// The utf8 sequence contains an invalid byte.
    invalid_byte = 5,
    /// The operation encountered an invalid utf8 codepoint.
    invalid_codepoint = 6,
    /// The utf8 sequence contains an overlong encoding of a utf8 codepoint.
    overlong_encoding = 7,
};
/// Get the size of a utf8-encoded codepoint for the first byte of the encoded sequence.
pub const sizeFromLeadingChar = oc_utf8_size_from_leading_char;
extern fn oc_utf8_size_from_leading_char(
    /// The first byte of utf8 sequence.
    leadingChar: u8,
) callconv(.c) u32;

/// Get the size of the utf8 encoding of a codepoint.
pub const codepointSize = oc_utf8_codepoint_size;
extern fn oc_utf8_codepoint_size(
    /// A unicode codepoint.
    codePoint: Utf32,
) callconv(.c) u32;

pub const codepointCountForString = oc_utf8_codepoint_count_for_string;
extern fn oc_utf8_codepoint_count_for_string(
    /// A utf8 encoded string.
    string: oc.strings.Str8,
) callconv(.c) u64;

/// Get the length of the utf8 encoding of a sequence of unicode codepoints.
pub const byteCountForCodepoints = oc_utf8_byte_count_for_codepoints;
extern fn oc_utf8_byte_count_for_codepoints(
    /// A sequence of unicode codepoints.
    codePoints: oc.strings.Str32,
) callconv(.c) u64;

/// Get the offset of the next codepoint after a given offset, in a utf8 encoded string.
pub const nextOffset = oc_utf8_next_offset;
extern fn oc_utf8_next_offset(
    /// A utf8 encoded string.
    string: oc.strings.Str8,
    /// The offset after which to look for the next codepoint, in bytes.
    byteOffset: u64,
) callconv(.c) u64;

/// Get the offset of the previous codepoint before a given offset, in a utf8 encoded string.
pub const prevOffset = oc_utf8_prev_offset;
extern fn oc_utf8_prev_offset(
    /// A utf8 encoded string.
    string: oc.strings.Str8,
    /// The offset before which to look for the previous codepoint, in bytes.
    byteOffset: u64,
) callconv(.c) u64;

/// A type representing the result of decoding of utf8-encoded codepoint.
pub const DecodeResult = extern struct {
    /// The status of the decoding operation. If not `OC_UTF8_OK`, it describes the error that was encountered during decoding.
    status: Status,
    /// The decoded codepoint.
    codepoint: Utf32,
    /// The size of the utf8 sequence encoding that codepoint.
    size: u32,
};

/// Decode a utf8 encoded codepoint.
pub const decode = oc_utf8_decode;
extern fn oc_utf8_decode(
    /// A utf8-encoded codepoint.
    string: oc.strings.Str8,
) callconv(.c) DecodeResult;

/// Decode a codepoint at a given offset in a utf8 encoded string.
pub const decodeAt = oc_utf8_decode_at;
extern fn oc_utf8_decode_at(
    /// A utf8 encoded string.
    string: oc.strings.Str8,
    /// The offset at which to decode a codepoint.
    offset: u64,
) callconv(.c) DecodeResult;

/// Encode a unicode codepoint into a utf8 sequence.
pub const encode = oc_utf8_encode;
extern fn oc_utf8_encode(
    /// A pointer to the backing memory for the encoded sequence. This must point to a buffer big enough to encode the codepoint.
    dst: [*c]u8,
    /// The unicode codepoint to encode.
    codePoint: Utf32,
) callconv(.c) oc.strings.Str8;

/// Decode a utf8 string to a string of unicode codepoints using memory passed by the caller.
pub const toCodepoints = oc_utf8_to_codepoints;
extern fn oc_utf8_to_codepoints(
    /// The maximum number of codepoints that the backing memory can contain.
    maxCount: u64,
    /// A pointer to the backing memory for the result. This must point to a buffer capable of holding `maxCount` codepoints.
    backing: [*c]Utf32,
    /// A utf8 encoded string.
    string: oc.strings.Str8,
) callconv(.c) oc.strings.Str32;

/// Encode a string of unicode codepoints into a utf8 string using memory passed by the caller.
pub const fromCodepoints = oc_utf8_from_codepoints;
extern fn oc_utf8_from_codepoints(
    /// The maximum number of bytes that the backing memory can contain.
    maxBytes: u64,
    /// A pointer to the backing memory for the result. This must point to a buffer capable of holding `maxBytes` bytes.
    backing: [*c]u8,
    /// A string of unicode codepoints.
    codePoints: oc.strings.Str32,
) callconv(.c) oc.strings.Str8;

/// Decode a utf8 encoded string to a string of unicode codepoints using an arena.
pub const pushToCodepoints = oc_utf8_push_to_codepoints;
extern fn oc_utf8_push_to_codepoints(
    /// The arena on which to allocate the codepoints.
    arena: [*c]oc.mem.Arena,
    /// A utf8 encoded string.
    string: oc.strings.Str8,
) callconv(.c) oc.strings.Str32;

/// Encode a string of unicode codepoints into a utf8 string using an arena.
pub const pushFromCodepoints = oc_utf8_push_from_codepoints;
extern fn oc_utf8_push_from_codepoints(
    /// The arena on which to allocate the utf8 encoded string.
    arena: [*c]oc.mem.Arena,
    /// A string of unicode codepoints.
    codePoints: oc.strings.Str32,
) callconv(.c) oc.strings.Str8;

/// A type representing a contiguous range of unicode codepoints.
pub const Range = extern struct {
    /// The first codepoint of the range.
    firstCodePoint: Utf32,
    /// The number of codepoints in the range.
    count: u32,
};
