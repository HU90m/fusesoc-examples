// SPDX-FileCopyrightText: lowRISC contributors
// SPDX-License-Identifier: Apache-2.0
// SPDX-FileContributor: Hugo McNally

/*
 * A simple unsigned array multiplier
 */
module array_multiplier #(
  parameter int unsigned Width = 8
) (
  input  logic [ Width   -1:0] data_in1_i,
  input  logic [ Width   -1:0] data_in2_i,
  output logic [(Width*2)-1:0] data_out_o
);
  // Partial products.
  logic [Width-1:0] pp[Width];

  for (genvar idx = 0; idx < Width; ++idx) begin : gen_partial_products
    assign pp[idx] =  data_in1_i & {Width{data_in2_i[idx]}};
  end : gen_partial_products

  // Intermediate sum and carry.
  logic [Width-1:0] s[Width];
  logic c[Width];

  assign {c[0], s[0]} = {1'b0, pp[0]};

  for (genvar i = 0; i < Width-1; ++i) begin : adders
    adder #(
      .Width(Width)
    ) u_adder (
      .in1_i ({c[i], s[i][Width-1:1]}),
      .in2_i (pp[i+1]),
      .sum_o (s[i+1]),
      .carry_o (c[i+1])
    );
  end : adders

  // Output from intermediates
  assign data_out_o[(Width*2)-1:Width-1] = {c[Width-1], s[Width-1]};

  for (genvar idx = 0; idx < Width-1; ++idx) begin : gen_output_lower_bits
    assign data_out_o[idx] = s[idx][0];
  end : gen_output_lower_bits
endmodule : array_multiplier
