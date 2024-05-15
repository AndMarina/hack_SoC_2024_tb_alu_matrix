`ifndef ALU_MATRIX_ENV_IF
`define ALU_MATRIX_ENV_IF

interface alu_matrix_env_if();
  
  // Clock and Reset interfaces
  clk_agent_if         clk_if      ();
  rst_agent_if         rst_if      ();

  // Interrupt signals
  irq_agent_if         irq_if      ();
  
  // Matrix data interfaces
  axi_stream_agent_if  axis_in_if  (clk_if.clk, rst_if.rst_n);
  axi_stream_agent_if  axis_out_if (clk_if.clk, rst_if.rst_n);

  // Registers data interfaces
  apb_master_agent_if  apb_if      (clk_if.clk, rst_if.rst_n);

endinterface

`endif // !ALU_MATRIX_ENV_IF