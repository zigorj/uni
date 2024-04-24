const std = @import("std");
const testing = std.testing;

const esc_char: []const u8 = "\x1b";

/// Enumeration with the style's values.
pub const Style = enum(u8) {
    reset,
    bold,
    faint,
    italic,
    underline,
    slow_blink,
    rapid_blink,
    reverse_video,
    concealed,
    crossed_out,
};

/// Enumeration with the foreground color's values.
pub const FgColor = enum(u8) {
    black = 30,
    red,
    green,
    yellow,
    blue,
    magenta,
    cyan,
    white,
    default = 39,
};

/// Enumeration with the background color's values.
pub const BgColor = enum(u8) {
    black = 40,
    red,
    green,
    yellow,
    blue,
    magenta,
    cyan,
    white,
    default = 49,
};

/// Main structure for the color.
pub const ColorPrint = struct {
    alloc: std.heap.ArenaAllocator,
    fg_color: FgColor,
    bg_color: BgColor,

    /// Initialize an instance of the Uniduni_t struct.
    pub fn init(alloc: std.mem.Allocator) ColorPrint {
        return .{
            .alloc = std.heap.ArenaAllocator.init(alloc),
            .fg_color = FgColor.default,
            .bg_color = BgColor.default,
        };
    }

    /// Deinitialize a instance of the Uniduni_t struct.
    pub fn deinit(self: *ColorPrint) void {
        self.alloc.deinit();
        self.* = undefined;
    }

    /// Set a style or a color to a Uniduni_t struct.
    pub fn set(self: *ColorPrint, comptime attr: anytype) !void {
        const t_attr = @TypeOf(attr);
        switch (t_attr) {
            FgColor => self.fg_color = attr,
            BgColor => self.bg_color = attr,
            else => @panic("This function only accepts BgColor or FgColor as parameters.\n"),
        }
    }

    /// Print a string passed as parameter with the colors setted as fields
    /// of the Uniduni_t struct.
    pub fn print(self: *ColorPrint, str: []const u8) !void {
        const stdout = std.io.getStdOut().writer();
        try stdout.print("{s}{s}{s}", .{ try self.parse(), str, try self.reset() });
    }

    fn parse(self: *ColorPrint) ![]const u8 {
        const fmt = try std.fmt.allocPrint(self.alloc.allocator(), "{s}[{d};{d}m", .{ esc_char, @intFromEnum(self.fg_color), @intFromEnum(self.bg_color) });
        return fmt;
    }

    fn reset(self: *ColorPrint) ![]const u8 {
        const rst = try std.fmt.allocPrint(self.alloc.allocator(), "{s}[0m", .{esc_char});
        return rst;
    }
};

// Tests
test "Initialization of a Uniduni_t struct" {
    const expected = ColorPrint;

    const alloc = testing.allocator;
    var ut = ColorPrint.init(alloc);
    defer ut.deinit();

    const actual = @TypeOf(ut);

    try testing.expectEqual(expected, actual);
}

test "Set a foreground color" {
    const expected = FgColor.cyan;

    const alloc = testing.allocator;
    var ut = ColorPrint.init(alloc);
    defer ut.deinit();

    try ut.set(FgColor.cyan);

    const actual = ut.fg_color;

    try testing.expectEqual(expected, actual);
}

test "Set a background color" {
    const expected = BgColor.yellow;

    const alloc = testing.allocator;
    var ut = ColorPrint.init(alloc);
    defer ut.deinit();

    try ut.set(BgColor.yellow);

    const actual = ut.bg_color;

    try testing.expectEqual(expected, actual);
}

// write test to check failing when passing any type other than fg_color or bg_color.
//

test "Parse a colored string" {
    const expected: []const u8 = esc_char ++ "[30;41m";

    const alloc = testing.allocator;
    var ut = ColorPrint.init(alloc);
    defer ut.deinit();

    try ut.set(FgColor.black);
    try ut.set(BgColor.red);

    const actual = try ut.parse();

    try testing.expectEqualStrings(expected, actual);
}

test "Reset string" {
    const expected: []const u8 = esc_char ++ "[0m";

    const alloc = testing.allocator;
    var ut = ColorPrint.init(alloc);
    defer ut.deinit();

    const actual = try ut.reset();

    try testing.expectEqualStrings(expected, actual);
}
