`ifndef _DRIVER_
`define _DRIVER_

`include "types.sv"

class Driver;
  virtual cpu_if.tb duv_if;

  function new (virtual cpu_if.tb _duv_if);
    duv_if = _duv_if;
  endfunction

  function void setOpcode(Prol16Opcode opc);
    // TODO
  endfunction

endclass

`endif /* _DRIVER_ */
