const std = @import("std");
const uniduni_t = @import("uniduni_t.zig");

pub fn main() !void {
    const alloc = std.heap.page_allocator;
    var cp = uniduni_t.ColorPrint.init(alloc);
    defer cp.deinit();

    cp.add(.{ uniduni_t.Color{ .foreground = uniduni_t.ForegroundColor.green }, uniduni_t.Color{ .background = uniduni_t.BackgroundColor.magenta }, uniduni_t.Style.italic });

    const my_colorized_string: []const u8 = try cp.colorize("This is my colorized string\n");

    const stdout = std.io.getStdOut().writer();
    try stdout.print("{s}\n", .{my_colorized_string});
}
