`include "E.v"
`include "P.v"
`include "S1.v"
`include "S2.v"
`include "S3.v"
`include "S4.v"
`include "S5.v"
`include "S6.v"
`include "S7.v"
`include "S8.v"
`include "IP.v"
`include "IP_inv.v"
`include "PC1.v"
`include "PC2.v"

module f(input [32:1] R, input [48:1] K, output [32:1] OUT);
  wire [48:1] R_E;
  E E_inst(R, R_E);

  wire [48:1] T = R_E ^ K;

  wire [6:1] S1_in, S2_in, S3_in, S4_in, S5_in, S6_in, S7_in, S8_in;
  assign {S1_in, S2_in, S3_in, S4_in, S5_in, S6_in, S7_in, S8_in} = T;

  wire [4:1] S1_out, S2_out, S3_out, S4_out, S5_out, S6_out, S7_out, S8_out;
  S1 S1_inst(S1_in, S1_out);
  S2 S2_inst(S2_in, S2_out);
  S3 S3_inst(S3_in, S3_out);
  S4 S4_inst(S4_in, S4_out);
  S5 S5_inst(S5_in, S5_out);
  S6 S6_inst(S6_in, S6_out);
  S7 S7_inst(S7_in, S7_out);
  S8 S8_inst(S8_in, S8_out);

  wire [32:1] S_out = {S1_out, S2_out, S3_out, S4_out, S5_out, S6_out, S7_out, S8_out};
  P P_inst(S_out, OUT);
endmodule

module KS_left_shift(input [5:1] level, input [28:1] in, output [28:1] out);
  assign out = (level == 1 || level == 2 || level == 9 || level == 16) ?
                {in[27:1], in[28]} : {in[26:1], in[28:27]};
endmodule

module KS(input [64:1] key, output [48:1] k1,
                            output [48:1] k2,
                            output [48:1] k3,
                            output [48:1] k4,
                            output [48:1] k5,
                            output [48:1] k6,
                            output [48:1] k7,
                            output [48:1] k8,
                            output [48:1] k9,
                            output [48:1] k10,
                            output [48:1] k11,
                            output [48:1] k12,
                            output [48:1] k13,
                            output [48:1] k14,
                            output [48:1] k15,
                            output [48:1] k16);
  wire [56:1] key_pc1;
  PC1 pc1_inst(key, key_pc1);

  wire [28:1] c [0:16];
  wire [28:1] d [0:16];
  wire [48:1] k [1:16];

  assign {c[0], d[0]} = key_pc1;

  genvar i;
  generate
    for (i = 1; i <= 16; i = i + 1) begin : blk
      wire [5:1] j = i;
      KS_left_shift KS_ls_inst1(j, c[i - 1], c[i]);
      KS_left_shift KS_ls_inst2(j, d[i - 1], d[i]);
      PC2 pc2_inst({c[i], d[i]}, k[i]);
    end
  endgenerate

  assign k1 = k[1];
  assign k2 = k[2];
  assign k3 = k[3];
  assign k4 = k[4];
  assign k5 = k[5];
  assign k6 = k[6];
  assign k7 = k[7];
  assign k8 = k[8];
  assign k9 = k[9];
  assign k10 = k[10];
  assign k11 = k[11];
  assign k12 = k[12];
  assign k13 = k[13];
  assign k14 = k[14];
  assign k15 = k[15];
  assign k16 = k[16];
endmodule

module DES(input [64:1] in, input [64:1] key, output [64:1] out);
  wire [64:1] in_ip;
  IP ip_inst(in, in_ip);

  wire [32:1] l [0:16];
  wire [32:1] r [0:16];
  wire [32:1] f_val [1:16];
  assign {l[0], r[0]} = in_ip;

  wire [48:1] k [1:16];
  KS ks_inst(key, k[1], k[2], k[3], k[4], k[5], k[6], k[7], k[8], k[9],
                  k[10], k[11], k[12], k[13], k[14], k[15], k[16]);

  genvar i;
  generate
    for (i = 1; i <= 16; i = i + 1) begin : blk
      assign l[i] = r[i - 1];
      f f_inst(r[i - 1], k[i], f_val[i]);
      assign r[i] = l[i - 1] ^ f_val[i];
    end
  endgenerate

  IP_inv ip_inv_inst({r[16], l[16]}, out);
endmodule

`define ASSERT(expr) begin if (!(expr)) begin $display("FAIL"); $finish; end end

module testbench;
  reg [64:1] M;
  reg [64:1] K;
  wire [64:1] OUT;

  DES des_inst(M, K, OUT);

  initial begin
    M = 64'h85abcd1a98876543;
    K = 64'ha1b2c3d4e5f61234;
    #1
    `ASSERT(OUT == 64'h4bbd010363a955c0)
    $finish;
  end
  initial $monitor($time, " M=0x%x, K=0x%x, OUT=0x%x", M, K, OUT);
endmodule
