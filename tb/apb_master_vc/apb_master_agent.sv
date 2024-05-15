`ifndef APB_MASTER_AGENT
`define APB_MASTER_AGENT

`include "apb_master_agent_if.sv"
`include "apb_master_transaction.sv"
`include "apb_master_driver.sv"
`include "apb_master_monitor.sv"

class apb_master_agent;

  apb_master_driver  driver;
  apb_master_monitor monitor;

  mailbox            to_driver;

  function new(virtual apb_master_agent_if apb_if, mailbox mon_outside);
    to_driver = new();

    driver    = new(apb_if, to_driver);
    monitor   = new(apb_if, mon_outside);
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

endclass : apb_master_agent

`endif //!APB_MASTER_AGENT
