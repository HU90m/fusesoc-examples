// SPDX-FileCopyrightText: lowRISC contributors
// SPDX-License-Identifier: Apache-2.0
// SPDX-FileContributor: Hugo McNally

module top;
    localparam real HalfClockPeriod = 25ns; // 20MHz
    localparam int unsigned Width = 4;

    typedef logic [    Width-1:0] multiplicand_t;
    typedef logic [(Width*2)-1:0] product_t;

    typedef struct {
      multiplicand_t multiplicand;
      multiplicand_t multiplier;
      product_t expected;
    } test_t;

    logic clk_i = 1'b1;

    multiplicand_t multiplicand, multiplier;
    product_t product_array, product_wallace_tree;

    array_multiplier #(
      .Width(Width)
    ) u_array_multiplier (
        .data_in1_i (multiplicand),
        .data_in2_i (multiplier),
        .data_out_o (product_array)
    );

    wallace_tree_multiplier u_wallace_tree_multiplier (
        .data_in1_i (multiplicand),
        .data_in2_i (multiplier),
        .data_out_o (product_wallace_tree)
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
      '{multiplicand: 2, multiplier: 7, expected: 14},
      '{multiplicand: 13, multiplier: 6, expected: 78},
      '{multiplicand: 5, multiplier: 14, expected: 70},
      '{multiplicand: 0, multiplier: 0, expected: 0},
      '{multiplicand: 0, multiplier: 5, expected: 0},
      '{multiplicand: 11, multiplier: 1, expected: 11},
      '{multiplicand: 15, multiplier: 15, expected: 225}
    };
    initial begin : main
      #(HalfClockPeriod);

      foreach (tests[i]) begin : test_routine
        multiplicand = tests[i].multiplicand;
        multiplier = tests[i].multiplier;

        #(2*HalfClockPeriod);
        if (product_array != tests[i].expected) begin : check_array_result
          $error(
            "expected %d but got %d from array multiplier",
            tests[i].expected, product_array
          );
        end : check_array_result
        if (product_wallace_tree != tests[i].expected) begin : check_wallace_tree_result
          $error(
            "expected %d but got %d from wallace tree multiplier",
            tests[i].expected, product_wallace_tree
          );
        end : check_wallace_tree_result
      end : test_routine

      $finish;
    end : main

endmodule : top
