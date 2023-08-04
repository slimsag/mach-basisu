const std = @import("std");
const Build = std.Build;

pub fn build(b: *Build) void {
    const optimize = b.standardOptimizeOption(.{});
    const target = b.standardTargetOptions(.{});

    _ = b.addModule("mach-basisu", .{
        .source_file = .{ .path = "src/main.zig" },
    });

    // TODO: we cannot call b.dependency("basisu") inside of `pub fn build`
    // if we want users of the package to be able to make use of it.
    // See hexops/mach#902
    _ = optimize;
    _ = target;
    // // TODO: add this as a module dependency
    // const lib = b.addStaticLibrary(.{
    //     .name = "mach-basisu",
    //     .target = target,
    //     .optimize = optimize,
    // });
    // lib.linkLibCpp();
    // lib.linkLibrary(b.dependency("basisu", .{
    //     .target = target,
    //     .optimize = optimize,
    // }).artifact("basisu"));

    // lib.addCSourceFiles(&.{
    //     "src/encoder/wrapper.cpp",
    //     "src/transcoder/wrapper.cpp",
    // }, &.{});

    // b.installArtifact(lib);

    // const test_exe = b.addTest(.{
    //     .root_source_file = .{ .path = "src/main.zig" },
    //     .target = target,
    //     .optimize = optimize,
    // });

    // test_exe.linkLibrary(lib);

    // const test_step = b.step("test", "Run library tests");
    // test_step.dependOn(&b.addRunArtifact(test_exe).step);
}
