module alu_dec (
    input  [1:0] aluop,
    input  [2:0] funct3,
    input        funct7b5,
    input        op5,
    output reg [2:0] alucontrol
);

    always @(*) begin
        case (aluop)
            2'b00: alucontrol = 3'b000;  // ADD (LW, SW, AUIPC)
            2'b01: alucontrol = 3'b001;  // SUB (branches)
            2'b11: alucontrol = 3'b000;  // ADD (LUI — pass through)
            2'b10: begin                 // R-type and I-type ALU
                case (funct3)
                    3'b000: alucontrol = (funct7b5 & op5) ? 3'b001 : 3'b000;
                    3'b001: alucontrol = 3'b101;  // SLL
                    3'b010: alucontrol = 3'b111;  // SLT
                    3'b100: alucontrol = 3'b100;  // XOR
                    3'b101: alucontrol = 3'b110;  // SRL
                    3'b110: alucontrol = 3'b011;  // OR
                    3'b111: alucontrol = 3'b010;  // AND
                    default: alucontrol = 3'b000;
                endcase
            end
            default: alucontrol = 3'b000;
        endcase
    end

endmodule