module adder #(
  Width = 8
) (
  input  logic [Width-1:0] in1_i,
  input  logic [Width-1:0] in2_i,
  output logic [Width-1:0] sum_o,
  output logic             carry_o
);
  logic [Width:0] result;
  assign result = in1_i + in2_i;
  assign {carry_o, sum_o} = result;
endmodule : adder
