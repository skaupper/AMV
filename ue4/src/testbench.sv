`include "model/Prol16Model.sv"
`include "generator.sv"


module top;
    bit clk = 0, rst;


	always #10ns clk = ~clk;

    cpu_if dut_if(clk);

    test TheTest();

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
endmodule

program test;

    initial begin : stimuli
        static Generator generator = new;
        static Prol16OpcodeQueue ops = generator.generateTests();
        static Prol16Model model = new;

        for (int i = 0; i < ops.size(); ++i) begin
            model.execute(ops[i]);

            ops[i].print;
            model.print;
            $display();
        end

        $finish;
    end : stimuli
endprogram
