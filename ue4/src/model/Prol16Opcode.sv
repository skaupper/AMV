`ifndef PROL16_OPCODE
`define PROL16_OPCODE


`include "Prol16Types.sv"

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


class Prol16Opcode;
    int ra;
    int rb;
    Prol16Command cmd;
    data_v data;

    function new();
        setAll(NOP);
    endfunction

    static function Prol16Opcode create(Prol16Command cmd, int ra = UNUSED, int rb = UNUSED, data_v data = '0);
        Prol16Opcode op = new;
        op.setAll(cmd, ra, rb, data);
        return op;
    endfunction

    function void setAll(Prol16Command cmd, int ra = UNUSED, int rb = UNUSED, data_v data = '0);
        this.cmd = cmd;
        this.ra = ra;
        this.rb = rb;
        this.data = data;
    endfunction

    function data_v toBinary();
        data_v binary = 0;
        binary[15:10] = cmd;
        binary[9:5] = ra;
        binary[4:0] = rb;

        // print;
        // $display("Binary 0x%4h", binary);
        return binary;
    endfunction

    function void print;
        $write("Prol16Opcode: {");
        $write("Command: %s, ", cmd.name());
        $write("Ra: %2d, ", ra);
        $write("Rb: %2d, ", rb);
        $write("Data: 0x%4h", data);
        $write("}\n");
    endfunction
endclass


`endif
