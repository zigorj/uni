const std = @import("std");
const uniduni_t = @import("uniduni_t.zig");

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    const bright_yellow_string = Uniduni_t.init().brightYellow().format("This is a bright yellow string");
    try stdout.print("{s}\n", .{bright_yellow_string});
}
