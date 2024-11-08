// A Ripple Adder
module adder #(
  Width = 8
) (
  input  logic [Width-1:0] in1,
  input  logic [Width-1:0] in2,
  output logic [Width-1:0] sum,
  output logic             carry_o
);
  logic [Width-1:0] carry;
  assign carry_o = carry[Width-1];

  half_adder u_half_adder (
    .in1(in1[0]),
    .in2(in2[0]),
    .sum(sum[0]),
    .carry(carry[0])
  );
  for (genvar i = 1; i < Width; ++i) begin : full_adders
    full_adder u_full_adder (
      .carry_i(carry[i-1]),

      .in1(in1[i]),
      .in2(in2[i]),
      .sum(sum[i]),

      .carry_o(carry[i])
    );
  end : full_adders
endmodule : adder
