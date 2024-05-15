`ifndef APB_MASTER_MONITOR
`define APB_MASTER_MONITOR

class apb_master_monitor;

  mailbox mon_outside;

  virtual apb_master_agent_if vif;

  apb_master_transaction transaction;

  // The number of clock cycles after which,
  // in the absence of a pready signal, the transaction
  // will be considered suspended (default value is 50)
  int wait_cycles_max;

  function new(virtual apb_master_agent_if apb_if, mailbox mon_outside);
    this.vif             = apb_if;
    this.mon_outside     = mon_outside;

    this.wait_cycles_max = 50;
  endfunction

  task monitor_transaction();
    int wait_cycles_cnt = 0;

    while (transaction == null) begin
      @(posedge vif.clk);
      if (vif.penable) begin
        transaction = new();
        transaction.addr = vif.paddr;
      end
    end
    
    forever begin
      @(posedge vif.clk);
      if (vif.pready == 1) begin        
        if (vif.pwrite == 1) begin
          transaction.data = vif.pwdata;
        end else begin
          transaction.data = vif.prdata;
        end
        transaction.is_write = vif.pwrite;
        transaction.error    = vif.pslverr;
        break;
      end else begin
        wait_cycles_cnt++;
        if (wait_cycles_cnt > wait_cycles_max) begin
          $fatal(2, "TIME: %0t. APB transaction timeout!", $realtime);
        end
      end
    end
  endtask



  function void pre_main();
    // You can write your code here...
  endfunction

  task main();
    forever begin
      wait(!$isunknown(vif.rst_n));
      @(posedge vif.rst_n);
      fork
        begin
          forever begin
            monitor_transaction();
            if ($test$plusargs("TRAN_INFO")) begin
              transaction.display("[apb_master_monitor]");
            end
            mon_outside.put(transaction);
            transaction = null;
          end
        end
        begin
          @(negedge vif.rst_n);
          transaction = null;
        end
      join_any
      disable fork;
    end
  endtask

  // Run task
  task run;
    pre_main();
    main();
  endtask

endclass : apb_master_monitor

`endif //!APB_MASTER_MONITOR
