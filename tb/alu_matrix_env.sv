`ifndef ALU_MATRIX_ENV
`define ALU_MATRIX_ENV

`include "clk_agent.sv"
`include "rst_agent.sv"
`include "axi_stream_master_agent.sv"
`include "axi_stream_slave_agent.sv"
`include "apb_master_agent.sv"
`include "irq_agent.sv"
`include "alu_matrix_reg_model.sv"
`include "alu_matrix_scoreboard.sv"

class alu_matrix_env;

  // Register model instance
  alu_matrix_reg_model    alu_matrix_regs;

  // Agents instances
  clk_agent               clk_agent;
  rst_agent               rst_agent;

  axi_stream_master_agent axis_master_agent;
  axi_stream_slave_agent  axis_slave_agent;
  apb_master_agent        apb_master_agent;

  irq_agent               irq_agent;

  // Scoreboard instance
  alu_matrix_scoreboard   scrb;

  // Mailbox handles
  mailbox                 rst2scrb; // From reset             to scoreboard
  mailbox                 in2scrb;  // From axi_stream_master to scoreboard
  mailbox                 out2scrb; // From axi_stream_slave  to scoreboard
  mailbox                 apb2scrb; // From apb_master        to scoreboard
  mailbox                 irq2scrb; // From irq               to scoreboard

  // Virtual interface
  virtual alu_matrix_env_if vif;

  // Event fthat indicates first valid_ready
  // handshake on axis_in_if
  event first_hs;

  // Constructor
  function new(virtual alu_matrix_env_if vif);

    this.vif                 = vif;

    // Creating registers model
    this.alu_matrix_regs     = new();

    // Creating mailboxes
    this.rst2scrb            = new();
    this.in2scrb             = new();
    this.out2scrb            = new();
    this.apb2scrb            = new();
    this.irq2scrb            = new();

    // Creating agents
    this.clk_agent           = new(vif.clk_if                         );
    this.rst_agent           = new(vif.rst_if,      rst2scrb          );

    this.axis_master_agent   = new(vif.axis_in_if,  in2scrb,  first_hs);
    this.axis_slave_agent    = new(vif.axis_out_if, out2scrb          );
    this.apb_master_agent    = new(vif.apb_if,      apb2scrb          );

    this.irq_agent           = new(vif.irq_if,      irq2scrb          );

    // Creating scoreboard
    this.scrb                = new(alu_matrix_regs, rst2scrb, in2scrb, out2scrb, apb2scrb, irq2scrb, first_hs);
  endfunction
  
  // Test phases
  task pre_main();

  endtask
  
  task main();
    fork
      clk_agent.run();
      rst_agent.run();

      axis_master_agent.run();
      axis_slave_agent.run();
      apb_master_agent.run();

      irq_agent.run();

      scrb.run();
    join_none
  endtask

  // Run task
  task run;
    pre_main();
    main();
  endtask

endclass

`endif //!ALU_MATRIX_ENV
