`include "Prol16Model.sv"


module top;
    test TheTest();
endmodule

program test;

    task automatic execute(ref Prol16Model model, ref Prol16Opcode op, input Prol16Command cmd, int ra = UNUSED, int rb = UNUSED, data_v data = '0);
        op.setAll(cmd, ra, rb, data);
        model.execute(op);
        model.print;
        #1ns;
    endtask

    initial begin : stimuli
        // stimuli ------------------------------------------------------------
        // ...

        static Prol16Opcode op = new;
        static Prol16Model model = new;

        model.print;
        op.print;

        for (int i = 0; i < gRegs; ++i) begin
            execute(model, op, LOADI, i, UNUSED, 16'h1111 * i);
        end
        model.print;

        execute(model, op, SLEEP);
        execute(model, op, LOAD, 1, 0);
        execute(model, op, STORE, 2, 3);

        // TODO: assert state

        execute(model, op, JUMP, 21);
        execute(model, op, JUMPC, 26);
        execute(model, op, JUMPZ, 31);

        // TODO: assert PC

        // set carry and zero flags
        execute(model, op, SHL, 15);
        execute(model, op, COMP, 0, 0);


        execute(model, op, JUMP, 10);
        execute(model, op, JUMPC, 15);
        execute(model, op, JUMPZ, 20);

        // TODO: assert PC

        execute(model, op, MOVE, 5, 15);
        execute(model, op, AND, 14, 3);
        execute(model, op, OR, 13, 6);
        execute(model, op, XOR, 12, 11);
        execute(model, op, NOT, 11);

        // TODO: check registers

        execute(model, op, ADD, 3, 12);
        execute(model, op, ADDC, 1, 2);
        execute(model, op, SUB, 11, 7);
        execute(model, op, SUBC, 2, 3);

        // TODO: check registers

        execute(model, op, COMP, 3, 12);
        execute(model, op, INC, 15);
        execute(model, op, DEC, 1);

        // TODO: check registers

        execute(model, op, SHL, 3);
        execute(model, op, SHR, 4);
        execute(model, op, SHLC, 5);
        execute(model, op, SHRC, 6);

        // TODO: check registers


        $finish;
    end : stimuli
endprogram
