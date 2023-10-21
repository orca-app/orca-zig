## Overview
Here lies Zig bindings for the Orca project, along with some samples that demo how to setup a build.zig script to link with the orca libs, bundle your app, and run it. All bindings are contained in a single `orca.zig` file located in `src/`. 

### Warning
These bindings are in-progress and experimental. You may encounter bugs since not all the bound APIs have been tested extensively - the included samples are the only code doing so! Additionally, not all APIs have zig coverage yet, notably:
* `gles`

As more APIs get tested and ergonomics are worked out, there is a possibility of breaking changes. Please report any bugs or other issues you find on the Handmade discord in the #orca channel.

## Samples
Two samples are included:
* A general sample showing off common use APIs such as: logging, arena allocation, 
* A UI-focused sample that is essentially a port of the C UI sample in the main orca repo

### Build and run
Zig version `0.11.0` is required for the samples. Newer versions are not guaranteed to work. To build and run a given sample, `cd` into its' directory and simply run:
```
zig build run
```

This command performs the following steps:
1. Compile the orca runtime library as a wasm lib
2. Compile the app as a wasm lib and statically links it with the orca wasm lib
3. Runs the orca bundle script to bundle the compiled wasm module with the runtime and all assets into a standalone package
4. Runs the orca runtime executable inside the package, which will load and run the app's wasm module

To only build the sample, run `zig build`.
To build and bundle without running the app, use `zig build bundle`.

### Notes on build.zig
The `build.zig` is set up such that `orca.zig` is the root file, and the sample's `main.zig` is a module. This is because `orca.zig` exports the C bindings based on handlers exposed in `main.zig`, which allows the zig handlers defined in user code to return errors if they wish. See the bottom of `orca.zig` for a full list of all supported handlers and their signatures. Unless you make modifications to `orca.zig` to find your handlers in a different way, or manually export functions to match the orca function handlers yourself, it's recommended to follow the same pattern.

