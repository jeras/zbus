module zstr_src #(
  // bus
  parameter BW = 1,             // bus width
  parameter XZ = 1'bx,          // bus idle state
  // queue
  parameter QL = 1,             // queue length
  parameter QW = $clog2(QL)     // queue address width
)(
  // system signals
  input  logic          clk,    // system clock
  input  logic          rst,    // asinchronous reset
  // z stream signals
  output logic          z_vld,  // transfer valid
  output logic [BW-1:0] z_bus,  // grouped bus signals
  input  logic          z_rdy   // transfer ready
);

////////////////////////////////////////////////////////////////////////////////
// z stream
////////////////////////////////////////////////////////////////////////////////

logic z_trn;
int z_tmg;

// valid is active if there is data in the queue
assign z_vld = (qd_cnt > 0);

// queue read pointer points to stream data
assign z_bus = qd_buf [qd_rpt];

// stream transfer event
assign z_trn = z_vld & z_rdy;

// transfer delay counter
always @ (posedge clk, posedge rst)
if (rst)         z_tmg <= 0;
else if (z_vld)  z_tmg <= z_rdy ? 0 : z_tmg + 1;

////////////////////////////////////////////////////////////////////////////////
// bus data queue
////////////////////////////////////////////////////////////////////////////////

logic [BW-1:0] qd_buf [0:QL-1];
int qd_cnt = 0;
int qd_wpt = 0;
int qd_rpt = 0;

// queue 
always @(posedge rst, posedge clk)
if (rst) begin
  qd_cnt <= 0;
  qd_rpt <= qd_wpt;
end else if (z_trn) begin
  qd_cnt <=  qd_cnt - 1;
  qd_rpt <= (qd_rpt + 1) % QL;
end

// 
task put_bus (
  output int            sts,  // status
  input  logic [BW-1:0] bus   // bus data
);
begin
  // report queue overflow
  sts = (qd_cnt > QL);
  // put new bus data into the queue
  if (sts) begin
    qd_buf [qd_wpt] = bus;
    qd_cnt =  qd_cnt + 1;
    qd_wpt = (qd_wpt + 1) % QL;
  end
end
endtask

////////////////////////////////////////////////////////////////////////////////
// timing queue
////////////////////////////////////////////////////////////////////////////////

int qt_buf [0:QL-1];
int qt_cnt = 0;
int qt_wpt = 0;
int qt_rpt = 0;

// queue 
always @(posedge rst, posedge clk)
if (rst) begin
  qt_cnt <= 0;
  qt_wpt <= qt_rpt;
end else if (z_trn) begin
  qt_cnt <=  qt_cnt + 1;
  qt_wpt <= (qt_wpt + 1) % QL;
  qt_buf <= z_tmg;
end

task get_tmg (
  output int sts
  output int tmg
);
begin
  // report queue overflow
  sts = (qt_cnt == 0);
  // get timing from the queue
  if (sts) begin
    tmg = qt_buf [qt_rpt];
    qt_cnt =  qt_cnt - 1;
    qt_rpt = (qt_rpt + 1) % QL;
  end
end
endfunction

endmodule
