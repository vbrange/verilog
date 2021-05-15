module TestBench_Aes128Encrypt(
    input clk_in);

`ifdef ICARUS
  reg clk = 1;
  always #1 clk = ~clk;

`else // VERILATOR
  wire clk = clk_in;
`endif

  reg reset_n = 0;
  reg [127:0] in;
  reg [127:0] key;
  wire [127:0] out;
  wire ready;

  reg [4:0] state;

  initial
  begin
    state = 0;
    reset_n = 0;
  end

  always @(posedge clk)
  begin
    $display("%d %x", ready, out);

    state <= state + 1;

    case (state)
    1: begin
      in <= 0;
      key <= 0;
    end

    2: begin
      reset_n <= 1;
    end

    15: $finish;
    endcase
  end

  Aes128Encrypt a (
    .clk(clk),
    .reset_n(reset_n),
    .in(in),
    .key(key),
    .out(out),
    .ready(ready)
  );
endmodule
