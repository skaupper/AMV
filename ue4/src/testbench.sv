`include "model/Prol16Model.sv"
`include "generator.sv"


module top;
    // Signal and interface definitions
    logic clk = 0, rst;
    cpu_if dut_if(clk);

    // Clock generator
    always #10ns clk = ~clk;

    // DUT
    cpu duv (
        .clk_i          (clk),
        .rst_i          (reset),
        .mem_addr_o     (dut_if.mem_addr_o),
        .mem_data_o     (dut_if.mem_data_o),
        .mem_data_i     (dut_if.mem_data_i),
        .mem_ce_no      (dut_if.mem_ce_no),
        .mem_oe_no      (dut_if.mem_oe_no),
        .mem_we_no      (dut_if.mem_we_no),
        .illegal_inst_o (dut_if.illegal_inst_o),
        .cpu_halt_o     (dut_if.cpu_halt_o)
    );

    // Testbench
    test TheTest(dut_if.tb, rst);
endmodule

program test (cpu_if.tb dut_if, output logic rst);

    initial begin : stimuli
        static Generator generator = new;
        static Prol16OpcodeQueue ops = generator.generateTests();
        static Prol16Model model = new;
        static Driver driver = new;

        for (int i = 0; i < ops.size(); ++i) begin
            model.execute(ops[i]);

            ops[i].print;
            model.print;
            $display();
        end

        $finish;
    end : stimuli
endprogram


`ifndef TYPES
`define TYPES


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
