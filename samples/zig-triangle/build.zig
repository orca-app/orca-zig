const std = @import("std");
const builtin = @import("builtin");

const OrcaDir = struct {
    arena: std.mem.Allocator,
    dir: []u8,

    fn init(arena_allocator: *std.heap.ArenaAllocator) !OrcaDir {
        var arena = arena_allocator.allocator();
        var dir = switch (builtin.os.tag) {
            .windows => try std.fs.getAppDataDir(arena, "orca"),
            else => blk: {
                if (std.os.getenv("HOME")) |home_z| {
                    var home_path = std.mem.sliceTo(home_z, 0);
                    var joined = try std.fs.path.join(arena, &[_][]const u8{ home_path, ".orca" });
                    break :blk joined;
                }
                return error.InvalidHomePath;
            },
        };

        return .{
            .arena = arena,
            .dir = dir,
        };
    }

    fn subpath(self: *OrcaDir, path: []const u8) ![]const u8 {
        return try std.fs.path.join(self.arena, &[_][]const u8{ self.dir, path });
    }

    fn argpath(self: *OrcaDir, prefix: []const u8, path: []const u8) ![]const u8 {
        var joined_path = try self.subpath(path);
        var buf = try self.arena.alloc(u8, prefix.len + joined_path.len);
        @memcpy(buf[0..prefix.len], prefix);
        @memcpy(buf[prefix.len..], joined_path);
        return buf;
    }
};

pub fn build(b: *std.Build) !void {
    const optimize = b.standardOptimizeOption(.{});
    var wasm_target = std.zig.CrossTarget{
        .cpu_arch = .wasm32,
        .os_tag = .freestanding,
    };
    wasm_target.cpu_features_add.addFeature(@intFromEnum(std.Target.wasm.Feature.bulk_memory));

    var arena_allocator = std.heap.ArenaAllocator.init(b.allocator);
    defer arena_allocator.deinit();

    var orca_dir = try OrcaDir.init(&arena_allocator);

    var orca_sources = try std.ArrayList([]const u8).initCapacity(b.allocator, 128);
    defer orca_sources.deinit();

    {
        try orca_sources.append(try orca_dir.subpath("src/orca.c"));

        const libc_shim_path = try orca_dir.subpath("src/libc-shim/src");
        var libc_shim_dir = try std.fs.cwd().openIterableDir(libc_shim_path, .{});
        var walker = try libc_shim_dir.walk(b.allocator);
        defer walker.deinit();

        while (try walker.next()) |entry| {
            const extension = std.fs.path.extension(entry.path);
            if (std.mem.eql(u8, extension, ".c")) {
                var abs_path = try libc_shim_dir.dir.realpathAlloc(orca_dir.arena, entry.path);
                try orca_sources.append(abs_path);
            }
        }
    }

    const orca_compile_opts = [_][]const u8{
        "-D__ORCA__",
        "--no-standard-libraries",
        "-fno-builtin",
        "-g",
        "-O2",
        "-mexec-model=reactor",
        "-fno-sanitize=undefined",
        try orca_dir.argpath("-isystem ", "src/libc-shim/include"), // space at end of -isystem is intentional
        try orca_dir.argpath("-I", "src"),
        try orca_dir.argpath("-I", "src/ext"),
        "-Wl,--export-dynamic",
    };

    var orca_lib = b.addStaticLibrary(.{
        .name = "orca",
        .target = wasm_target,
        .optimize = optimize,
    });
    orca_lib.rdynamic = true;
    orca_lib.addIncludePath(.{ .path = try orca_dir.subpath("src") });
    orca_lib.addIncludePath(.{ .path = try orca_dir.subpath("src/libc-shim/include") });
    orca_lib.addIncludePath(.{ .path = try orca_dir.subpath("src/ext") });
    orca_lib.addCSourceFiles(orca_sources.items, &orca_compile_opts);

    // builds the wasm module out of the orca C sources and main.zig
    const app_module: *std.Build.Module = b.createModule(.{
        .source_file = .{ .path = "src/main.zig" },
    });
    const wasm_lib = b.addSharedLibrary(.{
        .name = "module",
        .root_source_file = .{ .path = "../../src/orca.zig" },
        .target = wasm_target,
        .optimize = optimize,
    });
    wasm_lib.rdynamic = true;
    wasm_lib.addIncludePath(.{ .path = try orca_dir.subpath("src") });
    wasm_lib.addIncludePath(.{ .path = try orca_dir.subpath("src/libc-shim/include") });
    wasm_lib.addIncludePath(.{ .path = try orca_dir.subpath("ext") });
    wasm_lib.addModule("app", app_module);
    wasm_lib.linkLibrary(orca_lib);

    // copies the wasm module into zig-out/wasm_lib
    b.installArtifact(wasm_lib);

    // Runs the orca build command
    const bundle_cmd_str = [_][]const u8{ "orca", "bundle", "--orca-dir", orca_dir.dir, "--name", "Triangle", "zig-out/lib/module.wasm" };
    var bundle_cmd = b.addSystemCommand(&bundle_cmd_str);
    bundle_cmd.step.dependOn(b.getInstallStep());

    const bundle_step = b.step("bundle", "Runs the orca toolchain to bundle the wasm module into an orca app.");
    bundle_step.dependOn(&bundle_cmd.step);

    // Runs the app
    const run_cmd_windows = [_][]const u8{"Triangle/bin/Triangle.exe"};
    const run_cmd_macos = [_][]const u8{"Triangle.app/Contents/MacOS/orca_runtime"};
    const run_cmd_str: []const []const u8 = switch (builtin.os.tag) {
        .windows => &run_cmd_windows,
        .macos => &run_cmd_macos,
        else => @compileError("unsupported platform"),
    };
    var run_cmd = b.addSystemCommand(run_cmd_str);
    run_cmd.step.dependOn(&bundle_cmd.step);

    const run_step = b.step("run", "Runs the bundled app using the Orca runtime.");
    run_step.dependOn(&run_cmd.step);
}
