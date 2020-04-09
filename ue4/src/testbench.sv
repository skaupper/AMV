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
        .res_i          (rst),
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

    event executeNextOpc;

    const string cpu_prefix = "/top/duv";
    Prol16Model model = new;

    logic test_zero;


    initial begin
        model.setOpcode(Prol16Opcode::create(NOP));

        forever begin
            @(executeNextOpc.triggered);
            model.executeNext();
        end
    end

    initial begin : stimuli
        static Generator generator = new;
        static Driver driver = new(duv_if, cpu_prefix);
        static Agent agent = new(model, driver, duv_if);
        static Prol16Opcode opc;

        // Generate reset
        rst <= 1;
        #123ns;
        rst <= 0;

        $init_signal_spy("/top/duv/control_inst/zero", "/top/TheTest/test_zero");

        driver.resetCpuRegs();

        // Run all test cases
        while (generator.hasTests()) begin
            opc = generator.nextTest();
            opc.print();
            agent.runTest(opc);
        end

        $finish;
    end : stimuli

    initial begin : monitor_checker
        static Checker check = new(model);
        static Monitor monitor = new(duv_if, cpu_prefix);
        static Prol16State state;

        @(negedge rst);
        monitor.setupSignalSpy();

        forever begin
            monitor.waitForTest(state);
            state.print();
            check.checkResult(state);
            ->executeNextOpc;
        end
    end : monitor_checker

endprogram
