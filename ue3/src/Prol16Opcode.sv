`ifndef PROL16_OPCODE
`define PROL16_OPCODE


`include "Types.sv"

typedef enum int {
    NOP     = 0,
    SLEEP   = 1,
    LOADI   = 2,
    LOAD    = 3,
    STORE   = 4,
    JUMP    = 8,
    JUMPC   = 10,
    JUMPZ   = 11,
    MOVE    = 12,
    AND     = 16,
    OR      = 17,
    XOR     = 18,
    NOT     = 19,
    ADD     = 20,
    ADDC    = 21,
    SUB     = 22,
    SUBC    = 23,
    COMP    = 24,
    INC     = 26,
    DEC     = 27,
    SHL     = 28,
    SHR     = 29,
    SHLC    = 30,
    SHRC    = 31
} Prol16Command;

const int UNUSED = -1;

class Prol16Opcode;
    int ra;
    int rb;
    Prol16Command cmd;
    data_v data;

    function new(Prol16Command cmd, int ra, int rb, data_v data = '0);
        setAll(cmd, ra, rb, data);
    endfunction

    task setAll(Prol16Command cmd, int ra, int rb, data_v data = '0);
        this.cmd = cmd;
        this.ra = ra;
        this.rb = rb;
        this.data = data;
    endtask
endclass


`endif
