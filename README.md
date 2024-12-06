## Overview
Here lies Zig bindings for the Orca project, along with some samples that demo how to setup a build.zig script to link with the orca libs, bundle your app, and run it.

### Warning
These bindings are in-progress and experimental. You may encounter bugs since not all the bound APIs have been tested extensively - the included samples are the only code doing so!

As more APIs get tested and ergonomics are worked out, there is a possibility of breaking changes. Please report any bugs or other issues you find on the Handmade discord in the #orca channel.

## Samples
* A general sample showing off common use APIs such as: logging, arena allocation, file IO, vector image drawing, etc.
* Ports of the samples in the main Orca repo: UI and Triangle.

### Build and run
First you must have installed the orca runtime and ensured the `orca` executable is in your `PATH`.

Zig version `0.13.0` is required to build the samples. To build the samples simply run:
```sh
zig build samples
```

This command performs the following steps:

1. Compile the app as a wasm library and statically links it with the orca wasm library

2. Runs the orca bundle script to bundle the compiled wasm module with the runtime and all assets into a standalone package

To run a sample:
```sh
./zig-out/$sample/bin/$sample
```
This runs the orca runtime executable inside the package, which will load and run the app's wasm module.

### Notes on build.zig
The `build.zig` is set up such that `orca.zig` is the root file, and the sample's `main.zig` is a module. This is because `orca.zig` exports the C bindings based on handlers exposed in `main.zig`, which allows the zig handlers defined in user code to return errors if they wish. See the bottom of `orca.zig` for a full list of all supported handlers and their signatures. Unless you make modifications to `orca.zig` to find your handlers in a different way, or manually export functions to match the orca function handlers yourself, it's recommended to follow the same pattern.
