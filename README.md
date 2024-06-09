![uniduni_t image](uniduni_t.jpeg)

# uniduni_t

`uniduni_t` is a Zig library that lets you easily colorize your strings and outputs on your code. It uses ANSI escape codes to put color and styles in your strings and outputs.

It was built with :heart:, as part of my ongoing journey of learning Zig (v0.12).

I'm so grateful for all the help I got from the [Ziggit.dev](https://ziggit.dev) community!

## Examples:

### Print with custom foreground, background color and style:
```
const std = @import("std");
const Uniduni_t = @import("uniduni_t.zig").Uniduni_t;
const attr = @import("attributes.zig");
const Color = attr.Color;
const Style = attr.Style;

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    const warn = Uniduni_t.init().add(.{ Color.Foreground.red, Color.Background.black, Style.bold });
    try stdout.print("{s}: This is a warning!\n", .{ warn.format("WARNING") });
}
```
### Print with main color aliases:
```
const std = @import("std");
const Uniduni_t = @import("uniduni_t.zig").Uniduni_t;

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    const green = Uniduni_t.init().green(.foreground).bold();
    try stdout.print("{s}: success!\n", .{green.format("GREAT")});

    const bg_green = Uniduni_t.init().green(.background).bold();
    try stdout.print("{s}: success!\n", .{bg_green.format("GREAT")});
}
```
### Colorize a string:
```
const std = @import("std");
const Uniduni_t = @import("uniduni_t.zig").Uniduni_t;

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    const bright_yellow_string = Uniduni_t.init().brightYellow(.foreground).format("This is a bright yellow string");
    try stdout.print("{s}\n", .{bright_yellow_string});
}
```
### Reuse your setted colors:
```
const std = @import("std");
const Uniduni_t = @import("uniduni_t.zig").Uniduni_t;

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    const magenta = Uniduni_t.init().magenta(.foreground);
    try stdout.print("This is {s}. This is also a magenta word: {s}.\n", .{ magenta.format("magenta"), magenta.format("Uniduni_t") });
}
```
### Print with RGB color:
```
const std = @import("std");
const Uniduni_t = @import("uniduni_t.zig").Uniduni_t;
const attr = @import("attributes.zig");
const Color = attr.Color;

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    const red = Uniduni_t.init().rgb(102, 0, 0, .foreground); // First way
    const green = Uniduni_t.init().add(.{Color.RGB.fg(0, 102, 0)}); // Second way
    const blue = Uniduni_t.init().add(.{Color.RGB.fg(0, 0, 102)});
    try stdout.print("{s}{s}{s}\n", .{ red.format("R"), green.format("G"), blue.format("B") });

    const bg_red = Uniduni_t.init().rgb(102, 0, 0, .background); // First way
    const bg_green = Uniduni_t.init().add(.{Color.RGB.bg(0, 102, 0)}); // Second way
    const bg_blue = Uniduni_t.init().add(.{Color.RGB.bg(0, 0, 102)});
    try stdout.print("{s}{s}{s}\n", .{ bg_red.format("R"), bg_green.format("G"), bg_blue.format("B") });
}
```
### Use uniduni_t on your existing code:
```
const std = @import("std");
const Uniduni_t = @import("uniduni_t.zig").Uniduni_t;

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    const uni = Uniduni_t.init().cyan(.foreground);

    try uni.on();
    try stdout.print("This is a cyan string\n", .{});

    try uni.off();
    try stdout.print("This is a default colored string\n", .{});
}
```
### Print with Hexadecimal code:
```
const std = @import("std");

const Uniduni_t = @import("uniduni_t.zig").Uniduni_t;
const attr = @import("attributes.zig");
const Color = attr.Color;

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    const first = Uniduni_t.init().add(.{ Color.Hex.fg("#a7c080"), Color.Hex.bg("2d353b") }); // First way
    const second = Uniduni_t.init().hex("A7C080", .foreground).hex("#2D353B", .background); // Second way
    try stdout.print("{s}\n", .{first.format("We accept hexadecimal too! Yay!")});
    try stdout.print("{s}\n", .{second.format("Everforest theme is great!")});
}
```
## TODO:
- Detect TTY color and print accordingly
