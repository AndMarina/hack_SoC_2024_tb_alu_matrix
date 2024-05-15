`ifndef RESET_AGENT
`define RESET_AGENT

`include "rst_agent_if.sv"
`include "rst_transaction.sv"
`include "rst_driver.sv"
`include "rst_monitor.sv"

class rst_agent;

  rst_driver  driver;
  rst_monitor monitor;

  mailbox     to_driver;

  function new(virtual rst_agent_if rst_if, mailbox mon2scrb);
    to_driver = new();

    driver  = new(rst_if, to_driver);
    monitor = new(rst_if, mon2scrb);
  endfunction

  function void pre_main();
    // You can write your code here...
  endfunction
  
  task main();
    fork
      driver.run();
      monitor.run();
    join_none
  endtask
  
  // Run task
  task run();
    pre_main();
    main();
  endtask

endclass : rst_agent

`endif //!RESET_AGENT
