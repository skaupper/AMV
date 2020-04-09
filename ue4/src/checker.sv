`ifndef _CHECKER_
`define _CHECKER_

`include "types.sv"
`include "model/Prol16Model.sv"

class Checker;
    Prol16Model model;

    function new (Prol16Model _model);
        model = _model;
    endfunction

    function void checkResult (Prol16State duv_state);
        assert (duv_state == model.state);
    endfunction

endclass


`endif /* _CHECKER_ */
