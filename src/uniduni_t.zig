const std = @import("std");

const esc_char: []const u8 = "\x1b";

/// This function initialize an instance of the Color struct.
pub fn init(alloc: std.mem.Allocator, color: Color) Uniduni_t {
    return Uniduni_t{
        .color = color,
        .alloc = alloc,
    };
}

/// Main structure for the color.
pub const Uniduni_t = struct {
    // options: std.ArrayList(Attribute),
    color: Color,
    alloc: std.mem.Allocator,

    /// Deinitialize a given instance of the Color struct.
    pub fn deinit(self: *Uniduni_t) void {
        self.* = undefined;
    }

    /// Prepare the attributes string.
    fn prepAttributeStr(self: *Uniduni_t) ![]const u8 {
        const s: []const u8 = try std.fmt.allocPrint(self.alloc, "{s}[{d}m", .{ esc_char, @intFromEnum(self.color) });
        return s;
    }

    /// Print a given string considering the Color struct attributes.
    pub fn print(self: *Uniduni_t, s: []const u8) !void {
        const stdout = std.io.getStdOut().writer();

        const c_str = try self.prepAttributeStr();
        defer self.alloc.free(c_str);

        try stdout.print("{s}{s}{s}", .{
            c_str,
            s,
        });
    }
};

/// Enumeration with the color's values.
pub const Color = enum(u8) {
    black = 30,
    red,
    green,
    yellow,
    blue,
    magenta,
    cyan,
    white,
};

/// Enumerations with the attributes' values.
pub const Attribute = enum(u8) {
    reset,
    bold,
    faint,
    italic,
    underline,
    slow_blink,
    rapid_blink,
    reverse_video,
    concealed,
    crossed_out,
};
