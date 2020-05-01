`ifndef PROL16_OPCODE
`define PROL16_OPCODE


`include "Prol16Types.sv"

typedef enum bit[5:0] {
    NOP     = 'd0,
    SLEEP   = 'd1,
    LOADI   = 'd2,
    LOAD    = 'd3,
    STORE   = 'd4,
    JUMP    = 'd8,
    JUMPC   = 'd10,
    JUMPZ   = 'd11,
    MOVE    = 'd12,
    AND     = 'd16,
    OR      = 'd17,
    XOR     = 'd18,
    NOT     = 'd19,
    ADD     = 'd20,
    ADDC    = 'd21,
    SUB     = 'd22,
    SUBC    = 'd23,
    COMP    = 'd24,
    INC     = 'd26,
    DEC     = 'd27,
    SHL     = 'd28,
    SHR     = 'd29,
    SHLC    = 'd30,
    SHRC    = 'd31
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
