//! uni is a library used for managing and applying terminal text attributes such as colors and styles.
//! It allows combining multiple attributes (like foreground and background colors, and text styles) into a single
//! ANSI escape sequence that can be applied to text in terminal output.
const std = @import("std");
const testing = std.testing;

// Import of attributes.zig It contains the structure for colors and styles.
const attr = @import("attr.zig");
pub const Style = attr.Style;
pub const Color = attr.Color;

// This module
pub const uni = @This();

/// Fields:
/// - level: defines the color level (e.g.: truecolor).
/// - start: stores the beginning part of the ANSI escape sequence.
/// - end: stores the ending part of the ANSI escape sequence (resets formatting).
level: Color.Level,
start: []const u8 = "",
end: []const u8 = attr.esc_char ++ "0m",

/// Initializes a uni instance.
pub inline fn init() uni {
    comptime return .{
        .level = .truecolor,
    };
}

/// Adds one or more attributes (color or style) to a uni instance.
///
/// Parameters:
/// - attribute: a tuple of attributes to be added.
///
/// Returns a uni struct instance with the attribute added.
pub inline fn add(self: uni, comptime attribute: anytype) uni {
    const t_attr = @TypeOf(attribute);
    const t_info_attr = @typeInfo(t_attr);
    if (t_info_attr != .@"struct") @compileError("the 'attribute' parameter must be a tuple.");
    if (!t_info_attr.@"struct".is_tuple) @compileError("the 'attribute' parameter must be a tuple.");

    comptime var uni_t: uni = .{
        .level = self.level,
    };

    inline for (attribute) |value| {
        switch (@TypeOf(value)) {
            Color.Hex, Color.RGB, Color.Foreground, Color.Background, Style => {
                const parsed_code = parse(value);
                uni_t.start = uni_t.start ++ parsed_code;
            },
            else => @compileError("the 'attribute' tupple must contain valid colors."),
        }
    }

    return uni_t;
}

test "Add colors and a styles" {
    var expected = uni{
        .level = .truecolor,
        .start = "\x1b[31m\x1b[1m",
    };
    var actual = uni.init().add(.{ Color.Foreground.red, Style.bold });
    try testing.expectEqualDeep(expected, actual);

    expected.start = "\x1b[101m\x1b[3m";
    actual = uni.init().add(.{ Color.Background.bright_red, Style.italic });
    try testing.expectEqualDeep(expected.start, actual.start);

    expected.start = "\x1b[30m\x1b[1m\x1b[3m";
    actual = uni.init().add(.{ Color.Foreground.black, Style.bold, Style.italic });
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
/// Returns a uni struct instance with the color added.
pub inline fn black(self: uni, t: Color.Type) uni {
    const parsed_code = if (t == .foreground) parse(@field(Color.Foreground, @src().fn_name)) else parse(@field(Color.Background, @src().fn_name));
    comptime return .{
        .level = self.level,
        .start = self.start ++ parsed_code,
    };
}

test "Black color function" {
    var expected = uni{
        .level = Color.Level.truecolor,
        .start = "\x1b[30m",
    };
    var actual = uni.init().black(.foreground);
    try testing.expectEqualDeep(expected, actual);

    expected.start = "\x1b[40m";
    actual = uni.init().black(.background);
    try testing.expectEqualDeep(expected, actual);
}

/// Adds red color.
///
/// Parameter:
/// - t: the color type (.foreground or .background).
///
///Returns a uni struct instance with the color added.
pub inline fn red(self: uni, t: Color.Type) uni {
    const parsed_code = if (t == .foreground) parse(@field(Color.Foreground, @src().fn_name)) else parse(@field(Color.Background, @src().fn_name));
    comptime return .{
        .level = self.level,
        .start = self.start ++ parsed_code,
    };
}

test "Red color function" {
    var expected = uni{
        .level = Color.Level.truecolor,
        .start = "\x1b[31m",
    };
    var actual = uni.init().red(.foreground);
    try testing.expectEqualDeep(expected, actual);

    expected.start = "\x1b[41m";
    actual = uni.init().red(.background);
    try testing.expectEqualDeep(expected, actual);
}

/// Adds green color.
///
/// Parameter:
/// - t: the color type (.foreground or .background).
///
///Returns a uni struct instance with the color added.
pub inline fn green(self: uni, t: Color.Type) uni {
    const parsed_code = if (t == .foreground) parse(@field(Color.Foreground, @src().fn_name)) else parse(@field(Color.Background, @src().fn_name));
    comptime return .{
        .level = self.level,
        .start = self.start ++ parsed_code,
    };
}

test "Green color function" {
    var expected = uni{
        .level = Color.Level.truecolor,
        .start = "\x1b[32m",
    };
    var actual = uni.init().green(.foreground);
    try testing.expectEqualDeep(expected, actual);

    expected.start = "\x1b[42m";
    actual = uni.init().green(.background);
    try testing.expectEqualDeep(expected, actual);
}

/// Adds yellow color.
///
/// Parameter:
/// - t: the color type (.foreground or .background).
///
///Returns a uni struct instance with the color added.
pub inline fn yellow(self: uni, t: Color.Type) uni {
    const parsed_code = if (t == .foreground) parse(@field(Color.Foreground, @src().fn_name)) else parse(@field(Color.Background, @src().fn_name));
    comptime return .{
        .level = self.level,
        .start = self.start ++ parsed_code,
    };
}

test "Yellow color function" {
    var expected = uni{
        .level = Color.Level.truecolor,
        .start = "\x1b[33m",
    };
    var actual = uni.init().yellow(.foreground);
    try testing.expectEqualDeep(expected, actual);

    expected.start = "\x1b[43m";
    actual = uni.init().yellow(.background);
    try testing.expectEqualDeep(expected, actual);
}

/// Adds blue color.
///
/// Parameter:
/// - t: the color type (.foreground or .background).
///
///Returns a uni struct instance with the color added.
pub inline fn blue(self: uni, t: Color.Type) uni {
    const parsed_code = if (t == .foreground) parse(@field(Color.Foreground, @src().fn_name)) else parse(@field(Color.Background, @src().fn_name));
    comptime return .{
        .level = self.level,
        .start = self.start ++ parsed_code,
    };
}

test "Blue color function" {
    var expected = uni{
        .level = Color.Level.truecolor,
        .start = "\x1b[34m",
    };
    var actual = uni.init().blue(.foreground);
    try testing.expectEqualDeep(expected, actual);

    expected.start = "\x1b[44m";
    actual = uni.init().blue(.background);
    try testing.expectEqualDeep(expected, actual);
}

/// Adds magenta color.
///
/// Parameter:
/// - t: the color type (.foreground or .background).
///
///Returns a uni struct instance with the color added.
pub inline fn magenta(self: uni, t: Color.Type) uni {
    const parsed_code = if (t == .foreground) parse(@field(Color.Foreground, @src().fn_name)) else parse(@field(Color.Background, @src().fn_name));
    comptime return .{
        .level = self.level,
        .start = self.start ++ parsed_code,
    };
}

test "Magenta color function" {
    var expected = uni{
        .level = Color.Level.truecolor,
        .start = "\x1b[35m",
    };
    var actual = uni.init().magenta(.foreground);
    try testing.expectEqualDeep(expected, actual);

    expected.start = "\x1b[45m";
    actual = uni.init().magenta(.background);
    try testing.expectEqualDeep(expected, actual);
}

/// Adds cyan color.
///
/// Parameter:
/// - t: the color type (.foreground or .background).
///
///Returns a uni struct instance with the color added.
pub inline fn cyan(self: uni, t: Color.Type) uni {
    const parsed_code = if (t == .foreground) parse(@field(Color.Foreground, @src().fn_name)) else parse(@field(Color.Background, @src().fn_name));
    comptime return .{
        .level = self.level,
        .start = self.start ++ parsed_code,
    };
}

test "Cyan color function" {
    var expected = uni{
        .level = Color.Level.truecolor,
        .start = "\x1b[36m",
    };
    var actual = uni.init().cyan(.foreground);
    try testing.expectEqualDeep(expected, actual);

    expected.start = "\x1b[46m";
    actual = uni.init().cyan(.background);
    try testing.expectEqualDeep(expected, actual);
}

/// Adds white color.
///
/// Parameter:
/// - t: the color type (.foreground or .background).
///
///Returns a uni struct instance with the color added.
pub inline fn white(self: uni, t: Color.Type) uni {
    const parsed_code = if (t == .foreground) parse(@field(Color.Foreground, @src().fn_name)) else parse(@field(Color.Background, @src().fn_name));
    comptime return .{
        .level = self.level,
        .start = self.start ++ parsed_code,
    };
}

test "White color function" {
    var expected = uni{
        .level = Color.Level.truecolor,
        .start = "\x1b[37m",
    };
    var actual = uni.init().white(.foreground);
    try testing.expectEqualDeep(expected, actual);

    expected.start = "\x1b[47m";
    actual = uni.init().white(.background);
    try testing.expectEqualDeep(expected, actual);
}

/// Adds bright black color.
///
/// Parameter:
/// - t: the color type (.foreground or .background).
///
///Returns a uni struct instance with the color added.
pub inline fn brightBlack(self: uni, t: Color.Type) uni {
    const parsed_code = if (t == .foreground) parse(@field(Color.Foreground, "bright_black")) else parse(@field(Color.Background, "bright_black"));
    comptime return .{
        .level = self.level,
        .start = self.start ++ parsed_code,
    };
}

test "Bright black color function" {
    var expected = uni{
        .level = Color.Level.truecolor,
        .start = "\x1b[90m",
    };
    var actual = uni.init().brightBlack(.foreground);
    try testing.expectEqualDeep(expected, actual);

    expected.start = "\x1b[100m";
    actual = uni.init().brightBlack(.background);
    try testing.expectEqualDeep(expected, actual);
}

/// Adds bright red color.
///
/// Parameter:
/// - t: the color type (.foreground or .background).
///
///Returns a uni struct instance with the color added.
pub inline fn brightRed(self: uni, t: Color.Type) uni {
    const parsed_code = if (t == .foreground) parse(@field(Color.Foreground, "bright_red")) else parse(@field(Color.Background, "bright_red"));
    comptime return .{
        .level = self.level,
        .start = self.start ++ parsed_code,
    };
}

test "Bright red color function" {
    var expected = uni{
        .level = Color.Level.truecolor,
        .start = "\x1b[91m",
    };
    var actual = uni.init().brightRed(.foreground);
    try testing.expectEqualDeep(expected, actual);

    expected.start = "\x1b[101m";
    actual = uni.init().brightRed(.background);
    try testing.expectEqualDeep(expected, actual);
}

/// Adds bright green color.
///
/// Parameter:
/// - t: the color type (.foreground or .background).
///
///Returns a uni struct instance with the color added.
pub inline fn brightGreen(self: uni, t: Color.Type) uni {
    const parsed_code = if (t == .foreground) parse(@field(Color.Foreground, "bright_green")) else parse(@field(Color.Background, "bright_green"));
    comptime return .{
        .level = self.level,
        .start = self.start ++ parsed_code,
    };
}

test "Bright green color function" {
    var expected = uni{
        .level = Color.Level.truecolor,
        .start = "\x1b[92m",
    };
    var actual = uni.init().brightGreen(.foreground);
    try testing.expectEqualDeep(expected, actual);

    expected.start = "\x1b[102m";
    actual = uni.init().brightGreen(.background);
    try testing.expectEqualDeep(expected, actual);
}

/// Adds bright yellow color.
///
/// Parameter:
/// - t: the color type (.foreground or .background).
///
///Returns a uni struct instance with the color added.
pub inline fn brightYellow(self: uni, t: Color.Type) uni {
    const parsed_code = if (t == .foreground) parse(@field(Color.Foreground, "bright_yellow")) else parse(@field(Color.Background, "bright_yellow"));
    comptime return .{
        .level = self.level,
        .start = self.start ++ parsed_code,
    };
}

test "Bright yellow color function" {
    var expected = uni{
        .level = Color.Level.truecolor,
        .start = "\x1b[93m",
    };
    var actual = uni.init().brightYellow(.foreground);
    try testing.expectEqualDeep(expected, actual);

    expected.start = "\x1b[103m";
    actual = uni.init().brightYellow(.background);
    try testing.expectEqualDeep(expected, actual);
}

/// Adds bright blue color.
///
/// Parameter:
/// - t: the color type (.foreground or .background).
///
///Returns a uni struct instance with the color added.
pub inline fn brightBlue(self: uni, t: Color.Type) uni {
    const parsed_code = if (t == .foreground) parse(@field(Color.Foreground, "bright_blue")) else parse(@field(Color.Background, "bright_blue"));
    comptime return .{
        .level = self.level,
        .start = self.start ++ parsed_code,
    };
}

test "Bright blue color function" {
    var expected = uni{
        .level = Color.Level.truecolor,
        .start = "\x1b[94m",
    };
    var actual = uni.init().brightBlue(.foreground);
    try testing.expectEqualDeep(expected, actual);

    expected.start = "\x1b[104m";
    actual = uni.init().brightBlue(.background);
    try testing.expectEqualDeep(expected, actual);
}

/// Adds bright magenta color.
///
/// Parameter:
/// - t: the color type (.foreground or .background).
///
///Returns a uni struct instance with the color added.
pub inline fn brightMagenta(self: uni, t: Color.Type) uni {
    const parsed_code = if (t == .foreground) parse(@field(Color.Foreground, "bright_magenta")) else parse(@field(Color.Background, "bright_magenta"));
    comptime return .{
        .level = self.level,
        .start = self.start ++ parsed_code,
    };
}

test "Bright magenta color function" {
    var expected = uni{
        .level = Color.Level.truecolor,
        .start = "\x1b[95m",
    };
    var actual = uni.init().brightMagenta(.foreground);
    try testing.expectEqualDeep(expected, actual);

    expected.start = "\x1b[105m";
    actual = uni.init().brightMagenta(.background);
    try testing.expectEqualDeep(expected, actual);
}

/// Adds bright cyan color.
///
/// Parameter:
/// - t: the color type (.foreground or .background).
///
///Returns a uni struct instance with the color added.
pub inline fn brightCyan(self: uni, t: Color.Type) uni {
    const parsed_code = if (t == .foreground) parse(@field(Color.Foreground, "bright_cyan")) else parse(@field(Color.Background, "bright_cyan"));
    comptime return .{
        .level = self.level,
        .start = self.start ++ parsed_code,
    };
}

test "Bright cyan color function" {
    var expected = uni{
        .level = Color.Level.truecolor,
        .start = "\x1b[96m",
    };
    var actual = uni.init().brightCyan(.foreground);
    try testing.expectEqualDeep(expected, actual);

    expected.start = "\x1b[106m";
    actual = uni.init().brightCyan(.background);
    try testing.expectEqualDeep(expected, actual);
}

/// Adds bright white color.
///
/// Parameter:
/// - t: the color type (.foreground or .background).
///
///Returns a uni struct instance with the color added.
pub inline fn brightWhite(self: uni, t: Color.Type) uni {
    const parsed_code = if (t == .foreground) parse(@field(Color.Foreground, "bright_white")) else parse(@field(Color.Background, "bright_white"));
    comptime return .{
        .level = self.level,
        .start = self.start ++ parsed_code,
    };
}

test "Bright white color function" {
    var expected = uni{
        .level = Color.Level.truecolor,
        .start = "\x1b[97m",
    };
    var actual = uni.init().brightWhite(.foreground);
    try testing.expectEqualDeep(expected, actual);

    expected.start = "\x1b[107m";
    actual = uni.init().brightWhite(.background);
    try testing.expectEqualDeep(expected, actual);
}

/// Adds bold style.
///
///Returns a uni struct instance with the style added.
pub inline fn bold(self: uni) uni {
    const parsed_code = parse(@field(Style, @src().fn_name));
    comptime return .{
        .level = self.level,
        .start = self.start ++ parsed_code,
    };
}

test "Bold function" {
    const expected = uni{
        .level = Color.Level.truecolor,
        .start = "\x1b[1m",
    };
    const actual = uni.init().bold();
    try testing.expectEqualDeep(expected, actual);
}

/// Adds faint style.
///
///Returns a uni struct instance with the style added.
pub inline fn faint(self: uni) uni {
    const parsed_code = parse(@field(Style, @src().fn_name));
    comptime return .{
        .level = self.level,
        .start = self.start ++ parsed_code,
    };
}

test "Faint function" {
    const expected = uni{
        .level = Color.Level.truecolor,
        .start = "\x1b[2m",
    };
    const actual = uni.init().faint();
    try testing.expectEqualDeep(expected, actual);
}

/// Adds italic style.
///
///Returns a uni struct instance with the style added.
pub inline fn italic(self: uni) uni {
    const parsed_code = parse(@field(Style, @src().fn_name));
    comptime return .{
        .level = self.level,
        .start = self.start ++ parsed_code,
    };
}

test "Italic function" {
    const expected = uni{
        .level = Color.Level.truecolor,
        .start = "\x1b[3m",
    };
    const actual = uni.init().italic();
    try testing.expectEqualDeep(expected, actual);
}

/// Adds underline style.
///
///Returns a uni struct instance with the style added.
pub inline fn underline(self: uni) uni {
    const parsed_code = parse(@field(Style, @src().fn_name));
    comptime return .{
        .level = self.level,
        .start = self.start ++ parsed_code,
    };
}

test "Underline function" {
    const expected = uni{
        .level = Color.Level.truecolor,
        .start = "\x1b[4m",
    };
    const actual = uni.init().underline();
    try testing.expectEqualDeep(expected, actual);
}

/// Adds slow blinking style.
///
///Returns a uni struct instance with the style added.
pub inline fn slowBlink(self: uni) uni {
    const parsed_code = parse(@field(Style, @src().fn_name));
    comptime return .{
        .level = self.level,
        .start = self.start ++ parsed_code,
    };
}

test "Slow blink function" {
    const expected = uni{
        .level = Color.Level.truecolor,
        .start = "\x1b[5m",
    };
    const actual = uni.init().slowBlink();
    try testing.expectEqualDeep(expected, actual);
}

/// Adds rapid blinking style.
///
///Returns a uni struct instance with the style added.
pub inline fn rapidBlink(self: uni) uni {
    const parsed_code = parse(@field(Style, @src().fn_name));
    comptime return .{
        .level = self.level,
        .start = self.start ++ parsed_code,
    };
}

test "Rapid blink function" {
    const expected = uni{
        .level = Color.Level.truecolor,
        .start = "\x1b[6m",
    };
    const actual = uni.init().rapidBlink();
    try testing.expectEqualDeep(expected, actual);
}

/// Adds invert style.
///
///Returns a uni struct instance with the style added.
pub inline fn invert(self: uni) uni {
    const parsed_code = parse(@field(Style, @src().fn_name));
    comptime return .{
        .level = self.level,
        .start = self.start ++ parsed_code,
    };
}

test "Invert function" {
    const expected = uni{
        .level = Color.Level.truecolor,
        .start = "\x1b[7m",
    };
    const actual = uni.init().invert();
    try testing.expectEqualDeep(expected, actual);
}

/// Adds hide style.
///
///Returns a uni struct instance with the style added.
pub inline fn hide(self: uni) uni {
    const parsed_code = parse(@field(Style, @src().fn_name));
    comptime return .{
        .level = self.level,
        .start = self.start ++ parsed_code,
    };
}

test "Hide function" {
    const expected = uni{
        .level = Color.Level.truecolor,
        .start = "\x1b[8m",
    };
    const actual = uni.init().hide();
    try testing.expectEqualDeep(expected, actual);
}

/// Adds strike style.
///
///Returns a uni struct instance with the style added.
pub inline fn strike(self: uni) uni {
    const parsed_code = parse(@field(Style, @src().fn_name));
    comptime return .{
        .level = self.level,
        .start = self.start ++ parsed_code,
    };
}

test "Strike function" {
    const expected = uni{
        .level = Color.Level.truecolor,
        .start = "\x1b[9m",
    };
    const actual = uni.init().strike();
    try testing.expectEqualDeep(expected, actual);
}

/// Adds overline style.
///
///Returns a uni struct instance with the style added.
pub inline fn overline(self: uni) uni {
    const parsed_code = parse(@field(Style, @src().fn_name));
    comptime return .{
        .level = self.level,
        .start = self.start ++ parsed_code,
    };
}

test "Overline function" {
    const expected = uni{
        .level = Color.Level.truecolor,
        .start = "\x1b[53m",
    };
    const actual = uni.init().overline();
    try testing.expectEqualDeep(expected, actual);
}

/// Formats a passed string with the desired styles and colors.
///
/// Parameter:
/// - str: the string to be formated with the corresponding ANSI escape code.
///
/// Returns the formatted string.
pub inline fn format(self: uni, comptime str: []const u8) []const u8 {
    return self.start ++ str ++ self.end;
}

test "Format a string with basic colors" {
    const expected: []const u8 = attr.esc_char ++ "30m" ++ "Black" ++ attr.esc_char ++ "0m";
    const actual: []const u8 = uni.init().black(.foreground).format("Black");

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
/// Returns a uni struct instance with the color added.
pub inline fn rgb(self: uni, r: u8, g: u8, b: u8, t: Color.Type) uni {
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
    var expected = uni{
        .level = Color.Level.truecolor,
        .start = "\x1b[38;2;255;255;255m",
    };
    var actual = uni.init().rgb(255, 255, 255, Color.Type.foreground);
    try testing.expectEqualStrings(expected.start, actual.start);

    expected.start = "\x1b[48;2;255;255;255m";
    actual = uni.init().rgb(255, 255, 255, Color.Type.background);
    try testing.expectEqualStrings(expected.start, actual.start);
}

/// Converts hexadecimal color codes to their ANSI escape code representation.
///
/// Parameters:
/// - code: the hexadecimal color code string (e.g., "#FF0000").
/// - t: the color type (.foreground or .background).
///
/// Returns a uni struct instance with the color added.
pub inline fn hex(self: uni, code: []const u8, t: Color.Type) uni {
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
    var expected = uni{
        .level = Color.Level.truecolor,
        .start = "\x1b[38;2;255;255;255m",
    };
    var actual = uni.init().hex("#ffffff", .foreground);
    try testing.expectEqualStrings(expected.start, actual.start);

    expected.start = "\x1b[48;2;255;255;255m";
    actual = uni.init().hex("ffffff", .background);
    try testing.expectEqualStrings(expected.start, actual.start);
}

/// "Turns on" uni setted colors and styles by printing them to stdout.
/// These styles and colors will remain until turned off.
pub inline fn on(self: uni, writer: *std.Io.Writer) !void {
    try writer.print("{s}", .{self.start});
}

/// "Turns off" uni setted colors and styles by printing the reset ANSI escape code to stdout.
pub inline fn off(self: uni, writer: *std.Io.Writer) !void {
    try writer.print("{s}", .{self.end});
}

test "Initialization of an uni struct" {
    const expected = uni{
        .level = Color.Level.truecolor,
        .start = "",
        .end = "\x1b[0m",
    };
    const actual = uni.init();
    try testing.expectEqualDeep(expected, actual);
}
