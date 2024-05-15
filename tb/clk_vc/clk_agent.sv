`ifndef CLOCK_AGENT
`define CLOCK_AGENT

`include "clk_agent_if.sv"
`include "clk_transaction.sv"
`include "clk_driver.sv"

class clk_agent;

  clk_driver  driver;

  mailbox     to_driver;

  function new(virtual clk_agent_if clk_if);
    to_driver = new();

    driver  = new(clk_if, to_driver);
  endfunction

  function void pre_main();
    // You can write your code here...
  endfunction
  
  task main();
    fork
      driver.run();
    join_none
  endtask
  
  // Run task
  task run();
    pre_main();
    main();
  endtask

endclass : clk_agent

`endif //!CLOCK_AGENT
