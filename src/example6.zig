const std = @import("std");
const uniduni_t = @import("uniduni_t.zig");

pub fn main() !void {
    const alloc = std.heap.page_allocator;
    var cp = uniduni_t.ColorPrint.init(alloc);
    defer cp.deinit();

    // Your existing code

    cp.add(.{uniduni_t.Color{ .foreground = uniduni_t.ForegroundColor.red }});
    try cp.set();

    // Your existing code printing something in red
    const stdout = std.io.getStdOut().writer();
    try stdout.print("This is your code printing something in red\n", .{});

    // Don't forget to unset ColorPrint to default color
    try cp.unset();

    // Your code printing something in default color
    try stdout.print("This is your code printing something in default color\n", .{});
}
