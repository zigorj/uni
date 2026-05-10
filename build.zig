const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const attr = b.addModule("attributes", .{
        .root_source_file = b.path("src/attr.zig"),
        .target = target,
        .optimize = optimize,
    });

    const uni = b.addModule("uni", .{
        .root_source_file = b.path("src/uni.zig"),
        .target = target,
        .optimize = optimize,
    });

    const uni_test_step = b.step("test", "Run uni tests.");

    const uni_tests = b.addTest(.{ .root_module = uni });
    const attr_tests = b.addTest(.{ .root_module = attr });

    const run_uni_tests = b.addRunArtifact(uni_tests);
    const run_attr_tests = b.addRunArtifact(attr_tests);

    uni_test_step.dependOn(&run_uni_tests.step);
    uni_test_step.dependOn(&run_attr_tests.step);
}
