const std = @import("std");
const uniduni_t = @import("uniduni_t.zig");

pub fn main() !void {
    const alloc = std.heap.page_allocator;
    var cp = uniduni_t.ColorPrint.init(alloc);
    defer cp.deinit();

    cp.add(.{ uniduni_t.Color{ .rgb = uniduni_t.RGB{ .r = 246, .g = 133, .b = 29, .t = uniduni_t.ColorType.foreground } }, uniduni_t.Style.bold, uniduni_t.Style.underline, uniduni_t.Style.italic });

    try cp.print("This is a string with RGB color, underline, bold and italic");
}
