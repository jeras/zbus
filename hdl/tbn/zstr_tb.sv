module zstr_tb ();

// bus
parameter BW = 1,             // bus width
parameter XZ = 1'bx,          // bus idle state
// queue
parameter QL = 1,             // queue length
parameter QW = $clog2(QL)     // queue address width

// system signals
logic          clk;    // system clock
logic          rst;    // asinchronous reset
// z stream signals
logic          z_vld;  // transfer valid
logic [BW-1:0] z_bus;  // grouped bus signals
logic          z_rdy;  // transfer ready

////////////////////////////////////////////////////////////////////////////////
// source instance
////////////////////////////////////////////////////////////////////////////////

zstr_src #(
  .BW  (BW),
  .XZ  (XZ),
  .QL  (QL)
)(
  .z_vld  (z_vld),
  .z_bus  (z_bus),
  .z_rdy  (z_rdy)
);

////////////////////////////////////////////////////////////////////////////////
// drain instance
////////////////////////////////////////////////////////////////////////////////

zstr_drn #(
  .BW  (BW),
  .XZ  (XZ),
  .QL  (QL)
)(
  .z_vld  (z_vld),
  .z_bus  (z_bus),
  .z_rdy  (z_rdy)
);

endmodule
