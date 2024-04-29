![uniduni_t image](https://codeberg.org/attachments/f0ba7e70-05fe-4f6a-9aa8-1f8bbb087d15)

# uniduni_t

*uniduni_t* is a Zig library that lets you easily colorize your strings and outputs on your code. It uses ANSI escape codes to put color and styles in your strings and outputs.

It was built with :heart:, as part of my ongoing journey of learning Zig.

## Examples:

### Print with custom foreground, background color and style:
```
const std = @import("std");
const uniduni_t = @import("uniduni_t.zig");

pub fn main() !void {
  const alloc = std.heap.page_allocator;
  var cp = uniduni_t.ColorPrint.init(alloc);
  defer cp.deinit();

  cp.add(.{ uniduni_t.ForegroundColor.green, uniduni_t.BackgroundColor.magenta, uniduni_t.Style.italic });
  try cp.print("This is an italic green text on a magenta background\n");
}
```
### Print with main color aliases:
```
const std = @import("std");
const uniduni_t = @import("uniduni_t.zig");

pub fn main() !void {
  const alloc = std.heap.page_allocator;
  var cp = uniduni_t.ColorPrint.init(alloc);
  defer cp.deinit();

  try cp.black("This is a black foreground text\n");
  try cp.red("This is a red foreground text\n");
  try cp.green("This is a green foreground text\n");
  try cp.yellow("This is a yellow foreground text\n");
  try cp.blue("This is a blue foreground text\n");
  try cp.magenta("This is a magenta foreground text\n");
  try cp.cyan("This is a cyan foreground text\n");
  try cp.white("This is a white foreground text\n");
  try cp.default("This is your default text color\n");
}
```
### Print with RGB color:
```
const std = @import("std");
const uniduni_t = @import("uniduni_t.zig");

pub fn main() !void {
  const alloc = std.heap.page_allocator;
  var cp = uniduni_t.ColorPrint.init(alloc);
  defer cp.deinit();

  cp.add(.{ uniduni_t.Color{ .rgb = uniduni_t.RGB{ .r = 80, .g = 250, .b = 123, .t = uniduni_t.ColorType.foreground } }, uniduni_t.Color{ .rgb = uniduni_t.RGB{ .r = 40, .g = 42, .b = 54, .t = uniduni_t.ColorType.background } } });

  try cp.print("Dracula\n");
}
```
### Reuse your setted colors:
```
const std = @import("std");
const uniduni_t = @import("uniduni_t.zig");

pub fn main() !void {
  const alloc = std.heap.page_allocator;
  var cp = uniduni_t.ColorPrint.init(alloc);
  defer cp.deinit();

  cp.add(.{uniduni_t.Color{ .foreground = uniduni_t.ForegroundColor.red }});
  try cp.print("This is a red text\n");
  try cp.print("This is also a red text\n");
}
```
### Colorize a string:
```
const std = @import("std");
const uniduni_t = @import("uniduni_t.zig");

pub fn main() !void {
  const alloc = std.heap.page_allocator;
  var cp = uniduni_t.ColorPrint.init(alloc);
  defer cp.deinit();

    cp.add(.{ uniduni_t.Color{ .foreground = uniduni_t.ForegroundColor.green }, uniduni_t.Color{ .background = uniduni_t.BackgroundColor.magenta }, uniduni_t.Style.italic });

  const my_colorized_string: []const u8 = try cp.colorize("This is my colorized string\n");

  const stdout = std.io.getStdOut().writer();
  try stdout.print("{}\n", .{my_colorized_string});
}
```
### Use uniduni_t on your existing code:
```
const std = @import("std");
const uniduni_t = @import("uniduni_t.zig");

pub fn main() !void {
  const alloc = std.heap.page_allocator;
  var cp = uniduni_t.ColorPrint.init(alloc);
  defer cp.deinit();

  // Your existing code

  cp.add(.{uniduni_t.Color{ .foreground = uniduni_t.ForegroundColor.red }});
  try cp.set();

  // Your existing code printing something in red
  const stdout = std.io.getStdOut().writer();
  try stdout.print("This is your code printing something in red\n", .{});

  // Don't forget to unset ColorPrint to default color
  try cp.unset();

  // Your code printing something in default color
  try stdout.print("This is your code printing something in default color\n", .{});
}
```
## TODO:
- Format printing;
- Use RGB with normal colors;
- Print with more than one style;
- Use your own writer;
