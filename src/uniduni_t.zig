//! Uniduni_t is a library used for managing and applying terminal text attributes such as colors and styles.
//! It allows combining multiple attributes (like foreground and background colors, and text styles) into a single
//! ANSI escape sequence that can be applied to text in terminal output.
const std = @import("std");
const testing = std.testing;

// Import of attributes.zig It contains the structure for colors and styles.
const attr = @import("attributes.zig");
const Style = attr.Style;
const Color = attr.Color;

/// Structure that stores color level information and start and end attribute strings.
///
/// Fields:
/// - level: defines the color level (e.g.: truecolor).
/// - start: stores the beginning part of the ANSI escape sequence.
/// - end: stores the ending part of the ANSI escape sequence (resets formatting).
pub const Uniduni_t = struct {
    level: Color.Level,
    start: []const u8 = "",
    end: []const u8 = attr.esc_char ++ "0m",

    /// Initializes a Uniduni_t instance.
    pub inline fn init() Uniduni_t {
        comptime return .{
            .level = .truecolor,
        };
    }

    /// Adds one or more attributes (color or style) to a Uniduni_t instance.
    ///
    /// Parameters:
    /// - attribute: a tuple of attributes to be added.
    ///
    /// Returns a Uniduni_t struct instance with the attribute added.
    pub inline fn add(self: Uniduni_t, comptime attribute: anytype) Uniduni_t {
        const t_info_attr = @typeInfo(@TypeOf(attribute));
        if (t_info_attr != .Struct) @compileError("the 'attribute' parameter must be a tuple.");
        if (!t_info_attr.Struct.is_tuple) @compileError("the 'attribute' parameter must be a tuple.");

        comptime var uni: Uniduni_t = .{
            .level = self.level,
        };

        inline for (attribute) |value| {
            switch (@TypeOf(value)) {
                Color.Hex, Color.RGB, Color.Foreground, Color.Background, Style => {
                    const parsed_code = parse(value);
                    uni.start = uni.start ++ parsed_code;
                },
                else => @compileError("the 'attribute' tupple must contain valid colors."),
            }
        }

        return uni;
    }

    test "Add colors and a styles" {
        var expected = Uniduni_t{
            .level = .truecolor,
            .start = "\x1b[31m\x1b[1m",
        };
        var actual = Uniduni_t.init().add(.{ Color.Foreground.red, Style.bold });
        try testing.expectEqualDeep(expected, actual);

        expected.start = "\x1b[101m\x1b[3m";
        actual = Uniduni_t.init().add(.{ Color.Background.bright_red, Style.italic });
        try testing.expectEqualDeep(expected.start, actual.start);

        expected.start = "\x1b[30m\x1b[1m\x1b[3m";
        actual = Uniduni_t.init().add(.{ Color.Foreground.black, Style.bold, Style.italic });
        try testing.expectEqualDeep(expected, actual);
    }

    /// Converts a color or style attribute into an ANSI escape code string.
    ///
    /// Parameter:
    /// - attribute: the color or style attribute to be parsed.
    ///
    /// Returns the corresponding ANSI code string.
    inline fn parse(comptime attribute: anytype) []const u8 {
        switch (@TypeOf(attribute)) {
            Color.Foreground, Color.Background, Style => return std.fmt.comptimePrint("{s}{d}m", .{ attr.esc_char, @intFromEnum(attribute) }),
            Color.RGB => {
                return std.fmt.comptimePrint("{s}{d};2;{d};{d};{d}m", .{ attr.esc_char, @intFromEnum(attribute.t), attribute.r, attribute.g, attribute.b });
            },
            Color.Hex => {
                const hex_code: []const u8 = if (attribute.code[0] == '#') attribute.code[1..] else attribute.code;
                const hex_to_dec: u32 = comptime std.fmt.parseInt(u32, hex_code, 16) catch @compileError("error parsing hex code " ++ hex_code);

                return parse(Color.RGB{
                    .r = hex_to_dec >> 16,
                    .g = (hex_to_dec >> 8) & 0xFF,
                    .b = hex_to_dec & 0xFF,
                    .t = if (attribute.t == .foreground) .foreground else .background,
                });
            },
            else => @compileError("the 'attribute' must be one of the following types: Color.Foreground, Color.Background, Color.RGB, Color.Hex or Style."),
        }
    }

    test "Parse a string with colors" {
        const expected = attr.esc_char ++ "37m";
        const actual = parse(Color.Foreground.white);
        try testing.expectEqualStrings(expected, actual);
    }

    test "Parse a string with RGB foreground color" {
        const expected = attr.esc_char ++ "38;2;35;78;102m";
        const actual = parse(Color.RGB.fg(35, 78, 102));
        try testing.expectEqualStrings(expected, actual);
    }

    test "Parse a string with RGB background color" {
        const expected = attr.esc_char ++ "48;2;35;78;102m";
        const actual = parse(Color.RGB.bg(35, 78, 102));
        try testing.expectEqualStrings(expected, actual);
    }

    test "Parse a string with hex colors" {
        var expected = attr.esc_char ++ "38;2;171;8;15m";
        var actual = parse(Color.Hex.fg("#ab080f"));
        try testing.expectEqualStrings(expected, actual);

        actual = parse(Color.Hex.fg("AB080F"));
        try testing.expectEqualStrings(expected, actual);

        expected = attr.esc_char ++ "48;2;171;8;15m";
        actual = parse(Color.Hex.bg("#ab080f"));
        try testing.expectEqualStrings(expected, actual);

        actual = parse(Color.Hex.bg("AB080F"));
        try testing.expectEqualStrings(expected, actual);
    }

    /// Adds black color.
    ///
    /// Parameter:
    /// - t: the color type (.foreground or .background).
    ///
    /// Returns a Uniduni_t struct instance with the color added.
    pub inline fn black(self: Uniduni_t, t: Color.Type) Uniduni_t {
        const parsed_code = if (t == .foreground) parse(@field(Color.Foreground, @src().fn_name)) else parse(@field(Color.Background, @src().fn_name));
        comptime return .{
            .level = self.level,
            .start = self.start ++ parsed_code,
        };
    }

    test "Black color function" {
        var expected = Uniduni_t{
            .level = Color.Level.truecolor,
            .start = "\x1b[30m",
        };
        var actual = Uniduni_t.init().black(.foreground);
        try testing.expectEqualDeep(expected, actual);

        expected.start = "\x1b[40m";
        actual = Uniduni_t.init().black(.background);
        try testing.expectEqualDeep(expected, actual);
    }

    /// Adds red color.
    ///
    /// Parameter:
    /// - t: the color type (.foreground or .background).
    ///
    ///Returns a Uniduni_t struct instance with the color added.
    pub inline fn red(self: Uniduni_t, t: Color.Type) Uniduni_t {
        const parsed_code = if (t == .foreground) parse(@field(Color.Foreground, @src().fn_name)) else parse(@field(Color.Background, @src().fn_name));
        comptime return .{
            .level = self.level,
            .start = self.start ++ parsed_code,
        };
    }

    test "Red color function" {
        var expected = Uniduni_t{
            .level = Color.Level.truecolor,
            .start = "\x1b[31m",
        };
        var actual = Uniduni_t.init().red(.foreground);
        try testing.expectEqualDeep(expected, actual);

        expected.start = "\x1b[41m";
        actual = Uniduni_t.init().red(.background);
        try testing.expectEqualDeep(expected, actual);
    }

    /// Adds green color.
    ///
    /// Parameter:
    /// - t: the color type (.foreground or .background).
    ///
    ///Returns a Uniduni_t struct instance with the color added.
    pub inline fn green(self: Uniduni_t, t: Color.Type) Uniduni_t {
        const parsed_code = if (t == .foreground) parse(@field(Color.Foreground, @src().fn_name)) else parse(@field(Color.Background, @src().fn_name));
        comptime return .{
            .level = self.level,
            .start = self.start ++ parsed_code,
        };
    }

    test "Green color function" {
        var expected = Uniduni_t{
            .level = Color.Level.truecolor,
            .start = "\x1b[32m",
        };
        var actual = Uniduni_t.init().green(.foreground);
        try testing.expectEqualDeep(expected, actual);

        expected.start = "\x1b[42m";
        actual = Uniduni_t.init().green(.background);
        try testing.expectEqualDeep(expected, actual);
    }

    /// Adds yellow color.
    ///
    /// Parameter:
    /// - t: the color type (.foreground or .background).
    ///
    ///Returns a Uniduni_t struct instance with the color added.
    pub inline fn yellow(self: Uniduni_t, t: Color.Type) Uniduni_t {
        const parsed_code = if (t == .foreground) parse(@field(Color.Foreground, @src().fn_name)) else parse(@field(Color.Background, @src().fn_name));
        comptime return .{
            .level = self.level,
            .start = self.start ++ parsed_code,
        };
    }

    test "Yellow color function" {
        var expected = Uniduni_t{
            .level = Color.Level.truecolor,
            .start = "\x1b[33m",
        };
        var actual = Uniduni_t.init().yellow(.foreground);
        try testing.expectEqualDeep(expected, actual);

        expected.start = "\x1b[43m";
        actual = Uniduni_t.init().yellow(.background);
        try testing.expectEqualDeep(expected, actual);
    }

    /// Adds blue color.
    ///
    /// Parameter:
    /// - t: the color type (.foreground or .background).
    ///
    ///Returns a Uniduni_t struct instance with the color added.
    pub inline fn blue(self: Uniduni_t, t: Color.Type) Uniduni_t {
        const parsed_code = if (t == .foreground) parse(@field(Color.Foreground, @src().fn_name)) else parse(@field(Color.Background, @src().fn_name));
        comptime return .{
            .level = self.level,
            .start = self.start ++ parsed_code,
        };
    }

    test "Blue color function" {
        var expected = Uniduni_t{
            .level = Color.Level.truecolor,
            .start = "\x1b[34m",
        };
        var actual = Uniduni_t.init().blue(.foreground);
        try testing.expectEqualDeep(expected, actual);

        expected.start = "\x1b[44m";
        actual = Uniduni_t.init().blue(.background);
        try testing.expectEqualDeep(expected, actual);
    }

    /// Adds magenta color.
    ///
    /// Parameter:
    /// - t: the color type (.foreground or .background).
    ///
    ///Returns a Uniduni_t struct instance with the color added.
    pub inline fn magenta(self: Uniduni_t, t: Color.Type) Uniduni_t {
        const parsed_code = if (t == .foreground) parse(@field(Color.Foreground, @src().fn_name)) else parse(@field(Color.Background, @src().fn_name));
        comptime return .{
            .level = self.level,
            .start = self.start ++ parsed_code,
        };
    }

    test "Magenta color function" {
        var expected = Uniduni_t{
            .level = Color.Level.truecolor,
            .start = "\x1b[35m",
        };
        var actual = Uniduni_t.init().magenta(.foreground);
        try testing.expectEqualDeep(expected, actual);

        expected.start = "\x1b[45m";
        actual = Uniduni_t.init().magenta(.background);
        try testing.expectEqualDeep(expected, actual);
    }

    /// Adds cyan color.
    ///
    /// Parameter:
    /// - t: the color type (.foreground or .background).
    ///
    ///Returns a Uniduni_t struct instance with the color added.
    pub inline fn cyan(self: Uniduni_t, t: Color.Type) Uniduni_t {
        const parsed_code = if (t == .foreground) parse(@field(Color.Foreground, @src().fn_name)) else parse(@field(Color.Background, @src().fn_name));
        comptime return .{
            .level = self.level,
            .start = self.start ++ parsed_code,
        };
    }

    test "Cyan color function" {
        var expected = Uniduni_t{
            .level = Color.Level.truecolor,
            .start = "\x1b[36m",
        };
        var actual = Uniduni_t.init().cyan(.foreground);
        try testing.expectEqualDeep(expected, actual);

        expected.start = "\x1b[46m";
        actual = Uniduni_t.init().cyan(.background);
        try testing.expectEqualDeep(expected, actual);
    }

    /// Adds white color.
    ///
    /// Parameter:
    /// - t: the color type (.foreground or .background).
    ///
    ///Returns a Uniduni_t struct instance with the color added.
    pub inline fn white(self: Uniduni_t, t: Color.Type) Uniduni_t {
        const parsed_code = if (t == .foreground) parse(@field(Color.Foreground, @src().fn_name)) else parse(@field(Color.Background, @src().fn_name));
        comptime return .{
            .level = self.level,
            .start = self.start ++ parsed_code,
        };
    }

    test "White color function" {
        var expected = Uniduni_t{
            .level = Color.Level.truecolor,
            .start = "\x1b[37m",
        };
        var actual = Uniduni_t.init().white(.foreground);
        try testing.expectEqualDeep(expected, actual);

        expected.start = "\x1b[47m";
        actual = Uniduni_t.init().white(.background);
        try testing.expectEqualDeep(expected, actual);
    }

    /// Adds bright black color.
    ///
    /// Parameter:
    /// - t: the color type (.foreground or .background).
    ///
    ///Returns a Uniduni_t struct instance with the color added.
    pub inline fn brightBlack(self: Uniduni_t, t: Color.Type) Uniduni_t {
        const parsed_code = if (t == .foreground) parse(@field(Color.Foreground, "bright_black")) else parse(@field(Color.Background, "bright_black"));
        comptime return .{
            .level = self.level,
            .start = self.start ++ parsed_code,
        };
    }

    test "Bright black color function" {
        var expected = Uniduni_t{
            .level = Color.Level.truecolor,
            .start = "\x1b[90m",
        };
        var actual = Uniduni_t.init().brightBlack(.foreground);
        try testing.expectEqualDeep(expected, actual);

        expected.start = "\x1b[100m";
        actual = Uniduni_t.init().brightBlack(.background);
        try testing.expectEqualDeep(expected, actual);
    }

    /// Adds bright red color.
    ///
    /// Parameter:
    /// - t: the color type (.foreground or .background).
    ///
    ///Returns a Uniduni_t struct instance with the color added.
    pub inline fn brightRed(self: Uniduni_t, t: Color.Type) Uniduni_t {
        const parsed_code = if (t == .foreground) parse(@field(Color.Foreground, "bright_red")) else parse(@field(Color.Background, "bright_red"));
        comptime return .{
            .level = self.level,
            .start = self.start ++ parsed_code,
        };
    }

    test "Bright red color function" {
        var expected = Uniduni_t{
            .level = Color.Level.truecolor,
            .start = "\x1b[91m",
        };
        var actual = Uniduni_t.init().brightRed(.foreground);
        try testing.expectEqualDeep(expected, actual);

        expected.start = "\x1b[101m";
        actual = Uniduni_t.init().brightRed(.background);
        try testing.expectEqualDeep(expected, actual);
    }

    /// Adds bright green color.
    ///
    /// Parameter:
    /// - t: the color type (.foreground or .background).
    ///
    ///Returns a Uniduni_t struct instance with the color added.
    pub inline fn brightGreen(self: Uniduni_t, t: Color.Type) Uniduni_t {
        const parsed_code = if (t == .foreground) parse(@field(Color.Foreground, "bright_green")) else parse(@field(Color.Background, "bright_green"));
        comptime return .{
            .level = self.level,
            .start = self.start ++ parsed_code,
        };
    }

    test "Bright green color function" {
        var expected = Uniduni_t{
            .level = Color.Level.truecolor,
            .start = "\x1b[92m",
        };
        var actual = Uniduni_t.init().brightGreen(.foreground);
        try testing.expectEqualDeep(expected, actual);

        expected.start = "\x1b[102m";
        actual = Uniduni_t.init().brightGreen(.background);
        try testing.expectEqualDeep(expected, actual);
    }

    /// Adds bright yellow color.
    ///
    /// Parameter:
    /// - t: the color type (.foreground or .background).
    ///
    ///Returns a Uniduni_t struct instance with the color added.
    pub inline fn brightYellow(self: Uniduni_t, t: Color.Type) Uniduni_t {
        const parsed_code = if (t == .foreground) parse(@field(Color.Foreground, "bright_yellow")) else parse(@field(Color.Background, "bright_yellow"));
        comptime return .{
            .level = self.level,
            .start = self.start ++ parsed_code,
        };
    }

    test "Bright yellow color function" {
        var expected = Uniduni_t{
            .level = Color.Level.truecolor,
            .start = "\x1b[93m",
        };
        var actual = Uniduni_t.init().brightYellow(.foreground);
        try testing.expectEqualDeep(expected, actual);

        expected.start = "\x1b[103m";
        actual = Uniduni_t.init().brightYellow(.background);
        try testing.expectEqualDeep(expected, actual);
    }

    /// Adds bright blue color.
    ///
    /// Parameter:
    /// - t: the color type (.foreground or .background).
    ///
    ///Returns a Uniduni_t struct instance with the color added.
    pub inline fn brightBlue(self: Uniduni_t, t: Color.Type) Uniduni_t {
        const parsed_code = if (t == .foreground) parse(@field(Color.Foreground, "bright_blue")) else parse(@field(Color.Background, "bright_blue"));
        comptime return .{
            .level = self.level,
            .start = self.start ++ parsed_code,
        };
    }

    test "Bright blue color function" {
        var expected = Uniduni_t{
            .level = Color.Level.truecolor,
            .start = "\x1b[94m",
        };
        var actual = Uniduni_t.init().brightBlue(.foreground);
        try testing.expectEqualDeep(expected, actual);

        expected.start = "\x1b[104m";
        actual = Uniduni_t.init().brightBlue(.background);
        try testing.expectEqualDeep(expected, actual);
    }

    /// Adds bright magenta color.
    ///
    /// Parameter:
    /// - t: the color type (.foreground or .background).
    ///
    ///Returns a Uniduni_t struct instance with the color added.
    pub inline fn brightMagenta(self: Uniduni_t, t: Color.Type) Uniduni_t {
        const parsed_code = if (t == .foreground) parse(@field(Color.Foreground, "bright_magenta")) else parse(@field(Color.Background, "bright_magenta"));
        comptime return .{
            .level = self.level,
            .start = self.start ++ parsed_code,
        };
    }

    test "Bright magenta color function" {
        var expected = Uniduni_t{
            .level = Color.Level.truecolor,
            .start = "\x1b[95m",
        };
        var actual = Uniduni_t.init().brightMagenta(.foreground);
        try testing.expectEqualDeep(expected, actual);

        expected.start = "\x1b[105m";
        actual = Uniduni_t.init().brightMagenta(.background);
        try testing.expectEqualDeep(expected, actual);
    }

    /// Adds bright cyan color.
    ///
    /// Parameter:
    /// - t: the color type (.foreground or .background).
    ///
    ///Returns a Uniduni_t struct instance with the color added.
    pub inline fn brightCyan(self: Uniduni_t, t: Color.Type) Uniduni_t {
        const parsed_code = if (t == .foreground) parse(@field(Color.Foreground, "bright_cyan")) else parse(@field(Color.Background, "bright_cyan"));
        comptime return .{
            .level = self.level,
            .start = self.start ++ parsed_code,
        };
    }

    test "Bright cyan color function" {
        var expected = Uniduni_t{
            .level = Color.Level.truecolor,
            .start = "\x1b[96m",
        };
        var actual = Uniduni_t.init().brightCyan(.foreground);
        try testing.expectEqualDeep(expected, actual);

        expected.start = "\x1b[106m";
        actual = Uniduni_t.init().brightCyan(.background);
        try testing.expectEqualDeep(expected, actual);
    }

    /// Adds bright white color.
    ///
    /// Parameter:
    /// - t: the color type (.foreground or .background).
    ///
    ///Returns a Uniduni_t struct instance with the color added.
    pub inline fn brightWhite(self: Uniduni_t, t: Color.Type) Uniduni_t {
        const parsed_code = if (t == .foreground) parse(@field(Color.Foreground, "bright_white")) else parse(@field(Color.Background, "bright_white"));
        comptime return .{
            .level = self.level,
            .start = self.start ++ parsed_code,
        };
    }

    test "Bright white color function" {
        var expected = Uniduni_t{
            .level = Color.Level.truecolor,
            .start = "\x1b[97m",
        };
        var actual = Uniduni_t.init().brightWhite(.foreground);
        try testing.expectEqualDeep(expected, actual);

        expected.start = "\x1b[107m";
        actual = Uniduni_t.init().brightWhite(.background);
        try testing.expectEqualDeep(expected, actual);
    }

    /// Adds bold style.
    ///
    ///Returns a Uniduni_t struct instance with the style added.
    pub inline fn bold(self: Uniduni_t) Uniduni_t {
        const parsed_code = parse(@field(Style, @src().fn_name));
        comptime return .{
            .level = self.level,
            .start = self.start ++ parsed_code,
        };
    }

    test "Bold function" {
        const expected = Uniduni_t{
            .level = Color.Level.truecolor,
            .start = "\x1b[1m",
        };
        const actual = Uniduni_t.init().bold();
        try testing.expectEqualDeep(expected, actual);
    }

    /// Adds faint style.
    ///
    ///Returns a Uniduni_t struct instance with the style added.
    pub inline fn faint(self: Uniduni_t) Uniduni_t {
        const parsed_code = parse(@field(Style, @src().fn_name));
        comptime return .{
            .level = self.level,
            .start = self.start ++ parsed_code,
        };
    }

    test "Faint function" {
        const expected = Uniduni_t{
            .level = Color.Level.truecolor,
            .start = "\x1b[2m",
        };
        const actual = Uniduni_t.init().faint();
        try testing.expectEqualDeep(expected, actual);
    }

    /// Adds italic style.
    ///
    ///Returns a Uniduni_t struct instance with the style added.
    pub inline fn italic(self: Uniduni_t) Uniduni_t {
        const parsed_code = parse(@field(Style, @src().fn_name));
        comptime return .{
            .level = self.level,
            .start = self.start ++ parsed_code,
        };
    }

    test "Italic function" {
        const expected = Uniduni_t{
            .level = Color.Level.truecolor,
            .start = "\x1b[3m",
        };
        const actual = Uniduni_t.init().italic();
        try testing.expectEqualDeep(expected, actual);
    }

    /// Adds underline style.
    ///
    ///Returns a Uniduni_t struct instance with the style added.
    pub inline fn underline(self: Uniduni_t) Uniduni_t {
        const parsed_code = parse(@field(Style, @src().fn_name));
        comptime return .{
            .level = self.level,
            .start = self.start ++ parsed_code,
        };
    }

    test "Underline function" {
        const expected = Uniduni_t{
            .level = Color.Level.truecolor,
            .start = "\x1b[4m",
        };
        const actual = Uniduni_t.init().underline();
        try testing.expectEqualDeep(expected, actual);
    }

    /// Adds slow blinking style.
    ///
    ///Returns a Uniduni_t struct instance with the style added.
    pub inline fn slowBlink(self: Uniduni_t) Uniduni_t {
        const parsed_code = parse(@field(Style, @src().fn_name));
        comptime return .{
            .level = self.level,
            .start = self.start ++ parsed_code,
        };
    }

    test "Slow blink function" {
        const expected = Uniduni_t{
            .level = Color.Level.truecolor,
            .start = "\x1b[5m",
        };
        const actual = Uniduni_t.init().slowBlink();
        try testing.expectEqualDeep(expected, actual);
    }

    /// Adds rapid blinking style.
    ///
    ///Returns a Uniduni_t struct instance with the style added.
    pub inline fn rapidBlink(self: Uniduni_t) Uniduni_t {
        const parsed_code = parse(@field(Style, @src().fn_name));
        comptime return .{
            .level = self.level,
            .start = self.start ++ parsed_code,
        };
    }

    test "Rapid blink function" {
        const expected = Uniduni_t{
            .level = Color.Level.truecolor,
            .start = "\x1b[6m",
        };
        const actual = Uniduni_t.init().rapidBlink();
        try testing.expectEqualDeep(expected, actual);
    }

    /// Adds invert style.
    ///
    ///Returns a Uniduni_t struct instance with the style added.
    pub inline fn invert(self: Uniduni_t) Uniduni_t {
        const parsed_code = parse(@field(Style, @src().fn_name));
        comptime return .{
            .level = self.level,
            .start = self.start ++ parsed_code,
        };
    }

    test "Invert function" {
        const expected = Uniduni_t{
            .level = Color.Level.truecolor,
            .start = "\x1b[7m",
        };
        const actual = Uniduni_t.init().invert();
        try testing.expectEqualDeep(expected, actual);
    }

    /// Adds hide style.
    ///
    ///Returns a Uniduni_t struct instance with the style added.
    pub inline fn hide(self: Uniduni_t) Uniduni_t {
        const parsed_code = parse(@field(Style, @src().fn_name));
        comptime return .{
            .level = self.level,
            .start = self.start ++ parsed_code,
        };
    }

    test "Hide function" {
        const expected = Uniduni_t{
            .level = Color.Level.truecolor,
            .start = "\x1b[8m",
        };
        const actual = Uniduni_t.init().hide();
        try testing.expectEqualDeep(expected, actual);
    }

    /// Adds strike style.
    ///
    ///Returns a Uniduni_t struct instance with the style added.
    pub inline fn strike(self: Uniduni_t) Uniduni_t {
        const parsed_code = parse(@field(Style, @src().fn_name));
        comptime return .{
            .level = self.level,
            .start = self.start ++ parsed_code,
        };
    }

    test "Strike function" {
        const expected = Uniduni_t{
            .level = Color.Level.truecolor,
            .start = "\x1b[9m",
        };
        const actual = Uniduni_t.init().strike();
        try testing.expectEqualDeep(expected, actual);
    }

    /// Adds overline style.
    ///
    ///Returns a Uniduni_t struct instance with the style added.
    pub inline fn overline(self: Uniduni_t) Uniduni_t {
        const parsed_code = parse(@field(Style, @src().fn_name));
        comptime return .{
            .level = self.level,
            .start = self.start ++ parsed_code,
        };
    }

    test "Overline function" {
        const expected = Uniduni_t{
            .level = Color.Level.truecolor,
            .start = "\x1b[53m",
        };
        const actual = Uniduni_t.init().overline();
        try testing.expectEqualDeep(expected, actual);
    }

    /// Formats a passed string with the desired styles and colors.
    ///
    /// Parameter:
    /// - str: the string to be formated with the corresponding ANSI escape code.
    ///
    /// Returns the formatted string.
    pub inline fn format(self: Uniduni_t, comptime str: []const u8) []const u8 {
        return self.start ++ str ++ self.end;
    }

    test "Format a string with basic colors" {
        const expected: []const u8 = attr.esc_char ++ "30m" ++ "Black" ++ attr.esc_char ++ "0m";
        const actual: []const u8 = Uniduni_t.init().black(.foreground).format("Black");

        try testing.expectEqualStrings(expected, actual);
    }

    /// Converts RGB color values to their ANSI escape code representation.
    ///
    /// Parameters:
    /// - r: the red color component (0-255).
    /// - g: the green color component (0-255).
    /// - b: the blue color component (0-255).
    /// - t: the color type (.foreground or .background).
    ///
    /// Returns a Uniduni_t struct instance with the color added.
    pub inline fn rgb(self: Uniduni_t, r: u8, g: u8, b: u8, t: Color.Type) Uniduni_t {
        const parsed_code = parse(Color.RGB{
            .r = r,
            .g = g,
            .b = b,
            .t = t,
        });
        comptime return .{
            .level = self.level,
            .start = self.start ++ parsed_code,
        };
    }

    test "RGB function" {
        var expected = Uniduni_t{
            .level = Color.Level.truecolor,
            .start = "\x1b[38;2;255;255;255m",
        };
        var actual = Uniduni_t.init().rgb(255, 255, 255, Color.Type.foreground);
        try testing.expectEqualStrings(expected.start, actual.start);

        expected.start = "\x1b[48;2;255;255;255m";
        actual = Uniduni_t.init().rgb(255, 255, 255, Color.Type.background);
        try testing.expectEqualStrings(expected.start, actual.start);
    }

    /// Converts hexadecimal color codes to their ANSI escape code representation.
    ///
    /// Parameters:
    /// - code: the hexadecimal color code string (e.g., "#FF0000").
    /// - t: the color type (.foreground or .background).
    ///
    /// Returns a Uniduni_t struct instance with the color added.
    pub inline fn hex(self: Uniduni_t, code: []const u8, t: Color.Type) Uniduni_t {
        const parsed_code = parse(Color.Hex{
            .code = code,
            .t = t,
        });
        comptime return .{
            .level = self.level,
            .start = self.start ++ parsed_code,
        };
    }

    test "Hex function" {
        var expected = Uniduni_t{
            .level = Color.Level.truecolor,
            .start = "\x1b[38;2;255;255;255m",
        };
        var actual = Uniduni_t.init().hex("#ffffff", .foreground);
        try testing.expectEqualStrings(expected.start, actual.start);

        expected.start = "\x1b[48;2;255;255;255m";
        actual = Uniduni_t.init().hex("ffffff", .background);
        try testing.expectEqualStrings(expected.start, actual.start);
    }

    /// "Turns on" Uniduni_t setted colors and styles by printing them to stdout.
    /// These styles and colors will remain until turned off.
    pub inline fn on(self: Uniduni_t) !void {
        const stdout = std.io.getStdOut().writer();
        try stdout.print("{s}", .{self.start});
    }

    /// "Turns off" Uniduni_t setted colors and styles by printing the reset ANSI escape code to stdout.
    pub inline fn off(self: Uniduni_t) !void {
        const stdout = std.io.getStdOut().writer();
        try stdout.print("{s}", .{self.end});
    }
};

test "Initialization of an Uniduni_t struct" {
    const expected = Uniduni_t{
        .level = Color.Level.truecolor,
        .start = "",
        .end = "\x1b[0m",
    };
    const actual = Uniduni_t.init();
    try testing.expectEqualDeep(expected, actual);
}
