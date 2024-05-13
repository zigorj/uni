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
        pub const bright_black = "90";
        pub const bright_red = "91";
        pub const bright_green = "92";
        pub const bright_yellow = "93";
        pub const bright_blue = "94";
        pub const bright_magenta = "95";
        pub const bright_cyan = "96";
        pub const bright_white = "97";
    };

    pub const Background = struct {
        pub const black = "40";
        pub const red = "41";
        pub const green = "42";
        pub const yellow = "43";
        pub const blue = "44";
        pub const magenta = "45";
        pub const cyan = "46";
        pub const white = "47";
        pub const bright_black = "100";
        pub const bright_red = "101";
        pub const bright_green = "102";
        pub const bright_yellow = "103";
        pub const bright_blue = "104";
        pub const bright_magenta = "105";
        pub const bright_cyan = "106";
        pub const bright_white = "107";
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
