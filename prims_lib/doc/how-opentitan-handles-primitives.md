# How OpenTitan Handles Primitives

Back in 2021, FuseSoC 1.12.0 had no way to handle primitive libraries, which is a reason behind the lowRISC fork of FuseSoC.

The lowRISC fork adds a patch that provides FuseSoC generators with the list of cores found.
OpenTitan's `primgen` generator searches this list of cores for primitive implementations with the library prefix `prims_`.
Then for every primitive an *abstract* module is generated, with preprocessor can be used to select the preferred primitive module.

Below is an example of one of this generated module for OpenTitan's `pad_wrapper` primitive.
There are three implementations `xilinx_ultrascale`, `xilinx` and `generic`.
One can swap out the generic implementation for a specific Xilinx implementation by setting setting either the `ImplXilinx_ultrascale` or `ImplXilinx` define.
*In this example, the Xilinx versions of the pad_wrapper primitive make use of Xilinx's `IOBUF` and `IBUF` cells.*

Not only does `primgen` allow one to avoid manually writing these abstract modules, but it allows users to add a new primitives library with the library prefix `prims_` and `primgen` will automatically add it as an option to any of the abstract modules it has an implementation for.

```systemverilog
// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

// This file is auto-generated.
// Used parser: Fallback (regex)

`ifndef PRIM_DEFAULT_IMPL
  `define PRIM_DEFAULT_IMPL prim_pkg::ImplGeneric
`endif

// This is to prevent AscentLint warnings in the generated
// abstract prim wrapper. These warnings occur due to the .*
// use. TODO: we may want to move these inline waivers
// into a separate, generated waiver file for consistency.
//ri lint_check_off OUTPUT_NOT_DRIVEN INPUT_NOT_READ HIER_BRANCH_NOT_READ
module prim_pad_wrapper
import prim_pad_wrapper_pkg::*;
#(

  // These parameters are ignored in this model.
  parameter pad_type_e PadType = BidirStd,
  parameter scan_role_e ScanRole = NoScan

) (
  // This is only used for scanmode (not used in generic models)
  input              clk_scan_i,
  input              scanmode_i,
  // Power sequencing signals (not used in generic models)
  input pad_pok_t    pok_i,
  // Main Pad signals
  inout wire         inout_io, // bidirectional pad
  output logic       in_o,     // input data
  output logic       in_raw_o, // uninverted output data
  input              ie_i,     // input enable
  input              out_i,    // output data
  input              oe_i,     // output enable
  input pad_attr_t   attr_i    // additional pad attributes
);
  localparam prim_pkg::impl_e Impl = `PRIM_DEFAULT_IMPL;

if (Impl == prim_pkg::ImplXilinx) begin : gen_xilinx
    prim_xilinx_pad_wrapper #(
      .PadType(PadType),
      .ScanRole(ScanRole)
    ) u_impl_xilinx (
      .*
    );
end else if (Impl == prim_pkg::ImplXilinx_ultrascale) begin : gen_xilinx_ultrascale
    prim_xilinx_ultrascale_pad_wrapper #(
      .PadType(PadType),
      .ScanRole(ScanRole)
    ) u_impl_xilinx_ultrascale (
      .*
    );
end else begin : gen_generic
    prim_generic_pad_wrapper #(
      .PadType(PadType),
      .ScanRole(ScanRole)
    ) u_impl_generic (
      .*
    );
end

endmodule
//ri lint_check_on OUTPUT_NOT_DRIVEN INPUT_NOT_READ HIER_BRANCH_NOT_READ
```
