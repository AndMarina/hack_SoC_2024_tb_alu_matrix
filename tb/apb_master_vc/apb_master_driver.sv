`ifndef APB_MASTER_DRIVER
`define APB_MASTER_DRIVER

class apb_master_driver;

  mailbox to_driver;
  virtual apb_master_agent_if vif;
  apb_master_transaction transaction;

  function new(virtual apb_master_agent_if apb_if, mailbox to_driver);
    this.to_driver = to_driver;
    this.vif       = apb_if;
  endfunction

  task drive_transaction(apb_master_transaction transaction);
    e_apb_driver_state state = DRIVE_REQ;

    forever begin 
      @(posedge vif.clk)
      case (state)
        DRIVE_REQ:
          begin
            vif.paddr  <= transaction.addr;
            vif.pwrite <= transaction.is_write;
            if (transaction.is_write == 1) begin
              vif.pwdata <= transaction.data;
            end
            vif.penable <= 1;
            state = GET_RESP;
          end
        GET_RESP:
          begin
            if (vif.pready) begin
              vif.penable <= 0;
              vif.pwrite  <= 0;
              break;
            end
          end
      endcase
    end
  endtask

  function void pre_main();
    // You can write your code here...
  endfunction

  task main();
    forever begin
      wait(!$isunknown(vif.rst_n));
      fork
        begin
          @(posedge vif.rst_n);
          forever begin
            to_driver.get(transaction);
            if ($test$plusargs("TRAN_INFO")) begin
              transaction.display("[apb_master_driver]");
            end
            drive_transaction(transaction);
          end
        end
        begin
          @(negedge vif.rst_n);
          vif.paddr   <= 0;
          vif.pwrite  <= 0;
          vif.pwdata  <= 0;
          vif.penable <= 0;
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

endclass : apb_master_driver

`endif //!APB_MASTER_DRIVER
