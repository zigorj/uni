const std = @import("std");

const esc_char: []const u8 = "\x1b";

/// Main structure for the color.
pub const Color = struct {
    options: std.ArrayList(Attr),
    color_enabled: bool,
    alloc: std.mem.Allocator,

    /// This function initialize an instance of the Color struct.
    pub fn init(alloc: std.mem.Allocator) Color {
        const options = std.ArrayList(Attr).init(alloc);
        const color_enabled = true;
        return .{
            .options = options,
            .color_enabled = color_enabled,
            .alloc = alloc,
        };
    }

    /// Deinitialize a given instance of the Color struct.
    pub fn deinit(self: *Color) void {
        self.options.deinit();
        self.* = undefined;
    }

    /// Set the color attribute of a given Color struct.
    pub fn setAttr(self: *Color, attr: Attr) !void {
        try self.options.append(attr);
    }
};

/// Enumeration with the color attribute tag.
pub const Attr = enum(u8) {
    black = 30,
    red,
    green,
    yellow,
    blue,
    magenta,
    cyan,
    white,
};
