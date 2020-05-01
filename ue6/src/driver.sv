`ifndef _DRIVER_
`define _DRIVER_

`include "types.sv"

class Driver;
  virtual cpu_if.tb duv_if;
  event commandStart;


  function new (virtual cpu_if.tb _duv_if, event _commandStart);
    duv_if            = _duv_if;
    commandStart      = _commandStart;
    duv_if.mem_data_i <= 'X;
  endfunction


  task setOpcode(Prol16Opcode opc);
    assignWord(opc.toBinary());

    // Trigger the monitor and allow it to execute before we continue the processing here
    ->commandStart; #0ns;

    // The LOADI command consists of two input words
    if (opc.cmd == LOADI) begin
      assignWord(opc.data);
    end
  endtask

  local task assignWord(data_v word);
    // A data word has to be asserted while mem_oe_no is low
    // For debugging purposes drive mem_data_i with 'X when it should not be valid
    @(negedge duv_if.mem_oe_no);
    duv_if.mem_data_i <= word;
    @(posedge duv_if.mem_oe_no);
    duv_if.mem_data_i <= 'X;
  endtask

endclass

`endif /* _DRIVER_ */
