`ifndef _MONITOR_
`define _MONITOR_

`include "types.sv"

class Monitor;
  virtual cpu_if.tb duv_if;
  event commandStart;


  function new (virtual cpu_if.tb _duv_if, event _commandStart);
    duv_if       = _duv_if;
    commandStart = _commandStart;
  endfunction

  task waitForTest (output Prol16State state, ref duv_state_t duv_state);
    @(commandStart);
    state = new;
    state.regs[0] = duv_state.cpu_reg_0;
    state.regs[1] = duv_state.cpu_reg_1;
    state.regs[2] = duv_state.cpu_reg_2;
    state.regs[3] = duv_state.cpu_reg_3;
    state.regs[4] = duv_state.cpu_reg_4;
    state.regs[5] = duv_state.cpu_reg_5;
    state.regs[6] = duv_state.cpu_reg_6;
    state.regs[7] = duv_state.cpu_reg_7;
    state.pc      = duv_state.cpu_pc;
    state.zero    = duv_state.cpu_zero;
    state.carry   = duv_state.cpu_carry;
  endtask

endclass


`endif /* _MONITOR_ */
