`timescale 1ns/1ps
module tb_bug_check;

  reg clk, rst;

  riscv_core dut (
    .clk(clk),
    .rst(rst)
  );

  initial clk = 0;
  always #5 clk = ~clk;

  initial begin
    $dumpfile("SIMULATION/bug_check.vcd");
    $dumpvars(0, tb_bug_check);
    rst = 1;
    #12 rst = 0;
    #300 $finish;
  end

endmodule