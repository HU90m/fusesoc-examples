module full_adder (
  input logic carry_i,
  input logic in1,
  input logic in2,

  output logic sum,
  output logic carry_o
);
  logic a, b, c;
  half_adder u_first_half_adder (
    .in1,
    .in2,
    .sum(a),
    .carry(b)
  );
  half_adder u_second_half_adder (
    .in1(a),
    .in2(carry_i),
    .sum,
    .carry(c)
  );
  or u_or (carry_o, b, c);
endmodule : full_adder
