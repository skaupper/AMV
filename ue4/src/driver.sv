`ifndef _DRIVER_
`define _DRIVER_

`include "types.sv"

class Driver;
  virtual cpu_if.tb duv_if;
  event commandStart;


  function new (virtual cpu_if.tb _duv_if, event _commandStart);
    duv_if       = _duv_if;
    commandStart = _commandStart;
  endfunction


  task setOpcode(Prol16Opcode opc);
    assignWord(opc.toBinary());
    ->commandStart;

    // The LOADI command consists of two input words
    if (opc.cmd == LOADI) begin
        assignWord(opc.data);
    end
  endtask

  local task assignWord(data_v word);
    @(negedge duv_if.mem_oe_no);
    duv_if.mem_data_i <= word;
    @(posedge duv_if.mem_oe_no);
    duv_if.mem_data_i <= 'X;
  endtask

endclass

`endif /* _DRIVER_ */
