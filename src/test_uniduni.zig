const std = @import("std");
const testing = std.testing;
const uniduni = @import("uniduni.zig");

// Testing the initialization of a Color struct.
test "Initialization of a Color struct" {
    const expected = uniduni.Color;

    var alloc = testing.allocator;
    var color_struct = uniduni.Color.init(alloc);
    defer color_struct.deinit();

    const actual = @TypeOf(color_struct);

    try testing.expectEqual(expected, actual);
}

// Testing the assignment of a attribute to a Color struct.
test "Assigning an attribute to a Color struct" {
    const expected = uniduni.Attr.red;

    const alloc = testing.allocator;
    var color_struct = uniduni.Color.init(alloc);
    defer color_struct.deinit();

    try color_struct.setAttr(uniduni.Attr.red);
    const actual = color_struct.options.pop();

    try testing.expectEqual(expected, actual);
}

// Testing the correctness of the attribute's int representation.
test "Verify the correctness of the attribute's int representation" {
    const expected: u8 = 33; // Attr.yellow
    const actual = @intFromEnum(uniduni.Attr.yellow);

    try testing.expectEqual(expected, actual);
}
