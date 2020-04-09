`ifndef PROL16_TYPES
`define PROL16_TYPES


localparam int gRegs        = 16;
localparam int gDataWidth   = 16;

typedef logic[gDataWidth-1 : 0] data_v;

typedef class Prol16Opcode;
typedef Prol16Opcode Prol16OpcodeQueue[$];


class Prol16State;
    data_v regs[gRegs];
    bit zero;
    bit carry;
    int pc;
endclass


`include "Prol16Opcode.sv"

`endif
