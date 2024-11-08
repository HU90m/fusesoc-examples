// A Ripple Adder
module adder #(
  Width = 8
) (
  input  logic [Width-1:0] in1_i,
  input  logic [Width-1:0] in2_i,
  output logic [Width-1:0] sum_o,
  output logic             carry_o
);
  logic [Width-1:0] carry;
  assign carry_o = carry[Width-1];

  half_adder u_half_adder (
    .in1_i(in1_i[0]),
    .in2_i(in2_i[0]),
    .sum_o(sum_o[0]),
    .carry_o(carry[0])
  );
  for (genvar i = 1; i < Width; ++i) begin : full_adders
    full_adder u_full_adder (
      .carry_i(carry[i-1]),

      .in1_i(in1_i[i]),
      .in2_i(in2_i[i]),
      .sum_o(sum_o[i]),

      .carry_o(carry[i])
    );
  end : full_adders
endmodule : adder
