module half_adder (
  input logic in1_i,
  input logic in2_i,

  output logic sum_o,
  output logic carry_o
);
  assign sum_o = in1_i ^ in2_i;
  assign carry_o = in1_i & in2_i;
endmodule : half_adder
