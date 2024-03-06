/*
 * Testbench for the ibex Pext-ALU
 */
module ibex_pext_tb;

  import ibex_pkg_pext::*;
  import ibex_pkg::*;

  // clock
  logic clk = 1'b0;
  always #5 clk <= ~clk;

  // Define ALU signals 
  logic[31:0] alu_operand_a;
  logic[31:0] alu_operand_b;
  logic[31:0] alu_operand_rd;

  logic[31:0] alu_result;

  ibex_pkg_pext::zpn_op_e     zpn_operator;
  ibex_pkg::alu_op_e          alu_operator;
  ibex_pkg::md_op_e           md_operator;

  logic multdiv_sel, mult_en, div_en, mult_sel, div_sel, multdiv_ready_id, data_ind_timing;
  logic[1:0] signed_mode;

  logic[4:0] imm_val;

  logic set_ov;
  logic valid;

  logic[31:0] unused_adder_result;
  logic unused_comp_result;

  // Multicycle register emulation
  logic[1:0]  imd_val_we;
  logic[33:0] imd_val_d[2];
  logic[33:0] imd_val_q[2];
  for (genvar r = 0; r < 2; r++) begin : gen_mult_reg
    always_ff @(posedge clk) begin
      if (imd_val_we[r]) begin
        imd_val_q[r] <= imd_val_d[r];
      end
    end
  end

  // Instansiate ALU
  ibex_alu_pext alu_pext(
    .clk_i              (clk),
    .rst_ni             (1'b1),

    .zpn_operator_i     (zpn_operator),
    .alu_operator_i     (alu_operator),
    .multdiv_operator_i (md_operator),

    .multdiv_sel_i      (multdiv_sel),
    .mult_en_i          (mult_en),
    .div_en_i           (div_en),
    .mult_sel_i         (mult_sel),
    .div_sel_i          (div_sel),
    .signed_mode_i      (signed_mode),
    .multdiv_ready_id_i (multdiv_ready_id),
    .data_ind_timing_i  (data_ind_timing),

    .imd_val_q_i        (imd_val_q),
    .imd_val_d_o        (imd_val_d),
    .imd_val_we_o       (imd_val_we),

    .operand_a_i        (alu_operand_a),
    .operand_b_i        (alu_operand_b),
    .operand_rd_i       (alu_operand_rd),

    .imm_val_i          (imm_val),

    .adder_result_o     (unused_adder_result),

    .result_o           (alu_result),
    .valid_o            (valid),
    .set_ov_o           (set_ov),
    .comparison_result_o(unused_comp_result)
  );


  always @(posedge clk) begin
    $display($stime,,,"alu_result=%8h mult_valid=%1b imd_val1=%8h imd_val0=%8h quad=%2b", alu_result, valid, imd_val_q[1], imd_val_q[0], alu_pext.mult_pext_i.quadrant);
  end

  initial begin
    #20;

    imm_val = 5'b00110;

    alu_operand_a  = 32'h1545_0015;
    //alu_operand_a  = 32'ha545_a545;
    alu_operand_b  = 32'h5142_18d4;
    alu_operand_rd = 32'hffff_ffff;

    zpn_operator = ZPN_KMMSB;
    alu_operator = ZPN_INSTR;
    md_operator  = MD_OP_MULH;

    multdiv_sel = 1'b1;
    mult_en = 1'b1;
    div_en = 1'b0;
    mult_sel = mult_en;
    div_sel = div_en;
    signed_mode = 2'b00;
    multdiv_ready_id = 1'b0;
    data_ind_timing = 1'b0;

    #10;
    //mult_en = 1'b1;
    //$display("%4b", alu_pext.saturated);
    $display("%1b", valid);
    $display("%1b", set_ov);
    $display("%1b", alu_pext.signed_ops);
    $display("%1b", alu_pext.mult_pext_i.crossed);
    $display("%4b", alu_pext.mult_pext_i.saturated);
    $display("%4b", alu_pext.operand_negative);
    $display("%8h", alu_pext.shift_result);
    $display("%8h", alu_pext.clip_mask);
   //$display("%8h", alu_pext.mult_pext_i.sum_op_a);
    $display("%8h", alu_pext.mult_pext_i.mult_sum_32x32W);

    #40;
    $display("%8h", alu_pext.mult_pext_i.mult_sum_32x32W);
    $display("%8h", imd_val_q);
    $finish;
  end

endmodule
