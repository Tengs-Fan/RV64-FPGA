// Smallest useful program: print over the UART, then power off.
// Runs on QEMU virt today and on our SoC at M2 (same memory map, D4).

const uart_thr: *volatile u8 = @ptrFromInt(0x1000_0000); // 16550 transmit register
const test_finisher: *volatile u32 = @ptrFromInt(0x0010_0000); // write 0x5555 = pass and stop

export fn _start() linksection(".text.boot") callconv(.naked) noreturn {
    asm volatile (
        \\ la sp, __stack_top
        \\ call main
        \\1: j 1b
    );
}

fn puts(s: []const u8) void {
    for (s) |c| uart_thr.* = c;
}

export fn main() void {
    puts("hello from rv64\n");
    test_finisher.* = 0x5555;
}
