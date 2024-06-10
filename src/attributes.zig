const std = @import("std");

/// Escape character for ANSI escape codes.
pub const esc_char: []const u8 = "\x1b[";

/// Enum representing various text styles.
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

/// Struct containing color-related constants and utilities.
pub const Color = struct {
    /// Enum representing foreground colors.
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

    /// Enum representing background colors.
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

    /// Struct representing RGB color values.
    pub const RGB = struct {
        r: u8,
        g: u8,
        b: u8,
        t: Color.Type,

        /// Function to create a foreground RGB color.
        ///
        /// Returns an RGB instance.
        pub fn fg(r: u8, g: u8, b: u8) RGB {
            return .{
                .r = r,
                .g = g,
                .b = b,
                .t = Color.Type.foreground,
            };
        }

        /// Function to create a background RGB color.
        ///
        /// Returns an RGB instance.
        pub fn bg(r: u8, g: u8, b: u8) RGB {
            return .{
                .r = r,
                .g = g,
                .b = b,
                .t = Color.Type.background,
            };
        }
    };

    /// Struct representing hexadecimal color codes.
    pub const Hex = struct {
        code: []const u8,
        t: Color.Type,

        /// Function to create a foreground color from a hexadecimal code.
        ///
        /// Returns a Hex instance.
        pub fn fg(code: []const u8) Hex {
            return .{
                .code = code,
                .t = Color.Type.foreground,
            };
        }

        /// Function to create a background color from a hexadecimal code.
        ///
        /// Returns a Hex instance.
        pub fn bg(code: []const u8) Hex {
            return .{
                .code = code,
                .t = Color.Type.background,
            };
        }
    };

    /// Enum representing color types (foreground or background).
    pub const Type = enum(u8) {
        foreground = 38,
        background = 48,
    };

    /// Enum representing color levels for detecting color support.
    pub const Level = enum {
        none,
        basic,
        color256,
        truecolor,

        /// Function to detect the level of color support.
        ///
        /// Returns a Level enum option.
        pub fn detect() Level {
            const stdout = std.io.getStdOut();
            const color_term = std.posix.getenv("COLORTERM");
            const term = std.posix.getenv("TERM");
            const no_color = std.posix.getenv("NO_COLOR");

            if (!stdout.supportsAnsiEscapeCodes() or no_color != null) return .none;
            if (color_term != null and (std.mem.eql(u8, color_term.?, "truecolor") or std.mem.eql(u8, color_term.?, "24bit"))) return .truecolor;
            if (term != null and (std.mem.endsWith(u8, term.?, "256") or std.mem.endsWith(u8, term.?, "256color"))) return .color256;
            return .basic;
        }

        test "detect function" {
            const expected: Color.Level = .truecolor;
            const actual = Color.Level.detect();
            try std.testing.expectEqual(expected, actual);
        }
    };
};
