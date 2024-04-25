const std = @import("std");
const uniduni_t = @import("uniduni_t.zig");

pub fn main() !void {
    const alloc = std.heap.page_allocator;

    var ut = uniduni_t.ColorPrint.init(alloc);
    defer ut.deinit();

    ut.add(.{ uniduni_t.Color{ .foreground = uniduni_t.ForegroundColor.green }, uniduni_t.Color{ .background = uniduni_t.BackgroundColor.magenta }, uniduni_t.Style.italic });
    try ut.print("This is an italic green text on a magenta background\n");

    try ut.black("This is a black foreground text\n");
    try ut.red("This is a red foreground text\n");
    try ut.green("This is a green foreground text\n");
    try ut.yellow("This is a yellow foreground text\n");
    try ut.blue("This is a blue foreground text\n");
    try ut.magenta("This is a magenta foreground text\n");
    try ut.cyan("This is a cyan foreground text\n");
    try ut.white("This is a white foreground text\n");
    try ut.default("This is your default text color\n");
}
