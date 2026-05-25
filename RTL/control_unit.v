module control_unit (
    input  [6:0] op,
    input  [2:0] funct3,
    input        funct7b5,
    input        zero,
    output       regwrite,
    output       memwrite,
    output       alusrc,
    output       pcsrc,
    output [1:0] resultsrc,
    output [2:0] immsrc,
    output [2:0] alucontrol
);

    wire [1:0] aluop;
    wire       branch;
    wire       jump;

    main_dec md (
        .op        (op),
        .regwrite  (regwrite),
        .memwrite  (memwrite),
        .alusrc    (alusrc),
        .branch    (branch),
        .jump      (jump),
        .resultsrc (resultsrc),
        .aluop     (aluop),
        .immsrc    (immsrc)
    );

    alu_dec ad (
        .aluop      (aluop),
        .funct3     (funct3),
        .funct7b5   (funct7b5),
        .alucontrol (alucontrol)
    );

    assign pcsrc = (branch & zero) | jump;

endmodule