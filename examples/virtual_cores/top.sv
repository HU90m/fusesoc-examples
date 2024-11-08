module top (
   output logic modulated_o
);
    localparam HalfClockPeriod = 25ns; // 20MHz

    logic clk_i = 1'b1, rst_ni = 1'b0;

    logic [7:0] data_in1_i, data_in2_i;
    logic [15:0] data_out_o;
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
      if (data_out_o != 14) $error("expected 14, got:", data_out_o);
      if (!data_out_valid_o) $error("expected valid");

      data_in1_i = 211;
      data_in2_i = 98;

      #(2*HalfClockPeriod);
      if (data_out_o != 20678) $error("expected 20678, got:", data_out_o);
      if (!data_out_valid_o) $error("expected valid");

      data_in1_i = 123;
      data_in2_i = 77;

      #(2*HalfClockPeriod);
      if (data_out_o != 9471) $error("expected 9471, got:", data_out_o);
      if (!data_out_valid_o) $error("expected valid");

      data_in1_i = 0;
      data_in2_i = 0;

      #(2*HalfClockPeriod);
      if (data_out_o != 0) $error("expected 0, got:", data_out_o);
      if (!data_out_valid_o) $error("expected valid");

      data_in1_i = 255;
      data_in2_i = 255;

      #(2*HalfClockPeriod);
      if (data_out_o != 65025) $error("expected 65025, got:", data_out_o);
      if (!data_out_valid_o) $error("expected valid");

      #(2*HalfClockPeriod);
      $finish;
    end : main

endmodule : top
