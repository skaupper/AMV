`ifndef _CHECKER_
`define _CHECKER_

`include "types.sv"
`include "model/Prol16Model.sv"

class Checker;
  Prol16Model model;

  function new (Prol16Model _model);
    model = _model;
  endfunction

  function automatic bit checkResult (Prol16State duv_state);
    bit equal = duv_state.equals(model.state);
    assert (equal);
    if (!equal) begin
      duv_state.print();
      model.state.print();
    end
    return equal;
  endfunction

endclass


`endif /* _CHECKER_ */
