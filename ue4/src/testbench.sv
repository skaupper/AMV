`include "model/Prol16Model.sv"
`include "generator.sv"
`include "driver.sv"
`include "agent.sv"
`include "monitor.sv"
`include "checker.sv"


module top;
    // Signal and interface definitions
    logic clk = 0, rst;
    cpu_if duv_if(clk);

    // Clock generator
    always #10ns clk = ~clk;

    // DUV
    cpu duv (
        .clk_i          (clk),
        .rst_i          (reset),
        .mem_addr_o     (duv_if.mem_addr_o),
        .mem_data_o     (duv_if.mem_data_o),
        .mem_data_i     (duv_if.mem_data_i),
        .mem_ce_no      (duv_if.mem_ce_no),
        .mem_oe_no      (duv_if.mem_oe_no),
        .mem_we_no      (duv_if.mem_we_no),
        .illegal_inst_o (duv_if.illegal_inst_o),
        .cpu_halt_o     (duv_if.cpu_halt_o)
    );

    // Testbench
    test TheTest(duv_if.tb, rst);
endmodule

program test (cpu_if.tb duv_if, output logic rst);

    Prol16Model model;


    initial begin : stimuli
        static Generator generator = new;
        static Driver driver = new(duv_if);
        static Agent agent = new(model, driver, duv_if);
        static Prol16Opcode opc;

        #2ns;
        agent.model.execute(Prol16Opcode::create(LOADI, 3, 16'h1234));
        agent.model.print();
        #10ns;

        while (generator.hasTests()) begin
            opc = generator.nextTest();
            agent.runTest(opc);
        end

        $finish;
    end : stimuli

    initial begin : monitor_checker
        static Checker check = new(model);
        static Monitor monitor = new(duv_if);
        static Prol16State state;

        check.model.print();
        #10ns;
        check.model.print();


        while (1) begin
            monitor.waitForTest(state);
            check.checkResult(state);
        end
    end : monitor_checker

endprogram
