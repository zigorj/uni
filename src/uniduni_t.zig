const std = @import("std");
const testing = std.testing;

/// `esc_char` represents the escape character used to introduce ANSI codes for terminal formatting.
///
/// ANSI escape codes are special sequences of characters that, when printed to a terminal, instruct
/// the terminal to perform various text formatting tasks such as changing colors, moving the cursor, etc.
///
/// This constant holds the escape character '\x1b' as an array of unsigned 8-bit integers (bytes).
/// It is used as the prefix for ANSI escape codes.
const esc_char: []const u8 = "\x1b";

/// `Uniduni_t_Error` is an error union representing errors related to the `Uniduni_t` library.
const Uniduni_t_Error = error{
    ColorError,
    StyleError,
};

/// `Style` is an enumeration representing various text styles for formatting.
///
/// This enum defines different text styles that can be applied to text when printing,
/// such as bold, italic, underline, etc.
pub const Style = enum(u8) {
    /// Resets all text styles to default.
    reset,
    /// Makes the text bold.
    bold,
    /// Makes the text faint (rarely supported).
    faint,
    /// Sets the text to italic.
    italic,
    /// Underlines the text.
    underline,
    /// Causes the text to blink slowly (less than 150 per minute).
    slow_blink,
    /// Causes the text to blink rapidly (faster than 150 per minute).
    rapid_blink,
    /// Swaps the foreground and background colors of the text.
    reverse_video,
    /// Conceals (hides) the text.
    conceal,
    /// Adds a line through the text.
    cross_out,
};

/// `ForegroundColor` is an enumeration representing foreground colors for terminal text.
///
/// This enum defines various foreground colors that can be used to colorize text when printed to a terminal.
pub const ForegroundColor = enum(u8) {
    /// Black foreground color.
    black = 30,
    /// Red foreground color.
    red,
    /// Green foreground color.
    green,
    /// Yellow foreground color.
    yellow,
    /// Blue foreground color.
    blue,
    /// Magenta foreground color.
    magenta,
    /// Cyan foreground color.
    cyan,
    /// White foreground color.
    white,
    /// This should not be used for you. Uniduti_t will use it to parse RGB colors.
    rgb = 38,
    /// Default foreground color.
    default,
};

/// `BackgroundColor` is an enumeration representing background colors for terminal text.
///
/// This enum defines various background colors that can be used to colorize text when printed to a terminal.
pub const BackgroundColor = enum(u8) {
    /// Black background color.
    black = 40,
    /// Red background color.
    red,
    /// Green background color.
    green,
    /// Yellow background color.
    yellow,
    /// Blue background color.
    blue,
    /// Magenta background color.
    magenta,
    /// Cyan background color.
    cyan,
    /// White background color.
    white,
    /// This should not be used for you. Uniduti_t will use it to parse RGB colors.
    rgb = 48,
    /// Default background color.
    default,
};

/// `ColorType` is an enumeration representing the type of color.
///
/// This enum defines two variants, `foreground` and `background`, which indicate whether a color setting
/// applies to the foreground (text) or background of text printed to a terminal.
pub const ColorType = enum {
    foreground,
    background,
};

/// `RGB` is a struct representing an RGB color along with its associated color type.
///
/// This struct encapsulates the red, green, and blue components of an RGB color, along with
/// the color type indicating whether it represents a foreground or background color.
pub const RGB = struct {
    /// The red component of the RGB color (0-255).
    r: u8,
    /// The green component of the RGB color (0-255).
    g: u8,
    /// The blue component of the RGB color (0-255).
    b: u8,
    /// The color type indicating whether this RGB color represents foreground or background.
    t: ColorType,
};

/// `Color` is a tagged union representing different types of colors.
///
/// This union can hold either a foreground color (`ForegroundColor`), a background color (`BackgroundColor`),
/// or a RGB color (`RGB`). The specific type of color is indicated by the tag associated with each variant.
pub const Color = union(enum) {
    /// Represents a foreground color.
    foreground: ForegroundColor,
    /// Represents a background color.
    background: BackgroundColor,
    /// Represents a RGB color.
    rgb: RGB,
};

/// `ColorPrint` is a struct representing a colored printing configuration.
/// It encapsulates information about memory allocation, foreground and background colors,
/// and optional text styling.
pub const ColorPrint = struct {
    /// Memory allocator for managing memory within the struct.
    alloc: std.heap.ArenaAllocator,

    /// An array containing foreground and background colors.
    color: [2]Color,

    /// A StaticField representing text styling information.
    style: std.bit_set.StaticBitSet(@typeInfo(Style).Enum.fields.len),

    /// Initializes an instance of the `ColorPrint` struct.
    ///
    /// Parameters:
    ///   - alloc: The memory allocator to be used for managing memory within the struct.
    ///
    /// Returns:
    ///   - A new `ColorPrint` struct instance initialized with default values.
    pub fn init(alloc: std.mem.Allocator) ColorPrint {
        return .{ .alloc = std.heap.ArenaAllocator.init(alloc), .color = [2]Color{
            Color{ .foreground = ForegroundColor.default },
            Color{ .background = BackgroundColor.default },
        }, .style = std.bit_set.StaticBitSet(@typeInfo(Style).Enum.fields.len).initEmpty() };
    }

    /// Deinitializes an instance of the `ColorPrint` struct, releasing any allocated resources.
    ///
    /// This method is responsible for properly cleaning up the memory associated with the `ColorPrint` instance,
    /// ensuring that no memory leaks occur.
    ///
    /// Parameters:
    ///   - self: A pointer to the `ColorPrint` instance to be deinitialized.
    ///
    /// Note:
    ///   - After calling this method, the `ColorPrint` instance becomes invalid and should not be used.
    pub fn deinit(self: *ColorPrint) void {
        // Deinitialize the memory allocator to release allocated resources.
        self.alloc.deinit();

        // Set the entire `ColorPrint` struct to undefined to indicate that it's no longer valid.
        self.* = undefined;
    }

    /// Adds a color or style attribute to the `ColorPrint` configuration.
    ///
    /// This method allows adding color or style attributes to the `ColorPrint` configuration.
    /// It checks the type of the provided attribute at compile time to ensure correctness.
    ///
    /// Parameters:
    ///   - self: A pointer to the `ColorPrint` instance to which the attribute will be added.
    ///   - attr: The attribute to be added, which can be either a color or a style.
    ///
    /// Errors:
    ///   - If the provided attribute is not a struct or a tuple, a compile-time error is raised.
    ///   - If the provided attribute is not a recognized color or style, a compile-time error is raised.
    pub fn add(self: *ColorPrint, comptime attr: anytype) void {
        // Determine the type information of the provided attribute at compile time.
        const t_info_attr = @typeInfo(@TypeOf(attr));

        // Ensure that the provided attribute is a struct or a tuple.
        if (t_info_attr != .Struct) @compileError("Unaccepted parameter.");
        if (!t_info_attr.Struct.is_tuple) @compileError("Unaccepted parameter.");

        // Process each attribute provided in the tuple.
        inline for (attr) |attribute| {
            // Check the type of the attribute.
            switch (@TypeOf(attribute)) {
                // Handle color attributes.
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
                // Handle style attribute.
                Style => self.style.set(@intFromEnum(attribute)),
                // Raise a compile-time error for unaccepted parameters.
                else => @compileError("Unaccepted parameter."),
            }
        }
    }

    test "Add foreground and background color and a style" {
        const alloc = testing.allocator;

        var expected = ColorPrint{
            .alloc = std.heap.ArenaAllocator.init(alloc),
            .color = [2]Color{
                Color{ .foreground = ForegroundColor.cyan },
                Color{ .background = BackgroundColor.yellow },
            },
            .style = std.bit_set.StaticBitSet(@typeInfo(Style).Enum.fields.len).initEmpty(),
        };

        expected.style.set(@intFromEnum(Style.bold));

        var actual = ColorPrint.init(alloc);
        defer actual.deinit();

        actual.add(.{ Color{ .foreground = ForegroundColor.cyan }, Color{ .background = BackgroundColor.yellow }, Style.bold });

        try testing.expectEqual(expected, actual);
    }

    /// Resets the `ColorPrint` configuration to default values for colors and style.
    ///
    /// This method resets both foreground and background colors to their default values,
    /// and clears any existing text styling, setting it to null.
    ///
    /// Parameters:
    ///   - self: A pointer to the `ColorPrint` instance to be reset.
    ///
    /// Note:
    ///   - After calling this method, the `ColorPrint` instance will have its colors reset to defaults
    ///     and any existing style will be cleared.
    pub fn defaultEverything(self: *ColorPrint) void {
        self.color = [2]Color{
            Color{ .foreground = ForegroundColor.default },
            Color{ .background = BackgroundColor.default },
        };
        self.style = std.bit_set.StaticBitSet(@typeInfo(Style).Enum.fields.len).initEmpty();
    }

    test "Unset everything" {
        const alloc = testing.allocator;

        const expected = ColorPrint{
            .alloc = std.heap.ArenaAllocator.init(alloc),
            .color = [2]Color{
                Color{ .foreground = ForegroundColor.default },
                Color{ .background = BackgroundColor.default },
            },
            .style = std.bit_set.StaticBitSet(@typeInfo(Style).Enum.fields.len).initEmpty(),
        };

        var actual = ColorPrint.init(alloc);
        defer actual.deinit();

        actual.add(.{ Color{ .foreground = ForegroundColor.green }, Color{ .background = BackgroundColor.cyan }, Style.italic });

        actual.defaultEverything();

        try testing.expectEqual(expected, actual);
    }

    /// Sets the default foreground color for the `ColorPrint` configuration.
    ///
    /// This method sets the foreground color of the `ColorPrint` configuration to its default value.
    /// The default foreground color is usually the terminal's default text color.
    ///
    /// Parameters:
    ///   - self: A pointer to the `ColorPrint` instance for which the foreground color will be set.
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
            .style = std.bit_set.StaticBitSet(@typeInfo(Style).Enum.fields.len).initEmpty(),
        };

        var actual = ColorPrint.init(alloc);
        defer actual.deinit();

        actual.add(.{Color{ .foreground = ForegroundColor.black }});

        actual.defaultForeground();

        try testing.expectEqual(expected, actual);
    }

    /// Sets the default background color for the `ColorPrint` configuration.
    ///
    /// This method sets the background color of the `ColorPrint` configuration to its default value.
    /// The default background color is usually the terminal's default background color.
    ///
    /// Parameters:
    ///   - self: A pointer to the `ColorPrint` instance for which the background color will be set.
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
            .style = std.bit_set.StaticBitSet(@typeInfo(Style).Enum.fields.len).initEmpty(),
        };

        var actual = ColorPrint.init(alloc);
        defer actual.deinit();

        actual.add(.{Color{ .background = BackgroundColor.magenta }});
        actual.defaultBackground();

        try testing.expectEqual(expected, actual);
    }

    /// Unsets the text style for the `ColorPrint` configuration.
    ///
    /// This method clears any existing text styling in the `ColorPrint` configuration,
    /// setting the text style to null.
    ///
    /// Parameters:
    ///   - self: A pointer to the `ColorPrint` instance for which the text style will be unset.
    pub fn unsetStyle(self: *ColorPrint) void {
        self.style = std.bit_set.StaticBitSet(@typeInfo(Style).Enum.fields.len).initEmpty();
    }

    test "Unset style" {
        const alloc = testing.allocator;

        var expected = ColorPrint{
            .alloc = std.heap.ArenaAllocator.init(alloc),
            .color = [2]Color{
                Color{ .foreground = ForegroundColor.default },
                Color{ .background = BackgroundColor.default },
            },
            .style = std.bit_set.StaticBitSet(@typeInfo(Style).Enum.fields.len).initEmpty(),
        };

        var actual = ColorPrint.init(alloc);
        defer actual.deinit();

        actual.add(.{Style.underline});
        actual.unsetStyle();
        try testing.expectEqual(expected, actual);
    }

    /// Prints a string with color and style settings applied according to the `ColorPrint` configuration.
    ///
    /// This method prints the provided string to the standard output (stdout) with color and style settings
    /// applied based on the current configuration of the `ColorPrint` instance.
    ///
    /// Parameters:
    ///   - self: A pointer to the `ColorPrint` instance containing the color and style settings to be applied.
    ///   - str: The string to be printed.
    ///
    /// Returns:
    ///   - An error if printing fails due to any reason.
    ///
    /// Note:
    ///   - This method uses ANSI escape codes to apply color and style settings to the printed string.
    pub fn print(self: *ColorPrint, str: []const u8) !void {
        const stdout = std.io.getStdOut().writer();

        // Parse colors.
        try stdout.print("{s}{s}{s}", .{ try self.parse(), str, try self.reset() });
    }

    /// Parses the ANSI escape codes for color and style settings based on the `ColorPrint` configuration.
    ///
    /// This method parses the ANSI escape codes for color and style settings according to the current configuration
    /// of the `ColorPrint` instance. It constructs the ANSI escape sequences required to apply the configured
    /// foreground and background colors, as well as any specified text styling.
    ///
    /// Returns:
    ///   - A string containing the ANSI escape codes for the configured color and style settings.
    ///   - An error indicating a color type mismatch if the foreground or background color type is incorrect.
    fn parse(self: *ColorPrint) ![]const u8 {
        // Construct the ANSI escape sequence for the configured foreground and background colors.
        const parsed_color: ?[]const u8 = blk: {
            var foreground: ?[]const u8 = null;
            var background: ?[]const u8 = null;

            for (self.color) |color| {
                if (std.mem.eql(u8, @tagName(color), "foreground")) {
                    foreground = try std.fmt.allocPrint(self.alloc.allocator(), "{s}[{d}", .{ esc_char, @intFromEnum(color.foreground) });
                }
                if (std.mem.eql(u8, @tagName(color), "background")) background = try std.fmt.allocPrint(self.alloc.allocator(), ";{d}", .{@intFromEnum(color.background)});
                if (std.mem.eql(u8, @tagName(color), "rgb")) {
                    if (std.mem.eql(u8, @tagName(color.rgb.t), "foreground")) foreground = try std.fmt.allocPrint(self.alloc.allocator(), "{s}[{d};{d};{d};{d};{d}", .{ esc_char, @intFromEnum(ForegroundColor.rgb), 2, color.rgb.r, color.rgb.g, color.rgb.b });
                    if (std.mem.eql(u8, @tagName(color.rgb.t), "background")) background = try std.fmt.allocPrint(self.alloc.allocator(), ";{d};{d};{d};{d};{d}", .{ @intFromEnum(BackgroundColor.rgb), 2, color.rgb.r, color.rgb.g, color.rgb.b });
                }
            }

            if (foreground == null or background == null) break :blk null;

            break :blk try std.fmt.allocPrint(self.alloc.allocator(), "{s}{s}", .{ foreground.?, background.? });
        };

        if (parsed_color == null) return error.ColorError;

        // Construct the ANSI escape sequence for the configured text style.
        const parsed_style: []const u8 = blk: {
            var all_styles_bits = self.style.iterator(.{});
            var p_styles: []const u8 = "";

            while (all_styles_bits.next()) |style_bit| {
                p_styles = try std.fmt.allocPrint(self.alloc.allocator(), "{s};{d}", .{ p_styles, style_bit });
            }

            break :blk try std.fmt.allocPrint(self.alloc.allocator(), "{s}m", .{p_styles});
        };

        // Combine the color and style ANSI escape sequences to form the final ANSI escape codes.
        return try std.fmt.allocPrint(self.alloc.allocator(), "{s}{s}", .{ parsed_color.?, parsed_style });
    }

    test "Parse a string with colors" {
        const expected: []const u8 = esc_char ++ "[30;41m";

        const alloc = testing.allocator;
        var cp = ColorPrint.init(alloc);
        defer cp.deinit();

        cp.add(.{ Color{ .foreground = ForegroundColor.black }, Color{ .background = BackgroundColor.red } });

        const actual = try cp.parse();

        try testing.expectEqualStrings(expected, actual);
    }

    test "Parse a string with colors and 4 styles" {
        const expected: []const u8 = esc_char ++ "[30;41;2;4;7;9m";

        const alloc = testing.allocator;
        var cp = ColorPrint.init(alloc);
        defer cp.deinit();

        cp.add(.{ Color{ .foreground = ForegroundColor.black }, Color{ .background = BackgroundColor.red }, Style.underline, Style.cross_out, Style.reverse_video, Style.faint });

        const actual = try cp.parse();

        try testing.expectEqualStrings(expected, actual);
    }

    test "Parse a string with the two color of the same type" {
        const expected = error.ColorError;

        const alloc = testing.allocator;
        var cp = ColorPrint.init(alloc);
        defer cp.deinit();

        cp.color[0] = Color{ .foreground = ForegroundColor.white };
        cp.color[1] = Color{ .foreground = ForegroundColor.red };

        const actual = cp.parse();

        try testing.expectError(expected, actual);
    }

    test "Parse a string with RGB colors" {
        const expected: []const u8 = esc_char ++ "[38;2;255;255;255;48;2;0;0;0m";

        const alloc = testing.allocator;
        var cp = ColorPrint.init(alloc);
        defer cp.deinit();

        cp.add(.{ Color{ .rgb = RGB{ .r = 255, .g = 255, .b = 255, .t = ColorType.foreground } }, Color{ .rgb = RGB{ .r = 0, .g = 0, .b = 0, .t = ColorType.background } } });

        const actual = try cp.parse();

        try testing.expectEqualStrings(expected, actual);
    }

    test "Parse a string with RGB colors and 3 styles" {
        const expected: []const u8 = esc_char ++ "[38;2;255;255;255;48;2;0;0;0;1;3;6m";

        const alloc = testing.allocator;
        var cp = ColorPrint.init(alloc);
        defer cp.deinit();

        cp.add(.{ Color{ .rgb = RGB{ .r = 255, .g = 255, .b = 255, .t = ColorType.foreground } }, Color{ .rgb = RGB{ .r = 0, .g = 0, .b = 0, .t = ColorType.background } }, Style.italic, Style.bold, Style.rapid_blink });

        const actual = try cp.parse();

        try testing.expectEqualStrings(expected, actual);
    }

    test "Parse a string with the two color of the same type (RGB)" {
        const expected = error.ColorError;

        const alloc = testing.allocator;
        var cp = ColorPrint.init(alloc);
        defer cp.deinit();

        cp.color[0] = Color{ .rgb = RGB{ .r = 127, .g = 187, .b = 179, .t = ColorType.foreground } };
        cp.color[1] = Color{ .rgb = RGB{ .r = 167, .g = 192, .b = 128, .t = ColorType.foreground } };

        const actual = cp.parse();

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
        var cp = ColorPrint.init(alloc);
        defer cp.deinit();

        const actual = try cp.reset();

        try testing.expectEqualStrings(expected, actual);
    }

    /// Applies black foreground color to the provided string and prints it.
    ///
    /// This method sets the foreground color of the `ColorPrint` configuration to black and prints
    /// the provided string with the black foreground color applied.
    ///
    /// Parameters:
    ///   - self: A pointer to the `ColorPrint` instance for which the black foreground color will be applied.
    ///   - str: The string to be printed with the black foreground color applied.
    ///
    /// Returns:
    ///   - An error if printing fails due to any reason.
    pub fn black(self: *ColorPrint, str: []const u8) !void {
        // Reset the configuration to default values and set black foreground color.
        self.defaultEverything();
        self.add(.{Color{ .foreground = ForegroundColor.black }});

        // Print the string with the black foreground color applied.
        return try self.print(str);
    }

    /// Applies red foreground color to the provided string and prints it.
    ///
    /// This method sets the foreground color of the `ColorPrint` configuration to red and prints
    /// the provided string with the red foreground color applied.
    ///
    /// Parameters:
    ///   - self: A pointer to the `ColorPrint` instance for which the red foreground color will be applied.
    ///   - str: The string to be printed with the red foreground color applied.
    ///
    /// Returns:
    ///   - An error if printing fails due to any reason.
    pub fn red(self: *ColorPrint, str: []const u8) !void {
        // Reset the configuration to default values and set red foreground color.
        self.defaultEverything();
        self.add(.{Color{ .foreground = ForegroundColor.red }});

        // Print the string with the red foreground color applied.
        return try self.print(str);
    }

    /// Applies green foreground color to the provided string and prints it.
    ///
    /// This method sets the foreground color of the `ColorPrint` configuration to green and prints
    /// the provided string with the green foreground color applied.
    ///
    /// Parameters:
    ///   - self: A pointer to the `ColorPrint` instance for which the green foreground color will be applied.
    ///   - str: The string to be printed with the green foreground color applied.
    ///
    /// Returns:
    ///   - An error if printing fails due to any reason.
    pub fn green(self: *ColorPrint, str: []const u8) !void {
        // Reset the configuration to default values and set green foreground color.
        self.defaultEverything();
        self.add(.{Color{ .foreground = ForegroundColor.green }});

        // Print the string with the green foreground color applied.
        return try self.print(str);
    }

    /// Applies yellow foreground color to the provided string and prints it.
    ///
    /// This method sets the foreground color of the `ColorPrint` configuration to yellow and prints
    /// the provided string with the yellow foreground color applied.
    ///
    /// Parameters:
    ///   - self: A pointer to the `ColorPrint` instance for which the yellow foreground color will be applied.
    ///   - str: The string to be printed with the yellow foreground color applied.
    ///
    /// Returns:
    ///   - An error if printing fails due to any reason.
    pub fn yellow(self: *ColorPrint, str: []const u8) !void {
        // Reset the configuration to default values and set yellow foreground color.
        self.defaultEverything();
        self.add(.{Color{ .foreground = ForegroundColor.yellow }});

        // Print the string with the yellow foreground color applied.
        return try self.print(str);
    }

    /// Applies blue foreground color to the provided string and prints it.
    ///
    /// This method sets the foreground color of the `ColorPrint` configuration to blue and prints
    /// the provided string with the blue foreground color applied.
    ///
    /// Parameters:
    ///   - self: A pointer to the `ColorPrint` instance for which the blue foreground color will be applied.
    ///   - str: The string to be printed with the blue foreground color applied.
    ///
    /// Returns:
    ///   - An error if printing fails due to any reason.
    pub fn blue(self: *ColorPrint, str: []const u8) !void {
        // Reset the configuration to default values and set blue foreground color.
        self.defaultEverything();
        self.add(.{Color{ .foreground = ForegroundColor.blue }});

        // Print the string with the blue foreground color applied.
        return try self.print(str);
    }

    /// Applies magenta foreground color to the provided string and prints it.
    ///
    /// This method sets the foreground color of the `ColorPrint` configuration to magenta and prints
    /// the provided string with the magenta foreground color applied.
    ///
    /// Parameters:
    ///   - self: A pointer to the `ColorPrint` instance for which the magenta foreground color will be applied.
    ///   - str: The string to be printed with the magenta foreground color applied.
    ///
    /// Returns:
    ///   - An error if printing fails due to any reason.
    pub fn magenta(self: *ColorPrint, str: []const u8) !void {
        // Reset the configuration to default values and set magenta foreground color.
        self.defaultEverything();
        self.add(.{Color{ .foreground = ForegroundColor.magenta }});

        // Print the string with the magenta foreground color applied.
        return try self.print(str);
    }

    /// Applies cyan foreground color to the provided string and prints it.
    ///
    /// This method sets the foreground color of the `ColorPrint` configuration to cyan and prints
    /// the provided string with the cyan foreground color applied.
    ///
    /// Parameters:
    ///   - self: A pointer to the `ColorPrint` instance for which the cyan foreground color will be applied.
    ///   - str: The string to be printed with the cyan foreground color applied.
    ///
    /// Returns:
    ///   - An error if printing fails due to any reason.
    pub fn cyan(self: *ColorPrint, str: []const u8) !void {
        // Reset the configuration to default values and set cyan foreground color.
        self.defaultEverything();
        self.add(.{Color{ .foreground = ForegroundColor.cyan }});

        // Print the string with the cyan foreground color applied.
        return try self.print(str);
    }

    /// Applies white foreground color to the provided string and prints it.
    ///
    /// This method sets the foreground color of the `ColorPrint` configuration to white and prints
    /// the provided string with the white foreground color applied.
    ///
    /// Parameters:
    ///   - self: A pointer to the `ColorPrint` instance for which the white foreground color will be applied.
    ///   - str: The string to be printed with the white foreground color applied.
    ///
    /// Returns:
    ///   - An error if printing fails due to any reason.
    pub fn white(self: *ColorPrint, str: []const u8) !void {
        // Reset the configuration to default values and set white foreground color.
        self.defaultEverything();
        self.add(.{Color{ .foreground = ForegroundColor.white }});

        // Print the string with the white foreground color applied.
        return try self.print(str);
    }

    /// Applies default foreground color to the provided string and prints it.
    ///
    /// This method sets the foreground color of the `ColorPrint` configuration to default and prints
    /// the provided string with the default foreground color applied.
    ///
    /// Parameters:
    ///   - self: A pointer to the `ColorPrint` instance for which the default foreground color will be applied.
    ///   - str: The string to be printed with the default foreground color applied.
    ///
    /// Returns:
    ///   - An error if printing fails due to any reason.
    pub fn default(self: *ColorPrint, str: []const u8) !void {
        // Reset the configuration to default values.
        self.defaultEverything();

        // Print the string with the default foreground color applied.
        return try self.print(str);
    }

    /// Applies color and style settings to the provided string.
    ///
    /// This method applies the color and style settings configured in the `ColorPrint` instance to the provided string.
    /// It constructs the ANSI escape codes required to apply the configured colors and style settings to the string.
    ///
    /// Parameters:
    ///   - self: A pointer to the `ColorPrint` instance containing the color and style settings to be applied.
    ///   - str: The string to which the color and style settings will be applied.
    ///
    /// Returns:
    ///   - A string containing the ANSI escape codes applied to the provided string.
    ///   - An error if formatting fails due to any reason.
    pub fn colorize(self: *ColorPrint, str: []const u8) ![]const u8 {
        // Construct the ANSI escape codes for the configured color and style settings.
        const fmt = try std.fmt.allocPrint(self.alloc.allocator(), "{s}{s}{s}", .{ try self.parse(), str, try self.reset() });
        return fmt;
    }

    test "Colorize a string" {
        const expected: []const u8 = esc_char ++ "[35;47;9m" ++ "Colorize Me!" ++ esc_char ++ "[0m";

        const alloc = testing.allocator;
        var cp = ColorPrint.init(alloc);
        defer cp.deinit();

        cp.add(.{ Color{ .foreground = ForegroundColor.magenta }, Color{ .background = BackgroundColor.white }, Style.cross_out });

        const actual = try cp.colorize("Colorize Me!");

        try testing.expectEqualStrings(expected, actual);
    }

    /// Applies the color and style settings configured in the `ColorPrint` instance to the standard output.
    ///
    /// This method applies the color and style settings configured in the `ColorPrint` instance to the standard output.
    /// It constructs the ANSI escape codes required to apply the configured colors and style settings and prints them
    /// to the standard output.
    ///
    /// Parameters:
    ///   - self: A pointer to the `ColorPrint` instance containing the color and style settings to be applied.
    ///
    /// Returns:
    ///   - An error if printing fails due to any reason.
    pub fn set(self: *ColorPrint) !void {
        const stdout = std.io.getStdOut().writer();
        try stdout.print("{s}", .{try self.parse()});
    }

    /// Resets the color and style settings configured in the `ColorPrint` instance to default standard output values.
    ///
    /// This method resets the color and style settings configured in the `ColorPrint` instance to their default values
    /// and prints the ANSI escape codes required to reset the colors and styles to the standard output.
    ///
    /// Parameters:
    ///   - self: A pointer to the `ColorPrint` instance for which the color and style settings will be reset.
    ///
    /// Returns:
    ///   - An error if printing fails due to any reason.
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
