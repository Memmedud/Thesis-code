/*
 * Testbench for the ibex Pext-ALU
 */
module ibex_pext_tb;

  import ibex_pkg_pext::*;

  // clock
  logic clk = 1'b0;
  always #5 clk <= ~clk;

  // Define ALU signals 
  logic[31:0] alu_operand_a;
  logic[31:0] alu_operand_b;
  logic[31:0] alu_result;
  ibex_pkg_pext::signed_type_e signed_operands;
  ibex_pkg_pext::zpn_op_e     operator;
  logic enable;

  // Instansiate ALU
  ibex_alu_pext alu_pext(
    .operand_a_i        (alu_operand_a),
    .operand_b_i        (alu_operand_b),
    .enable_i           (enable),

    .signed_operands_i  (signed_operands),
    .operator_i         (operator),

    .result_o           (alu_result)
  );

  always @(posedge clk) begin
    $display($stime,,,"clk=%b alu_result=%8h", clk, alu_result);
  end

  initial begin
    #20;
    alu_operand_a = 32'h8126_7f83;
    alu_operand_b = 32'h0000_0002;
    operator = ZPN_ZUNPKD810;
    enable = 1'b1;
    signed_operands = U16;
    #20;
    $finish;
  end

endmodule
