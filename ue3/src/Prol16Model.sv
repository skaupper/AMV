`ifndef PROL16_MODEL
`define PROL16_MODEL


`include "Prol16Opcode.sv"


class Prol16State;
    data_v regs[gRegs];
    bit zero;
    bit carry;
endclass


class Prol16Model;
    local Prol16State state;

    local function __reset;
        state.regs = '{gRegs{'0}};
        state.zero = 0;
        state.carry = 0;
        return 0;
    endfunction

    function new;
        state = new;
        void'(__reset);
    endfunction

    task reset;
        void'(__reset);
    endtask

    function execute (Prol16Opcode opc);

    endfunction

endclass


`endif
