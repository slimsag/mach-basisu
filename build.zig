const std = @import("std");
const Build = std.Build;

pub fn build(b: *Build) void {
    const optimize = b.standardOptimizeOption(.{});
    const target = b.standardTargetOptions(.{});

    _ = b.addModule("mach-basisu", .{
        .source_file = .{ .path = "src/main.zig" },
    });

    // TODO: add this as a module dependency
    const lib = b.addStaticLibrary(.{
        .name = "mach-basisu",
        .target = target,
        .optimize = optimize,
    });
    lib.linkLibCpp();
    link(b, lib);

    lib.addCSourceFiles(.{ .files = &.{
        "src/encoder/wrapper.cpp",
        "src/transcoder/wrapper.cpp",
    }, .flags = &.{} });

    b.installArtifact(lib);

    const test_exe = b.addTest(.{
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    test_exe.linkLibrary(lib);

    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&b.addRunArtifact(test_exe).step);
}

pub fn link(b: *std.Build, step: *std.build.CompileStep) void {
    step.linkLibrary(b.dependency("basisu", .{
        .target = step.target,
        .optimize = step.optimize,
    }).artifact("basisu"));
}
