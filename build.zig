const std = @import("std");
const Build = std.Build;

// These two should match the same orca version.
// @Incomplete verify our api.json and sdk versions match
// @Cleanup can we combine these?
const sdk_version = "test-release-4f124dd346";
const orca_api_commit = "4f124dd3461f48c444518ad48c6337de6bfeb72f";

pub fn build(b: *Build) !void {
    const optimize = b.standardOptimizeOption(.{});
    const wasm_target = b.resolveTargetQuery(.{
        .cpu_arch = .wasm32,
        .os_tag = .freestanding,
        .cpu_features_add = std.Target.wasm.featureSet(&.{.bulk_memory}),
    });

    const sdk_path: Build.LazyPath = .{
        .cwd_relative = b.run(&.{
            "orca",      "sdk-path",
            "--version", sdk_version,
        }),
    };

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
        icon: ?[]const u8 = null,
        resource_dir: ?[]const u8 = null,
    };

    for ([_]Sample{
        .{
            .name = "Triangle",
            .root_source_file = "samples/triangle/src/main.zig",
        },
        .{
            .name = "General",
            .root_source_file = "samples/general/src/main.zig",
            .icon = "samples/general/icon.png",
            .resource_dir = "samples/general/data",
        },
        .{
            .name = "Clock",
            .root_source_file = "samples/clock/src/main.zig",
            .icon = "samples/clock/icon.png",
            .resource_dir = "samples/clock/data",
        },
        .{
            .name = "UI",
            .root_source_file = "samples/ui/src/main.zig",
            .resource_dir = "samples/ui/data",
        },
    }) |sample| {
        // Module structure:
        //  root = src/orca.zig
        //  app = sample/src/main.zig
        // @Incomplete: modify orca.zig so it can be used as a module instead of taking over the root

        const root = b.createModule(.{
            .root_source_file = b.path("src/orca.zig"),
            .target = wasm_target,
            .optimize = optimize,
        });
        const user_root = b.createModule(.{
            .root_source_file = b.path(sample.root_source_file),
        });
        root.addImport("user_root", user_root);
        user_root.addImport("orca", root);

        const app_wasm = b.addExecutable(.{
            .name = sample.name,
            .root_module = root,
        });
        app_wasm.entry = .disabled; // See https://github.com/ziglang/zig/pull/17815
        app_wasm.rdynamic = true;
        app_wasm.addObjectFile(sdk_path.path(b, "bin/liborca_wasm.a"));
        app_wasm.addObjectFile(sdk_path.path(b, "orca-libc/lib/libc.o"));
        app_wasm.addObjectFile(sdk_path.path(b, "orca-libc/lib/libc.a"));
        app_wasm.addObjectFile(sdk_path.path(b, "orca-libc/lib/crt1.o"));

        sample_check_step.dependOn(&app_wasm.step);

        const run_bundle = b.addSystemCommand(&.{
            "orca",      "bundle",
            "--name",    sample.name,
            "--version", sdk_version,
        });
        if (sample.icon) |icon| {
            run_bundle.addArg("--icon");
            run_bundle.addDirectoryArg(b.path(icon));
        }
        if (sample.resource_dir) |res_dir| {
            run_bundle.addArg("--resource-dir");
            run_bundle.addDirectoryArg(b.path(res_dir));
        }
        run_bundle.addArg("--out-dir");
        const bundle_output = run_bundle.addOutputDirectoryArg(sample.name);
        run_bundle.addArtifactArg(app_wasm);

        sample_step.dependOn(
            &b.addInstallDirectory(.{
                .source_dir = bundle_output.path(b, sample.name), // orca bundle creates a subdir with the app name
                .install_dir = .prefix,
                .install_subdir = sample.name,
            }).step,
        );
    }
}
