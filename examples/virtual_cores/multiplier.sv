/*
 * This isn't a multiplier at the moment, but it has lofty ambitions.
 */
module multiplier (
  input clk_i,
  input rst_ni,

  input  logic [7:0] data_in1_i,
  input  logic [7:0] data_in2_i,
  output logic [7:0] data_out_o,
  output logic       data_out_valid_o
);
  logic [7:0] sum;

  adder u_adder (
    .in1     (data_in1_i),
    .in2     (data_in2_i),
    .sum,
    .carry_o (          )
  );

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      data_out_o <= 8'd0;
      data_out_valid_o <= 1'b0;
    end else begin
      data_out_o <= sum;
      data_out_valid_o <= 1'b1;
    end
  end
endmodule : multiplier
