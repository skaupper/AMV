`ifndef _GENERATOR_
`define _GENERATOR_

`include "model/Prol16Opcode.sv"

class Generator;
  Prol16OpcodeQueue testQueue;

  function new();
    $random(gSeed);
    testQueue = {
      generateRandomTests(),
      generateUnlikelyTests()
    };
  endfunction

  function bit hasTests();
    return testQueue.size() > 0;
  endfunction

  function Prol16Opcode nextTest();
    assert(hasTests());
    return testQueue.pop_front();
  endfunction

  local function Prol16OpcodeQueue generateRandomTests();
    Prol16OpcodeQueue tests;

    for (int i = 0; i < gTestCount; ++i) begin
      tests.push_back(Prol16Opcode::createRandomized());
    end

    return tests;
  endfunction


  local function Prol16OpcodeQueue generateUnlikelyTests();
    Prol16OpcodeQueue tests;

    // bin <op_add,carry[1],trans_11>
    // bin <op_add,trans_11,trans_11>
    // bin <op_add,trans_01,trans_11>
    tests.push_back(Prol16Opcode::create(LOADI, 0, UNUSED, 16'hffff));
    tests.push_back(Prol16Opcode::create(LOADI, 1, UNUSED, 16'h0001));
    tests.push_back(Prol16Opcode::create(COMP, 0, 0)); // set zero flag
    tests.push_back(Prol16Opcode::create(ADD, 0, 1));  // produce overflow

    // TODO: implement tests for the following unlikely cases

    // bin <op_subc,carry[1],trans_11>
    // bin <op_shlc,carry[1],trans_11>
    // bin <op_shlc,trans_01,trans_11>
    // bin <op_or,trans_10,trans_11>
    // bin <op_xor,trans_10,trans_11>
    // bin <op_add,trans_10,trans_11>
    // bin <op_dec,trans_10,trans_11>
    // bin <op_addc,trans_11,trans_11>
    // bin <op_subc,trans_11,trans_11>
    // bin <op_shl,trans_11,trans_11>
    // bin <op_shr,trans_11,trans_11>

    return tests;
  endfunction


  local function Prol16OpcodeQueue generateDirectedTests();
    Prol16OpcodeQueue tests;

    tests.push_back(Prol16Opcode::create(LOADI, 7, UNUSED, $urandom_range(0, 2**16-1)));
    tests.push_back(Prol16Opcode::create(NOP));
    tests.push_back(Prol16Opcode::create(LOADI, 0, UNUSED, 16'hfff0));
    tests.push_back(Prol16Opcode::create(LOADI, 1, UNUSED, 16'h10));
    tests.push_back(Prol16Opcode::create(LOADI, 2, UNUSED, 16'h1));
    tests.push_back(Prol16Opcode::create(ADD, 0, 1));
    tests.push_back(Prol16Opcode::create(LOADI, 6, UNUSED, $urandom_range(0, 2**16-1)));
    tests.push_back(Prol16Opcode::create(JUMPC, 6));
    tests.push_back(Prol16Opcode::create(JUMP, 7));
    tests.push_back(Prol16Opcode::create(LOADI, 6, UNUSED, $urandom_range(0, 2**16-1)));
    tests.push_back(Prol16Opcode::create(JUMPZ, 6));
    tests.push_back(Prol16Opcode::create(JUMP, 7));
    tests.push_back(Prol16Opcode::create(ADD, 0, 1));
    tests.push_back(Prol16Opcode::create(JUMPC, 7));
    tests.push_back(Prol16Opcode::create(JUMPZ, 7));
    tests.push_back(Prol16Opcode::create(LOADI, 1, UNUSED, 16'h20));
    tests.push_back(Prol16Opcode::create(SUB, 0, 1));
    tests.push_back(Prol16Opcode::create(JUMPZ, 7));
    tests.push_back(Prol16Opcode::create(LOADI, 6, UNUSED, $urandom_range(0, 2**16-1)));
    tests.push_back(Prol16Opcode::create(JUMPC, 6));
    tests.push_back(Prol16Opcode::create(JUMP, 7));
    tests.push_back(Prol16Opcode::create(MOVE, 1, 0));
    tests.push_back(Prol16Opcode::create(SUB, 0, 1));
    tests.push_back(Prol16Opcode::create(JUMPC, 7));
    tests.push_back(Prol16Opcode::create(LOADI, 6, UNUSED, $urandom_range(0, 2**16-1)));
    tests.push_back(Prol16Opcode::create(JUMPZ, 6));
    tests.push_back(Prol16Opcode::create(JUMP, 7));
    tests.push_back(Prol16Opcode::create(SUB, 0, 1));
    tests.push_back(Prol16Opcode::create(JUMPZ, 7));
    tests.push_back(Prol16Opcode::create(LOADI, 6, UNUSED, $urandom_range(0, 2**16-1)));
    tests.push_back(Prol16Opcode::create(JUMPC, 6));
    tests.push_back(Prol16Opcode::create(JUMP, 7));
    tests.push_back(Prol16Opcode::create(MOVE, 0, 1));
    tests.push_back(Prol16Opcode::create(AND, 0, 1));
    tests.push_back(Prol16Opcode::create(JUMPC, 7));
    tests.push_back(Prol16Opcode::create(JUMPZ, 7));
    tests.push_back(Prol16Opcode::create(LOADI, 0, UNUSED, 16'hf1f1));
    tests.push_back(Prol16Opcode::create(LOADI, 1, UNUSED, 16'he0e));
    tests.push_back(Prol16Opcode::create(AND, 0, 1));
    tests.push_back(Prol16Opcode::create(JUMPC, 7));
    tests.push_back(Prol16Opcode::create(LOADI, 6, UNUSED, $urandom_range(0, 2**16-1)));
    tests.push_back(Prol16Opcode::create(JUMPZ, 6));
    tests.push_back(Prol16Opcode::create(JUMP, 7));
    tests.push_back(Prol16Opcode::create(LOADI, 0, UNUSED, 16'h6f6f));
    tests.push_back(Prol16Opcode::create(LOADI, 1, UNUSED, 16'hf5f5));
    tests.push_back(Prol16Opcode::create(LOADI, 2, UNUSED, 16'h6565));
    tests.push_back(Prol16Opcode::create(AND, 0, 1));
    tests.push_back(Prol16Opcode::create(NOP));
    tests.push_back(Prol16Opcode::create(COMP, 0, 2));
    tests.push_back(Prol16Opcode::create(JUMPC, 7));
    tests.push_back(Prol16Opcode::create(LOADI, 6, UNUSED, $urandom_range(0, 2**16-1)));
    tests.push_back(Prol16Opcode::create(JUMPZ, 6));
    tests.push_back(Prol16Opcode::create(JUMP, 7));
    tests.push_back(Prol16Opcode::create(LOADI, 0, UNUSED, 16'h6666));
    tests.push_back(Prol16Opcode::create(LOADI, 1, UNUSED, 16'h1919));
    tests.push_back(Prol16Opcode::create(LOADI, 2, UNUSED, 16'h7f7f));
    tests.push_back(Prol16Opcode::create(MOVE, 3, 0));
    tests.push_back(Prol16Opcode::create(SUB, 3, 2));
    tests.push_back(Prol16Opcode::create(OR, 0, 1));
    tests.push_back(Prol16Opcode::create(JUMPC, 7));
    tests.push_back(Prol16Opcode::create(JUMPZ, 7));
    tests.push_back(Prol16Opcode::create(COMP, 0, 2));
    tests.push_back(Prol16Opcode::create(JUMPC, 7));
    tests.push_back(Prol16Opcode::create(LOADI, 6, UNUSED, $urandom_range(0, 2**16-1)));
    tests.push_back(Prol16Opcode::create(JUMPZ, 6));
    tests.push_back(Prol16Opcode::create(JUMP, 7));
    tests.push_back(Prol16Opcode::create(LOADI, 0, UNUSED, 16'h0));
    tests.push_back(Prol16Opcode::create(LOADI, 1, UNUSED, 16'h0));
    tests.push_back(Prol16Opcode::create(OR, 0, 1));
    tests.push_back(Prol16Opcode::create(JUMPC, 7));
    tests.push_back(Prol16Opcode::create(LOADI, 6, UNUSED, $urandom_range(0, 2**16-1)));
    tests.push_back(Prol16Opcode::create(JUMPZ, 6));
    tests.push_back(Prol16Opcode::create(JUMP, 7));
    tests.push_back(Prol16Opcode::create(LOADI, 0, UNUSED, 16'hfedc));
    tests.push_back(Prol16Opcode::create(LOADI, 1, UNUSED, 16'h1234));
    tests.push_back(Prol16Opcode::create(LOADI, 2, UNUSED, 16'hece8));
    tests.push_back(Prol16Opcode::create(MOVE, 3, 0));
    tests.push_back(Prol16Opcode::create(SUB, 3, 2));
    tests.push_back(Prol16Opcode::create(XOR, 0, 1));
    tests.push_back(Prol16Opcode::create(JUMPC, 7));
    tests.push_back(Prol16Opcode::create(JUMPZ, 7));
    tests.push_back(Prol16Opcode::create(COMP, 0, 2));
    tests.push_back(Prol16Opcode::create(JUMPC, 7));
    tests.push_back(Prol16Opcode::create(LOADI, 6, UNUSED, $urandom_range(0, 2**16-1)));
    tests.push_back(Prol16Opcode::create(JUMPZ, 6));
    tests.push_back(Prol16Opcode::create(JUMP, 7));
    tests.push_back(Prol16Opcode::create(LOADI, 0, UNUSED, 16'h1212));
    tests.push_back(Prol16Opcode::create(LOADI, 1, UNUSED, 16'h1212));
    tests.push_back(Prol16Opcode::create(XOR, 0, 1));
    tests.push_back(Prol16Opcode::create(JUMPC, 7));
    tests.push_back(Prol16Opcode::create(LOADI, 6, UNUSED, $urandom_range(0, 2**16-1)));
    tests.push_back(Prol16Opcode::create(JUMPZ, 6));
    tests.push_back(Prol16Opcode::create(JUMP, 7));
    tests.push_back(Prol16Opcode::create(LOADI, 0, UNUSED, 16'h0));
    tests.push_back(Prol16Opcode::create(LOADI, 2, UNUSED, 16'hffff));
    tests.push_back(Prol16Opcode::create(MOVE, 3, 0));
    tests.push_back(Prol16Opcode::create(DEC, 3));
    tests.push_back(Prol16Opcode::create(NOT, 0));
    tests.push_back(Prol16Opcode::create(JUMPC, 7));
    tests.push_back(Prol16Opcode::create(JUMPZ, 7));
    tests.push_back(Prol16Opcode::create(COMP, 0, 2));
    tests.push_back(Prol16Opcode::create(JUMPC, 7));
    tests.push_back(Prol16Opcode::create(LOADI, 6, UNUSED, $urandom_range(0, 2**16-1)));
    tests.push_back(Prol16Opcode::create(JUMPZ, 6));
    tests.push_back(Prol16Opcode::create(JUMP, 7));
    tests.push_back(Prol16Opcode::create(NOT, 0));
    tests.push_back(Prol16Opcode::create(JUMPC, 7));
    tests.push_back(Prol16Opcode::create(LOADI, 6, UNUSED, $urandom_range(0, 2**16-1)));
    tests.push_back(Prol16Opcode::create(JUMPZ, 6));
    tests.push_back(Prol16Opcode::create(JUMP, 7));
    tests.push_back(Prol16Opcode::create(LOADI, 0, UNUSED, 16'h0));
    tests.push_back(Prol16Opcode::create(INC, 0));
    tests.push_back(Prol16Opcode::create(JUMPC, 7));
    tests.push_back(Prol16Opcode::create(JUMPZ, 7));
    tests.push_back(Prol16Opcode::create(LOADI, 0, UNUSED, 16'hffff));
    tests.push_back(Prol16Opcode::create(INC, 0));
    tests.push_back(Prol16Opcode::create(LOADI, 6, UNUSED, $urandom_range(0, 2**16-1)));
    tests.push_back(Prol16Opcode::create(JUMPZ, 6));
    tests.push_back(Prol16Opcode::create(JUMP, 7));
    tests.push_back(Prol16Opcode::create(LOADI, 6, UNUSED, $urandom_range(0, 2**16-1)));
    tests.push_back(Prol16Opcode::create(JUMPZ, 6));
    tests.push_back(Prol16Opcode::create(JUMP, 7));
    tests.push_back(Prol16Opcode::create(LOADI, 0, UNUSED, 16'h1));
    tests.push_back(Prol16Opcode::create(DEC, 0));
    tests.push_back(Prol16Opcode::create(JUMPC, 7));
    tests.push_back(Prol16Opcode::create(LOADI, 6, UNUSED, $urandom_range(0, 2**16-1)));
    tests.push_back(Prol16Opcode::create(JUMPZ, 6));
    tests.push_back(Prol16Opcode::create(JUMP, 7));
    tests.push_back(Prol16Opcode::create(LOADI, 0, UNUSED, 16'h0));
    tests.push_back(Prol16Opcode::create(DEC, 0));
    tests.push_back(Prol16Opcode::create(JUMPZ, 7));
    tests.push_back(Prol16Opcode::create(LOADI, 6, UNUSED, $urandom_range(0, 2**16-1)));
    tests.push_back(Prol16Opcode::create(JUMPC, 6));
    tests.push_back(Prol16Opcode::create(JUMP, 7));
    tests.push_back(Prol16Opcode::create(LOADI, 0, UNUSED, 16'hf249));
    tests.push_back(Prol16Opcode::create(LOADI, 2, UNUSED, 16'he492));
    tests.push_back(Prol16Opcode::create(SHL, 0));
    tests.push_back(Prol16Opcode::create(JUMPZ, 7));
    tests.push_back(Prol16Opcode::create(LOADI, 6, UNUSED, $urandom_range(0, 2**16-1)));
    tests.push_back(Prol16Opcode::create(JUMPC, 6));
    tests.push_back(Prol16Opcode::create(JUMP, 7));
    tests.push_back(Prol16Opcode::create(COMP, 0, 2));
    tests.push_back(Prol16Opcode::create(JUMPC, 7));
    tests.push_back(Prol16Opcode::create(LOADI, 6, UNUSED, $urandom_range(0, 2**16-1)));
    tests.push_back(Prol16Opcode::create(JUMPZ, 6));
    tests.push_back(Prol16Opcode::create(JUMP, 7));
    tests.push_back(Prol16Opcode::create(LOADI, 0, UNUSED, 16'h8000));
    tests.push_back(Prol16Opcode::create(SHL, 0));
    tests.push_back(Prol16Opcode::create(LOADI, 6, UNUSED, $urandom_range(0, 2**16-1)));
    tests.push_back(Prol16Opcode::create(JUMPC, 6));
    tests.push_back(Prol16Opcode::create(JUMP, 7));
    tests.push_back(Prol16Opcode::create(LOADI, 6, UNUSED, $urandom_range(0, 2**16-1)));
    tests.push_back(Prol16Opcode::create(JUMPZ, 6));
    tests.push_back(Prol16Opcode::create(JUMP, 7));
    tests.push_back(Prol16Opcode::create(LOADI, 0, UNUSED, 16'hf249));
    tests.push_back(Prol16Opcode::create(LOADI, 2, UNUSED, 16'h7924));
    tests.push_back(Prol16Opcode::create(SHR, 0));
    tests.push_back(Prol16Opcode::create(JUMPZ, 7));
    tests.push_back(Prol16Opcode::create(LOADI, 6, UNUSED, $urandom_range(0, 2**16-1)));
    tests.push_back(Prol16Opcode::create(JUMPC, 6));
    tests.push_back(Prol16Opcode::create(JUMP, 7));
    tests.push_back(Prol16Opcode::create(COMP, 0, 2));
    tests.push_back(Prol16Opcode::create(JUMPC, 7));
    tests.push_back(Prol16Opcode::create(LOADI, 6, UNUSED, $urandom_range(0, 2**16-1)));
    tests.push_back(Prol16Opcode::create(JUMPZ, 6));
    tests.push_back(Prol16Opcode::create(JUMP, 7));
    tests.push_back(Prol16Opcode::create(LOADI, 0, UNUSED, 16'h1));
    tests.push_back(Prol16Opcode::create(SHR, 0));
    tests.push_back(Prol16Opcode::create(LOADI, 6, UNUSED, $urandom_range(0, 2**16-1)));
    tests.push_back(Prol16Opcode::create(JUMPC, 6));
    tests.push_back(Prol16Opcode::create(JUMP, 7));
    tests.push_back(Prol16Opcode::create(LOADI, 6, UNUSED, $urandom_range(0, 2**16-1)));
    tests.push_back(Prol16Opcode::create(JUMPZ, 6));
    tests.push_back(Prol16Opcode::create(JUMP, 7));
    tests.push_back(Prol16Opcode::create(LOADI, 0, UNUSED, 16'hf249));
    tests.push_back(Prol16Opcode::create(LOADI, 2, UNUSED, 16'he492));
    tests.push_back(Prol16Opcode::create(COMP, 0, 2));
    tests.push_back(Prol16Opcode::create(SHLC, 0));
    tests.push_back(Prol16Opcode::create(JUMPZ, 7));
    tests.push_back(Prol16Opcode::create(LOADI, 6, UNUSED, $urandom_range(0, 2**16-1)));
    tests.push_back(Prol16Opcode::create(JUMPC, 6));
    tests.push_back(Prol16Opcode::create(JUMP, 7));
    tests.push_back(Prol16Opcode::create(COMP, 0, 2));
    tests.push_back(Prol16Opcode::create(JUMPC, 7));
    tests.push_back(Prol16Opcode::create(LOADI, 6, UNUSED, $urandom_range(0, 2**16-1)));
    tests.push_back(Prol16Opcode::create(JUMPZ, 6));
    tests.push_back(Prol16Opcode::create(JUMP, 7));
    tests.push_back(Prol16Opcode::create(LOADI, 0, UNUSED, 16'h8000));
    tests.push_back(Prol16Opcode::create(SHLC, 0));
    tests.push_back(Prol16Opcode::create(LOADI, 6, UNUSED, $urandom_range(0, 2**16-1)));
    tests.push_back(Prol16Opcode::create(JUMPC, 6));
    tests.push_back(Prol16Opcode::create(JUMP, 7));
    tests.push_back(Prol16Opcode::create(LOADI, 6, UNUSED, $urandom_range(0, 2**16-1)));
    tests.push_back(Prol16Opcode::create(JUMPZ, 6));
    tests.push_back(Prol16Opcode::create(JUMP, 7));
    tests.push_back(Prol16Opcode::create(LOADI, 1, UNUSED, 16'h1));
    tests.push_back(Prol16Opcode::create(SHLC, 0));
    tests.push_back(Prol16Opcode::create(JUMPC, 7));
    tests.push_back(Prol16Opcode::create(JUMPZ, 7));
    tests.push_back(Prol16Opcode::create(COMP, 0, 1));
    tests.push_back(Prol16Opcode::create(JUMPC, 7));
    tests.push_back(Prol16Opcode::create(LOADI, 6, UNUSED, $urandom_range(0, 2**16-1)));
    tests.push_back(Prol16Opcode::create(JUMPZ, 6));
    tests.push_back(Prol16Opcode::create(JUMP, 7));
    tests.push_back(Prol16Opcode::create(LOADI, 0, UNUSED, 16'hf249));
    tests.push_back(Prol16Opcode::create(LOADI, 2, UNUSED, 16'h7924));
    tests.push_back(Prol16Opcode::create(COMP, 0, 2));
    tests.push_back(Prol16Opcode::create(SHRC, 0));
    tests.push_back(Prol16Opcode::create(JUMPZ, 7));
    tests.push_back(Prol16Opcode::create(LOADI, 6, UNUSED, $urandom_range(0, 2**16-1)));
    tests.push_back(Prol16Opcode::create(JUMPC, 6));
    tests.push_back(Prol16Opcode::create(JUMP, 7));
    tests.push_back(Prol16Opcode::create(COMP, 0, 2));
    tests.push_back(Prol16Opcode::create(JUMPC, 7));
    tests.push_back(Prol16Opcode::create(LOADI, 6, UNUSED, $urandom_range(0, 2**16-1)));
    tests.push_back(Prol16Opcode::create(JUMPZ, 6));
    tests.push_back(Prol16Opcode::create(JUMP, 7));
    tests.push_back(Prol16Opcode::create(LOADI, 0, UNUSED, 16'h1));
    tests.push_back(Prol16Opcode::create(SHR, 0));
    tests.push_back(Prol16Opcode::create(LOADI, 6, UNUSED, $urandom_range(0, 2**16-1)));
    tests.push_back(Prol16Opcode::create(JUMPC, 6));
    tests.push_back(Prol16Opcode::create(JUMP, 7));
    tests.push_back(Prol16Opcode::create(LOADI, 6, UNUSED, $urandom_range(0, 2**16-1)));
    tests.push_back(Prol16Opcode::create(JUMPZ, 6));
    tests.push_back(Prol16Opcode::create(JUMP, 7));
    tests.push_back(Prol16Opcode::create(LOADI, 1, UNUSED, 16'h8000));
    tests.push_back(Prol16Opcode::create(SHRC, 0));
    tests.push_back(Prol16Opcode::create(JUMPC, 7));
    tests.push_back(Prol16Opcode::create(JUMPZ, 7));
    tests.push_back(Prol16Opcode::create(COMP, 0, 1));
    tests.push_back(Prol16Opcode::create(JUMPC, 7));
    tests.push_back(Prol16Opcode::create(LOADI, 6, UNUSED, $urandom_range(0, 2**16-1)));
    tests.push_back(Prol16Opcode::create(JUMPZ, 6));
    tests.push_back(Prol16Opcode::create(JUMP, 7));
    tests.push_back(Prol16Opcode::create(LOADI, 0, UNUSED, 16'hfff0));
    tests.push_back(Prol16Opcode::create(LOADI, 1, UNUSED, 16'h10));
    tests.push_back(Prol16Opcode::create(LOADI, 2, UNUSED, 16'h0));
    tests.push_back(Prol16Opcode::create(COMP, 0, 1));
    tests.push_back(Prol16Opcode::create(ADDC, 0, 1));
    tests.push_back(Prol16Opcode::create(LOADI, 6, UNUSED, $urandom_range(0, 2**16-1)));
    tests.push_back(Prol16Opcode::create(JUMPC, 6));
    tests.push_back(Prol16Opcode::create(JUMP, 7));
    tests.push_back(Prol16Opcode::create(LOADI, 6, UNUSED, $urandom_range(0, 2**16-1)));
    tests.push_back(Prol16Opcode::create(JUMPZ, 6));
    tests.push_back(Prol16Opcode::create(JUMP, 7));
    tests.push_back(Prol16Opcode::create(COMP, 0, 2));
    tests.push_back(Prol16Opcode::create(JUMPC, 7));
    tests.push_back(Prol16Opcode::create(LOADI, 6, UNUSED, $urandom_range(0, 2**16-1)));
    tests.push_back(Prol16Opcode::create(JUMPZ, 6));
    tests.push_back(Prol16Opcode::create(JUMP, 7));
    tests.push_back(Prol16Opcode::create(COMP, 0, 1));
    tests.push_back(Prol16Opcode::create(LOADI, 2, UNUSED, 16'h11));
    tests.push_back(Prol16Opcode::create(ADDC, 0, 1));
    tests.push_back(Prol16Opcode::create(JUMPC, 7));
    tests.push_back(Prol16Opcode::create(JUMPZ, 7));
    tests.push_back(Prol16Opcode::create(COMP, 0, 2));
    tests.push_back(Prol16Opcode::create(JUMPC, 7));
    tests.push_back(Prol16Opcode::create(LOADI, 6, UNUSED, $urandom_range(0, 2**16-1)));
    tests.push_back(Prol16Opcode::create(JUMPZ, 6));
    tests.push_back(Prol16Opcode::create(JUMP, 7));
    tests.push_back(Prol16Opcode::create(LOADI, 0, UNUSED, 16'h0));
    tests.push_back(Prol16Opcode::create(LOADI, 1, UNUSED, 16'h10));
    tests.push_back(Prol16Opcode::create(LOADI, 2, UNUSED, 16'hfff0));
    tests.push_back(Prol16Opcode::create(COMP, 1, 0));
    tests.push_back(Prol16Opcode::create(SUBC, 0, 1));
    tests.push_back(Prol16Opcode::create(JUMPZ, 7));
    tests.push_back(Prol16Opcode::create(LOADI, 6, UNUSED, $urandom_range(0, 2**16-1)));
    tests.push_back(Prol16Opcode::create(JUMPC, 6));
    tests.push_back(Prol16Opcode::create(JUMP, 7));
    tests.push_back(Prol16Opcode::create(COMP, 0, 2));
    tests.push_back(Prol16Opcode::create(JUMPC, 7));
    tests.push_back(Prol16Opcode::create(LOADI, 6, UNUSED, $urandom_range(0, 2**16-1)));
    tests.push_back(Prol16Opcode::create(JUMPZ, 6));
    tests.push_back(Prol16Opcode::create(JUMP, 7));
    tests.push_back(Prol16Opcode::create(LOADI, 2, UNUSED, 16'hffdf));
    tests.push_back(Prol16Opcode::create(COMP, 2, 0));
    tests.push_back(Prol16Opcode::create(SUBC, 0, 1));
    tests.push_back(Prol16Opcode::create(JUMPC, 7));
    tests.push_back(Prol16Opcode::create(JUMPZ, 7));
    tests.push_back(Prol16Opcode::create(COMP, 0, 2));
    tests.push_back(Prol16Opcode::create(JUMPC, 7));
    tests.push_back(Prol16Opcode::create(LOADI, 6, UNUSED, $urandom_range(0, 2**16-1)));
    tests.push_back(Prol16Opcode::create(JUMPZ, 6));
    tests.push_back(Prol16Opcode::create(JUMP, 7));
    tests.push_back(Prol16Opcode::create(LOADI, 0, UNUSED, 16'h1234));
    tests.push_back(Prol16Opcode::create(LOADI, 1, UNUSED, $urandom_range(0, 2**16-1)));
    tests.push_back(Prol16Opcode::create(LOADI, 2, UNUSED, 16'habcd));
    tests.push_back(Prol16Opcode::create(LOADI, 3, UNUSED, $urandom_range(0, 2**16-1)));
    tests.push_back(Prol16Opcode::create(ADD, 4, 5));
    tests.push_back(Prol16Opcode::create(LOADI, 6, UNUSED, $urandom_range(0, 2**16-1)));
    tests.push_back(Prol16Opcode::create(LOADI, 0, UNUSED, 16'hbe01));
    tests.push_back(Prol16Opcode::create(COMP, 1, 0));
    tests.push_back(Prol16Opcode::create(JUMPC, 7));
    tests.push_back(Prol16Opcode::create(LOADI, 6, UNUSED, $urandom_range(0, 2**16-1)));
    tests.push_back(Prol16Opcode::create(JUMPZ, 6));
    tests.push_back(Prol16Opcode::create(JUMP, 7));
    tests.push_back(Prol16Opcode::create(LOADI, 7, UNUSED, $urandom_range(0, 2**16-1)));
    tests.push_back(Prol16Opcode::create(JUMP, 7));
    tests.push_back(Prol16Opcode::create(LOADI, 7, UNUSED, $urandom_range(0, 2**16-1)));
    tests.push_back(Prol16Opcode::create(JUMP, 7));

    return tests;
  endfunction

endclass


`endif /* _GENERATOR_ */
