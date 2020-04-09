`ifndef PROL16_TYPES
`define PROL16_TYPES


localparam int gRegs        = 16;
localparam int gDataWidth   = 16;

typedef bit[gDataWidth-1 : 0] data_v;

typedef class Prol16Opcode;
typedef Prol16Opcode Prol16OpcodeQueue[$];


`include "Prol16Opcode.sv"

`endif
