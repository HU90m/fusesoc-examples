module top (
   output logic modulated_o
);
    localparam HalfClockPeriod = 25ns; // 20MHz

    logic clk_i = 1'b1, rst_ni = 1'b0;

    logic [7:0] data_in1_i, data_in2_i, data_out_o;
    logic data_out_valid_o;

    multiplier u_multiplier (
        .clk_i,
        .rst_ni,

        .data_in1_i,
        .data_in2_i,
        .data_out_o,
        .data_out_valid_o
    );

    // Toggle clock
    always #(HalfClockPeriod) clk_i <= !clk_i;

    initial begin : main
      string trace_file;

      if ($value$plusargs("trace=%s", trace_file)) begin
        $dumpfile(trace_file);
        $dumpvars;
      end

      #(HalfClockPeriod);
      rst_ni = 1;
      data_in1_i = 2;
      data_in2_i = 7;

      #(2*HalfClockPeriod);
      data_in1_i = 211;
      data_in2_i = 98;

      #(2*HalfClockPeriod);
      data_in1_i = 123;
      data_in2_i = 77;

      #(4*HalfClockPeriod);
      $finish;
    end : main

endmodule : top
