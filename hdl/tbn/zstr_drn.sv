module zstr_drn #(
  // bus
  parameter BW = 1,             // bus width
  parameter XZ = 1'bx,          // bus idle state
  // queue
  parameter QL = 1              // queue length
)(
  // system signals
  input  logic          clk,    // system clock
  input  logic          rst,    // asinchronous reset
  // z stream signals
  input  logic          z_vld,  // transfer valid
  input  logic [BW-1:0] z_bus,  // grouped bus signals
  output logic          z_rdy   // transfer ready
);

localparam QW = $clog2(QL);     // queue address width

////////////////////////////////////////////////////////////////////////////////
// z stream
////////////////////////////////////////////////////////////////////////////////

// valid is active if there is data in the queue
assign z_rdy = (qt_cnt > 0);

// queue read pointer points to stream data
assign z_tmg = qt_buf [qt_rpt];

// stream transfer event
assign z_trn = z_vld & z_rdy;

////////////////////////////////////////////////////////////////////////////////
// bus data queue
////////////////////////////////////////////////////////////////////////////////

logic [BW-1:0] qb_buf [0:QL-1];
int            qb_cnt = 0;
int            qb_wpt = 0;
int            qb_rpt = 0;

// write new bus data into the queue
always @(posedge rst, posedge clk)
if (rst) begin
  qb_cnt <= 0;
  qb_wpt <= qb_rpt;
end else if (z_trn) begin
  qb_cnt <=  qb_cnt + 1;
  qb_wpt <= (qb_wpt + 1) % QL;
end

// read 
task get_bus (
  output int            sts,
  output logic [BW-1:0] bus
);
begin
  // report queue overflow
  sts = (qb_cnt == 0);
  // get new bus data from the queue
  if (sts) begin
    bus = qb_buf [qb_rpt];
    qb_cnt =  qb_cnt - 1;
    qb_rpt = (qb_rpt + 1) % QL;
  end
end
endtask

////////////////////////////////////////////////////////////////////////////////
// timing queue
////////////////////////////////////////////////////////////////////////////////

logic [BW-1:0] qt_buf [0:QL-1];
int            qt_cnt = 0;
int            qt_wpt = 0;
int            qt_rpt = 0;

always @(posedge rst, posedge clk)
if (rst) begin
  qt_cnt <= 0;
  qt_rpt <= qt_wpt;
end else if (z_trn) begin
  qt_cnt <=  qt_cnt - 1;
  qt_rpt <= (qt_rpt + 1) % QL;
end

task put_tmg (
  output int            sts,  // status
  input  logic [BW-1:0] tmg   // timing
);
begin
  // report queue overflow
  sts = (qt_cnt > QL);
  // put timing into the queue
  if (sts) begin
    qt_buf [qt_wpt] = tmg;
    qt_cnt =  qt_cnt + 1;
    qt_wpt = (qt_wpt + 1) % QL;
  end
end
endtask

endmodule
