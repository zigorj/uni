const std = @import("std");
const uniduni_t = @import("uniduni_t.zig");

pub fn main() !void {
    const alloc = std.heap.page_allocator;

    var cprint = uniduni_t.ColorPrint.init(alloc);
    defer cprint.deinit();

    try cprint.set(.{ uniduni_t.FgColor.black, uniduni_t.BgColor.red });
    try cprint.print("This is a black text on a red background\n");

    const stdout = std.io.getStdOut().writer();
    try stdout.print("This is a normal text, printed with normal stdout\n", .{});

    try cprint.set(.{ uniduni_t.FgColor.green, uniduni_t.BgColor.blue });
    try cprint.print("This is a green text on a blue background\n");
}
