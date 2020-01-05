module main(input [64:1] key_in, output [64:1] key_out);
    assign key1 = key_in[64:33];
  assign key2 = key_in[32:1];

  wire [64:1] ko;
  IP i1(key_in, ko);
  IP_inv i2(ko, key_out);
endmodule