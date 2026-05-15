# uni

![Static Badge](https://img.shields.io/badge/Zig-v.0.16.0-%23F7A41D?style=for-the-badge&logo=zig&logoColor=%23F7A41D&color=%23F7A41D)
![Static Badge](https://img.shields.io/badge/tests-passing-black?style=for-the-badge&label=Tests&color=green)

![uni image](uni.png)

`uni` is a Zig library that lets you easily colorize your strings and outputs on your code. It uses ANSI escape codes to put color and styles in your strings and outputs.

It was built on Linux, with :heart:, as part of my ongoing journey of learning Zig.

I'm so grateful for all the help I got from the [Ziggit.dev](https://ziggit.dev) community!

## Roadmap:

- [x] Normal colors
- [x] Styles
- [x] RGB
- [x] Hexadecimal
- [x] Detects terminal capacity
- [ ] Use colors only when the terminal supports it
- [ ] Supports major OSes
  - [x] Linux
  - [ ] FreeBSD
  - [ ] Windows
  - [ ] MacOS

## How to use Uni in your project?

1. Add Uni as a dependency in your `build.zig.zon` file, running the following command: `zig fetch --save git+https://github.com/menosbits/uni`
```zig
.{
    .name = "YourProject",
    .version = "0.0.0",
    .dependencies = .{
        .uni = .{
            .url = "git+https://github.com/menosbits/uni#2b4013623a29c41904a03d662a813760045aec16",
            .hash = "uni-0.9.0-tz1MSq2bAADWZhGuUZ8Ot-5k0ALjlsFMZNIO0HyIFmIZ",
        },
    },
    .paths = .{
        "...",
    },
}
```

2. Import uni in your `build.zig` file:
```zig
pub fn build(b: *std.Build) void {
   const exe = b.addExecutable(.{ ... });

   const uni = b.dependency("uni", .{
      .target = target,
      .optimize = optimize,
   });
   exe.root_module.addImport("uni", uni.module("uni"));
}
```

3. See the examples below for usage.

## Examples:

<details>
<summary>Print with custom foreground, background color and style</summary>

```zig
const std = @import("std");
const uni = @import("uni");
const Color = uni.Color;
const Style = uni.Style;

pub fn main(init: std.process.Init) !void {
    var stdout_buff: [1024]u8 = undefined;
    var stdout_file = std.Io.File.stdout();
    var stdout_writer = stdout_file.writer(init.io, &stdout_buff);
    const stdout = &stdout_writer.interface;

    const warn = uni.init().add(.{ Color.Foreground.red, Color.Background.black, Style.bold });
    try stdout.print("{s}: This is a warning!\n", .{ warn.format("WARNING") });

    try stdout.flush();
}
```

</details>

<details>
<summary>Print with main color aliases</summary>

```zig
const std = @import("std");
const uni = @import("uni");

pub fn main(init: std.process.Init) !void {
    var stdout_buff: [1024]u8 = undefined;
    var stdout_file = std.Io.File.stdout();
    var stdout_writer = stdout_file.writer(init.io, &stdout_buff);
    const stdout = &stdout_writer.interface;

    const green = uni.init().green(.foreground).bold();
    try stdout.print("{s}: success!\n", .{ green.format("GREAT") });

    const bg_green = uni.init().green(.background).bold();
    try stdout.print("{s}: success!\n", .{ bg_green.format("GREAT") });

    try stdout.flush();
}
```

</details>

<details>
<summary>Colorize a string</summary>

```zig
const std = @import("std");
const uni = @import("uni");

pub fn main(init: std.process.Init) !void {
    var stdout_buff: [1024]u8 = undefined;
    var stdout_file = std.Io.File.stdout();
    var stdout_writer = stdout_file.writer(init.io, &stdout_buff);
    const stdout = &stdout_writer.interface;

    const bright_yellow_string = uni.init().brightYellow(.foreground).format("This is a bright yellow string");
    try stdout.print("{s}\n", .{ bright_yellow_string });

    try stdout.flush();
}
```

</details>

<details>
<summary>Reuse your setted colors</summary>

```zig
const std = @import("std");
const uni = @import("uni");

pub fn main(init: std.process.Init) !void {
    var stdout_buff: [1024]u8 = undefined;
    var stdout_file = std.Io.File.stdout();
    var stdout_writer = stdout_file.writer(init.io, &stdout_buff);
    const stdout = &stdout_writer.interface;

    const magenta = uni.init().magenta(.foreground);
    try stdout.print("This is {s}. This is also a magenta word: {s}.\n", .{ magenta.format("magenta"), magenta.format("Uni") });

    try stdout.flush();
}
```

</details>

<details>
<summary>Print with RGB color</summary>

```zig
const std = @import("std");
const uni = @import("uni");
const Color = uni.Color;

pub fn main(init: std.process.Init) !void {
    var stdout_buff: [1024]u8 = undefined;
    var stdout_file = std.Io.File.stdout();
    var stdout_writer = stdout_file.writer(init.io, &stdout_buff);
    const stdout = &stdout_writer.interface;

    const red = uni.init().rgb(102, 0, 0, .foreground); // First way
    const green = uni.init().add(.{ Color.RGB.fg(0, 102, 0) }); // Second way
    const blue = uni.init().add(.{ Color.RGB.fg(0, 0, 102) });
    try stdout.print("{s}{s}{s}\n", .{ red.format("R"), green.format("G"), blue.format("B") });

    const bg_red = uni.init().rgb(102, 0, 0, .background); // First way
    const bg_green = uni.init().add(.{ Color.RGB.bg(0, 102, 0) }); // Second way
    const bg_blue = uni.init().add(.{ Color.RGB.bg(0, 0, 102) });
    try stdout.print("{s}{s}{s}\n", .{ bg_red.format("R"), bg_green.format("G"), bg_blue.format("B") });
}
```

</details>

<details>
<summary>Use uni on your existing code</summary>

```zig
const std = @import("std");
const uni = @import("uni");

pub fn main(init: std.process.Init) !void {
    var stdout_buff: [1024]u8 = undefined;
    var stdout_file = std.Io.File.stdout();
    var stdout_writer = stdout_file.writer(init.io, &stdout_buff);
    const stdout = &stdout_writer.interface;

    const uni = uni.init().cyan(.foreground);

    try uni.on(stdout);
    try stdout.print("This is a cyan string\n", .{});
    try uni.off(stdout);
    
    try stdout.print("This is a default colored string\n", .{});

    try stdout.flush();
}
```

</details>

<details>
<summary>Print with Hexadecimal code</summary>

```zig
const std = @import("std");
const uni = @import("uni");
const Color = uni.Color;

pub fn main(init: std.process.Init) !void {

    const first = uni.init().add(.{ Color.Hex.fg("#a7c080"), Color.Hex.bg("2d353b") }); // First way
    const second = uni.init().hex("A7C080", .foreground).hex("#2D353B", .background); // Second way

    try stdout.print("{s}\n", .{ first.format("We accept hexadecimal too! Yay!") });
    try stdout.print("{s}\n", .{ second.format("Everforest theme is great!") });

    try stdout.flush();
}
```

</details>
