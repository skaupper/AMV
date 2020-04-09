`ifndef _MONITOR_
`define _MONITOR_

`include "types.sv"

class Monitor;
    virtual cpu_if.tb dut_if;
    string cpu_prefix;

    // DUV state
    data_v cpu_reg_0;
    data_v cpu_reg_1;
    data_v cpu_reg_2;
    data_v cpu_reg_3;
    data_v cpu_reg_4;
    data_v cpu_reg_5;
    data_v cpu_reg_6;
    data_v cpu_reg_7;
    data_v cpu_pc;
    logic cpu_zero;
    logic cpu_carry;

    function new (virtual cpu_if.tb _dut_if, string _cpu_prefix);
        dut_if      = _dut_if;
        cpu_prefix  = _cpu_prefix;

        setupSignalSpy();
    endfunction

    local function void setupSignalSpy();
      $init_signal_spy({cpu_prefix, "/datapath_inst/thereg_file/registers(0)"},  "cpu_reg_0");
      $init_signal_spy({cpu_prefix, "/datapath_inst/thereg_file/registers(1)"},  "cpu_reg_1");
      $init_signal_spy({cpu_prefix, "/datapath_inst/thereg_file/registers(2)"},  "cpu_reg_2");
      $init_signal_spy({cpu_prefix, "/datapath_inst/thereg_file/registers(3)"},  "cpu_reg_3");
      $init_signal_spy({cpu_prefix, "/datapath_inst/thereg_file/registers(4)"},  "cpu_reg_4");
      $init_signal_spy({cpu_prefix, "/datapath_inst/thereg_file/registers(5)"},  "cpu_reg_5");
      $init_signal_spy({cpu_prefix, "/datapath_inst/thereg_file/registers(6)"},  "cpu_reg_6");
      $init_signal_spy({cpu_prefix, "/datapath_inst/thereg_file/registers(7)"},  "cpu_reg_7");
      $init_signal_spy({cpu_prefix, "/datapath_inst/RegPC"},                     "cpu_pc");
      $init_signal_spy({cpu_prefix, "/control_inst/zero"},                       "cpu_zero");
      $init_signal_spy({cpu_prefix, "/control_inst/carry"},                      "cpu_carry");
    endfunction

    task waitForTest (output Prol16State state);
        @(posedge duv_if.mem_oe_no);
        state = new;
        state.regs[0] = cpu_reg_0;
        state.regs[1] = cpu_reg_1;
        state.regs[2] = cpu_reg_2;
        state.regs[3] = cpu_reg_3;
        state.regs[4] = cpu_reg_4;
        state.regs[5] = cpu_reg_5;
        state.regs[6] = cpu_reg_6;
        state.regs[7] = cpu_reg_7;
        state.pc      = cpu_pc;
        state.zero    = cpu_zero;
        state.carry   = cpu_carry;
    endtask


endclass


`endif /* _MONITOR_ */
