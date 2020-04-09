`ifndef _MONITOR_
`define _MONITOR_

`include "types.sv"

class Monitor;
    virtual cpu_if.tb duv_if;
    string cpu_prefix;

    // DUV state
    static data_v cpu_reg_0;
    static data_v cpu_reg_1;
    static data_v cpu_reg_2;
    static data_v cpu_reg_3;
    static data_v cpu_reg_4;
    static data_v cpu_reg_5;
    static data_v cpu_reg_6;
    static data_v cpu_reg_7;
    static data_v cpu_pc;
    static logic cpu_zero;
    static logic cpu_carry;

    function void setupSignalSpy();
      $init_signal_spy("/top/duv/datapath_inst/thereg_file/registers(0)",  "/top/TheTest/monitor_checker/monitor.cpu_reg_0");
      $init_signal_spy("/top/duv/datapath_inst/thereg_file/registers(1)",  "/top/TheTest/monitor_checker/monitor.cpu_reg_1");
      $init_signal_spy("/top/duv/datapath_inst/thereg_file/registers(2)",  "/top/TheTest/monitor_checker/monitor.cpu_reg_2");
      $init_signal_spy("/top/duv/datapath_inst/thereg_file/registers(3)",  "/top/TheTest/monitor_checker/monitor.cpu_reg_3");
      $init_signal_spy("/top/duv/datapath_inst/thereg_file/registers(4)",  "/top/TheTest/monitor_checker/monitor.cpu_reg_4");
      $init_signal_spy("/top/duv/datapath_inst/thereg_file/registers(5)",  "/top/TheTest/monitor_checker/monitor.cpu_reg_5");
      $init_signal_spy("/top/duv/datapath_inst/thereg_file/registers(6)",  "/top/TheTest/monitor_checker/monitor.cpu_reg_6");
      $init_signal_spy("/top/duv/datapath_inst/thereg_file/registers(7)",  "/top/TheTest/monitor_checker/monitor.cpu_reg_7");
      $init_signal_spy("/top/duv/datapath_inst/RegPC",                     "/top/TheTest/monitor_checker/monitor.cpu_pc");
      $init_signal_spy("/top/duv/control_inst/zero",                       "/top/TheTest/monitor_checker/monitor.cpu_zero");
      $init_signal_spy("/top/duv/control_inst/carry",                      "/top/TheTest/monitor_checker/monitor.cpu_carry");
    endfunction

    function new (virtual cpu_if.tb _duv_if, string _cpu_prefix);
        duv_if      = _duv_if;
        cpu_prefix  = _cpu_prefix;
    endfunction

    task waitForTest (output Prol16State state);
        @(posedge duv_if.cb.mem_oe_no);
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
