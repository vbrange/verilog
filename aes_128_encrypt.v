module Aes128Encrypt(
    input clk,
    input reset_n,
    input [127:0] in,
    input [127:0] key,
    output [127:0] out,
    output ready);

  localparam STATE_BUSY = 0;
  localparam STATE_IDLE = 1;

  reg state;
  reg [10:0] round;
  reg buf_ready;
  reg [127:0] buf_in;
  reg [127:0] buf_out;
  reg [127:0] buf_key;

  assign out = buf_out;
  assign ready = buf_ready;

  wire[159:0] sbox_circuit_in;
  wire[159:0] sbox_circuit;

  assign sbox_circuit_in[127:0] = buf_in;
  assign sbox_circuit_in[159:128] = buf_key[127:96];

  genvar ii;
  generate 
    for (ii=0; ii<20; ii=ii+1)
    begin
      wire x0, x1, x2, x3, x4, x5, x6, x7;

      assign x0 = sbox_circuit_in[8*ii + 0];
      assign x1 = sbox_circuit_in[8*ii + 1];
      assign x2 = sbox_circuit_in[8*ii + 2];
      assign x3 = sbox_circuit_in[8*ii + 3];
      assign x4 = sbox_circuit_in[8*ii + 4];
      assign x5 = sbox_circuit_in[8*ii + 5];
      assign x6 = sbox_circuit_in[8*ii + 6];
      assign x7 = sbox_circuit_in[8*ii + 7];

      // Based on "An Optimized S-Box Circuit Architecture for Low Power AES Design"
      // Sumio Morioka and Akashi Satoh
      // IBM Research, Tokyo Research Laboratory, IBM Japan Ltd.,
      wire a0, a1, a2, a3;

      assign a3 = x7 ^ x5;
      assign a2 = x7 ^ x6 ^ x4 ^ x3 ^ x2 ^ x1;
      assign a1 = x7 ^ x5 ^ x3 ^ x2;
      assign a0 = x7 ^ x5 ^ x3 ^ x2 ^ x1;

      wire b0, b1, b2, b3;

      assign b3 = x5 ^ x6 ^ x2 ^ x1;
      assign b2 = x6;
      assign b1 = x7 ^ x5 ^ x3 ^ x2 ^ x6 ^ x4 ^ x1;
      assign b0 = x7 ^ x5 ^ x3 ^ x2 ^ x6 ^ x0;

      wire c0, c1, c2, c3;

      assign c3 = (x5 & x1) ^ (x7 & x1) ^ (x5 & x2) ^ (x5 & x6) ^ (x5 & x7) ^ (x5 & x4) ^ (x7 & x4) ^ (x5 & x0) ^ (x7 & x0) ^ (x3 & x1) ^ (x4 & x1) ^ (x3 & x2) ^ (x2 & x4) ^ (x4 & x6) ^ (x2 & x1) ^ (x2 & x6) ^ (x6 & x1);
      assign c2 = (x6 & x1) ^ (x2 & x6) ^ (x3 & x6) ^ (x7 & x6) ^ (x1 & x0) ^ (x2 & x0) ^ (x3 & x0) ^ (x4 & x0) ^ (x6 & x0) ^ (x7 & x0) ^ (x5 & x2) ^ (x5 & x3) ^ (x2 & x4) ^ (x3 & x4) ^ (x5 & x7) ^ (x7 & x2) ^ (x5 & x6) ^ (x3 & x2) ^ (x7 & x3);
      assign c1 = (x2 & x1) ^ (x2 & x4) ^ (x5 & x4) ^ (x3 & x6) ^ (x5 & x6) ^ (x2 & x0) ^ (x3 & x0) ^ (x5 & x0) ^ (x7 & x0) ^ x1 ^ (x5 & x2) ^ (x7 &x2) ^ (x5 & x3) ^ (x5 & x7) ^ x7 ^ x2 ^ (x3 & x2) ^ x4 ^ x5;
      assign c0 = (x1 & x0) ^ (x2 & x0) ^ (x3 & x0) ^ (x5 & x0) ^ (x7 & x0) ^ (x3 & x1) ^ (x6 & x1) ^ (x3 & x6) ^ (x5 & x6) ^ (x7 & x6) ^ (x3 & x4) ^ (x7 & x4) ^ (x5 & x3) ^ (x4 & x1) ^ x2 ^ (x3 & x2) ^ (x4 & x6) ^ x6 ^ x5 ^ x3 ^ x0;

      wire d0, d1, d2, d3;

      assign d3 = (c3 & c2 & c1) ^ (c3 & c0) ^ c3 ^ c2;
      assign d2 = (c3 & c2 & c0) ^ (c3 & c0) ^ (c3 & c2 & c1) ^ (c2 & c1) ^ c2;
      assign d1 = (c3 & c2 & c1) ^ (c3 & c1 & c0) ^ c3 ^ (c2 & c0) ^ c2 ^ c1;
      assign d0 = (c3 & c2 & c0) ^ (c3 & c1 & c0) ^ (c3 & c2 & c1) ^ (c3 & c1) ^ (c3 & c0) ^ (c2 & c1 & c0) ^ c2 ^ (c2 & c1) ^ c1 ^ c0;

      wire y0, y1, y2, y3, y4, y5, y6, y7;

      assign y7 = (d3 & a0) ^ (d2 & a1) ^ (d1 & a2) ^ (d0 & a3) ^ (b2 & d3) ^ (b3 & d2) ^ (b2 & d2) ^ (d3 & a3) ^ (d3 & a1) ^ (d1 & a3) ^ (b0 & d2) ^ (b2 & d0) ^ (d3 & a2) ^ (d2 & a3) ^ (b0 & d3) ^ (b1 & d2) ^ (b2 & d1) ^ (b3 & d0);
      assign y6 = 1 ^ (a0  & d2) ^ (a2 & d0) ^ (d3 & a3) ^ (a0 & d1) ^ (a1 & d0) ^ (d3 & a2) ^ (d2 & a3) ^ (a0 & d0) ^ (d3 & a0) ^ (d2 & a1) ^ (d1 & a2) ^ (d0 & a3);
      assign y5 = 1 ^ (d3 & a3) ^ (d3 & a1) ^ (d1 & a3) ^ (d3 & a2) ^ (d2 & a3) ^ (b2 & d2) ^ (b0 & d2) ^ (b2 & d0) ^ (b3 & d3) ^ (b1 & d3) ^ (b3 & d1) ^ (d3 & a0) ^ (d2 & a1) ^ (d1 & a2) ^ (d0 & a3);
      assign y4 = (d3 & a1) ^ (d1 & a3) ^ (a0 & d0) ^ (b3 & d3) ^ (b0 & d1) ^ (b1 & d0) ^ (d3 & a0) ^ (d2 & a1) ^ (d1 & a2) ^ (d0 & a3) ^ (a1 & d1) ^ (b2 & d2) ^ (b0 & d0);
      assign y3 = (b0 & d1) ^ (b1 & d0) ^ (b0 & d2) ^ (b2 & d0) ^ (b1 & d3) ^ (b3 & d1) ^ (b0 & d0);
      assign y2 = (a0 & d2) ^ (a2 & d0) ^ (a0 & d1) ^ (a1 & d0) ^ (b1 & d1) ^ (b2 & d2) ^ (d3 & a1) ^ (d1 & a3) ^ (b0 & d2) ^ (b2 & d0) ^ (b3 & d3) ^ (a0 & d0) ^ (b0 & d3) ^ (b1 & d2) ^ (b2 & d1) ^ (b3 & d0) ^ (b0 & d0);
      assign y1 = 1 ^ (d3 & a0) ^ (d2 & a1) ^ (d1 & a2) ^ (d0 & a3) ^ (b1 & d1) ^ (b2 & d3) ^ (b3 & d2) ^ (d3 & a3) ^ (d3 & a1) ^ (d1 & a3) ^ (b3 & d3) ^ (d3 & a2) ^ (d2 & a3) ^ (b0 & d0);
      assign y0 = 1 ^ (d3 & a0) ^ (d2 & a1) ^ (d1 & a2) ^ (d0 & a3) ^ (a0 & d2) ^ (a2 & d0) ^ (b0 & d1) ^ (b1 & d0) ^ (d2 & a2) ^ (b0 & d2) ^ (b2 & d0) ^ (b1 & d3) ^ (b3 & d1) ^ (d3 & a2) ^ (d2 & a3) ^ (b0 & d0);

      assign sbox_circuit[8*ii + 7:8*ii + 0] = { y7, y6, y5, y4, y3, y2, y1, y0 };
    end  
  endgenerate

  function [127:0] ShiftRows (input [127:0] buf_state);
    integer i, j, col, row;
  begin
    for (i = 0; i < 16; i = i + 1)
    begin
      col = i / 4;
      row = i % 4;
      col = (4 + col - row) % 4;
      j = col*4 + row;

      ShiftRows[8*j+:8] = buf_state[8*i+:8];
    end
  end
  endfunction

  function [31:0] MixColumn (input [7:0] c0, input [7:0] c1, input [7:0] c2, input [7:0] c3);
  begin
    MixColumn[  7:  0] = (c3 << 1) ^ ({8 {c3[7]}} & 8'h1b) ^ (c2 << 0) ^ (c2 << 1) ^ ({8 {c2[7]}} & 8'h1b) ^ (c1 << 0) ^ (c0 << 0);
    MixColumn[ 15:  8] = (c3 << 0) ^ (c2 << 1) ^ ({8 {c2[7]}} & 8'h1b) ^ (c1 << 0) ^ (c1 << 1) ^ ({8 {c1[7]}} & 8'h1b) ^ (c0 << 0);
    MixColumn[ 23: 16] = (c3 << 0) ^ (c2 << 0) ^ (c1 << 1) ^ ({8 {c1[7]}} & 8'h1b) ^ (c0 << 0) ^ (c0 << 1) ^ ({8 {c0[7]}} & 8'h1b);
    MixColumn[ 31: 24] = (c3 << 0) ^ (c3 << 1) ^ ({8 {c3[7]}} & 8'h1b) ^ (c2 << 0) ^ (c1 << 0) ^ (c0 << 1) ^ ({8 {c0[7]}} & 8'h1b);
  end
  endfunction

  function [127:0] MixColumns (input [127:0] buf_state);
    integer i;
  begin
    for (i = 0; i < 4; i = i + 1)
    begin
      MixColumns[32*i+:32] = MixColumn(buf_state[32*i+24+:8], buf_state[32*i+16+:8], buf_state[32*i+8+:8], buf_state[32*i+0+:8]);
    end
  end
  endfunction

  reg [7:0] rcon;
  wire[31:0] key_schedule_w0 = { sbox_circuit[135:128], sbox_circuit[159:152], sbox_circuit[151:144], sbox_circuit[143:136] } ^ buf_key[31:0] ^ {24'b0, rcon};
  wire[31:0] key_schedule_w1 = key_schedule_w0 ^ buf_key[63:32];
  wire[31:0] key_schedule_w2 = key_schedule_w1 ^ buf_key[95:64];
  wire[31:0] key_schedule_w3 = key_schedule_w2 ^ buf_key[127:96];

  wire [127:0] key_schedule_circuit;
  assign key_schedule_circuit = { key_schedule_w3, key_schedule_w2, key_schedule_w1, key_schedule_w0 };

  wire[127:0] final_round_circuit;
  assign final_round_circuit[127:0] = ShiftRows(sbox_circuit[127:0]);

  wire[127:0] round_circuit;
  assign round_circuit[127:0] = MixColumns(final_round_circuit);

  always @(posedge clk)
  begin
    if (!reset_n)
    begin
      state <= STATE_BUSY;

      buf_out <= 0;
      buf_ready <= 0;
      buf_in <= in;
      buf_key <= key;

      round <= 1;
      rcon <= 8'h01;
    end
    else
    begin
      case (state)
          STATE_BUSY:
          begin
            casez (round)
              // First round.
              11'b0?????????1: buf_in <= buf_in ^ buf_key;
              // Normal rounds.
              11'b0?????????0: buf_in <= round_circuit ^ buf_key;
              // Last round.
              11'b1?????????0: buf_out <= final_round_circuit ^ buf_key;
              default:;
            endcase

            buf_key <= key_schedule_circuit;

            if (rcon[7])
              rcon <= (rcon << 1) ^ 8'h1B;
            else
              rcon <= (rcon << 1);

            if (round == 11'b10000000000)
              state <= STATE_IDLE;

            round <= round << 1;
          end

          STATE_IDLE:
          begin
            buf_ready <= 1;
          end
      endcase
    end
  end
endmodule
