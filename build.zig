const std = @import("std");
const Build = std.Build;

pub fn build(b: *Build) void {
    const optimize = b.standardOptimizeOption(.{});
    const target = b.standardTargetOptions(.{});

    const lib = b.addStaticLibrary(.{
        .name = "mach-basisu",
        .target = target,
        .optimize = optimize,
    });
    lib.linkLibCpp();
    lib.addCSourceFiles(.{ .files = &.{
        "src/encoder/wrapper.cpp",
        "src/transcoder/wrapper.cpp",
    }, .flags = &.{} });
    lib.linkLibrary(b.dependency("basisu", .{
        .target = target,
        .optimize = optimize,
    }).artifact("basisu"));
    b.installArtifact(lib);

    const module = b.addModule("mach-basisu", .{
        .root_source_file = .{ .path = "src/main.zig" },
    });
    module.linkLibrary(lib);

    const test_exe = b.addTest(.{
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    test_exe.linkLibrary(lib);

    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&b.addRunArtifact(test_exe).step);
}
