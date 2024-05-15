`ifndef RESET_DRIVER
`define RESET_DRIVER

class rst_driver;

  typedef enum bit {LOW = 0, HIGH = 1} e_rst_lvl;

  bit active_lvl = LOW; // Reset signal active level
  int duration;

  mailbox to_driver;

  virtual rst_agent_if vif;

  rst_transaction transaction;

  function new(virtual rst_agent_if rst_if, mailbox to_driver);
    this.to_driver = to_driver;
    this.vif = rst_if;
  endfunction

  function void pre_main();
    // You can write your code here...
  endfunction
  
  task main();
    vif.rst_n <= ~active_lvl;

    forever begin
      to_driver.get(transaction);

      duration = transaction.duration;

      if (duration <= 0) begin
        $warning("[rst_driver]: Reset transaction duration is negative or zero! Reset is not applied...");
      end else begin
        fork
          begin
            vif.rst_n <= active_lvl;
            #(duration);
            vif.rst_n <= ~active_lvl;
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

endclass : rst_driver

`endif //!RESET_DRIVER
