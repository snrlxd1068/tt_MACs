/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_snrlxd1068_MACs (
    input  logic [7:0] ui_in,    // Dedicated inputs
    output logic [7:0] uo_out,   // Dedicated outputs
    input  logic [7:0] uio_in,   // IOs: Input path
    output logic [7:0] uio_out,  // IOs: Output path
    output logic [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  logic       ena,      // always 1 when the design is powered, so you can ignore it
    input  logic       clk,      // clock
    input  logic       rst_n     // reset_n - low to reset
);

MAC_top MAC_top(
  .clk(clk),
  .rst_n(rst_n),
  .i_data(ui_in),
  .o_data(uo_out),
  .i_mode(uio_in[5:4]),
  .i_valid(uio_in[3]),
  .i_key(uio_in[2]),
  .o_section(uio_out[7:6])
)

  // All output pins must be assigned. If not used, assign to 0.
  assign uio_out [5:0] = 6'b000000;
  assign uio_oe  = 8'b11000000;

  // List all unused inputs to prevent warnings
  logic _unused = &{ena, uio_in[7:6], uio_in[1:0], 1'b0};

endmodule
