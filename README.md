## Overview
Here lies Zig bindings for the Orca project, along with some samples that demo how to setup a build.zig script to link with the orca libs, bundle your app, and run it.

### Warning
These bindings are in-progress and experimental. You may encounter bugs since not all the bound APIs have been tested extensively - the included samples are the only code doing so!

As more APIs get tested and ergonomics are worked out, there is a possibility of breaking changes. Please report any bugs or other issues you find on the Handmade discord in the #orca channel.

### Why not use the C headers?
Because we want to improve Orca's API metadata for everyone. By using `api.json` as our only Source of Truth, any gaps or missing/ambiguous types in the bindings highlight missing information in the metadata. Once the missing information is upstreamed, all other bindings projects can benefit, *including the C API*.

## Usage
First you must have installed the orca runtime (specifically the version these bindings target) and ensured the `orca` executable is in your `PATH`. Zig version `0.14` is required. Then fetch the package:

```sh
zig fetch --save git+https://github.com/orca-app/orca-zig.git
```

Next, setup your `build.zig`:
```zig
const std = @import("std");
const orca = @import("orca");
pub fn build(b: *std.Build) void {
    const optimize = b.standardOptimizeOption(.{});
    const app_wasm = orca.addApplication(b, .{
        .name = "your_app",
        .root_module = b.createModule(.{
            .root_source_file = b.path("main.zig"),
            .target = orca.target(b),
            .optimize = optimize,
        }),
        .sdk_path = orca.sdkPath(b),
    });

    const orca_dep = b.dependency("orca", .{ .optimize = optimize });
    app_wasm.root_module.addImport("orca", orca_dep.module("orca"));

    b.getInstallStep().dependOn(
        &orca.addInstallApplication(b, .{ .app = app_wasm }).step,
    );
}
```
This script performs the following steps:

1. Run `orca sdk-path` to find the corresponding version of the sdk for these bindings
2. Compile the app as a wasm library and statically link it with the Orca wasm library
3. Runs the `orca bundle` script to bundle the compiled wasm module with the runtime and all assets into a standalone package in the prefix directory

### Event Hooks
Applications hook into Orca's event loop by exporting handlers to the host runtime. These bindings provide wrappers which can catch and report Zig errors that bubble up out of your application. They can be used like so:
```zig
// In the root source file
const orca = @import("orca");
pub const panic = orca.panic; // You'll probably want to use our panic handler too
comptime {
    // This step is important!
    orca.exportEventHandlers();
}
pub fn onInit() void {
    // ...
}
pub fn onResize(width: u32, height: u32) !void {
    // ...
}
// etc...
```
Of course, you can always export these symbols manually if you prefer. See [`src/orca.zig`](./src/orca.zig) for more detail.

## Samples
* A [general](./samples/general) sample showing off common use APIs such as: logging, arena allocation, file IO, vector image drawing, etc.
* Ports of the samples in the main Orca repo: [UI](./samples/ui), [Triangle](./samples/triangle), and [Clock](./samples/clock).

### Build and run
To build the samples simply run:
```sh
zig build samples
```
To run a sample:
```sh
./zig-out/$sample/bin/$sample
```
This runs the orca runtime executable inside the package, which will load and run the app's wasm module.
