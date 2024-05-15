`ifndef CLOCK_DRIVER
`define CLOCK_DRIVER

class clk_driver;

  int period;

  mailbox to_driver;

  virtual clk_agent_if vif;

  clk_transaction transaction;

  function new(virtual clk_agent_if clk_if, mailbox to_driver);
    this.to_driver = to_driver;
    this.vif = clk_if;
  endfunction

  function void pre_main();
    // You can write your code here...
  endfunction
  
  task main();
    vif.clk <= 0;

    forever begin
      to_driver.get(transaction);

      period = transaction.period;

      if (period <= 0) begin
        $warning("[clk_driver]: Clock transaction period is negative or zero! Clock period is unchanged...");
      end else if (period % 2 != 0) begin
        $warning("[clk_driver]: Clock transaction period is not even! Clock period is unchanged...");
      end else begin
        if ($test$plusargs("TRAN_INFO")) begin
          transaction.display("[clk_driver]");
        end
        disable fork;
        fork
          forever begin
            #(period/2);
            vif.clk <= ~vif.clk;
          end
        join_none
      end
    end
  endtask

  // Run task
  task run();
    pre_main();
    main();
  endtask

endclass : clk_driver

`endif //!CLOCK_DRIVER
