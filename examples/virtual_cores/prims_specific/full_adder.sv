module full_adder (
  input logic carry_i,
  input logic in1_i,
  input logic in2_i,

  output logic sum_o,
  output logic carry_o
);
  logic a, b, c;
  half_adder u_first_half_adder (
    .in1_i,
    .in2_i,
    .sum_o(a),
    .carry_o(b)
  );
  half_adder u_second_half_adder (
    .in1_i(a),
    .in2_i(carry_i),
    .sum_o,
    .carry_o(c)
  );
  or u_or (carry_o, b, c);
endmodule : full_adder
