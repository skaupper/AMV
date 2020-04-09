`ifndef _MONITOR_
`define _MONITOR_

`include "types.sv"

class Monitor;
    virtual cpu_if.tb dut_if;

    function new (virtual cpu_if.tb _dut_if);
        this.dut_if = dut_if;
    endfunction

    task waitForTest (output Prol16State state);
        state = new;
        // TODO
    endtask

endclass


`endif /* _MONITOR_ */
