`ifndef _GENERATOR_
`define _GENERATOR_

`include "model/Prol16Opcode.sv"

class Generator;
  Prol16OpcodeQueue testQueue;

  function new();
    testQueue = generateTests();
  endfunction

  function bit hasTests();
    return testQueue.size() > 0;
  endfunction

  function Prol16Opcode nextTest();
    assert(hasTests());
    return testQueue.pop_front();
  endfunction



  local function Prol16OpcodeQueue generateTests();
    Prol16OpcodeQueue tests;

    tests.push_back(Prol16Opcode::create(LOADI, 7, UNUSED, 16'h4711));
    tests.push_back(Prol16Opcode::create(JUMP, 7));

    for (int i = 0; i < gRegs; ++i) begin
        tests.push_back(Prol16Opcode::create(LOADI, i, UNUSED, 16'h1111 * i));
    end

    tests.push_back(Prol16Opcode::create(NOP));
    tests.push_back(Prol16Opcode::create(NOP));
    tests.push_back(Prol16Opcode::create(NOP));

    // These commands are not supported by the model!
    // tests.push_back(Prol16Opcode::create(SLEEP));
    // tests.push_back(Prol16Opcode::create(LOAD, 1, 0));
    // tests.push_back(Prol16Opcode::create(STORE, 2, 3));

    tests.push_back(Prol16Opcode::create(JUMP, 5));
    tests.push_back(Prol16Opcode::create(SHL, 3));
    tests.push_back(Prol16Opcode::create(JUMPC, 6));
    tests.push_back(Prol16Opcode::create(JUMPZ, 7));

    tests.push_back(Prol16Opcode::create(COMP, 0, 0));

    tests.push_back(Prol16Opcode::create(JUMP, 4));
    tests.push_back(Prol16Opcode::create(JUMPC, 1));
    tests.push_back(Prol16Opcode::create(JUMPZ, 2));

    tests.push_back(Prol16Opcode::create(MOVE, 5, 0));
    tests.push_back(Prol16Opcode::create(AND, 6, 3));
    tests.push_back(Prol16Opcode::create(OR, 4, 2));
    tests.push_back(Prol16Opcode::create(XOR, 0, 1));
    tests.push_back(Prol16Opcode::create(NOT, 7));

    tests.push_back(Prol16Opcode::create(ADD, 3, 1));
    tests.push_back(Prol16Opcode::create(ADDC, 1, 2));
    tests.push_back(Prol16Opcode::create(SUBC, 2, 3));
    tests.push_back(Prol16Opcode::create(SUB, 0, 7));

    tests.push_back(Prol16Opcode::create(COMP, 3, 4));
    tests.push_back(Prol16Opcode::create(INC, 7));
    tests.push_back(Prol16Opcode::create(DEC, 1));

    tests.push_back(Prol16Opcode::create(SHL, 3));
    tests.push_back(Prol16Opcode::create(SHLC, 5));
    tests.push_back(Prol16Opcode::create(SHR, 4));
    tests.push_back(Prol16Opcode::create(SHRC, 6));

    return tests;
  endfunction

endclass


`endif /* _GENERATOR_ */
