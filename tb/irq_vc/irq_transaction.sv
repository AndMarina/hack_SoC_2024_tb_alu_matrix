`ifndef IRQ_TRANSACTION
`define IRQ_TRANSACTION

class irq_transaction;

  // Declaring the transaction fields
  bit value;

  function void display(string name);
    $display("-------------------------");
    $display("TIME: %0t", $realtime);
    $display("-------------------------");
    $display("- %s ", name);
    $display("-------------------------");
    $display("- Value = %0d", value);
    $display("-------------------------");
  endfunction

endclass : irq_transaction

`endif //!IRQ_TRANSACTION
