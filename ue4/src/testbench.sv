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
    event commandStart;

    const string cpu_prefix = "/top/duv";



    Prol16Model model = new;
    duv_state_t duv_state;


    function void setupSignalSpy();
      $init_signal_spy("/top/duv/datapath_inst/thereg_file/registers(0)",  "/top/TheTest/duv_state.cpu_reg_0");
      $init_signal_spy("/top/duv/datapath_inst/thereg_file/registers(1)",  "/top/TheTest/duv_state.cpu_reg_1");
      $init_signal_spy("/top/duv/datapath_inst/thereg_file/registers(2)",  "/top/TheTest/duv_state.cpu_reg_2");
      $init_signal_spy("/top/duv/datapath_inst/thereg_file/registers(3)",  "/top/TheTest/duv_state.cpu_reg_3");
      $init_signal_spy("/top/duv/datapath_inst/thereg_file/registers(4)",  "/top/TheTest/duv_state.cpu_reg_4");
      $init_signal_spy("/top/duv/datapath_inst/thereg_file/registers(5)",  "/top/TheTest/duv_state.cpu_reg_5");
      $init_signal_spy("/top/duv/datapath_inst/thereg_file/registers(6)",  "/top/TheTest/duv_state.cpu_reg_6");
      $init_signal_spy("/top/duv/datapath_inst/thereg_file/registers(7)",  "/top/TheTest/duv_state.cpu_reg_7");
      $init_signal_spy("/top/duv/datapath_inst/RegPC",                     "/top/TheTest/duv_state.cpu_pc");
      $init_signal_spy("/top/duv/control_inst/zero",                       "/top/TheTest/duv_state.cpu_zero");
      $init_signal_spy("/top/duv/control_inst/carry",                      "/top/TheTest/duv_state.cpu_carry");
    endfunction


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
        rst <= 0;
        #123ns;
        rst <= 1;

        // Initialize signal spy and reset CPU regs
        driver.resetCpuRegs();
        setupSignalSpy();

        @(negedge duv_if.mem_oe_no);
        @(posedge duv_if.mem_oe_no);


        // Run all test cases
        while (generator.hasTests()) begin
            opc = generator.nextTest();
            opc.print();
            agent.runTest(opc, commandStart);
        end

        agent.runTest(Prol16Opcode::create(NOP), commandStart);

        $finish;
    end : stimuli

    initial begin : monitor_checker
        static Checker check = new(model);
        static Monitor monitor = new(duv_if, cpu_prefix);
        static Prol16State state;

        @(posedge rst);
        wait(commandStart.triggered);

        forever begin
            monitor.waitForTest(state, duv_state, commandStart);
            state.print();
            check.checkResult(state);
            ->executeNextOpc;
        end
    end : monitor_checker

endprogram
