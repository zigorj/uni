// - writer
const std = @import("std");
const testing = std.testing;

const esc_char: []const u8 = "\x1b";

const Error = error{
    ColorTypeError,
};

/// Style's values.
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

/// Foreground color's values.
pub const ForegroundColor = enum(u8) {
    black = 30,
    red,
    green,
    yellow,
    blue,
    magenta,
    cyan,
    white,
    rgb = 38,
    default,
};

/// Background color's values.
pub const BackgroundColor = enum(u8) {
    black = 40,
    red,
    green,
    yellow,
    blue,
    magenta,
    cyan,
    white,
    rgb = 48,
    default,
};

/// ColorType is an union to specify if a color is background or foreground (for RGB).
pub const ColorType = enum {
    foreground,
    background,
};

/// RGB struct to store color code for red, green and blue notation.
pub const RGB = struct {
    r: u8,
    g: u8,
    b: u8,
    t: ColorType,
};

/// Color is a struct representing all type of colors.
pub const Color = union(enum) {
    foreground: ForegroundColor,
    background: BackgroundColor,
    rgb: RGB,
};

/// ColorPrint is the main structure for colorizing strings and has fields to store
/// foreground and background colors and other styles, like bold, italic, blinking etc.
pub const ColorPrint = struct {
    alloc: std.heap.ArenaAllocator,
    color: [2]Color,
    style: ?Style,

    /// Initialize an instance of ColorPrint struct.
    pub fn init(alloc: std.mem.Allocator) ColorPrint {
        return .{
            .alloc = std.heap.ArenaAllocator.init(alloc),
            .color = [2]Color{
                Color{ .foreground = ForegroundColor.default },
                Color{ .background = BackgroundColor.default },
            },
            .style = null,
        };
    }

    /// Deinitialize an instance of ColorPrint struct.
    pub fn deinit(self: *ColorPrint) void {
        self.alloc.deinit();
        self.* = undefined;
    }

    /// Add foreground and background colors or styles. It accepts a tupple as parameter,
    /// with elements of type Color or Style.
    /// It iterates throught the elements of the tuple and adds them as fields of the
    /// ColorPrint struct.
    pub fn add(self: *ColorPrint, comptime attr: anytype) void {
        const t_info_attr = @typeInfo(@TypeOf(attr));
        if (t_info_attr != .Struct) @compileError("Unaccepted parameter.");
        if (!t_info_attr.Struct.is_tuple) @compileError("Unaccepted parameter.");

        inline for (attr) |attribute| {
            switch (@TypeOf(attribute)) {
                Color => {
                    switch (attribute) {
                        .foreground => |fg_color| self.color[0] = Color{ .foreground = fg_color },
                        .background => |bg_color| self.color[1] = Color{ .background = bg_color },
                        .rgb => |rgb_color| {
                            if (std.mem.eql(u8, @tagName(rgb_color.t), "foreground")) {
                                self.color[0] = Color{ .rgb = rgb_color };
                            } else {
                                self.color[1] = Color{ .rgb = rgb_color };
                            }
                        },
                    }
                },
                Style => self.style = attribute,
                else => @compileError("Unaccepted parameter."),
            }
        }
    }

    test "Add foreground and background color and a style" {
        const alloc = testing.allocator;

        const expected = ColorPrint{
            .alloc = std.heap.ArenaAllocator.init(alloc),
            .color = [2]Color{
                Color{ .foreground = ForegroundColor.cyan },
                Color{ .background = BackgroundColor.yellow },
            },
            .style = Style.bold,
        };

        var actual = ColorPrint.init(alloc);
        defer actual.deinit();

        actual.add(.{ Color{ .foreground = ForegroundColor.cyan }, Color{ .background = BackgroundColor.yellow }, Style.bold });

        try testing.expectEqual(expected, actual);
    }

    /// Unset colors and styles.
    pub fn defaultEverything(self: *ColorPrint) void {
        self.color = [2]Color{
            Color{ .foreground = ForegroundColor.default },
            Color{ .background = BackgroundColor.default },
        };
        self.style = null;
    }

    test "Unset everything" {
        const alloc = testing.allocator;

        const expected = ColorPrint{
            .alloc = std.heap.ArenaAllocator.init(alloc),
            .color = [2]Color{
                Color{ .foreground = ForegroundColor.default },
                Color{ .background = BackgroundColor.default },
            },
            .style = null,
        };

        var actual = ColorPrint.init(alloc);
        defer actual.deinit();

        actual.add(.{
            Color{ .foreground = ForegroundColor.green },
            Color{ .background = BackgroundColor.cyan },
            Style.bold,
        });
        actual.defaultEverything();

        try testing.expectEqual(expected, actual);
    }

    /// Set foreground color to default
    pub fn defaultForeground(self: *ColorPrint) void {
        self.color[0] = Color{ .foreground = ForegroundColor.default };
    }

    test "Set foreground to default" {
        const alloc = testing.allocator;

        const expected = ColorPrint{
            .alloc = std.heap.ArenaAllocator.init(alloc),
            .color = [2]Color{
                Color{ .foreground = ForegroundColor.default },
                Color{ .background = BackgroundColor.default },
            },
            .style = null,
        };

        var actual = ColorPrint.init(alloc);
        defer actual.deinit();

        actual.add(.{Color{ .foreground = ForegroundColor.black }});

        actual.defaultForeground();

        try testing.expectEqual(expected, actual);
    }

    /// Set background color to default.
    pub fn defaultBackground(self: *ColorPrint) void {
        self.color[1] = Color{ .background = BackgroundColor.default };
    }

    test "Set background to default" {
        const alloc = testing.allocator;

        const expected = ColorPrint{
            .alloc = std.heap.ArenaAllocator.init(alloc),
            .color = [2]Color{
                Color{ .foreground = ForegroundColor.default },
                Color{ .background = BackgroundColor.default },
            },
            .style = null,
        };

        var actual = ColorPrint.init(alloc);
        defer actual.deinit();

        actual.add(.{Color{ .background = BackgroundColor.magenta }});
        actual.defaultBackground();

        try testing.expectEqual(expected, actual);
    }

    /// Unset style.
    pub fn unsetStyle(self: *ColorPrint) void {
        self.style = null;
    }

    test "Unset style" {
        const alloc = testing.allocator;

        const expected = ColorPrint{
            .alloc = std.heap.ArenaAllocator.init(alloc),
            .color = [2]Color{
                Color{ .foreground = ForegroundColor.default },
                Color{ .background = BackgroundColor.default },
            },
            .style = null,
        };

        var actual = ColorPrint.init(alloc);
        defer actual.deinit();

        actual.add(.{Style.underline});
        actual.unsetStyle();
        try testing.expectEqual(expected, actual);
    }

    /// Print a given string with the colors added to the ColorPrint struct instance.
    /// It calls the parse private method to parse the colors and styles to a string that
    /// will be added before the str parameter.
    pub fn print(self: *ColorPrint, str: []const u8) !void {
        const stdout = std.io.getStdOut().writer();
        const f_tag = @tagName(self.color[0]);
        const b_tag = @tagName(self.color[1]);
        if (std.mem.eql(u8, f_tag, "rgb") and std.mem.eql(u8, b_tag, "rgb")) {
            try stdout.print("{s}{s}{s}", .{ try self.parseRGB(), str, try self.reset() });
        } else {
            try stdout.print("{s}{s}{s}", .{ try self.parse(), str, try self.reset() });
        }
    }

    /// Parse colors to ANSI code string.
    fn parse(self: *ColorPrint) ![]const u8 {
        if (!std.mem.eql(u8, @tagName(self.color[0]), "foreground") or !std.mem.eql(u8, @tagName(self.color[1]), "background")) {
            return error.ColorTypeError;
        }

        const parsed_color: []const u8 = try std.fmt.allocPrint(self.alloc.allocator(), "{s}[{d};{d}", .{ esc_char, @intFromEnum(self.color[0].foreground), @intFromEnum(self.color[1].background) });
        const parsed_style: ?[]const u8 = blk: {
            if (self.style != null) {
                break :blk try std.fmt.allocPrint(self.alloc.allocator(), "{d}", .{@intFromEnum(self.style.?)});
            }
            break :blk null;
        };

        if (parsed_style != null) {
            return try std.fmt.allocPrint(self.alloc.allocator(), "{s};{s}m", .{ parsed_color, parsed_style.? });
        }

        return try std.fmt.allocPrint(self.alloc.allocator(), "{s}m", .{parsed_color});
    }

    test "Parse a string with colors" {
        const expected: []const u8 = esc_char ++ "[30;41m";

        const alloc = testing.allocator;
        var ut = ColorPrint.init(alloc);
        defer ut.deinit();

        ut.add(.{ Color{ .foreground = ForegroundColor.black }, Color{ .background = BackgroundColor.red } });

        const actual = try ut.parse();

        try testing.expectEqualStrings(expected, actual);
    }

    test "Parse a string with colors and a style" {
        const expected: []const u8 = esc_char ++ "[30;41;8m";

        const alloc = testing.allocator;
        var ut = ColorPrint.init(alloc);
        defer ut.deinit();

        ut.add(.{ Color{ .foreground = ForegroundColor.black }, Color{ .background = BackgroundColor.red }, Style.conceal });

        const actual = try ut.parse();

        try testing.expectEqualStrings(expected, actual);
    }

    test "Parse a string with the foreground in the place of the background" {
        const expected = error.ColorTypeError;

        const alloc = testing.allocator;
        var cp = ColorPrint.init(alloc);
        defer cp.deinit();

        cp.color[0] = Color{ .background = BackgroundColor.white };
        cp.color[1] = Color{ .foreground = ForegroundColor.black };

        const actual = cp.parse();

        try testing.expectError(expected, actual);
    }

    test "Parse a string with the two color of the same type" {
        const expected = error.ColorTypeError;

        const alloc = testing.allocator;
        var cp = ColorPrint.init(alloc);
        defer cp.deinit();

        cp.color[0] = Color{ .foreground = ForegroundColor.white };
        cp.color[1] = Color{ .foreground = ForegroundColor.red };

        const actual = cp.parse();

        try testing.expectError(expected, actual);
    }

    test "Parse a string with the RGB and normal color" {
        const expected = error.ColorTypeError;

        const alloc = testing.allocator;
        var cp = ColorPrint.init(alloc);
        defer cp.deinit();

        cp.color[0] = Color{ .foreground = ForegroundColor.white };
        cp.color[1] = Color{ .rgb = RGB{ .r = 255, .g = 255, .b = 255, .t = ColorType.background } };

        const actual = cp.parse();

        try testing.expectError(expected, actual);
    }

    /// Parse RGB colors to ANSI code string.
    fn parseRGB(self: *ColorPrint) ![]const u8 {
        if (!std.mem.eql(u8, @tagName(self.color[0]), @tagName((self.color[1])))) {
            return error.ColorTypeError;
        }

        if (!std.mem.eql(u8, @tagName(self.color[0].rgb.t), "foreground") or !std.mem.eql(u8, @tagName(self.color[1].rgb.t), "background")) {
            return error.ColorTypeError;
        }

        const foreground = self.color[0].rgb;
        const background = self.color[1].rgb;

        const parsed_color: []const u8 = try std.fmt.allocPrint(self.alloc.allocator(), "{s}[{d};{d};{d};{d};{d};{d};{d};{d};{d};{d}", .{
            esc_char,
            @intFromEnum(ForegroundColor.rgb),
            2,
            foreground.r,
            foreground.g,
            foreground.b,
            @intFromEnum(BackgroundColor.rgb),
            2,
            background.r,
            background.g,
            background.b,
        });

        const parsed_style: ?[]const u8 = blk: {
            if (self.style != null) {
                break :blk try std.fmt.allocPrint(self.alloc.allocator(), "{d}", .{@intFromEnum(self.style.?)});
            }
            break :blk null;
        };

        if (parsed_style != null) {
            return try std.fmt.allocPrint(self.alloc.allocator(), "{s};{s}m", .{ parsed_color, parsed_style.? });
        }

        return try std.fmt.allocPrint(self.alloc.allocator(), "{s}m", .{parsed_color});
    }

    test "Parse a string with RGB colors" {
        const expected: []const u8 = esc_char ++ "[38;2;255;255;255;48;2;0;0;0m";

        const alloc = testing.allocator;
        var ut = ColorPrint.init(alloc);
        defer ut.deinit();

        ut.add(.{ Color{ .rgb = RGB{ .r = 255, .g = 255, .b = 255, .t = ColorType.foreground } }, Color{ .rgb = RGB{ .r = 0, .g = 0, .b = 0, .t = ColorType.background } } });

        const actual = try ut.parseRGB();

        try testing.expectEqualStrings(expected, actual);
    }

    test "Parse a string with RGB colors and a style" {
        const expected: []const u8 = esc_char ++ "[38;2;255;255;255;48;2;0;0;0;8m";

        const alloc = testing.allocator;
        var ut = ColorPrint.init(alloc);
        defer ut.deinit();

        ut.add(.{ Color{ .rgb = RGB{ .r = 255, .g = 255, .b = 255, .t = ColorType.foreground } }, Color{ .rgb = RGB{ .r = 0, .g = 0, .b = 0, .t = ColorType.background } }, Style.conceal });

        const actual = try ut.parseRGB();

        try testing.expectEqualStrings(expected, actual);
    }

    test "Parse a string with the foreground in the place of the background (RGB)" {
        const expected = error.ColorTypeError;

        const alloc = testing.allocator;
        var cp = ColorPrint.init(alloc);
        defer cp.deinit();

        cp.color[0] = Color{ .rgb = RGB{ .r = 127, .g = 187, .b = 179, .t = ColorType.background } };
        cp.color[1] = Color{ .rgb = RGB{ .r = 167, .g = 192, .b = 128, .t = ColorType.foreground } };

        const actual = cp.parseRGB();

        try testing.expectError(expected, actual);
    }

    test "Parse a string with the two color of the same type (RGB)" {
        const expected = error.ColorTypeError;

        const alloc = testing.allocator;
        var cp = ColorPrint.init(alloc);
        defer cp.deinit();

        cp.color[0] = Color{ .rgb = RGB{ .r = 127, .g = 187, .b = 179, .t = ColorType.foreground } };
        cp.color[1] = Color{ .rgb = RGB{ .r = 167, .g = 192, .b = 128, .t = ColorType.foreground } };

        const actual = cp.parseRGB();

        try testing.expectError(expected, actual);
    }

    /// Return the reset style string.
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

    /// Print a text with black foreground and default background color.
    pub fn black(self: *ColorPrint, str: []const u8) !void {
        self.defaultEverything();
        self.add(.{Color{ .foreground = ForegroundColor.black }});
        return try self.print(str);
    }

    /// Print a text with red foreground and default background color.
    pub fn red(self: *ColorPrint, str: []const u8) !void {
        self.defaultEverything();
        self.add(.{Color{ .foreground = ForegroundColor.red }});
        return try self.print(str);
    }

    /// Print a text with green foreground and default background color.
    pub fn green(self: *ColorPrint, str: []const u8) !void {
        self.defaultEverything();
        self.add(.{Color{ .foreground = ForegroundColor.green }});
        return try self.print(str);
    }

    /// Print a text with yellow foreground and default background color.
    pub fn yellow(self: *ColorPrint, str: []const u8) !void {
        self.defaultEverything();
        self.add(.{Color{ .foreground = ForegroundColor.yellow }});
        return try self.print(str);
    }

    /// Print a text with blue foreground and default background color.
    pub fn blue(self: *ColorPrint, str: []const u8) !void {
        self.defaultEverything();
        self.add(.{Color{ .foreground = ForegroundColor.blue }});
        return try self.print(str);
    }

    /// Print a text with magenta foreground and default background color.
    pub fn magenta(self: *ColorPrint, str: []const u8) !void {
        self.defaultEverything();
        self.add(.{Color{ .foreground = ForegroundColor.magenta }});
        return try self.print(str);
    }

    /// Print a text with cyan foreground and default background color.
    pub fn cyan(self: *ColorPrint, str: []const u8) !void {
        self.defaultEverything();
        self.add(.{Color{ .foreground = ForegroundColor.cyan }});
        return try self.print(str);
    }

    /// Print a text with white foreground and default background color.
    pub fn white(self: *ColorPrint, str: []const u8) !void {
        self.defaultEverything();
        self.add(.{Color{ .foreground = ForegroundColor.white }});
        return try self.print(str);
    }

    /// Print a text with default foreground and default background color.
    pub fn default(self: *ColorPrint, str: []const u8) !void {
        self.defaultEverything();
        return try self.print(str);
    }

    /// Colorize the string passed as str parameter, returning it with the
    /// color and styles that were setted to the ColorPrint struct fields.
    pub fn colorize(self: *ColorPrint, str: []const u8) ![]const u8 {
        const fmt = try std.fmt.allocPrint(self.alloc.allocator(), "{s}{s}{s}", .{ try self.parse(), str, try self.reset() });
        return fmt;
    }

    test "Colorize a string" {
        const expected: []const u8 = esc_char ++ "[35;47;9m" ++ "Colorize Me!" ++ esc_char ++ "[0m";

        const alloc = testing.allocator;
        var ut = ColorPrint.init(alloc);
        defer ut.deinit();

        ut.add(.{ Color{ .foreground = ForegroundColor.magenta }, Color{ .background = BackgroundColor.white }, Style.cross_out });

        const actual = try ut.colorize("Colorize Me!");

        try testing.expectEqualStrings(expected, actual);
    }

    /// Activate the color setted in the ColorPrint struct on the normal
    /// printings of the stdout.
    pub fn set(self: *ColorPrint) !void {
        const stdout = std.io.getStdOut().writer();
        try stdout.print("{s}", .{try self.parse()});
    }

    /// Deactivate the color setted in the ColorPrint struct on the normal
    /// printings of the stdout.
    pub fn unset(self: *ColorPrint) !void {
        const stdout = std.io.getStdOut().writer();
        try stdout.print("{s}", .{try self.reset()});
    }
};

test "Initialization of a ColorPrint struct" {
    const alloc = testing.allocator;
    var actual = ColorPrint.init(alloc);
    defer actual.deinit();

    try testing.expectEqual(ColorPrint, @TypeOf(actual));
}
