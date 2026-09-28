const std = @import("std");

pub fn build(b: *std.Build) void {
    // Build for exactly what our core implements (D2, D7). Remove an entry
    // from `sub` when the core gains that extension, e.g. drop .m after M3.
    const target = b.resolveTargetQuery(.{
        .cpu_arch = .riscv64,
        .os_tag = .freestanding,
        .abi = .none,
        .cpu_model = .{ .explicit = &std.Target.riscv.cpu.generic_rv64 },
        .cpu_features_sub = std.Target.riscv.featureSet(&.{ .c, .m, .a, .f, .d }),
    });
    const optimize = b.standardOptimizeOption(.{ .preferred_optimize_mode = .ReleaseSmall });

    const hello = b.addExecutable(.{
        .name = "hello",
        .root_module = b.createModule(.{
            .root_source_file = b.path("hello/main.zig"),
            .target = target,
            .optimize = optimize,
            // Code linked at 0x8000_0000 needs medany (D7).
            .code_model = .medium,
        }),
    });
    hello.setLinkerScript(b.path("link.ld"));
    b.installArtifact(hello);

    // `zig build run`: boot it on QEMU's virt machine (D4, D5). Ctrl-A X quits.
    const qemu = b.addSystemCommand(&.{
        "qemu-system-riscv64", "-machine", "virt", "-nographic", "-bios", "none", "-kernel",
    });
    qemu.addArtifactArg(hello);
    b.step("run", "Run hello on QEMU virt").dependOn(&qemu.step);
}
