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

    pub inline fn slowblink(self: Uniduni_t) Uniduni_t {
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
        const actual = Uniduni_t.init().slowblink();

        try testing.expectEqualStrings(expected.start, actual.start);
    }

    pub inline fn rapidblink(self: Uniduni_t) Uniduni_t {
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
        const actual = Uniduni_t.init().rapidblink();

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
