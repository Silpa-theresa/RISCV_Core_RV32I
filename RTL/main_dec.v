module main_dec (
    input  [6:0] op,
    output reg       regwrite,
    output reg       memwrite,
    output reg       alusrc,
    output reg       branch,
    output reg       jump,
    output reg [1:0] resultsrc,
    output reg [1:0] aluop,
    output reg [2:0] immsrc
);

    always @(*) begin
        case (op)
            // R-type
            7'b0110011: begin
                regwrite  = 1; memwrite = 0; alusrc = 0;
                branch    = 0; jump     = 0;
                resultsrc = 2'b00; aluop = 2'b10; immsrc = 3'b000;
            end
            // I-type ALU (ADDI, ORI, ANDI...)
            7'b0010011: begin
                regwrite  = 1; memwrite = 0; alusrc = 1;
                branch    = 0; jump     = 0;
                resultsrc = 2'b00; aluop = 2'b10; immsrc = 3'b000;
            end
            // LW
            7'b0000011: begin
                regwrite  = 1; memwrite = 0; alusrc = 1;
                branch    = 0; jump     = 0;
                resultsrc = 2'b01; aluop = 2'b00; immsrc = 3'b000;
            end
            // SW
            7'b0100011: begin
                regwrite  = 0; memwrite = 1; alusrc = 1;
                branch    = 0; jump     = 0;
                resultsrc = 2'b00; aluop = 2'b00; immsrc = 3'b001;
            end
            // B-type (BEQ, BNE, BLT, BGE...)
            7'b1100011: begin
                regwrite  = 0; memwrite = 0; alusrc = 0;
                branch    = 1; jump     = 0;
                resultsrc = 2'b00; aluop = 2'b01; immsrc = 3'b010;
            end
            // JAL
            7'b1101111: begin
                regwrite  = 1; memwrite = 0; alusrc = 0;
                branch    = 0; jump     = 1;
                resultsrc = 2'b10; aluop = 2'b00; immsrc = 3'b100;
            end
            // LUI
            7'b0110111: begin
                regwrite  = 1; memwrite = 0; alusrc = 1;
                branch    = 0; jump     = 0;
                resultsrc = 2'b00; aluop = 2'b11; immsrc = 3'b011;
            end
            // AUIPC
            7'b0010111: begin
                regwrite  = 1; memwrite = 0; alusrc = 1;
                branch    = 0; jump     = 0;
                resultsrc = 2'b00; aluop = 2'b11; immsrc = 3'b011;
            end
            // JALR
            7'b1100111: begin
                regwrite  = 1; memwrite = 0; alusrc = 1;
                branch    = 0; jump     = 1;
                resultsrc = 2'b10; aluop = 2'b00; immsrc = 3'b000;
            end
            default: begin
                regwrite  = 0; memwrite = 0; alusrc = 0;
                branch    = 0; jump     = 0;
                resultsrc = 2'b00; aluop = 2'b00; immsrc = 3'b000;
            end
        endcase
    end

endmodule