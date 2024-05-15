`ifndef AXI_STREAM_SLAVE_AGENT
`define AXI_STREAM_SLAVE_AGENT

`include "axi_stream_agent_if.sv"
`include "axi_stream_transaction.sv"
`include "axi_stream_slave_driver.sv"
`include "axi_stream_monitor.sv"

class axi_stream_slave_agent;

  axi_stream_slave_driver  driver;
  axi_stream_monitor monitor;

  function new(virtual axi_stream_agent_if axi_stream_if, mailbox mon_outside);
    driver  = new(axi_stream_if);
    monitor = new(axi_stream_if, mon_outside, null);
  endfunction

  function void pre_main();
    // You can write your code here...
  endfunction

  task main();
    fork
      monitor.run();
      driver.run();
    join_none
  endtask

  // Run task
  task run();
    pre_main();
    main();
  endtask

endclass : axi_stream_slave_agent

`endif //!AXI_STREAM_SLAVE_AGENT
