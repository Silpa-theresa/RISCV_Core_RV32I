module datapath (
    input         clk,
    input         rst,
    input         regwrite,
    input         memwrite,
    input         alusrc,
    input         pcsrc,
    input  [1:0]  resultsrc,
    input  [2:0]  immsrc,
    input  [2:0]  alucontrol,
    output [6:0]  op,
    output [2:0]  funct3,
    output        funct7b5,
    output        zero,
    output        negative,
    output [31:0] mem_addr,
    output [31:0] mem_wdata,
    input  [31:0] mem_rdata
);

    reg  [31:0] pc_reg;
    wire [31:0] pc_next, pc_plus4, pc_target;
    wire [31:0] instr;
    wire [31:0] rd1, rd2;
    wire [31:0] immext;
    wire [31:0] alu_b, alu_result;
    wire [31:0] result;

    // PC register
    initial pc_reg = 32'b0;

    always @(posedge clk) begin
        if (rst) pc_reg <= 32'b0;
        else     pc_reg <= pc_next;
    end

    // PC arithmetic
    assign pc_plus4  = pc_reg + 32'd4;
    assign pc_target = pc_reg + immext;
    assign pc_next   = pcsrc ? pc_target : pc_plus4;

    // Instruction memory
    imem im (
        .addr  (pc_reg),
        .instr (instr)
    );

    // Instruction fields
    assign op       = instr[6:0];
    assign funct3   = instr[14:12];
    assign funct7b5 = instr[30];

    // Register file
    regfile rf (
        .clk (clk),
        .we3 (regwrite),
        .a1  (instr[19:15]),
        .a2  (instr[24:20]),
        .a3  (instr[11:7]),
        .wd3 (result),
        .rd1 (rd1),
        .rd2 (rd2)
    );

    // Immediate extender
    imm_ext ie (
        .instr  (instr),
        .immsrc (immsrc),
        .immext (immext)
    );

    // ALU
    assign alu_b = alusrc ? immext : rd2;

    alu al (
        .a          (rd1),
        .b          (alu_b),
        .alucontrol (alucontrol),
        .result     (alu_result),
        .zero       (zero),
        .negative   (negative)
    );

    // Memory interface
    assign mem_addr  = alu_result;
    assign mem_wdata = rd2;

    // Writeback MUX
    assign result = (resultsrc == 2'b00) ? alu_result :
                    (resultsrc == 2'b01) ? mem_rdata  :
                    (resultsrc == 2'b10) ? pc_plus4   :
                                           32'b0;

endmodule