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
  input  logic          z_vld,  // transfer valid
  input  logic [BW-1:0] z_bus,  // grouped bus signals
  output logic          z_rdy   // transfer ready
);

////////////////////////////////////////////////////////////////////////////////
// bus data queue
////////////////////////////////////////////////////////////////////////////////

logic [BW-1:0] qf_buf [0:QL-1];
int            qf_cnt = 0;
int            qf_wpt = 0;
int            qf_rpt = 0;

// write new bus data into the queue
always @(posedge rst, posedge clk)
if (rst) begin
  qf_cnt <= 0;
  qf_wpt <= qf_rpt;
end else if (z_trn) begin
  qf_cnt <=  qf_cnt + 1;
  qf_wpt <= (qf_wpt + 1) % QL;
end

// read 
task get_bus (
  output int            sts
  output logic [BW-1:0] bus
);
begin
  // report queue overflow
  sts = (qf_cnt == 0);
  // get timing from the queue
  if (sts) begin
    tmg = qf_buf [qf_rpt];
    qf_cnt =  qf_cnt - 1;
    qf_rpt = (qf_rpt + 1) % QL;
  end
end
endfunction

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

task put_dat (
  output int            sts,  // status
  input  logic [BW-1:0] bus   // bus data
);
begin
  // report queue overflow
  sts = (qt_cnt > QL);
  // put new bus data into the queue
  if (sts) begin
    qt_buf [qt_wpt] = bus;
    qt_cnt =  qt_cnt + 1;
    qt_wpt = (qt_wpt + 1) % QL;
  end
end
endtask

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
