const std = @import("std");
const uniduni_t = @import("uniduni_t.zig");

pub fn main() !void {
    const alloc = std.heap.page_allocator;
    var cp = uniduni_t.ColorPrint.init(alloc);
    defer cp.deinit();

    cp.add(.{ uniduni_t.Color{ .rgb = uniduni_t.RGB{ .r = 80, .g = 250, .b = 123, .t = uniduni_t.ColorType.foreground } }, uniduni_t.Color{ .rgb = uniduni_t.RGB{ .r = 40, .g = 42, .b = 54, .t = uniduni_t.ColorType.background } } });

    try cp.print("Dracula\n");
}
