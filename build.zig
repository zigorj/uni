const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});

    const optimize = b.standardOptimizeOption(.{});

    _ = b.addModule("uniduni_t", .{
        .root_source_file = .{ .path = "src/uniduni_t.zig" },
        .target = target,
        .optimize = optimize,
    });

    const uni_tests = b.addTest(.{
        .root_source_file = .{ .path = "src/uniduni_t.zig" },
        .target = target,
        .optimize = optimize,
    });

    const run_uni_tests = b.addRunArtifact(uni_tests);

    const attr_tests = b.addTest(.{
        .root_source_file = .{ .path = "src/attributes.zig" },
        .target = target,
        .optimize = optimize,
    });

    const run_attr_tests = b.addRunArtifact(attr_tests);

    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&run_uni_tests.step);
    test_step.dependOn(&run_attr_tests.step);
}
