`ifndef IRQ_MONITOR
`define IRQ_MONITOR

class irq_monitor;

  mailbox mon_outside;

  virtual irq_agent_if vif;

  irq_transaction transaction;

  function new(virtual irq_agent_if irq_if, mailbox mon_outside);
    this.vif         = irq_if;
    this.mon_outside = mon_outside;
  endfunction

  task monitor_transaction();
    // Interface listening
    @(posedge vif.irq or negedge vif.irq);
    transaction.value = vif.irq;
  endtask

  function void pre_main();
    // You can write your code here...
  endfunction

  task main();
    wait(!$isunknown(vif.irq));
    forever begin
      transaction = new();
      monitor_transaction();
      if ($test$plusargs("TRAN_INFO")) begin
        transaction.display("[irq_monitor]");
      end
      mon_outside.put(transaction);
    end
  endtask

  // Run task
  task run;
    pre_main();
    main();
  endtask

endclass : irq_monitor

`endif //!IRQ_MONITOR
