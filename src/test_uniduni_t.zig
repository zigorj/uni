const std = @import("std");
const testing = std.testing;
const uniduni_t = @import("uniduni_t.zig");

// Testing the initialization of a Uniduni_t struct.
test "Initialization of a Color struct" {
    const expected = uniduni_t.Uniduni_t;

    const alloc = testing.allocator;
    var black = uniduni_t.init(alloc, uniduni_t.Color.black);
    defer black.deinit();

    const actual = @TypeOf(black);

    try testing.expectEqual(expected, actual);
}

// Testing the assignment of a color to a Uniduni_t struct.
test "Assigning a color attribute to a Color struct" {
    const expected = uniduni_t.Color.red;

    const alloc = testing.allocator;
    var red = uniduni_t.init(alloc, expected);
    defer red.deinit();

    const actual = red.color;

    try testing.expectEqual(expected, actual);
}

// Testing the correctness of the color value.
test "Verify the correctness of the attribute's int representation" {
    const expected: u8 = 33; // Attribute.yellow
    const actual = @intFromEnum(uniduni_t.Color.yellow);

    try testing.expectEqual(expected, actual);
}
