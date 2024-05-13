const std = @import("std");
pub const esc_char: []const u8 = "\x1b[";

pub const Style = struct {
    pub const bold = "1";
    pub const faint = "2";
    pub const italic = "3";
    pub const underline = "4";
    pub const slowBlink = "5";
    pub const rapidBlink = "6";
    pub const invert = "7";
    pub const hide = "8";
    pub const strike = "9";
    pub const overline = "53";
};

pub const Color = struct {
    pub const Foreground = struct {
        pub const black = "30";
        pub const red = "31";
        pub const green = "32";
        pub const yellow = "33";
        pub const blue = "34";
        pub const magenta = "35";
        pub const cyan = "36";
        pub const white = "37";
    };

    pub const Background = struct {
        pub const bgBlack = "40";
        pub const bgRed = "41";
        pub const bgGreen = "42";
        pub const bgYellow = "43";
        pub const bgBlue = "44";
        pub const bgMagenta = "45";
        pub const bgCyan = "46";
        pub const bgWhite = "47";
    };

    pub const RGB = struct {
        r: u8,
        g: u8,
        b: u8,
        t: ColorType,

        const ColorType = enum(u8) {
            foreground = 38,
            background = 48,
        };

        pub fn fg(r: u8, g: u8, b: u8) RGB {
            return .{
                .r = r,
                .g = g,
                .b = b,
                .t = RGB.ColorType.foreground,
            };
        }

        pub fn bg(r: u8, g: u8, b: u8) RGB {
            return .{
                .r = r,
                .g = g,
                .b = b,
                .t = RGB.ColorType.background,
            };
        }
    };

    pub const Level = enum {
        none,
        basic,
        color256,
        truecolor,
    };
};
