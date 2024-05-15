`ifndef RESET_TRANSACTION
`define RESET_TRANSACTION

class rst_transaction;

  // Declaring the transaction fields
  rand int duration;

  function void display(string name);
    $display("-------------------------");
    $display("TIME: %0t", $realtime);
    $display("-------------------------");
    $display("- %s ", name);
    $display("-------------------------");
    $display("- Duration = %0d ns", duration);
    $display("-------------------------");
  endfunction

endclass : rst_transaction

`endif //!RESET_TRANSACTION
