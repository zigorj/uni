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

        pub fn detect() Level {
            const stdout = std.io.getStdOut();
            const color_term = std.posix.getenv("COLORTERM");
            const term = std.posix.getenv("TERM");
            const no_color = std.posix.getenv("NO_COLOR");

            if (!stdout.supportsAnsiEscapeCodes() or no_color) return .none;
            if (color_term and (std.mem.eql(u8, color_term, "truecolor" or std.mem.eql(u8, color_term, "24bit")))) return .truecolor;
            if (term and (std.mem.endsWith(u8, term, "256") or std.mem.endsWith(u8, term, "256color"))) return .color256;
            return .basic;
        }
    };
};
