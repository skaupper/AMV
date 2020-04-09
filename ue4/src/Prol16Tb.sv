`include "model/Prol16Model.sv"


module top;
    test TheTest();
endmodule

program test;

    typedef Prol16Opcode Prol16OpcodeQueue[$];

    function Prol16OpcodeQueue generateTests();
        Prol16OpcodeQueue tests;

        for (int i = 0; i < gRegs; ++i) begin
            tests.push_back(Prol16Opcode::create(LOADI, i, UNUSED, 16'h1111 * i));
        end

        tests.push_back(Prol16Opcode::create(NOP));
        tests.push_back(Prol16Opcode::create(SLEEP));
        tests.push_back(Prol16Opcode::create(LOAD, 1, 0));
        tests.push_back(Prol16Opcode::create(STORE, 2, 3));

        tests.push_back(Prol16Opcode::create(JUMP, 21));
        tests.push_back(Prol16Opcode::create(SHL, 15));
        tests.push_back(Prol16Opcode::create(JUMPC, 26));
        tests.push_back(Prol16Opcode::create(JUMPZ, 31));

        tests.push_back(Prol16Opcode::create(COMP, 0, 0));

        tests.push_back(Prol16Opcode::create(JUMP, 10));
        tests.push_back(Prol16Opcode::create(JUMPC, 15));
        tests.push_back(Prol16Opcode::create(JUMPZ, 20));

        tests.push_back(Prol16Opcode::create(MOVE, 5, 15));
        tests.push_back(Prol16Opcode::create(AND, 14, 3));
        tests.push_back(Prol16Opcode::create(OR, 13, 6));
        tests.push_back(Prol16Opcode::create(XOR, 12, 11));
        tests.push_back(Prol16Opcode::create(NOT, 11));

        tests.push_back(Prol16Opcode::create(ADD, 3, 12));
        tests.push_back(Prol16Opcode::create(ADDC, 1, 2));
        tests.push_back(Prol16Opcode::create(SUBC, 2, 3));
        tests.push_back(Prol16Opcode::create(SUB, 11, 7));

        tests.push_back(Prol16Opcode::create(COMP, 3, 12));
        tests.push_back(Prol16Opcode::create(INC, 15));
        tests.push_back(Prol16Opcode::create(DEC, 1));

        tests.push_back(Prol16Opcode::create(SHL, 3));
        tests.push_back(Prol16Opcode::create(SHLC, 5));
        tests.push_back(Prol16Opcode::create(SHR, 4));
        tests.push_back(Prol16Opcode::create(SHRC, 6));

        return tests;
    endfunction


    initial begin : stimuli
        static Prol16OpcodeQueue ops = generateTests();
        static Prol16Model model = new;

        for (int i = 0; i < ops.size(); ++i) begin
            model.execute(ops[i]);

            ops[i].print;
            model.print;
            $display();
        end

        $finish;
    end : stimuli
endprogram
