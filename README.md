![uniduni_t image](https://codeberg.org/attachments/f0ba7e70-05fe-4f6a-9aa8-1f8bbb087d15)

# uniduni_t

`uniduni_t` is a Zig library that lets you easily colorize your strings and outputs on your code. It uses ANSI escape codes to put color and styles in your strings and outputs.

It was built with :heart:, as part of my ongoing journey of learning Zig.

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
    const green = Uniduni_t.init().green().bold();
    try stdout.print("{s}: success!\n", .{green.format("GREAT")});
}
```
### Colorize a string:
```
const std = @import("std");
const Uniduni_t = @import("uniduni_t.zig").Uniduni_t;

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    const bright_yellow_string = Uniduni_t.init().brightYellow().format("This is a bright yellow string");
    try stdout.print("{s}\n", .{bright_yellow_string});
}
```
### Reuse your setted colors:
```
const std = @import("std");
const Uniduni_t = @import("uniduni_t.zig").Uniduni_t;

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    const magenta = Uniduni_t.init().magenta();
    try stdout.print("This is {s}. This is also a magenta word: {s}.\n", .{ magenta.format("magenta"), magenta.format("Uniduni_t") });
}
```
### Print with RGB color:
```
```
### Use uniduni_t on your existing code:
```
```
## TODO:
- Add RGB support
- Add hex support
- Detect TTY
