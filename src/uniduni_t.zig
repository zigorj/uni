const std = @import("std");

const esc_char: []const u8 = "\x1b";

/// Main structure for the color.
pub const Color = struct {
    options: std.ArrayList(Attribute),
    alloc: std.mem.Allocator,

    /// This function initialize an instance of the Color struct.
    pub fn init(alloc: std.mem.Allocator) Color {
        return .{
            .options = std.ArrayList(Attribute).init(alloc),
            .alloc = alloc,
        };
    }

    /// Deinitialize a given instance of the Color struct.
    pub fn deinit(self: *Color) void {
        self.options.deinit();
        self.* = undefined;
    }

    /// Set the color attribute of a given Color struct.
    pub fn setAttribute(self: *Color, attr: Attribute) !void {
        try self.options.append(attr);
    }

    pub fn setBlack(self: *Color) !void {
        try self.setAttribute(Attribute.black);
    }

    pub fn setRed(self: *Color) !void {
        try self.setAttribute(Attribute.red);
    }

    pub fn setGreen(self: *Color) !void {
        try self.setAttribute(Attribute.green);
    }

    pub fn setYellow(self: *Color) !void {
        try self.setAttribute(Attribute.yellow);
    }

    pub fn setBlue(self: *Color) !void {
        try self.setAttribute(Attribute.blue);
    }

    pub fn setMagenta(self: *Color) !void {
        try self.setAttribute(Attribute.magenta);
    }

    pub fn setCyan(self: *Color) !void {
        try self.setAttribute(Attribute.cyan);
    }

    pub fn setWhite(self: *Color) !void {
        try self.setAttribute(Attribute.white);
    }

    pub fn print(self: *Color, output: ?[]const u8) !void {
        // TODO
        _ = output;
        _ = self;
    }
};

/// Enumeration with the color attribute tag.
pub const Attribute = enum(u8) {
    black = 30,
    red,
    green,
    yellow,
    blue,
    magenta,
    cyan,
    white,
};
