`ifndef APB_MASTER_MASTER_AGENT_IF
`define APB_MASTER_MASTER_AGENT_IF

interface apb_master_agent_if(input logic clk, rst_n);

  // APB signals
  logic  [`APB_ADDR_W -1:0] paddr;
  logic  [`APB_DATA_W -1:0] pwdata;
  logic  [`APB_DATA_W -1:0] prdata;
  logic                     penable;
  logic                     pwrite;
  logic                     pready;
  logic                     pslverr; 

endinterface

`endif //!APB_MASTER_AGENT_IF