// SPDX-FileCopyrightText: lowRISC contributors
// SPDX-License-Identifier: Apache-2.0
// SPDX-FileContributor: Hugo McNally

// Carry look ahead adder
module adder #(
  parameter int unsigned Width = 8
) (
  input  logic [Width-1:0] in1_i,
  input  logic [Width-1:0] in2_i,
  output logic [Width-1:0] sum_o,
  output logic             carry_o
);
  // verilator lint_off UNOPTFLAT
  logic [Width-1:0] carry;
  // verilator lint_on UNOPTFLAT

  logic [Width-1:0] carry_gen, carry_prop, carry_shifted;

  assign carry_gen  = in1_i & in2_i;
  assign carry_prop = in1_i | in2_i;

  assign carry_shifted = carry << 1;
  assign carry = carry_gen | (carry_prop & carry_shifted);

  assign carry_o = carry[Width-1];

  half_adder u_half_adder (
    .in1_i(in1_i[0]),
    .in2_i(in2_i[0]),
    .sum_o(sum_o[0]),
    .carry_o()
  );
  for (genvar i = 1; i < Width; ++i) begin : full_adders
    full_adder u_full_adder (
      .carry_i(carry[i-1]),

      .in1_i(in1_i[i]),
      .in2_i(in2_i[i]),
      .sum_o(sum_o[i]),

      .carry_o()
    );
  end : full_adders
endmodule : adder
