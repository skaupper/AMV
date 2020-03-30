`include "Prol16Model.sv"


module top;
    test TheTest();
endmodule

program test;
    initial begin : stimuli
        // stimuli ------------------------------------------------------------
        // ...

        Prol16Model model;
        model.reset;

        #100ns;

        $finish;
    end : stimuli
endprogram
