`ifndef PROL16_TYPES
`define PROL16_TYPES


localparam int gRegs        = 8;
localparam int gDataWidth   = 16;
localparam int gTestCount   = 10;

const int UNUSED = 0;

typedef logic[gDataWidth-1 : 0] data_v;

typedef class Prol16Opcode;
typedef Prol16Opcode Prol16OpcodeQueue[$];


class Prol16State;
    data_v regs[gRegs];
    bit zero;
    bit carry;
    int pc;

    function automatic bit equals(ref Prol16State state);
        bit zeroEqual = (zero == state.zero);
        bit carryEqual = (carry == state.carry);
        bit pcEqual = (pc == state.pc);
        bit regsEqual = 1;

        foreach(regs[i]) begin
            if (regs[i] != state.regs[i]) begin
                regsEqual = 0;
                break;
            end
        end

        return zeroEqual && carryEqual && pcEqual && regsEqual;
    endfunction

    function void print;
        $write("Prol16Model State: {");
        $write("PC: %0d, ", pc);
        $write("Zero: %b, ", zero);
        $write("Carry: %b, ", carry);

        $write("(");
        for (int i = 0; i < gRegs; i++) begin
            if (i != 0) begin
                $write(", ");
            end
            $write("[%2d]: 0x%4h", i, regs[i]);
        end
        $write(")}\n");
    endfunction
endclass


`include "Prol16Opcode.sv"

`endif
