`ifndef AXI_STREAM_TRANSACTION
`define AXI_STREAM_TRANSACTION

class axi_stream_transaction;

  // Declaring the transaction fields
  rand logic signed [`AXI_DATA_W -1:0] data [$];

  function void display(string name);
    $display("-------------------------");
    $display("TIME: %0t", $realtime);
    $display("-------------------------");
    $display("- %s ", name);
    $display("-------------------------");
    $display("- Data: ");
    $display("%p", data);
    $display("-------------------------");
  endfunction

endclass : axi_stream_transaction

`endif //!AXI_STREAM_TRANSACTION
