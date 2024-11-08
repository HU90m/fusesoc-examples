/*
  Single-cycle unsigned multiplier
 */
module multiplier (
  input clk_i,
  input rst_ni,

  input  logic  [7:0] data_in1_i,
  input  logic  [7:0] data_in2_i,
  output logic [15:0] data_out_o,
  output logic        data_out_valid_o
);
  // Partial products
  logic [7:0] [7:0] pp;
  // Intermediate sum and carry.
  // Unrolled to avoid UNOPTFLAT warnings from Verilator.
  logic [7:0] s0;
  logic c0;
  logic [7:0] s1;
  logic c1;
  logic [7:0] s2;
  logic c2;
  logic [7:0] s3;
  logic c3;
  logic [7:0] s4;
  logic c4;
  logic [7:0] s5;
  logic c5;
  logic [7:0] s6;
  logic c6;
  // Final result
  logic [15:0] result;

  // Generate partial products
  for (genvar ii = 0; ii < 8; ii++) begin : g_partial_products
    assign pp[ii] = {8{data_in1_i[ii]}} & data_in2_i;
  end

  // Adders
  adder #(
    .Width(8)
  ) u_adder_0 (
    .in1_i ({1'b0, pp[0][7:1]}),
    .in2_i (pp[1]),
    .sum_o (s0),
    .carry_o (c0)
  );
  adder #(
    .Width(8)
  ) u_adder_1 (
    .in1_i ({c0, s0[7:1]}),
    .in2_i (pp[2]),
    .sum_o (s1),
    .carry_o (c1)
  );
  adder #(
    .Width(8)
  ) u_adder_2 (
    .in1_i ({c1, s1[7:1]}),
    .in2_i (pp[3]),
    .sum_o (s2),
    .carry_o (c2)
  );
  adder #(
    .Width(8)
  ) u_adder_3 (
    .in1_i ({c2, s2[7:1]}),
    .in2_i (pp[4]),
    .sum_o (s3),
    .carry_o (c3)
  );
  adder #(
    .Width(8)
  ) u_adder_4 (
    .in1_i ({c3, s3[7:1]}),
    .in2_i (pp[5]),
    .sum_o (s4),
    .carry_o (c4)
  );
  adder #(
    .Width(8)
  ) u_adder_5 (
    .in1_i ({c4, s4[7:1]}),
    .in2_i (pp[6]),
    .sum_o (s5),
    .carry_o (c5)
  );
  adder #(
    .Width(8)
  ) u_adder_6 (
    .in1_i ({c5, s5[7:1]}),
    .in2_i (pp[7]),
    .sum_o (s6),
    .carry_o (c6)
  );

  // Assemble final result
  assign result = {c6, s6, s5[0], s4[0], s3[0], s2[0], s1[0], s0[0], pp[0][0]};

  // Register
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      data_out_o <= 16'd0;
      data_out_valid_o <= 1'b0;
    end else begin
      data_out_o <= result;
      data_out_valid_o <= 1'b1;
    end
  end
endmodule : multiplier
