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
  logic[31:0] mult_result;
  ibex_pkg_pext::signed_type_e signed_operands;
  ibex_pkg_pext::zpn_op_e     operator;
  logic enable;
  logic mult_en;

  // Instansiate ALU
  ibex_alu_pext alu_pext(
    .operand_a_i        (alu_operand_a),
    .operand_b_i        (alu_operand_b),
    .enable_i           (enable),

    .signed_operands_i  (signed_operands),
    .operator_i         (operator),
    .mult_result_i      (mult_result),

    .result_o           (alu_result)
  );

  // Instansiate Multiplier
  ibex_mult_pext mult_pext(
    .clk_i              (clk),
    .rst_ni             (1'b1),
    .op_a_i             (alu_operand_a),
    .op_b_i             (alu_operand_b),
    .mult_en_i          (mult_en),
    .operator_i         (operator),
    .signed_operands_i  (signed_operands),
    .mult_result_o      (mult_result)
  );

  always @(posedge clk) begin
    $display($stime,,,"clk=%b alu_result=%8h mult_result=%8h fsm_state=%d", clk, alu_result, mult_result, mult_pext.mult_state);
  end

  initial begin
    #20;
    mult_en = 1'b0;
    alu_operand_a = 32'h8201_11dc;
    alu_operand_b = 32'h0505_7fca;
    //operator = ZPN_KSUB16;
    operator = ZPN_KCRSA16;
    enable = 1'b1;
    signed_operands = S16;
    #10;
    mult_en = 1'b1;
    $display("%4b", alu_pext.saturated);
    $display("%1b", alu_pext.set_ov);
    #40;
    $finish;
  end

endmodule
