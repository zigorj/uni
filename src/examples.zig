const std = @import("std");
const uniduni_t = @import("uniduni_t.zig");

pub fn main() !void {
    const alloc = std.heap.page_allocator;
    var blue = uniduni_t.init(alloc, uniduni_t.Color.blue);
    defer blue.deinit();

    try blue.print("This is a blue text\n");
}
