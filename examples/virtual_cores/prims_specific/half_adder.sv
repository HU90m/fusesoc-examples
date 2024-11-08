module half_adder (
  input logic in1,
  input logic in2,

  output logic sum,
  output logic carry
);
  xor u_xor (sum, in1, in2);
  and u_and (carry, in1, in2);
endmodule : half_adder

