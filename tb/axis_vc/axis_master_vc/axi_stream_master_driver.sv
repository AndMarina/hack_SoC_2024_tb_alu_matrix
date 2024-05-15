`ifndef AXI_STREAM_MASTER_DRIVER
`define AXI_STREAM_MASTER_DRIVER

import alu_matrix_pkg::*;

class axi_stream_master_driver;

  mailbox to_driver;
  virtual axi_stream_agent_if vif;

  axi_stream_transaction transaction;

  function new(virtual axi_stream_agent_if axi_stream_if, mailbox to_driver);
    this.to_driver = to_driver;
    this.vif       = axi_stream_if;
  endfunction

  task drive_transaction();
    e_axis_driver_state state = DRIVE_INITIAL;
    int i = 0;

    forever begin
      @(posedge vif.clk)
      case (state)
        DRIVE_INITIAL:
          begin
            vif.axis_data  <= transaction.data[i];
            vif.axis_valid <= 1;
            if (i == transaction.data.size()-1) begin
              vif.axis_last <= 1;
            end
            state = DRIVE;
          end
        DRIVE:
          begin
            if (vif.axis_ready) begin
              if (i < transaction.data.size()-1) begin
                i++;
                vif.axis_data  <= transaction.data[i];
                if (i == transaction.data.size()-1) begin
                  vif.axis_last <= 1;
                end
              end else begin
                vif.axis_data  <= 0;
                vif.axis_valid <= 0;
                vif.axis_last  <= 0;
                break;
              end
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
            transaction.display("[axi_stream_master_driver]");
          end
          drive_transaction();
        end
        end
        begin
          @(negedge vif.rst_n);
          vif.axis_data  <= 0;
          vif.axis_valid <= 0;
          vif.axis_last  <= 0;
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

endclass : axi_stream_master_driver

`endif //!AXI_STREAM_MASTER_DRIVER
