`ifndef AXI_STREAM_MONITOR
`define AXI_STREAM_MONITOR

class axi_stream_monitor;

  mailbox mon_outside;

  virtual axi_stream_agent_if vif;

  axi_stream_transaction transaction;

  event first_hs;

  function new(virtual axi_stream_agent_if axi_stream_if, mailbox mon_outside, event first_hs);
    this.vif             = axi_stream_if;
    this.mon_outside     = mon_outside;
    this.first_hs        = first_hs;
  endfunction

  task monitor_transaction();
    // Interface listening
    forever begin
      @(posedge vif.clk)
      if (vif.axis_valid && vif.axis_ready) begin
        transaction.data.push_back(vif.axis_data);
        if (transaction.data.size() == 1) begin
          ->first_hs;
        end
        if (vif.axis_last) begin
          break;
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
            transaction = new();
            monitor_transaction();
            if ($test$plusargs("TRAN_INFO")) begin
              transaction.display("[axi_stream_monitor]");
            end
            mon_outside.put(transaction);
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

endclass : axi_stream_monitor

`endif //!AXI_STREAM_MONITOR
