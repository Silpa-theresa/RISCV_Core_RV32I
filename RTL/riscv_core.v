module riscv_core (
    input  clk,
    input  rst
);

    // Control signals
    wire        regwrite;
    wire        memwrite;
    wire        alusrc;
    wire        pcsrc;
    wire [1:0]  resultsrc;
    wire [2:0]  immsrc;
    wire [2:0]  alucontrol;

    // Decode feedback signals
    wire [6:0]  op;
    wire [2:0]  funct3;
    wire        funct7b5;
    wire        zero;

    // Memory interface
    wire [31:0] mem_addr;
    wire [31:0] mem_wdata;
    wire [31:0] mem_rdata;

    // ── Datapath ─────────────────────────────────────────────────
    datapath dp (
        .clk        (clk),
        .rst        (rst),
        .regwrite   (regwrite),
        .memwrite   (memwrite),
        .alusrc     (alusrc),
        .pcsrc      (pcsrc),
        .resultsrc  (resultsrc),
        .immsrc     (immsrc),
        .alucontrol (alucontrol),
        .op         (op),
        .funct3     (funct3),
        .funct7b5   (funct7b5),
        .zero       (zero),
        .mem_addr   (mem_addr),
        .mem_wdata  (mem_wdata),
        .mem_rdata  (mem_rdata)
    );

    // ── Control Unit ─────────────────────────────────────────────
    control_unit cu (
        .op         (op),
        .funct3     (funct3),
        .funct7b5   (funct7b5),
        .zero       (zero),
        .regwrite   (regwrite),
        .memwrite   (memwrite),
        .alusrc     (alusrc),
        .pcsrc      (pcsrc),
        .resultsrc  (resultsrc),
        .immsrc     (immsrc),
        .alucontrol (alucontrol)
    );

    // ── Data Memory ───────────────────────────────────────────────
    dmem dm (
        .clk  (clk),
        .we   (memwrite),
        .addr (mem_addr),
        .wd   (mem_wdata),
        .rd   (mem_rdata)
    );

endmodule