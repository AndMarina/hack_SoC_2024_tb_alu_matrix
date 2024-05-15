`ifndef ALU_MATRIX_TEST
`define ALU_MATRIX_TEST

class alu_matrix_test;

  /* !!!----------------------------------------------------!!! */
  /* !!! DO NOT TOUCH CODE BELOW OR YOU MAY BE DISQUALIFIED !!! */
  /* !!!----------------------------------------------------!!! */
  int timeout_us;
  int max_err_count;

  string testname;
  /* !!!----------------------------------------------------!!! */
  /* !!! DO NOT TOUCH CODE ABOVE OR YOU MAY BE DISQUALIFIED !!! */
  /* !!!----------------------------------------------------!!! */

  alu_matrix_env env;

  apb_master_transaction apb_transaction ;
  axi_stream_transaction axis_transaction;
  clk_transaction        clk_transaction ;
  rst_transaction        rst_transaction ;

  // Your variables here...
  logic signed [`AXI_DATA_W - 1:0] matrix [$]; // For BASIC_TEST



  function new(alu_matrix_env env);
    this.env = env;



    /* !!!----------------------------------------------------!!! */
    /* !!! DO NOT TOUCH CODE BELOW OR YOU MAY BE DISQUALIFIED !!! */
    /* !!!----------------------------------------------------!!! */
    if ($value$plusargs("testname=%s", testname)) begin
      $display("--- TESTNAME IS %0s ---", testname);
    end else begin
      $fatal(3, "TESTNAME WAS NOT SET! Exiting...");
    end
    /* !!!----------------------------------------------------!!! */
    /* !!! DO NOT TOUCH CODE ABOVE OR YOU MAY BE DISQUALIFIED !!! */
    /* !!!----------------------------------------------------!!! */
  endfunction


  task run();

    fork

      begin
        env.run();
      end

      begin
        case (testname)
          "TEST_BASIC" : begin
            basic_test();
          end
          // Your tests here...
          //
          //
          default : begin
            $fatal(2, "UNDEFINED TESTNAME WAS SET! Exiting...");
          end
        endcase

        /* !!!---------------------------------------------------!!! */
        /* !!! DO NOT TOUCH CODE BELOW OR YOU MAY BE DISQUALIFIED!!! */
        /* !!!---------------------------------------------------!!! */
        finish();
        /* !!!---------------------------------------------------!!! */
        /* !!! DO NOT TOUCH CODE ABOVE OR YOU MAY BE DISQUALIFIED!!! */
        /* !!!---------------------------------------------------!!! */
      end


      /* !!!---------------------------------------------------!!! */
      /* !!! DO NOT TOUCH CODE BELOW OR YOU MAY BE DISQUALIFIED!!! */
      /* !!!---------------------------------------------------!!! */
      begin
        if ($value$plusargs("timeout_us=%d", timeout_us)) begin
          $display("--- TEST TIMEOUT IS SET TO %0d us ---", timeout_us);
          #(timeout_us*1000);
          $fatal(2, "SIMULATION TIME EXCEEDED! Exiting...");
        end else begin
          $fatal(2, "TIMEOUT WAS NOT SET! Exiting...");
        end
      end

      begin
        if ($value$plusargs("max_err_count=%d", max_err_count)) begin
          $display("--- MAXIMUM ERROR COUNT IS SET TO %0d ---", max_err_count);
          wait (env.scrb.error_count >= max_err_count);
          $fatal(2, "MAXIMUM ERROR COUNT REACHED! Exiting...");
        end else begin
          $fatal(2, "MAXIMUM ERROR COUNT WAS NOT SET! Exiting...");
        end
      end
      /* !!!---------------------------------------------------!!! */
      /* !!! DO NOT TOUCH CODE ABOVE OR YOU MAY BE DISQUALIFIED!!! */
      /* !!!---------------------------------------------------!!! */

    join_none

  endtask


  // API
  task clk_transaction_put(int t_period);
    clk_transaction = new();
    clk_transaction.period = t_period;
    env.clk_agent.to_driver.put(clk_transaction);
  endtask

  task rst_transaction_put(int t_duration);
    rst_transaction = new();
    rst_transaction.duration = t_duration;
    env.rst_agent.to_driver.put(rst_transaction);
  endtask

  task apb_transaction_put(logic [`APB_ADDR_W -1:0] t_addr = 0, t_data = 0, logic t_is_write = 0);
    apb_transaction = new();
    apb_transaction.addr = t_addr;
    apb_transaction.is_write = t_is_write;
    apb_transaction.data = t_data;
    env.apb_master_agent.to_driver.put(apb_transaction);
  endtask

  task axis_transaction_put(logic signed [`AXI_DATA_W -1:0] t_data[$]);
    axis_transaction = new();
    axis_transaction.data = t_data;
    env.axis_master_agent.to_driver.put(axis_transaction);
  endtask

  task wait_apb_end_trans();
    @(posedge (env.vif.apb_if.pready && env.vif.apb_if.penable));
    @(posedge env.vif.clk_if.clk);
  endtask

  task wait_axis_in_end_trans();
    @(posedge (env.vif.axis_in_if.axis_last && env.vif.axis_in_if.axis_valid && env.vif.axis_in_if.axis_ready));
    @(posedge env.vif.clk_if.clk);
  endtask

  task wait_axis_out_end_trans();
    @(posedge (env.vif.axis_out_if.axis_last && env.vif.axis_out_if.axis_valid && env.vif.axis_out_if.axis_ready));
    repeat(2) @(posedge env.vif.clk_if.clk);
  endtask


  // Example basic test
  task basic_test();
    // Start generating clock signal with period of 10 ns
    clk_transaction_put(10);
    // Wait for the first posedge clk
    @(posedge env.vif.clk_if.clk);
    // Drive active reset for 50 ns
    rst_transaction_put(50);
    // Set some values in registers using APB
    apb_transaction_put(32'h10, 3, 1);
    wait_apb_end_trans();
    apb_transaction_put(32'h14, 3, 1);
    wait_apb_end_trans();
    apb_transaction_put(32'h00, 3, 1);
    wait_apb_end_trans();
    // Drive matrix using AXI-stream
    matrix = {1,2,3,4,5,6,7,8,9};
    axis_transaction_put(matrix);
    wait_axis_in_end_trans();
    // Check ISR, write 1 to clear it
    // and then collect result or repeat
    // ...
  endtask


  /* !!!----------------------------------------------------!!! */
  /* !!! DO NOT TOUCH CODE BELOW OR YOU MAY BE DISQUALIFIED !!! */
  /* !!!----------------------------------------------------!!! */

  task finish();
    if (env.scrb.error_count == 0) begin
      $display("========== TEST PASSED ===========",);
    end else begin
      $display("========== TEST FAILED ===========",);
      $display("Performed %0d result matrix checks", env.scrb.check_count);
      $display("Collected %0d errors in total     ", env.scrb.error_count);
    end
    $finish();
  endtask

  /* !!!----------------------------------------------------!!! */
  /* !!! DO NOT TOUCH CODE ABOVE OR YOU MAY BE DISQUALIFIED !!! */
  /* !!!----------------------------------------------------!!! */

endclass

`endif //!ALU_MATRIX_TEST
