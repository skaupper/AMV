`ifndef _MONITOR_
`define _MONITOR_

`include "types.sv"

class Monitor;
    function new (virtual cpu_if.tb dut_if);

    endfunction

endclass


`endif /* _MONITOR_ */
