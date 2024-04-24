const std = @import("std");
const testing = std.testing;

const esc_char: []const u8 = "\x1b";

///
/// Style's values.
///
pub const Style = enum(u8) {
    reset,
    bold,
    faint,
    italic,
    underline,
    slow_blink,
    rapid_blink,
    reverse_video,
    conceal,
    cross_out,
};

///
/// Foreground color's values.
///
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

///
/// Background color's values.
///
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

///
/// RGB struct to store color code for red, green and blue notation.
///
pub const RGB = struct {
    r: u8,
    g: u8,
    b: u8,
};

///
/// ColorPrint is the main structure for colorizing strings and has fields
/// to store foreground and background colors, and other styles, like bold,
/// italic, blinking etc.
///
/// ColorPrint
/// * alloc: it uses the Arena Allocator with a given allocator as a child allocator,
/// * fg_color: some FgColor enum value,
/// * bg_color: some BgColor enum value,
/// * style: some Style enum value,
///
pub const ColorPrint = struct {
    alloc: std.heap.ArenaAllocator,
    fg_color: FgColor,
    bg_color: BgColor,
    style: ?Style,

    ///
    /// Initialize an instance of ColorPrint struct.
    ///
    pub fn init(alloc: std.mem.Allocator) ColorPrint {
        return .{
            .alloc = std.heap.ArenaAllocator.init(alloc),
            .fg_color = FgColor.default,
            .bg_color = BgColor.default,
            .style = null,
        };
    }

    ///
    /// Deinitialize an instance of ColorPrint struct.
    ///
    pub fn deinit(self: *ColorPrint) void {
        self.alloc.deinit();
        self.* = undefined;
    }

    ///
    /// Sets foreground and background colors or a style.
    /// It accepts a tupple as parameter, with elements
    /// of type FgColor, BgColor or Style.
    ///
    /// It iterates throught the elements of the tuple and sets
    /// them as fields of the ColorPrint struct.
    ///
    /// Example: set(.{ FgColor.black, BgColor.red, Style.blinking });
    ///
    pub fn set(self: *ColorPrint, comptime attr: anytype) !void {
        const t_info_attr = @typeInfo(@TypeOf(attr));
        if (t_info_attr != .Struct) @compileError("Unaccepted parameter");
        if (!t_info_attr.Struct.is_tuple) @compileError("Unaccepted parameter");

        inline for (attr) |v| {
            switch (@TypeOf(v)) {
                FgColor => self.fg_color = v,
                BgColor => self.bg_color = v,
                Style => self.style = v,
                else => @compileError("Unaccepted parameter"),
            }
        }
    }

    test "Set foreground and background color and a style" {
        const alloc = testing.allocator;

        const expected = ColorPrint{
            .alloc = std.heap.ArenaAllocator.init(alloc),
            .fg_color = FgColor.cyan,
            .bg_color = BgColor.yellow,
            .style = Style.bold,
        };

        var actual = ColorPrint.init(alloc);
        defer actual.deinit();

        try actual.set(.{ FgColor.cyan, BgColor.yellow, Style.bold });

        try testing.expectEqual(expected, actual);
    }

    ///
    /// Prints a given string with the colors chosen before with
    /// the set method.
    ///
    /// It calls the parse private method to parse the colors and styles to a string.
    ///
    /// Example: print("This is a test colored string\n");
    ///
    pub fn print(self: *ColorPrint, str: []const u8) !void {
        const stdout = std.io.getStdOut().writer();
        try stdout.print("{s}{s}{s}", .{ try self.parse(), str, try self.reset() });
    }

    fn parse(self: *ColorPrint) ![]const u8 {
        const fmt = blk: {
            if (self.style != null) {
                break :blk try std.fmt.allocPrint(self.alloc.allocator(), "{s}[{d};{d};{d}m", .{ esc_char, @intFromEnum(self.fg_color), @intFromEnum(self.bg_color), @intFromEnum(self.style.?) });
            } else {
                break :blk try std.fmt.allocPrint(self.alloc.allocator(), "{s}[{d};{d}m", .{ esc_char, @intFromEnum(self.fg_color), @intFromEnum(self.bg_color) });
            }
        };
        return fmt;
    }

    test "Parse a string" {
        const expected: []const u8 = esc_char ++ "[30;41m";

        const alloc = testing.allocator;
        var ut = ColorPrint.init(alloc);
        defer ut.deinit();

        try ut.set(.{ FgColor.black, BgColor.red });

        const actual = try ut.parse();

        try testing.expectEqualStrings(expected, actual);
    }

    fn reset(self: *ColorPrint) ![]const u8 {
        const rst = try std.fmt.allocPrint(self.alloc.allocator(), "{s}[{d}m", .{ esc_char, @intFromEnum(Style.reset) });
        return rst;
    }

    test "Reset string" {
        const expected: []const u8 = esc_char ++ "[0m";

        const alloc = testing.allocator;
        var ut = ColorPrint.init(alloc);
        defer ut.deinit();

        const actual = try ut.reset();

        try testing.expectEqualStrings(expected, actual);
    }

    //  implement a returnFn func and the colors helpers
    // implement rgb

    ///
    /// Colorizes the string passed as str parameter, returning it with the
    /// color and styles that were setted to the ColorPrint struct fields.
    ///
    /// Example: colorize("This is a test\n");
    ///
    pub fn colorize(self: *ColorPrint, str: []const u8) ![]const u8 {
        const fmt = try std.fmt.allocPrint(self.alloc.allocator(), "{s}{s}{s}", .{ try self.parse(), str, try self.reset() });
        return fmt;
    }

    test "Colorize a string" {
        const expected: []const u8 = esc_char ++ "[35;47;9m" ++ "Colorize Me!" ++ esc_char ++ "[0m";

        const alloc = testing.allocator;
        var ut = ColorPrint.init(alloc);
        defer ut.deinit();

        try ut.set(.{ FgColor.magenta, BgColor.white, Style.cross_out });

        const actual = try ut.colorize("Colorize Me!");

        try testing.expectEqualStrings(expected, actual);
    }
};

test "Initialization of a ColorPrint struct" {
    const expected = ColorPrint;

    const alloc = testing.allocator;
    var ut = ColorPrint.init(alloc);
    defer ut.deinit();

    const actual = @TypeOf(ut);

    try testing.expectEqual(expected, actual);
}
