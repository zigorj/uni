const std = @import("std");

const Uniduni_t = @import("uniduni_t.zig").Uniduni_t;
const attr = @import("attributes.zig");
const Color = attr.Color;
const Style = attr.Style;

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    const warn = Uniduni_t.init().add(.{ Color.Foreground.red, Color.Background.black, Style.bold });
    try stdout.print("{s}: This is a warning!\n", .{warn.format("WARNING")});
}
