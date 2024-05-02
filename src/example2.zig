const std = @import("std");
const Uniduni_t = @import("uniduni_t.zig").Uniduni_t;

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    const green = Uniduni_t.init().green().bold();
    try stdout.print("{s}: success!\n", .{green.format("GREAT")});
}
