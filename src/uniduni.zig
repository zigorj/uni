const std = @import("std");

const esc_char: []const u8 = "\x1b";

/// Main structure for the color.
pub const Color = struct {
    options: std.ArrayList(u8),
    color_enabled: bool,
    alloc: *std.mem.Allocator,

    /// This function initialize an instance of the Color struct.
    pub fn init(alloc: *std.mem.Allocator) Color {
        var options = std.ArrayList(u8).init(alloc);
        var color_enabled = true;
        return .{
            .options = options,
            .color_enabled = color_enabled,
            .alloc = alloc,
        };
    }

    /// Deinitialize a given instance of the Color struct.
    fn deinit(self: *Color) void {
        self.options.deinit();
    }

    /// Set the color attribute of a given Color struct.
    fn set(self: *Color, attr: Attr) void {
        self.options.append(attr);
    }
};

/// Enumeration with the color attribute
const Attr = enum {
    black,
    red,
    green,
    yellow,
    blue,
    magenta,
    cyan,
    white,
};
