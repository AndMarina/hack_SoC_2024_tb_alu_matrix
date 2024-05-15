`ifndef ALU_MATRIX_SCOREBOARD
`define ALU_MATRIX_SCOREBOARD

import alu_matrix_pkg::*;

class alu_matrix_scoreboard;

  /* !!!----------------------------------------------------!!! */
  /* !!! DO NOT TOUCH CODE BELOW OR YOU MAY BE DISQUALIFIED !!! */
  /* !!!----------------------------------------------------!!! */

  int error_count;
  int check_count;

  /* !!!----------------------------------------------------!!! */
  /* !!! DO NOT TOUCH CODE ABOVE OR YOU MAY BE DISQUALIFIED !!! */
  /* !!!----------------------------------------------------!!! */

  // Registers of golden model
  alu_matrix_reg_model alu_matrix_regs;

  // Mailboxes' handlers
  mailbox rst2scrb;
  mailbox in2scrb;
  mailbox out2scrb;
  mailbox apb2scrb;
  mailbox irq2scrb;

  // Event that indicates first valid_ready
  // handshake on axis_in_if
  event first_hs;

  // Handlers for transactions collected from mailboxes
  rst_transaction        coll_rst_transaction;
  irq_transaction        coll_irq_transaction;
  axi_stream_transaction coll_in_transaction;
  axi_stream_transaction coll_out_transaction;
  apb_master_transaction coll_apb_transaction;
 
  // Your variables here...



  function new(alu_matrix_reg_model alu_matrix_regs, mailbox rst2scrb, in2scrb, out2scrb, apb2scrb, irq2scrb, event first_hs);
    this.alu_matrix_regs = alu_matrix_regs;

    this.rst2scrb        = rst2scrb;
    this.in2scrb         = in2scrb;
    this.out2scrb        = out2scrb;
    this.apb2scrb        = apb2scrb;
    this.irq2scrb        = irq2scrb;

    this.first_hs        = first_hs;

    /* !!!----------------------------------------------------!!! */
    /* !!! DO NOT TOUCH CODE BELOW OR YOU MAY BE DISQUALIFIED !!! */
    /* !!!----------------------------------------------------!!! */
    this.error_count     = 0;
    this.check_count     = 0;
    /* !!!----------------------------------------------------!!! */
    /* !!! DO NOT TOUCH CODE ABOVE OR YOU MAY BE DISQUALIFIED !!! */
    /* !!!----------------------------------------------------!!! */
  endfunction


  function void pre_main();
    // You can write your code here...
  endfunction

  task main();
    fork

      forever begin
        rst2scrb.get(coll_rst_transaction);
        alu_matrix_regs.reset();
      end

      forever begin
        apb_master_transaction coll_apb_transaction_clone;
        apb2scrb.get(coll_apb_transaction);
        coll_apb_transaction_clone = new coll_apb_transaction;
        alu_matrix_regs.update(coll_apb_transaction_clone);
        process_apb_transaction(coll_apb_transaction);
      end

      // ...

    join_none
  endtask

  task run;
    pre_main();
    main();
  endtask

endclass : alu_matrix_scoreboard


task automatic process_apb_transaction(apb_master_transaction coll_apb_transaction);
  // Your code here...
endtask

task automatic process_axis_in_transaction(axi_stream_transaction coll_in_transaction);
  // Your code here...
endtask

task automatic process_axis_out_transaction(axi_stream_transaction coll_out_transaction);
  // Your code here...
endtask

// ...

`endif //!ALU_MATRIX_SCOREBOARD
