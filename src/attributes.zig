const std = @import("std");
pub const esc_char: []const u8 = "\x1b[";

pub const Style = enum(u8) {
    bold = 1,
    faint,
    italic,
    underline,
    slowBlink,
    rapidBlink,
    invert,
    hide,
    strike,
    overline = 53,
};

pub const Color = struct {
    pub const Foreground = enum(u8) {
        black = 30,
        red,
        green,
        yellow,
        blue,
        magenta,
        cyan,
        white,
        bright_black = 90,
        bright_red,
        bright_green,
        bright_yellow,
        bright_blue,
        bright_magenta,
        bright_cyan,
        bright_white,
    };

    pub const Background = enum(u8) {
        black = 40,
        red,
        green,
        yellow,
        blue,
        magenta,
        cyan,
        white,
        bright_black = 100,
        bright_red,
        bright_green,
        bright_yellow,
        bright_blue,
        bright_magenta,
        bright_cyan,
        bright_white,
    };

    pub const RGB = struct {
        r: u8,
        g: u8,
        b: u8,
        t: Color.Type,

        pub fn fg(r: u8, g: u8, b: u8) RGB {
            return .{
                .r = r,
                .g = g,
                .b = b,
                .t = Color.Type.foreground,
            };
        }

        pub fn bg(r: u8, g: u8, b: u8) RGB {
            return .{
                .r = r,
                .g = g,
                .b = b,
                .t = Color.Type.background,
            };
        }
    };

    pub const Hex = struct {
        code: []const u8,
        t: Color.Type,

        pub fn fg(code: []const u8) Hex {
            return .{
                .code = code,
                .t = Color.Type.foreground,
            };
        }

        pub fn bg(code: []const u8) Hex {
            return .{
                .code = code,
                .t = Color.Type.background,
            };
        }
    };

    pub const Type = enum(u8) {
        foreground = 38,
        background = 48,
    };

    pub const Level = enum {
        none,
        basic,
        color256,
        truecolor,
    };
};
