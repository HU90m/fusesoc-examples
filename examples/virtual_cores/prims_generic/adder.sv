module adder #(
  Width = 8
) (
  input  logic [Width-1:0] in1,
  input  logic [Width-1:0] in2,
  output logic [Width-1:0] sum,
  output logic             carry_o
);
  logic [Width:0] result;
  assign result = in1 + in2;
  assign {carry_o, sum} = result;
endmodule : adder
