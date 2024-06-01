const std = @import("std");

const Uniduni_t = @import("uniduni_t.zig").Uniduni_t;
const attr = @import("attributes.zig");
const Color = attr.Color;

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    const first = Uniduni_t.init().add(.{ Color.Hex.fg("#a7c080"), Color.Hex.bg("2d353b") }); // First way
    const second = Uniduni_t.init().hex("A7C080", .foreground).hex("#2D353B", .background); // Second way
    try stdout.print("{s}\n", .{first.format("We accept hexadecimal too! Yay!")});
    try stdout.print("{s}\n", .{second.format("Everforest theme is great!")});
}
