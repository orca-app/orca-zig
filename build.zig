const std = @import("std");
const Build = std.Build;

// These two should match the same orca version.
// @Incomplete verify our api.json and sdk versions match
// @Cleanup can we combine these?
pub const sdk_version = "test-release-4f124dd346";
pub const orca_api_commit = "4f124dd3461f48c444518ad48c6337de6bfeb72f";

pub fn build(b: *Build) !void {
    const wasm_target = target(b);
    const optimize = b.standardOptimizeOption(.{});

    const sdk: Build.LazyPath = .{
        // orca will report a nice error for us
        // if the target sdk version is missing.
        .cwd_relative = b.run(&.{
            "orca",      "sdk-path",
            "--version", sdk_version,
        }),
    };
    // escape hatch if the user needs access to the sdk for some reason.
    b.addNamedLazyPath("sdk_path", sdk);

    const orca = b.addModule("orca", .{
        .root_source_file = b.path("src/orca.zig"),
        .target = wasm_target,
        .optimize = optimize,
        .link_libc = false,
        .single_threaded = true,
    });
    orca.addObjectFile(sdk.path(b, "bin/liborca_wasm.a"));
    orca.addObjectFile(sdk.path(b, "orca-libc/lib/libc.o"));
    orca.addObjectFile(sdk.path(b, "orca-libc/lib/libc.a"));
    orca.addObjectFile(sdk.path(b, "orca-libc/lib/crt1.o"));

    const gl_gen_step = b.step("gl-api", "Generates GLES bindings to be modified and committed");
    {
        const zglgen = @import("zigglgen");
        const version = b.option(
            zglgen.GeneratorOptions.Version,
            "gles-version",
            "Generate API bindings for a specific version of GLES (default: 3.0)",
        ) orelse .@"3.0";

        const gl_bindings = zglgen.generateBindingsSourceFile(b, .{
            .api = .gles,
            .version = version,
        });
        const usf = b.addUpdateSourceFiles();
        usf.addCopyFileToSource(
            gl_bindings,
            b.fmt("src/graphics/gles{s}_DO_NOT_COMMIT.zig", .{@tagName(version)}),
        );
        gl_gen_step.dependOn(&usf.step);
    }

    const sample_step = b.step("samples", "Build sample Orca applications");
    const sample_check_step = b.step("check", "Check sample Orca applications");

    const Sample = struct {
        name: []const u8,
        root_source_file: []const u8,
        icon: ?Build.LazyPath = null,
        resource_dir: ?Build.LazyPath = null,
    };

    for ([_]Sample{
        .{
            .name = "Triangle",
            .root_source_file = "samples/triangle/src/main.zig",
        },
        .{
            .name = "General",
            .root_source_file = "samples/general/src/main.zig",
            .icon = b.path("samples/general/icon.png"),
            .resource_dir = b.path("samples/general/data"),
        },
        .{
            .name = "Clock",
            .root_source_file = "samples/clock/src/main.zig",
            .icon = b.path("samples/clock/icon.png"),
            .resource_dir = b.path("samples/clock/data"),
        },
        .{
            .name = "UI",
            .root_source_file = "samples/ui/src/main.zig",
            .resource_dir = b.path("samples/ui/data"),
        },
    }) |sample| {
        const root = b.createModule(.{
            .root_source_file = b.path(sample.root_source_file),
            .target = wasm_target,
            .optimize = optimize,
        });
        root.addImport("orca", orca);

        const sample_app = addApplication(b, .{
            .name = sample.name,
            .root_module = root,
        });
        sample_check_step.dependOn(&sample_app.step);

        sample_step.dependOn(
            &addInstallApplication(b, .{
                .app = sample_app,
                .icon = sample.icon,
                .resource_dir = sample.resource_dir,
            }).step,
        );
    }
}

pub fn target(b: *Build) Build.ResolvedTarget {
    return b.resolveTargetQuery(.{
        .cpu_arch = .wasm32,
        .os_tag = .freestanding,
        .cpu_features_add = std.Target.wasm.featureSet(&.{
            .bulk_memory,
            .nontrapping_fptoint,
        }),
    });
}

pub const ApplicationOptions = struct {
    name: []const u8,
    root_module: *Build.Module,
};
/// Creates a wasm executable configured for Orca.
/// Asserts `options.root_module.resolved_target` is correctly configured.
pub fn addApplication(b: *Build, options: ApplicationOptions) *Build.Step.Compile {
    const resolved = options.root_module.resolved_target;
    if (resolved == null or
        resolved.?.result.cpu.arch != .wasm32 or
        resolved.?.result.os.tag != .freestanding)
    {
        @panic("root module must define a target using `orca.target()`");
    }

    const app_exe = b.addExecutable(.{
        .name = options.name,
        .root_module = options.root_module,
    });
    app_exe.entry = .disabled; // See https://github.com/ziglang/zig/pull/17815
    app_exe.rdynamic = true;

    return app_exe;
}

pub const BundleOptions = struct {
    app: *Build.Step.Compile,
    icon: ?Build.LazyPath = null,
    resource_dir: ?Build.LazyPath = null,
};
/// Returns a `LazyPath` representing the base directory that contains all the
/// bundled files for an application.
pub fn bundleApplication(b: *Build, options: BundleOptions) Build.LazyPath {
    const name = options.app.name;
    const run = b.addSystemCommand(&.{
        "orca",      "bundle",
        "--name",    name,
        "--version", sdk_version,
    });
    run.setName(b.fmt("orca bundle {s}", .{name}));
    if (options.icon) |icon| {
        run.addArg("--icon");
        run.addFileArg(icon);
    }
    if (options.resource_dir) |res_dir| {
        run.addArg("--resource-dir");
        run.addDirectoryArg(res_dir);
    }
    run.addArg("--out-dir");
    const output = run.addOutputDirectoryArg(name);
    run.addArtifactArg(options.app);

    return output.path(b, name); // orca bundle creates a subdir with the app name
}

/// Bundle an application and install it to the output prefix.
/// See `orca.bundleApplication` for more control.
pub fn addInstallApplication(b: *Build, options: BundleOptions) *Build.Step.InstallDir {
    const bundle = bundleApplication(b, options);
    return b.addInstallDirectory(.{
        .source_dir = bundle,
        .install_dir = .prefix,
        .install_subdir = options.app.name,
    });
}
