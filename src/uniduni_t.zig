const std = @import("std");
const testing = std.testing;

const attr = @import("attributes.zig");
const Style = attr.Style;
const Color = attr.Color;

pub const Uniduni_t = struct {
    level: Color.Level,
    start: []const u8 = "",
    end: []const u8 = attr.esc_char ++ "0m",

    pub inline fn init() Uniduni_t {
        comptime return .{
            .level = .truecolor,
        };
    }

    pub inline fn add(self: Uniduni_t, comptime attribute: anytype) Uniduni_t {
        const t_info_attr = @typeInfo(@TypeOf(attribute));
        if (t_info_attr != .Struct) @compileError("The 'attribute' parameter must be a tuple.");
        if (!t_info_attr.Struct.is_tuple) @compileError("The 'attribute' parameter must be a tuple.");

        comptime var uni: Uniduni_t = .{
            .level = self.level,
        };

        inline for (attribute) |value| {
            const parsed_code = parse(value);
            uni.start = uni.start ++ parsed_code;
        }

        return uni;
    }

    test "Add foreground color and a style" {
        const expected = Uniduni_t{
            .level = Color.Level.truecolor,
            .start = "\x1b[31m\x1b[1m",
        };

        var actual = Uniduni_t.init().add(.{ Color.Foreground.red, Style.bold });

        try testing.expectEqualStrings(expected.start, actual.start);
    }

    inline fn parse(comptime attribute: []const u8) []const u8 {
        comptime return attr.esc_char ++ attribute ++ "m";
    }

    test "Parse a string with colors" {
        const expected = attr.esc_char ++ "37m";
        const actual = parse(Color.Foreground.white);
        try testing.expectEqualSlices(u8, expected, actual);
    }

    pub inline fn black(self: Uniduni_t) Uniduni_t {
        const parsed_code = parse(@field(Color.Foreground, @src().fn_name));
        comptime return .{
            .level = self.level,
            .start = self.start ++ parsed_code,
        };
    }

    test "Black color function" {
        const expected = Uniduni_t{
            .level = Color.Level.truecolor,
            .start = "\x1b[30m",
        };
        const actual = Uniduni_t.init().black();

        try testing.expectEqualStrings(expected.start, actual.start);
    }

    pub inline fn red(self: Uniduni_t) Uniduni_t {
        const parsed_code = parse(@field(Color.Foreground, @src().fn_name));
        comptime return .{
            .level = self.level,
            .start = self.start ++ parsed_code,
        };
    }

    test "Red color function" {
        const expected = Uniduni_t{
            .level = Color.Level.truecolor,
            .start = "\x1b[31m",
        };
        const actual = Uniduni_t.init().red();

        try testing.expectEqualStrings(expected.start, actual.start);
    }

    pub inline fn green(self: Uniduni_t) Uniduni_t {
        const parsed_code = parse(@field(Color.Foreground, @src().fn_name));
        comptime return .{
            .level = self.level,
            .start = self.start ++ parsed_code,
        };
    }

    test "Green color function" {
        const expected = Uniduni_t{
            .level = Color.Level.truecolor,
            .start = "\x1b[32m",
        };
        const actual = Uniduni_t.init().green();

        try testing.expectEqualStrings(expected.start, actual.start);
    }

    pub inline fn yellow(self: Uniduni_t) Uniduni_t {
        const parsed_code = parse(@field(Color.Foreground, @src().fn_name));
        comptime return .{
            .level = self.level,
            .start = self.start ++ parsed_code,
        };
    }

    test "Yellow color function" {
        const expected = Uniduni_t{
            .level = Color.Level.truecolor,
            .start = "\x1b[33m",
        };
        const actual = Uniduni_t.init().yellow();

        try testing.expectEqualStrings(expected.start, actual.start);
    }

    pub inline fn blue(self: Uniduni_t) Uniduni_t {
        const parsed_code = parse(@field(Color.Foreground, @src().fn_name));
        comptime return .{
            .level = self.level,
            .start = self.start ++ parsed_code,
        };
    }

    test "Blue color function" {
        const expected = Uniduni_t{
            .level = Color.Level.truecolor,
            .start = "\x1b[34m",
        };
        const actual = Uniduni_t.init().blue();

        try testing.expectEqualStrings(expected.start, actual.start);
    }

    pub inline fn magenta(self: Uniduni_t) Uniduni_t {
        const parsed_code = parse(@field(Color.Foreground, @src().fn_name));
        comptime return .{
            .level = self.level,
            .start = self.start ++ parsed_code,
        };
    }

    test "Magenta color function" {
        const expected = Uniduni_t{
            .level = Color.Level.truecolor,
            .start = "\x1b[35m",
        };
        const actual = Uniduni_t.init().magenta();

        try testing.expectEqualStrings(expected.start, actual.start);
    }

    pub inline fn cyan(self: Uniduni_t) Uniduni_t {
        const parsed_code = parse(@field(Color.Foreground, @src().fn_name));
        comptime return .{
            .level = self.level,
            .start = self.start ++ parsed_code,
        };
    }

    test "Cyan color function" {
        const expected = Uniduni_t{
            .level = Color.Level.truecolor,
            .start = "\x1b[36m",
        };
        const actual = Uniduni_t.init().cyan();

        try testing.expectEqualStrings(expected.start, actual.start);
    }

    pub inline fn white(self: Uniduni_t) Uniduni_t {
        const parsed_code = parse(@field(Color.Foreground, @src().fn_name));
        comptime return .{
            .level = self.level,
            .start = self.start ++ parsed_code,
        };
    }

    test "White color function" {
        const expected = Uniduni_t{
            .level = Color.Level.truecolor,
            .start = "\x1b[37m",
        };
        const actual = Uniduni_t.init().white();

        try testing.expectEqualStrings(expected.start, actual.start);
    }

    pub inline fn brightBlack(self: Uniduni_t) Uniduni_t {
        const parsed_code = parse(@field(Color.Foreground, "bright_black"));
        comptime return .{
            .level = self.level,
            .start = self.start ++ parsed_code,
        };
    }

    test "Bright black color function" {
        const expected = Uniduni_t{
            .level = Color.Level.truecolor,
            .start = "\x1b[90m",
        };
        const actual = Uniduni_t.init().brightBlack();

        try testing.expectEqualStrings(expected.start, actual.start);
    }

    pub inline fn brightRed(self: Uniduni_t) Uniduni_t {
        const parsed_code = parse(@field(Color.Foreground, "bright_red"));
        comptime return .{
            .level = self.level,
            .start = self.start ++ parsed_code,
        };
    }

    test "Bright red color function" {
        const expected = Uniduni_t{
            .level = Color.Level.truecolor,
            .start = "\x1b[91m",
        };
        const actual = Uniduni_t.init().brightRed();

        try testing.expectEqualStrings(expected.start, actual.start);
    }

    pub inline fn brightGreen(self: Uniduni_t) Uniduni_t {
        const parsed_code = parse(@field(Color.Foreground, "bright_green"));
        comptime return .{
            .level = self.level,
            .start = self.start ++ parsed_code,
        };
    }

    test "Bright green color function" {
        const expected = Uniduni_t{
            .level = Color.Level.truecolor,
            .start = "\x1b[92m",
        };
        const actual = Uniduni_t.init().brightGreen();

        try testing.expectEqualStrings(expected.start, actual.start);
    }

    pub inline fn brightYellow(self: Uniduni_t) Uniduni_t {
        const parsed_code = parse(@field(Color.Foreground, "bright_yellow"));
        comptime return .{
            .level = self.level,
            .start = self.start ++ parsed_code,
        };
    }

    test "Bright yellow color function" {
        const expected = Uniduni_t{
            .level = Color.Level.truecolor,
            .start = "\x1b[93m",
        };
        const actual = Uniduni_t.init().brightYellow();

        try testing.expectEqualStrings(expected.start, actual.start);
    }

    pub inline fn brightBlue(self: Uniduni_t) Uniduni_t {
        const parsed_code = parse(@field(Color.Foreground, "bright_blue"));
        comptime return .{
            .level = self.level,
            .start = self.start ++ parsed_code,
        };
    }

    test "Bright blue color function" {
        const expected = Uniduni_t{
            .level = Color.Level.truecolor,
            .start = "\x1b[94m",
        };
        const actual = Uniduni_t.init().brightBlue();

        try testing.expectEqualStrings(expected.start, actual.start);
    }

    pub inline fn brightMagenta(self: Uniduni_t) Uniduni_t {
        const parsed_code = parse(@field(Color.Foreground, "bright_magenta"));
        comptime return .{
            .level = self.level,
            .start = self.start ++ parsed_code,
        };
    }

    test "Bright magenta color function" {
        const expected = Uniduni_t{
            .level = Color.Level.truecolor,
            .start = "\x1b[95m",
        };
        const actual = Uniduni_t.init().brightMagenta();

        try testing.expectEqualStrings(expected.start, actual.start);
    }

    pub inline fn brightCyan(self: Uniduni_t) Uniduni_t {
        const parsed_code = parse(@field(Color.Foreground, "bright_cyan"));
        comptime return .{
            .level = self.level,
            .start = self.start ++ parsed_code,
        };
    }

    test "Bright cyan color function" {
        const expected = Uniduni_t{
            .level = Color.Level.truecolor,
            .start = "\x1b[96m",
        };
        const actual = Uniduni_t.init().brightCyan();

        try testing.expectEqualStrings(expected.start, actual.start);
    }

    pub inline fn brightWhite(self: Uniduni_t) Uniduni_t {
        const parsed_code = parse(@field(Color.Foreground, "bright_white"));
        comptime return .{
            .level = self.level,
            .start = self.start ++ parsed_code,
        };
    }

    test "Bright white color function" {
        const expected = Uniduni_t{
            .level = Color.Level.truecolor,
            .start = "\x1b[97m",
        };
        const actual = Uniduni_t.init().brightWhite();

        try testing.expectEqualStrings(expected.start, actual.start);
    }

    pub inline fn bgBlack(self: Uniduni_t) Uniduni_t {
        const parsed_code = parse(@field(Color.Background, "black"));
        comptime return .{
            .level = self.level,
            .start = self.start ++ parsed_code,
        };
    }

    test "Black background color function" {
        const expected = Uniduni_t{
            .level = Color.Level.truecolor,
            .start = "\x1b[40m",
        };
        const actual = Uniduni_t.init().bgBlack();

        try testing.expectEqualStrings(expected.start, actual.start);
    }

    pub inline fn bgRed(self: Uniduni_t) Uniduni_t {
        const parsed_code = parse(@field(Color.Background, "red"));
        comptime return .{
            .level = self.level,
            .start = self.start ++ parsed_code,
        };
    }

    test "Red background color function" {
        const expected = Uniduni_t{
            .level = Color.Level.truecolor,
            .start = "\x1b[41m",
        };
        const actual = Uniduni_t.init().bgRed();

        try testing.expectEqualStrings(expected.start, actual.start);
    }

    pub inline fn bgGreen(self: Uniduni_t) Uniduni_t {
        const parsed_code = parse(@field(Color.Background, "green"));
        comptime return .{
            .level = self.level,
            .start = self.start ++ parsed_code,
        };
    }

    test "Green background color function" {
        const expected = Uniduni_t{
            .level = Color.Level.truecolor,
            .start = "\x1b[42m",
        };
        const actual = Uniduni_t.init().bgGreen();

        try testing.expectEqualStrings(expected.start, actual.start);
    }

    pub inline fn bgYellow(self: Uniduni_t) Uniduni_t {
        const parsed_code = parse(@field(Color.Background, "yellow"));
        comptime return .{
            .level = self.level,
            .start = self.start ++ parsed_code,
        };
    }

    test "Yellow background color function" {
        const expected = Uniduni_t{
            .level = Color.Level.truecolor,
            .start = "\x1b[43m",
        };
        const actual = Uniduni_t.init().bgYellow();

        try testing.expectEqualStrings(expected.start, actual.start);
    }

    pub inline fn bgBlue(self: Uniduni_t) Uniduni_t {
        const parsed_code = parse(@field(Color.Background, "blue"));
        comptime return .{
            .level = self.level,
            .start = self.start ++ parsed_code,
        };
    }

    test "Blue background color function" {
        const expected = Uniduni_t{
            .level = Color.Level.truecolor,
            .start = "\x1b[44m",
        };
        const actual = Uniduni_t.init().bgBlue();

        try testing.expectEqualStrings(expected.start, actual.start);
    }

    pub inline fn bgMagenta(self: Uniduni_t) Uniduni_t {
        const parsed_code = parse(@field(Color.Background, "magenta"));
        comptime return .{
            .level = self.level,
            .start = self.start ++ parsed_code,
        };
    }

    test "Magenta background color function" {
        const expected = Uniduni_t{
            .level = Color.Level.truecolor,
            .start = "\x1b[45m",
        };
        const actual = Uniduni_t.init().bgMagenta();

        try testing.expectEqualStrings(expected.start, actual.start);
    }

    pub inline fn bgCyan(self: Uniduni_t) Uniduni_t {
        const parsed_code = parse(@field(Color.Background, "cyan"));
        comptime return .{
            .level = self.level,
            .start = self.start ++ parsed_code,
        };
    }

    test "Cyan background color function" {
        const expected = Uniduni_t{
            .level = Color.Level.truecolor,
            .start = "\x1b[46m",
        };
        const actual = Uniduni_t.init().bgCyan();

        try testing.expectEqualStrings(expected.start, actual.start);
    }

    pub inline fn bgWhite(self: Uniduni_t) Uniduni_t {
        const parsed_code = parse(@field(Color.Background, "white"));
        comptime return .{
            .level = self.level,
            .start = self.start ++ parsed_code,
        };
    }

    test "White background color function" {
        const expected = Uniduni_t{
            .level = Color.Level.truecolor,
            .start = "\x1b[47m",
        };
        const actual = Uniduni_t.init().bgWhite();

        try testing.expectEqualStrings(expected.start, actual.start);
    }

    pub inline fn bgBrightBlack(self: Uniduni_t) Uniduni_t {
        const parsed_code = parse(@field(Color.Background, "bright_black"));
        comptime return .{
            .level = self.level,
            .start = self.start ++ parsed_code,
        };
    }

    test "Bright black background color function" {
        const expected = Uniduni_t{
            .level = Color.Level.truecolor,
            .start = "\x1b[100m",
        };
        const actual = Uniduni_t.init().bgBrightBlack();

        try testing.expectEqualStrings(expected.start, actual.start);
    }

    pub inline fn bgBrightRed(self: Uniduni_t) Uniduni_t {
        const parsed_code = parse(@field(Color.Background, "bright_red"));
        comptime return .{
            .level = self.level,
            .start = self.start ++ parsed_code,
        };
    }

    test "Bright red background color function" {
        const expected = Uniduni_t{
            .level = Color.Level.truecolor,
            .start = "\x1b[101m",
        };
        const actual = Uniduni_t.init().bgBrightRed();

        try testing.expectEqualStrings(expected.start, actual.start);
    }

    pub inline fn bgBrightGreen(self: Uniduni_t) Uniduni_t {
        const parsed_code = parse(@field(Color.Background, "bright_green"));
        comptime return .{
            .level = self.level,
            .start = self.start ++ parsed_code,
        };
    }

    test "Bright green background color function" {
        const expected = Uniduni_t{
            .level = Color.Level.truecolor,
            .start = "\x1b[102m",
        };
        const actual = Uniduni_t.init().bgBrightGreen();

        try testing.expectEqualStrings(expected.start, actual.start);
    }

    pub inline fn bgBrightYellow(self: Uniduni_t) Uniduni_t {
        const parsed_code = parse(@field(Color.Background, "bright_yellow"));
        comptime return .{
            .level = self.level,
            .start = self.start ++ parsed_code,
        };
    }

    test "Bright yellow background color function" {
        const expected = Uniduni_t{
            .level = Color.Level.truecolor,
            .start = "\x1b[103m",
        };
        const actual = Uniduni_t.init().bgBrightYellow();

        try testing.expectEqualStrings(expected.start, actual.start);
    }

    pub inline fn bgBrightBlue(self: Uniduni_t) Uniduni_t {
        const parsed_code = parse(@field(Color.Background, "bright_blue"));
        comptime return .{
            .level = self.level,
            .start = self.start ++ parsed_code,
        };
    }

    test "Bright blue background color function" {
        const expected = Uniduni_t{
            .level = Color.Level.truecolor,
            .start = "\x1b[104m",
        };
        const actual = Uniduni_t.init().bgBrightBlue();

        try testing.expectEqualStrings(expected.start, actual.start);
    }

    pub inline fn bgBrightMagenta(self: Uniduni_t) Uniduni_t {
        const parsed_code = parse(@field(Color.Background, "bright_magenta"));
        comptime return .{
            .level = self.level,
            .start = self.start ++ parsed_code,
        };
    }

    test "Bright magenta background color function" {
        const expected = Uniduni_t{
            .level = Color.Level.truecolor,
            .start = "\x1b[105m",
        };
        const actual = Uniduni_t.init().bgBrightMagenta();

        try testing.expectEqualStrings(expected.start, actual.start);
    }

    pub inline fn bgBrightCyan(self: Uniduni_t) Uniduni_t {
        const parsed_code = parse(@field(Color.Background, "bright_cyan"));
        comptime return .{
            .level = self.level,
            .start = self.start ++ parsed_code,
        };
    }

    test "Bright Cyan background color function" {
        const expected = Uniduni_t{
            .level = Color.Level.truecolor,
            .start = "\x1b[106m",
        };
        const actual = Uniduni_t.init().bgBrightCyan();

        try testing.expectEqualStrings(expected.start, actual.start);
    }

    pub inline fn bgBrightWhite(self: Uniduni_t) Uniduni_t {
        const parsed_code = parse(@field(Color.Background, "bright_white"));
        comptime return .{
            .level = self.level,
            .start = self.start ++ parsed_code,
        };
    }

    test "Bright white background color function" {
        const expected = Uniduni_t{
            .level = Color.Level.truecolor,
            .start = "\x1b[107m",
        };
        const actual = Uniduni_t.init().bgBrightWhite();

        try testing.expectEqualStrings(expected.start, actual.start);
    }

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

        try testing.expectEqualStrings(expected.start, actual.start);
    }

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

        try testing.expectEqualStrings(expected.start, actual.start);
    }

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

        try testing.expectEqualStrings(expected.start, actual.start);
    }

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

        try testing.expectEqualStrings(expected.start, actual.start);
    }

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

        try testing.expectEqualStrings(expected.start, actual.start);
    }

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

        try testing.expectEqualStrings(expected.start, actual.start);
    }

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

        try testing.expectEqualStrings(expected.start, actual.start);
    }

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

        try testing.expectEqualStrings(expected.start, actual.start);
    }

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

        try testing.expectEqualStrings(expected.start, actual.start);
    }

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

        try testing.expectEqualStrings(expected.start, actual.start);
    }

    pub inline fn format(self: Uniduni_t, comptime str: []const u8) []const u8 {
        return self.start ++ str ++ self.end;
    }

    test "Format a string with basic colors" {
        const expected: []const u8 = attr.esc_char ++ "30m" ++ "Black" ++ attr.esc_char ++ "0m";
        const actual: []const u8 = Uniduni_t.init().black().format("Black");

        try testing.expectEqualStrings(expected, actual);
    }
};

test "Initialization of an Uniduni_t struct" {
    const actual = Uniduni_t.init();
    try testing.expectEqual(Uniduni_t, @TypeOf(actual));
    try testing.expectEqualStrings("", actual.start);
    try testing.expectEqualStrings("\x1b[0m", actual.end);
    try testing.expectEqual(Color.Level.truecolor, actual.level);
}
