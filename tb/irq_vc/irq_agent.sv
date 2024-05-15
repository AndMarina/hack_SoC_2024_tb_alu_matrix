`ifndef IRQ_AGENT
`define IRQ_AGENT

`include "irq_agent_if.sv"
`include "irq_transaction.sv"
`include "irq_monitor.sv"

class irq_agent;

  irq_monitor monitor;

  function new(virtual irq_agent_if irq_if, mailbox mon2scrb);
    monitor = new(irq_if, mon2scrb);
  endfunction

  function void pre_main();
    // You can write your code here...
  endfunction
  
  task main();
    fork
      monitor.run();
    join_none
  endtask
  
  // Run task
  task run();
    pre_main();
    main();
  endtask

endclass : irq_agent

`endif //!IRQ_AGENT
