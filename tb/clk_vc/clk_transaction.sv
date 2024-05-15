`ifndef CLOCK_TRANSACTION
`define CLOCK_TRANSACTION

class clk_transaction;

  // Declaring the transaction fields
  rand int period; // Must be even

  function void display(string name);
    $display("-------------------------");
    $display("TIME: %0t", $realtime);
    $display("-------------------------");
    $display("- %s ", name);
    $display("-------------------------");
    $display("- Period = %0d ns", period);
    $display("-------------------------");
  endfunction

endclass : clk_transaction

`endif //!CLOCK_TRANSACTION
