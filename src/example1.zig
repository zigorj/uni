const std = @import("std");
const uniduni_t = @import("uniduni_t.zig");

pub fn main() !void {
    const alloc = std.heap.page_allocator;
    var cp = uniduni_t.ColorPrint.init(alloc);
    defer cp.deinit();

    cp.add(.{ uniduni_t.Color{ .foreground = uniduni_t.ForegroundColor.green }, uniduni_t.Color{ .background = uniduni_t.BackgroundColor.magenta }, uniduni_t.Style.italic });
    try cp.print("This is an italic green text on a magenta background\n");
}
