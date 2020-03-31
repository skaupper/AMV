`include "Prol16Model.sv"


module top;
    test TheTest();
endmodule

program test;

    initial begin : stimuli
        // stimuli ------------------------------------------------------------
        // ...

        static Prol16Opcode op = new;
        static Prol16Model model = new;

        model.print;
        op.print;


        op.setAll(LOADI, 0, UNUSED, 16'hABCD); model.execute(op); #1ns;
        model.print;

        op.setAll(LOADI, 1, UNUSED, 16'h1234); model.execute(op); #1ns;
        model.print;


        $finish;
    end : stimuli
endprogram
