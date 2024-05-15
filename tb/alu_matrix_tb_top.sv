`ifndef ALU_MATRIX_TB_TOP
`define ALU_MATRIX_TB_TOP

`include "alu_matrix_defines.sv"
`include "alu_matrix_env_if.sv"
`include "alu_matrix_env.sv"
`include "alu_matrix_test.sv"

module alu_matrix_tb_top;

  alu_matrix_env_if env_if();

  alu_matrix_env    env;

  alu_matrix_test   test;

  ymp_alu_matrix_top 
  #(
      .AXI_DATA_W   (`AXI_DATA_W),
      .BUFFER_DEPTH (`BUFFER_DEPTH)
  )
  alu_matrix
  (
      // Clock and Reset
      .clk_i                 (env_if.clk_if.clk), 
      .resetn_i              (env_if.rst_if.rst_n),
      .irq_o                 (env_if.irq_if.irq),

      // APB
      .paddr_i               (env_if.apb_if.paddr),
      .pwdata_i              (env_if.apb_if.pwdata),
      .prdata_o              (env_if.apb_if.prdata),
      .penable_i             (env_if.apb_if.penable),
      .pwrite_i              (env_if.apb_if.pwrite),
      .pready_o              (env_if.apb_if.pready),
      .pslverr_o             (env_if.apb_if.pslverr),

      // AXI-Stream input
      .axis_data_i           (env_if.axis_in_if.axis_data),
      .axis_valid_i          (env_if.axis_in_if.axis_valid),
      .axis_ready_o          (env_if.axis_in_if.axis_ready),
      .axis_last_i           (env_if.axis_in_if.axis_last),

      // AXI-Stream output
      .axis_data_o           (env_if.axis_out_if.axis_data),
      .axis_valid_o          (env_if.axis_out_if.axis_valid),
      .axis_ready_i          (env_if.axis_out_if.axis_ready),
      .axis_last_o           (env_if.axis_out_if.axis_last)

  );

  initial begin
    // Set time format
    $timeformat(-12, 0, " ps", 10);

    // Creating environment
    env = new(env_if);

    // Creating test
    test = new(env);

    // Calling run of test
    test.run();
  end

endmodule : alu_matrix_tb_top

`endif // !ALU_MATRIX_TB_TOP
