	imescale 1ns/1ps
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
        repeat(25) @(posedge clk);
        $display("==== Final State ====")
        $display("x1 = %0d", uut.dp.rf.rf[1]);
        $display("x2 = %0d", uut.dp.rf.rf[2]);
        $display("x3 = %0d", uut.dp.rf.rf[3]);
        $display("x4 = %0d", uut.dp.rf.rf[4]);
        $display("PC = %0d", uut.dp.pc_reg);
        $display("mem[1] = %0d", uut.dm.mem[1]);
        $finish;
    end
endmodule
