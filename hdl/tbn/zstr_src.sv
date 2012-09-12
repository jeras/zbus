module zstr_src #(
  // bus
  parameter BW = 1,
  parameter XZ = 1'bx,
  // queue
  parameter QL = 1,             // queue length
  parameter QW = $clog2(QL)     // queue address width
)(
  // system signals
  input  logic          clk,    // system clock
  input  logic          rst,    // asinchronous reset
  // zstr signals
  output logic          z_vld,  // transfer valid
  output logic [BW-1:0] z_bus,  // grouped bus signals
  input  logic          z_rdy   // transfer ready
);

////////////////////////////////////////////////////////////////////////////////
// queue
////////////////////////////////////////////////////////////////////////////////

logic [BW-1:0] q_buf [0:QL-1];
int            q_cnt = 0;
int            q_wpt = 0;
int            q_rpt = 0;

// queue 
always @(posedge rst, posedge clk)
if (rst) begin
  q_cnt <= 0;
  q_rpt <= q_wpt;
end else if (z_trn) begin
  q_cnt <=  q_cnt - 1;
  q_rpt <= (q_rpt + 1) % QL;
end

function int put (input logic [BW-1:0] bus);
begin
  // put new data into the queue
  q_buf [q_wpt] = bus;
  q_cnt =  q_cnt + 1;
  q_wpt = (q_wpt + 1) % QL;
  // report queue overflow
  put = q_cnt > QL;
end
endfunction

////////////////////////////////////////////////////////////////////////////////
// z stream
////////////////////////////////////////////////////////////////////////////////

// valid is active if there is data in the queue
assign z_vld = (q_cnt > 0);

// queue read pointer points to stream data
assign z_bus = q_buf [q_rpt];

// stream transfer event
assign z_trn = z_vld & z_rdy;

endmodule
