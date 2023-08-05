pub const init_encoder = @import("encoder.zig").init_encoder;
pub const Compressor = @import("encoder.zig").Compressor;
pub const CompressorParams = @import("encoder.zig").CompressorParams;
pub const Image = @import("encoder.zig").Image;
pub const PackUASTCFlags = @import("encoder.zig").PackUASTCFlags;
pub const ColorSpace = @import("encoder.zig").ColorSpace;
pub const init_transcoder = @import("transcoder.zig").init_transcoder;
pub const isFormatEnabled = @import("transcoder.zig").isFormatEnabled;
pub const Transcoder = @import("transcoder.zig").Transcoder;

pub const BasisTextureFormat = enum(u1) {
    etc1s = 0,
    uastc4x4 = 1,
};

const testing = @import("std").testing;

test "reference decls" {
    testing.refAllDeclsRecursive(@This());
}

test "encode/transcode" {
    // Encode
    init_encoder();

    const params = CompressorParams.init(1);
    params.setGenerateMipMaps(true);
    params.setBasisFormat(.uastc4x4);
    params.setPackUASTCFlags(.{ .fastest = true });
    defer params.deinit();

    const image = params.getImageSource(0);
    image.fill(@embedFile("ziggy.png"), 379, 316, 4);

    const comp = try Compressor.init(params);
    try comp.process();

    // Transcode
    init_transcoder();

    const trans = try Transcoder.init(comp.output());
    defer trans.deinit();

    var out_buf = try testing.allocator.alloc(u8, try trans.calcTranscodedSize(0, 0, .astc_4x4_rgba));
    defer testing.allocator.free(out_buf);
    try trans.transcode(out_buf, 0, 0, .astc_4x4_rgba, .{});
}
