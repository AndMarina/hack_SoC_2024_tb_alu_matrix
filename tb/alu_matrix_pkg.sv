`ifndef ALU_MATRIX_PKG
`define ALU_MATRIX_PKG

`include "alu_matrix_defines.sv"

package alu_matrix_pkg;

  typedef enum {BYPASS = 0, SUMM = 1, MUL = 2, TRANS = 3, INVERS = 4, DETERMINANT = 5} e_opcode;

  typedef enum {DRIVE_REQ, GET_RESP} e_apb_driver_state;
  typedef enum {DRIVE_INITIAL, DRIVE} e_axis_driver_state;

endpackage

`endif //!ALU_MATRIX_PKG