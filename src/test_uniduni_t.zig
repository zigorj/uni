const std = @import("std");
const testing = std.testing;
const uniduni_t = @import("uniduni_t.zig");

// Testing the initialization of a Color struct.
test "Initialization of a Color struct" {
    const expected = uniduni_t.Color;

    var alloc = testing.allocator;
    var color_struct = uniduni_t.Color.init(alloc);
    defer color_struct.deinit();

    const actual = @TypeOf(color_struct);

    try testing.expectEqual(expected, actual);
}

// Testing the assignment of a color attribute to a Color struct.
test "Assigning a color attribute to a Color struct" {
    const alloc = testing.allocator;
    var color_struct = uniduni_t.Color.init(alloc);
    defer color_struct.deinit();

    var expected = uniduni_t.Attribute.black;
    try color_struct.setAttribute(expected);
    var actual = color_struct.options.pop();

    try testing.expectEqual(expected, actual);

    expected = uniduni_t.Attribute.green;
    try color_struct.setGreen();
    actual = color_struct.options.pop();

    try testing.expectEqual(expected, actual);
}

// Testing the correctness of the attribute's int representation.
test "Verify the correctness of the attribute's int representation" {
    const expected: u8 = 33; // Attribute.yellow
    const actual = @intFromEnum(uniduni_t.Attribute.yellow);

    try testing.expectEqual(expected, actual);
}
