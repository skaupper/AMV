`ifndef TYPES
`define TYPES

`include "model/Prol16Types.sv"

typedef struct {
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
} duv_state_t;

interface cpu_if(input bit clk);
    logic[gDataWidth-1:0] mem_addr_o;
    logic[gDataWidth-1:0] mem_data_i;
    logic[gDataWidth-1:0] mem_data_o;
    logic mem_ce_no;
    logic mem_oe_no;
    logic mem_we_no;
    logic illegal_inst_o;
    logic cpu_halt_o;


    modport tb (
        output mem_data_i;

        input  mem_addr_o, mem_data_o, mem_ce_no,
               mem_oe_no, mem_we_no, illegal_inst_o, cpu_halt_o;
    );
endinterface


`endif
