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
    rand int ra;
    rand int rb;
    rand Prol16Command cmd;
    data_v data;

    constraint reg_a { ra inside {[0:gRegs-1]}; }
    constraint reg_b { rb inside {[0:gRegs-1]}; }

    constraint ignore_cmds { !(cmd inside {SLEEP, STORE, LOAD}); }

    constraint no_reg_used {
        cmd inside {
            NOP, SLEEP
        } -> (ra == 0 && rb == 0);
    }

    constraint only_one_reg_used {
        cmd inside {
            LOADI, JUMP, JUMPC, JUMPZ, NOT, INC, DEC, SHL, SHR, SHLC, SHRC
        } -> (rb == 0);
    }

    constraint prio_cmd {
        solve cmd before ra;
        solve cmd before rb;
    }


    function new();
        setAll(NOP);
    endfunction

    static function Prol16Opcode create(Prol16Command cmd, int ra = UNUSED, int rb = UNUSED, data_v data = '0);
        Prol16Opcode op = new;
        op.setAll(cmd, ra, rb, data);
        return op;
    endfunction

    static function Prol16Opcode createRandomized();
        Prol16Opcode op = new;
        assert(op.randomize());
        if (op.cmd == LOADI) begin
            op.data = $urandom(2**gDataWidth);
        end
        op.print();
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
