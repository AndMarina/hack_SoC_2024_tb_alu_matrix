`ifndef AXI_STREAM_SLAVE_DRIVER
`define AXI_STREAM_SLAVE_DRIVER

import alu_matrix_pkg::*;

class axi_stream_slave_driver;

  virtual axi_stream_agent_if vif;

  function new(virtual axi_stream_agent_if axi_stream_if);
    this.vif = axi_stream_if;
  endfunction

  function void pre_main();
    // You can write your code here...
  endfunction

  task main();
    forever begin
      wait(!$isunknown(vif.rst_n));
      fork
        begin
          @(posedge vif.rst_n);
          vif.axis_ready <= 1;
        end
        begin
          @(negedge vif.rst_n);
          vif.axis_ready <= 0;
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

endclass : axi_stream_slave_driver

`endif //!AXI_STREAM_SLAVE_DRIVER
