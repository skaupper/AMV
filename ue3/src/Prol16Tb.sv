`include "Prol16Model.sv"


module top;
    test TheTest();
endmodule

program test;

    initial begin : stimuli
        // stimuli ------------------------------------------------------------
        // ...

        Prol16Opcode op;
        Prol16Model model;
        model.reset;

        op.setAll(LOADI, 0, UNUSED, 16'hABCD);
        model.execute(op);
        #1ns;

        #100ns;

        $finish;
    end : stimuli
endprogram
