// implement rgb
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
/// ColorPrint {
///     .alloc: it uses the Arena Allocator with a given allocator as a child allocator,
///     .fg_color: some FgColor enum value,
///     .bg_color: some BgColor enum value,
///     .style: some Style enum value,
/// };
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
    /// Example:
    ///
    /// const alloc = std.heap.page_allocator;
    ///
    /// var ut = ColorPrint.init(alloc);
    /// defer ut.deinit();
    ///
    /// try ut.set(.{ FgColor.black, BgColor.red, Style.blinking });
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
    /// Unsets every field of ColorPrint struct.
    ///
    /// It will set the default values as bellow:
    ///
    /// ColorPrint{
    ///     .fg_color = FgColor.default,
    ///     .bg_color = BgColor.default,
    ///     .style = null,
    /// };
    ///
    pub fn unsetAll(self: *ColorPrint) void {
        self.fg_color = FgColor.default;
        self.bg_color = BgColor.default;
        self.style = null;
    }

    test "Unset all fields" {
        const alloc = testing.allocator;

        const expected = ColorPrint{
            .alloc = std.heap.ArenaAllocator.init(alloc),
            .fg_color = FgColor.default,
            .bg_color = BgColor.default,
            .style = null,
        };

        var actual = ColorPrint.init(alloc);
        defer actual.deinit();

        try actual.set(.{ FgColor.cyan, BgColor.yellow, Style.bold });
        actual.unsetAll();

        try testing.expectEqual(expected, actual);
    }

    ///
    /// Unsets foreground color field
    ///
    /// It will set the default value as bellow:
    ///
    /// ColorPrint{
    ///     .fg_color = FgColor.default,
    /// };
    ///
    pub fn unsetFgColor(self: *ColorPrint) void {
        self.fg_color = FgColor.default;
    }

    test "Unset foreground color" {
        const alloc = testing.allocator;

        const expected = ColorPrint{
            .alloc = std.heap.ArenaAllocator.init(alloc),
            .fg_color = FgColor.default,
            .bg_color = BgColor.yellow,
            .style = Style.bold,
        };

        var actual = ColorPrint.init(alloc);
        defer actual.deinit();

        try actual.set(.{ FgColor.cyan, BgColor.yellow, Style.bold });
        actual.unsetFgColor();

        try testing.expectEqual(expected, actual);
    }

    ///
    /// Unsets background color field
    ///
    /// It will set the default value as bellow:
    ///
    /// ColorPrint{
    ///     .bg_color = BgColor.default,
    /// };
    ///
    pub fn unsetBgColor(self: *ColorPrint) void {
        self.bg_color = BgColor.default;
    }

    test "Unset background color" {
        const alloc = testing.allocator;

        const expected = ColorPrint{
            .alloc = std.heap.ArenaAllocator.init(alloc),
            .fg_color = FgColor.cyan,
            .bg_color = BgColor.default,
            .style = Style.bold,
        };

        var actual = ColorPrint.init(alloc);
        defer actual.deinit();

        try actual.set(.{ FgColor.cyan, BgColor.yellow, Style.bold });
        actual.unsetBgColor();

        try testing.expectEqual(expected, actual);
    }

    ///
    /// Unsets style color field
    ///
    /// It will set the default value as bellow:
    ///
    /// ColorPrint{
    ///     .style = null,
    /// };
    ///
    pub fn unsetStyle(self: *ColorPrint) void {
        self.style = null;
    }

    test "Unset style" {
        const alloc = testing.allocator;

        const expected = ColorPrint{
            .alloc = std.heap.ArenaAllocator.init(alloc),
            .fg_color = FgColor.cyan,
            .bg_color = BgColor.yellow,
            .style = null,
        };

        var actual = ColorPrint.init(alloc);
        defer actual.deinit();

        try actual.set(.{ FgColor.cyan, BgColor.yellow, Style.bold });
        actual.unsetStyle();

        try testing.expectEqual(expected, actual);
    }

    ///
    /// Prints a given string with the colors chosen before with
    /// the set method.
    ///
    /// It calls the parse private method to parse the colors and styles to a string.
    ///
    /// Example:
    /// const alloc = std.heap.page_allocator;
    ///
    /// var ut = ColorPrint.init(alloc);
    /// defer ut.deinit();
    ///
    /// try ut.set(.{ FgColor.yellow });
    ///
    /// print("This is a yellow text\n");
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
        const reset_string = try std.fmt.allocPrint(self.alloc.allocator(), "{s}[{d}m", .{ esc_char, @intFromEnum(Style.reset) });
        return reset_string;
    }

    test "Reset string" {
        const expected: []const u8 = esc_char ++ "[0m";

        const alloc = testing.allocator;
        var ut = ColorPrint.init(alloc);
        defer ut.deinit();

        const actual = try ut.reset();

        try testing.expectEqualStrings(expected, actual);
    }

    ///
    /// Prints a text with black foreground and default background color.
    ///
    /// This function is an alias for:
    ///
    /// const alloc = std.heap.page_allocator;
    /// var ut = ColorPrint.init(alloc);
    /// ut.set(.{FgColor.black});
    /// ut.print("String");
    ///
    pub fn black(self: *ColorPrint, str: []const u8) !void {
        self.unsetAll();
        try self.set(.{FgColor.black});
        return try self.print(str);
    }

    ///
    /// Prints a text with red foreground and default background color.
    ///
    /// This function is an alias for:
    ///
    /// const alloc = std.heap.page_allocator;
    /// var ut = ColorPrint.init(alloc);
    /// ut.set(.{FgColor.red});
    /// ut.print("String");
    ///
    pub fn red(self: *ColorPrint, str: []const u8) !void {
        self.unsetAll();
        try self.set(.{FgColor.red});
        return try self.print(str);
    }

    ///
    /// Prints a text with green foreground and default background color.
    ///
    /// This function is an alias for:
    ///
    /// const alloc = std.heap.page_allocator;
    /// var ut = ColorPrint.init(alloc);
    /// ut.set(.{FgColor.green});
    /// ut.print("String");
    ///
    pub fn green(self: *ColorPrint, str: []const u8) !void {
        self.unsetAll();
        try self.set(.{FgColor.green});
        return try self.print(str);
    }

    ///
    /// Prints a text with yellow foreground and default background color.
    ///
    /// This function is an alias for:
    ///
    /// const alloc = std.heap.page_allocator;
    /// var ut = ColorPrint.init(alloc);
    /// ut.set(.{FgColor.yellow});
    /// ut.print("String");
    ///
    pub fn yellow(self: *ColorPrint, str: []const u8) !void {
        self.unsetAll();
        try self.set(.{FgColor.yellow});
        return try self.print(str);
    }

    ///
    /// Prints a text with blue foreground and default background color.
    ///
    /// This function is an alias for:
    ///
    /// const alloc = std.heap.page_allocator;
    /// var ut = ColorPrint.init(alloc);
    /// ut.set(.{FgColor.blue});
    /// ut.print("String");
    ///
    pub fn blue(self: *ColorPrint, str: []const u8) !void {
        self.unsetAll();
        try self.set(.{FgColor.blue});
        return try self.print(str);
    }

    ///
    /// Prints a text with magenta foreground and default background color.
    ///
    /// This function is an alias for:
    ///
    /// const alloc = std.heap.page_allocator;
    /// var ut = ColorPrint.init(alloc);
    /// ut.set(.{FgColor.magenta});
    /// ut.print("String");
    ///
    pub fn magenta(self: *ColorPrint, str: []const u8) !void {
        self.unsetAll();
        try self.set(.{FgColor.magenta});
        return try self.print(str);
    }

    ///
    /// Prints a text with cyan foreground and default background color.
    ///
    /// This function is an alias for:
    ///
    /// const alloc = std.heap.page_allocator;
    /// var ut = ColorPrint.init(alloc);
    /// ut.set(.{FgColor.cyan});
    /// ut.print("String");
    ///
    pub fn cyan(self: *ColorPrint, str: []const u8) !void {
        self.unsetAll();
        try self.set(.{FgColor.cyan});
        return try self.print(str);
    }

    ///
    /// Prints a text with white foreground and default background color.
    ///
    /// This function is an alias for:
    ///
    /// const alloc = std.heap.page_allocator;
    /// var ut = ColorPrint.init(alloc);
    /// ut.set(.{FgColor.white});
    /// ut.print("String");
    ///
    pub fn white(self: *ColorPrint, str: []const u8) !void {
        self.unsetAll();
        try self.set(.{FgColor.white});
        return try self.print(str);
    }

    ///
    /// Prints a text with default foreground and default background color.
    ///
    /// This function is an alias for:
    ///
    /// const alloc = std.heap.page_allocator;
    /// var ut = ColorPrint.init(alloc);
    ///
    /// ut.print("String");
    ///
    pub fn default(self: *ColorPrint, str: []const u8) !void {
        self.unsetAll();
        return try self.print(str);
    }

    ///
    /// Colorizes the string passed as str parameter, returning it with the
    /// color and styles that were setted to the ColorPrint struct fields.
    ///
    /// Example:
    ///
    /// const alloc = std.heap.page_allocator;
    ///
    /// var ut = ColorPrint.init(alloc);
    /// try ut.set(.{ BgColor.red, FgColor.blue, Style.bold });
    ///
    /// const colorized_string = ut.colorize("This is a colorized string\n");
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
