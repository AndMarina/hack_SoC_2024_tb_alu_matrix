`ifndef ALU_MATRIX_REG_MODEL
`define ALU_MATRIX_REG_MODEL

class alu_matrix_reg_model;

  // Be careful - all unsigned as default for logic
  logic  [`APB_DATA_W -1:0]  OPCODE;
  logic  [`APB_DATA_W -1:0]  STATUS;
  logic  [`APB_DATA_W -1:0]  ISR;
  logic  [`APB_DATA_W -1:0]  IER;
  logic  [`APB_DATA_W -1:0]  MATRIX0V;
  logic  [`APB_DATA_W -1:0]  MATRIX0H;
  logic  [`APB_DATA_W -1:0]  MATRIX1V;
  logic  [`APB_DATA_W -1:0]  MATRIX1H;
  logic  [`APB_DATA_W -1:0]  SUM_CTR;
  logic  [`APB_DATA_W -1:0]  MULT_CTR;
  logic  [`APB_DATA_W -1:0]  TRAN_CTR;
  logic  [`APB_DATA_W -1:0]  REV_CTR;
  logic  [`APB_DATA_W -1:0]  DET_CTR;

  function void reset();
    OPCODE    = 0;
    STATUS    = 0;
    ISR       = 0;
    IER       = 0;
    MATRIX0V  = 0;
    MATRIX0H  = 0;
    MATRIX1V  = 0;
    MATRIX1H  = 0;
    SUM_CTR   = 0;
    MULT_CTR  = 0;
    TRAN_CTR  = 0;
    REV_CTR   = 0;
    DET_CTR   = 0;
  endfunction

  function void update(apb_master_transaction transaction);
    case (transaction.addr)
      32'h00: OPCODE   = transaction.data;
      32'h04: STATUS   = transaction.data;
      32'h08: ISR      = transaction.data;
      32'h0C: IER      = transaction.data;
      32'h10: MATRIX0V = transaction.data;
      32'h14: MATRIX0H = transaction.data;
      32'h18: MATRIX1V = transaction.data;
      32'h1C: MATRIX1H = transaction.data;
      32'h20: SUM_CTR  = transaction.data;
      32'h24: MULT_CTR = transaction.data;
      32'h28: TRAN_CTR = transaction.data;
      32'h2C: REV_CTR  = transaction.data;
      32'h30: DET_CTR  = transaction.data;
    endcase
  endfunction

endclass : alu_matrix_reg_model

`endif //!ALU_MATRIX_REG_MODEL