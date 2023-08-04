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

// TODO: remove this once hexops/mach#902 is fixed.
pub fn lib(
    b: *Build,
    optimize: std.builtin.OptimizeMode,
    target: std.zig.CrossTarget,
) *std.Build.Step.Compile {
    const l = b.addStaticLibrary(.{
        .name = "mach-basisu",
        .target = target,
        .optimize = optimize,
    });
    l.linkLibCpp();
    l.linkLibrary(b.dependency("basisu", .{
        .target = target,
        .optimize = optimize,
    }).artifact("basisu"));

    l.addCSourceFiles(&.{
        sdkPath("/src/encoder/wrapper.cpp"),
        sdkPath("/src/transcoder/wrapper.cpp"),
    }, &.{});
    return l;
}

fn sdkPath(comptime suffix: []const u8) []const u8 {
    if (suffix[0] != '/') @compileError("suffix must be an absolute path");
    return comptime blk: {
        const root_dir = std.fs.path.dirname(@src().file) orelse ".";
        break :blk root_dir ++ suffix;
    };
}
