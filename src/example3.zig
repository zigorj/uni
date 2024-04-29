const std = @import("std");
const uniduni_t = @import("uniduni_t.zig");

pub fn main() !void {
    const alloc = std.heap.page_allocator;
    var cp = uniduni_t.ColorPrint.init(alloc);
    defer cp.deinit();

    cp.add(.{uniduni_t.Color{ .foreground = uniduni_t.ForegroundColor.red }});
    try cp.print("This is a red text\n");
    try cp.print("This is also a red text\n");
}
