module top;
    localparam real HalfClockPeriod = 25ns; // 20MHz
    localparam int unsigned Width = 8;

    typedef logic [    Width-1:0] multiplicand_t;
    typedef logic [(Width*2)-1:0] product_t;

    typedef struct {
      multiplicand_t in1;
      multiplicand_t in2;
      product_t expected;
    } test_t;

    logic clk_i = 1'b1;

    multiplicand_t data_in1_i, data_in2_i;
    product_t data_out_o;

    multiplier u_multiplier (
        .data_in1_i,
        .data_in2_i,
        .data_out_o
    );

    initial begin : setup_tracing
      string trace_file;

      if ($value$plusargs("trace=%s", trace_file)) begin
        $dumpfile(trace_file);
        $dumpvars;
      end
    end : setup_tracing

    // Toggle clock
    always #(HalfClockPeriod) clk_i <= !clk_i;

    test_t tests[] = '{
      '{in1: 2, in2: 7, expected: 14},
      '{in1: 211, in2: 98, expected: 20678},
      '{in1: 123, in2: 77, expected: 9471},
      '{in1: 0, in2: 0, expected: 0},
      '{in1: 255, in2: 255, expected: 65025}
    };
    initial begin : main
      #(HalfClockPeriod);

      foreach (tests[i]) begin : test_routine
        data_in1_i = tests[i].in1;
        data_in2_i = tests[i].in2;

        #(2*HalfClockPeriod);
        if (data_out_o != tests[i].expected) begin
          $error("expected %d, got: %d", tests[i].expected, data_out_o);
        end
      end : test_routine

      $finish;
    end : main

endmodule : top
