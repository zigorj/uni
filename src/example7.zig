const std = @import("std");
const Uniduni_t = @import("uniduni_t.zig").Uniduni_t;

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    const uni = Uniduni_t.init().cyan();

    try uni.on();
    try stdout.print("This is a cyan string\n", .{});

    try uni.off();
    try stdout.print("This is a default colored string\n", .{});
}
