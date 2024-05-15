`ifndef RESET_MONITOR
`define RESET_MONITOR

class rst_monitor;

  time rst_begin;
  time rst_finish;

  mailbox mon_outside;

  virtual rst_agent_if vif;

  rst_transaction transaction_begin;
  rst_transaction transaction_end;

  function new(virtual rst_agent_if rst_if, mailbox mon_outside);
    this.vif         = rst_if;
    this.mon_outside = mon_outside;
  endfunction

  task monitor_transaction();

    // Interface listening
    forever begin
      @(negedge vif.rst_n); // Reset is active
      rst_begin  = $time;

      mon_outside.put(transaction_begin);
      
      @(posedge vif.rst_n); // Reset is inactive
      rst_finish = $time;
      break;
    end

    // Filling in a transaction with data
    transaction_end.duration = int'(rst_finish - rst_begin);
  endtask

  function void pre_main();
    // You can write your code here...
  endfunction

  task main();
    wait(!$isunknown(vif.rst_n));
    forever begin
      transaction_begin = new();
      transaction_end   = new();
      transaction_begin.duration = -1; // -1 is the flag for scoreboard that this
                                       // transaction indicates begining of reset
      monitor_transaction();
      if ($test$plusargs("TRAN_INFO")) begin
        transaction_end.display("[rst_monitor]");
      end
      mon_outside.put(transaction_end);
    end
  endtask

  // Run task
  task run;
    pre_main();
    main();
  endtask

endclass : rst_monitor

`endif //!RESET_MONITOR
