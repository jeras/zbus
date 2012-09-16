module zstr_tb ();

// bus
parameter BW = 8;             // bus width
parameter XZ = 1'bx;          // bus idle state
// queue
parameter QL = 4;             // queue length

// system signals
logic          clk;    // system clock
logic          rst;    // asinchronous reset
// z stream signals
logic          z_vld;  // transfer valid
logic [BW-1:0] z_bus;  // grouped bus signals
logic          z_rdy;  // transfer ready

// status report variables
int src_sts;
int drn_sts;

// temporal variables
logic [BW-1:0] bus;
int tmg;

////////////////////////////////////////////////////////////////////////////////
// test sequence
////////////////////////////////////////////////////////////////////////////////

initial begin
  // wait past reset
  repeat (5) @ (posedge clk);

  // source preparation
  src.put_bus (src_sts, "H");
  // drain preparation
  drn.put_tmg (drn_sts, 3);

  // wait past reset
  repeat (5) @ (posedge clk);

  // source readout
  src.get_tmg (src_sts, tmg);
  // drain readout
  drn.get_bus (drn_sts, bus);
end

////////////////////////////////////////////////////////////////////////////////
// clock and reset generator
////////////////////////////////////////////////////////////////////////////////

// clock toggling
initial   clk <= 1'b1;
always #5 clk <= ~clk;

// reset should be removed after a few clock periods
initial begin
  rst <= 1'b1;
  repeat (4) @ (posedge clk);
  rst <= 1'b0;
end

// request for a dumpfile
initial begin
  $dumpfile("zstr.vcd");
  $dumpvars(0, zstr_tb);
end

////////////////////////////////////////////////////////////////////////////////
// source instance
////////////////////////////////////////////////////////////////////////////////

zstr_src #(
  .BW  (BW),
  .XZ  (XZ),
  .QL  (QL)
) src (
  // system signals
  .clk  (clk),
  .rst  (rst),
  // z stream signals
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
) drn (
  // system signals
  .clk  (clk),
  .rst  (rst),
  // z stream signals
  .z_vld  (z_vld),
  .z_bus  (z_bus),
  .z_rdy  (z_rdy)
);

endmodule
