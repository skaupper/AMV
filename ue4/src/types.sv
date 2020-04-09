`ifndef TYPES
`define TYPES

`include "model/Prol16Types.sv"


interface cpu_if(input bit clk);
    logic[gDataWidth-1:0] mem_addr_o;
    logic[gDataWidth-1:0] mem_data_i;
    logic[gDataWidth-1:0] mem_data_o;
    logic mem_ce_no;
    logic mem_oe_no;
    logic mem_we_no;
    logic illegal_inst_o;
    logic cpu_halt_o;


    clocking cb @(posedge clk);
        input  mem_data_i;

        output mem_addr_o, mem_data_o, mem_ce_no,
               mem_oe_no, mem_we_no, illegal_inst_o, cpu_halt_o;
    endclocking

    modport tb (clocking cb);
endinterface


`endif
