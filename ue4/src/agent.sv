`ifndef _AGENT_
`define _AGENT_

`include "driver.sv"
`include "types.sv"
`include "model/Prol16Model.sv"

class Agent;
  Prol16Model model;
  Driver driver;
  virtual cpu_if.tb duv_if;

  function new (Prol16Model _model,
                Driver _driver,
                virtual cpu_if.tb _duv_if);
      model  = _model;
      driver = _driver;
      duv_if = _duv_if;
  endfunction

  task runTest(Prol16Opcode opc);
    model.setOpcode(opc);
    driver.setOpcode(opc);
  endtask

endclass


`endif /* _AGENT_ */
