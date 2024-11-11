// A wallace tree multiplier
module wallace_tree_multiplier (
  input  logic [3:0] data_in1_i,
  input  logic [3:0] data_in2_i,
  output logic [7:0] data_out_o
);
  // Partial products.
  logic [3:0] pp[4];

  for (genvar idx = 0; idx < 4; ++idx) begin : gen_partial_products
    assign pp[idx] =  data_in1_i & {4{data_in2_i[idx]}};
  end : gen_partial_products

  // First stage.
  logic [3:0] stage1_sum, stage1_carry;

  half_adder u_half_adder_stage1_0(
    .in1_i  (pp[0][1]),
    .in2_i  (pp[1][0]),
    .sum_o  (stage1_sum[0]),
    .carry_o(stage1_carry[0])
  );
  full_adder u_full_adder_stage1_1(
    .carry_i(pp[0][2]),
    .in1_i  (pp[1][1]),
    .in2_i  (pp[2][0]),
    .sum_o  (stage1_sum[1]),
    .carry_o(stage1_carry[1])
  );
  full_adder u_full_adder_stage1_2(
    .carry_i(pp[1][2]),
    .in1_i  (pp[2][1]),
    .in2_i  (pp[3][0]),
    .sum_o  (stage1_sum[2]),
    .carry_o(stage1_carry[2])
  );
  half_adder u_half_adder_stage1_2(
    .in1_i  (pp[2][2]),
    .in2_i  (pp[3][1]),
    .sum_o  (stage1_sum[3]),
    .carry_o(stage1_carry[3])
  );

  // Second stage.
  logic [3:0] stage2_sum, stage2_carry;

  half_adder u_half_adder_stage2_0(
    .in1_i  (stage1_carry[0]),
    .in2_i  (stage1_sum[1]),
    .sum_o  (stage2_sum[0]),
    .carry_o(stage2_carry[0])
  );
  full_adder u_full_adder_stage2_1(
    .carry_i(stage1_carry[1]),
    .in1_i  (stage1_sum[2]),
    .in2_i  (pp[0][3]),
    .sum_o  (stage2_sum[1]),
    .carry_o(stage2_carry[1])
  );
  full_adder u_full_adder_stage2_2(
    .carry_i(stage1_carry[2]),
    .in1_i  (stage1_sum[3]),
    .in2_i  (pp[1][3]),
    .sum_o  (stage2_sum[2]),
    .carry_o(stage2_carry[2])
  );
  full_adder u_full_adder_stage2_3(
    .carry_i(stage1_carry[3]),
    .in1_i  (pp[2][3]),
    .in2_i  (pp[3][2]),
    .sum_o  (stage2_sum[3]),
    .carry_o(stage2_carry[3])
  );

  // Final stage.
  assign data_out_o[2:0] = {
    stage2_sum[0],
    stage1_sum[0],
    pp[0][0]
  };
  adder #(
    .Width(4)
  ) u_adder (
    .in1_i({pp[3][3], stage2_sum[3:1]}),
    .in2_i(stage2_carry),
    .sum_o(data_out_o[6:3]),
    .carry_o(data_out_o[7])
  );
endmodule : wallace_tree_multiplier
