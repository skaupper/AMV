`ifndef _DRIVER_
`define _DRIVER_

`include "types.sv"

class Driver;
  virtual cpu_if.tb duv_if;
  string duv_prefix;

  function new (virtual cpu_if.tb _duv_if, string _duv_prefix);
    duv_if = _duv_if;
    duv_prefix = _duv_prefix;
  endfunction

  function void resetCpuRegs();
    $signal_force({duv_prefix, "/datapath_inst/thereg_file/registers(0)"}, "16#0000", 0, 1);
    $signal_force({duv_prefix, "/datapath_inst/thereg_file/registers(1)"}, "16#0000", 0, 1);
    $signal_force({duv_prefix, "/datapath_inst/thereg_file/registers(2)"}, "16#0000", 0, 1);
    $signal_force({duv_prefix, "/datapath_inst/thereg_file/registers(3)"}, "16#0000", 0, 1);
    $signal_force({duv_prefix, "/datapath_inst/thereg_file/registers(4)"}, "16#0000", 0, 1);
    $signal_force({duv_prefix, "/datapath_inst/thereg_file/registers(5)"}, "16#0000", 0, 1);
    $signal_force({duv_prefix, "/datapath_inst/thereg_file/registers(6)"}, "16#0000", 0, 1);
    $signal_force({duv_prefix, "/datapath_inst/thereg_file/registers(7)"}, "16#0000", 0, 1);
  endfunction

  task setOpcode(Prol16Opcode opc);
    @(negedge duv_if.cb.mem_oe_no);
    duv_if.cb.mem_data_i <= opc.toBinary();
  endtask

endclass

`endif /* _DRIVER_ */
