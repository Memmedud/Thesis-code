/*
 * Testbench for the ibex Pext-ALU
 */

module ibex_pext_mult_tb;

  import ibex_pkg_pext::*;
  int test_length = 100;

  // clock
  logic clk = 1'b0;
  always #5 clk <= ~clk;

  // Define ALU signals 
  logic[31:0] op_a;
  logic[31:0] op_b;

  logic[31:0] rd_val;
  assign rd_val = '0;

  logic[31:0] mult_result;
  ibex_pkg_pext::zpn_op_e     operator;
  logic mult_en;

  logic width8, width32, signed_ops;

  assign width32 = 1'b0;
  assign width8 = 1'b0;
  assign signed_ops = 1'b1;


  // Instansiate Multiplier
  ibex_mult_pext mult_pext(
    .clk_i              (clk),
    .rst_ni             (1'b1),
    .op_a_i             (op_a),
    .op_b_i             (op_b),
    .rd_val_i           (rd_val),
    .mult_en_i          (mult_en),
    .operator_i         (operator),
    .width32_i          (width32),
    .width8_i           (width8),
    .signed_ops_i       (signed_ops),
    .mult_result_o      (mult_result)
  );

  int total, success;
  logic[47:0] solution;
  initial begin
    total = 0;
    success = 0;

    operator = ZPN_SMMWB;
    $display(mult_result);
    mult_en = 1'b1;

    #20;
    for (int i = 0; i < test_length; i++) begin
        $random(op_a);
        $random(op_b);
        solution = $signed(op_a[31:0]) * $signed(op_b[15:0]);
        #10;
        if (solution == mult_pext.mult_sum_32x16) begin
            $display("SUCCESS: Applying %4h and %4h, resulting in %8h", op_a[31:0], op_b[15:0], mult_pext.mult_sum_32x16);
            total++;
            success++;
        end
        else begin
            $display("FAIL:    Applying %4h and %4h, resulting in %8h, should have been %8h", op_a[31:0], op_b[15:0], mult_pext.mult_sum_32x16, solution);
            total++;
        end
        #10;
    end
    $display("Test done, %d success ratio", success/total);
    $finish;
  end


  logic[47:0] unused_mult32x32;
  assign unused_mult32x32 = mult_pext.mult_sum_32x32;

endmodule
