// M0 smoke test for the build flow: the LEDs show the top bits of a free-running counter.
module blinky (
    input  logic       clk_50m,
    input  logic       rst_n,
    output logic [7:0] led
);
  logic [31:0] count;

  always_ff @(posedge clk_50m) begin
    if (!rst_n) count <= '0;
    else count <= count + 1;
  end

  assign led = count[31:24];  // bit 24 toggles about every 0.34 s at 50 MHz
endmodule
