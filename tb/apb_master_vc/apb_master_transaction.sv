`ifndef APB_MASTER_TRANSACTION
`define APB_MASTER_TRANSACTION

class apb_master_transaction;

  // Declaring the transaction fields
  rand logic [`APB_ADDR_W -1:0] addr;
  rand logic                    is_write;
  rand logic [`APB_DATA_W -1:0] data;

  // Flag of error if it happens
  bit error;

  function void display(string name);
    $display("-------------------------");
    $display("TIME: %0t", $realtime);
    $display("-------------------------");
    $display("- %s ", name);
    $display("-------------------------");
    $display("- Address: %0d'h%0h", `APB_ADDR_W, addr);
    $display("-------------------------");
    $display("- Is write: %0d", is_write);
    $display("-------------------------");
    $display("- Data: %0d'h%0h", `APB_DATA_W, data);
    $display("-------------------------");
  endfunction

endclass : apb_master_transaction

`endif //!APB_MASTER_TRANSACTION
