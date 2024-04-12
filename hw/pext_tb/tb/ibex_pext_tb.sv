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
    .zpn_instr_i        (1'b1),
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
    //$display($stime,,,"alu_result=%8h mult_valid=%1b imd_val1=%8h imd_val0=%8h quad=%2b cc=%2b div_en=%1b divbyzero=%1b divstate=%3b", alu_result, valid, imd_val_q[1], imd_val_q[0], alu_pext.mult_pext_i.zpn_signed_mult, alu_pext.mult_pext_i.cycle_count, alu_pext.mult_pext_i.div_en_internal, alu_pext.mult_pext_i.div_by_zero_d, alu_pext.mult_pext_i.md_state_q);
    $display($stime,,,"alu_result=%8h mult_result=%12h imd_val1=%8h imd_val0=%8h op_b=%8h valid=%1b is_byte_less=%4b signed_mult=%2b", alu_result, alu_pext.mult_pext_i.mult_sum_16x16_0, alu_pext.mult_pext_i.mult_sum_16x16_1, imd_val_d[1], imd_val_d[0], alu_pext.mult_pext_i.valid_o, alu_pext.is_byte_less, alu_pext.mult_pext_i.zpn_signed_mult);
  end

  initial begin
    #20;

    imm_val = 5'h1b;

    //alu_operand_a  = 32'h1545_0015;
    //alu_operand_a  = 32'hffff_7fff;
    //alu_operand_a  = 32'haaaa_aaab;
    alu_operand_a  = 32'hff7fffff;
    //alu_operand_a  = 32'hffff_fdff;
    //alu_operand_b  = 32'h5142_18d4;
    //alu_operand_b  = 32'hffff_f7ff;
    //alu_operand_b  = 32'hffff_ffff;
    alu_operand_b  = 32'h8;
    //alu_operand_b  = 32'h0000_0003;
    alu_operand_rd = 32'h0;

    zpn_operator = ZPN_KSLLW;
    alu_operator = ZPN_INSTR;
    md_operator  = MD_OP_MULL;

    multdiv_sel = 1'b0;
    mult_en = 1'b0;
    div_en = 1'b0;
    mult_sel = mult_en;
    div_sel = div_en;
    signed_mode = 2'b00;
    multdiv_ready_id = 1'b0;
    data_ind_timing = 1'b0;

    #10;
    //mult_en = 1'b1;
    //$display("%4b", alu_pext.saturated);
    $display("%8h", ~alu_pext.shift_mask);
    $display("%4b", alu_pext.saturation_bytes);
    $display("%4b", alu_pext.shift_saturation);
    $display("%4b", alu_pext.saturated);
    $display("%4b", alu_pext.shift);
    $display("%8h", alu_pext.operand_a_i);
    $display("%8h", alu_pext.shift_left);
    $display("%8h", alu_pext.shift_result);
    $display("%8h", alu_pext.saturating_result);
    $display("%8h", alu_pext.sat_imm_shift_result);
    $display("%8h", alu_pext.sat_op2);
    $display("%8h", alu_pext.sat_op1);
    $display("%8h", alu_pext.imm_instr);


    #40;
    //#500;
    $finish;
  end

endmodule
