module imem (
    input  [31:0] addr,
    output [31:0] instr
);

    reg [31:0] mem [0:63];

    integer i;
    initial begin
        for (i = 0; i < 64; i = i + 1)
            mem[i] = 32'b0;
        $readmemh("C:/Users/silpa/riscv_core/MEMORY/fibonacci.hex", mem);
    end

    assign instr = mem[addr[31:2]];

endmodule
