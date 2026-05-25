`timescale 1ns/1ps
module tb_riscv;
    reg clk;
    reg rst;
    riscv_core uut (.clk(clk), .rst(rst));
    initial clk = 0;
    always #5 clk = ~clk;
    initial begin
        $dumpfile("SIMULATION/waves.vcd");
        $dumpvars(0, tb_riscv);
    end
    initial begin
        rst = 1;
        repeat(4) @(posedge clk);
        rst = 0;
        repeat(30) @(posedge clk);
        $display("==== Fibonacci Results ===="  );
        $display("x1  = %0d", uut.dp.rf.rf[1]);
        $display("x2  = %0d", uut.dp.rf.rf[2]);
        $display("x3  = %0d", uut.dp.rf.rf[3]);
        $display("x4  = %0d", uut.dp.rf.rf[4]);
        $display("x5  = %0d", uut.dp.rf.rf[5]);
        $display("x6  = %0d", uut.dp.rf.rf[6]);
        $display("x7  = %0d", uut.dp.rf.rf[7]);
        $display("x8  = %0d", uut.dp.rf.rf[8]);
        $display("PC  = %0d", uut.dp.pc_reg);
        $finish;
    end
endmodule
