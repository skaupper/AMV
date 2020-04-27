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

    // Declare commandStart event which triggers when a new command started/the old one finished
    event commandStart;

    Prol16Opcode opc;

    // Declare the golden model and the DUV state struct
    Prol16Model model = new;
    duv_state_t duv_state;


    // Signal spy and signal force functions
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

    function void resetCpuRegs();
        $signal_force("/top/duv/datapath_inst/thereg_file/registers(0)", "16#0000", 0, 1);
        $signal_force("/top/duv/datapath_inst/thereg_file/registers(1)", "16#0000", 0, 1);
        $signal_force("/top/duv/datapath_inst/thereg_file/registers(2)", "16#0000", 0, 1);
        $signal_force("/top/duv/datapath_inst/thereg_file/registers(3)", "16#0000", 0, 1);
        $signal_force("/top/duv/datapath_inst/thereg_file/registers(4)", "16#0000", 0, 1);
        $signal_force("/top/duv/datapath_inst/thereg_file/registers(5)", "16#0000", 0, 1);
        $signal_force("/top/duv/datapath_inst/thereg_file/registers(6)", "16#0000", 0, 1);
        $signal_force("/top/duv/datapath_inst/thereg_file/registers(7)", "16#0000", 0, 1);
    endfunction

    covergroup cov_grp @(commandStart);
        option.per_instance = 1;

        pt_cmd : coverpoint opc {
            bins bin_op_nop   = {Prol16Opcode::Prol16Command::NOP};
            bins bin_op_nop   = {Prol16Opcode::Prol16Command::NOP};
            bins bin_op_sleep = {Prol16Opcode::Prol16Command::SLEEP};
            bins bin_op_loadi = {Prol16Opcode::Prol16Command::LOADI};
            bins bin_op_load  = {Prol16Opcode::Prol16Command::LOAD};
            bins bin_op_store = {Prol16Opcode::Prol16Command::STORE};
            bins bin_op_jump  = {Prol16Opcode::Prol16Command::JUMP};
            bins bin_op_jumpc = {Prol16Opcode::Prol16Command::JUMPC};
            bins bin_op_jumpz = {Prol16Opcode::Prol16Command::JUMPZ};
            bins bin_op_move  = {Prol16Opcode::Prol16Command::MOVE};
            bins bin_op_and   = {Prol16Opcode::Prol16Command::AND};
            bins bin_op_or    = {Prol16Opcode::Prol16Command::OR};
            bins bin_op_xor   = {Prol16Opcode::Prol16Command::XOR};
            bins bin_op_not   = {Prol16Opcode::Prol16Command::NOT};
            bins bin_op_add   = {Prol16Opcode::Prol16Command::ADD};
            bins bin_op_addc  = {Prol16Opcode::Prol16Command::ADDC};
            bins bin_op_sub   = {Prol16Opcode::Prol16Command::SUB};
            bins bin_op_subc  = {Prol16Opcode::Prol16Command::SUBC};
            bins bin_op_comp  = {Prol16Opcode::Prol16Command::COMP};
            bins bin_op_inc   = {Prol16Opcode::Prol16Command::INC};
            bins bin_op_dec   = {Prol16Opcode::Prol16Command::DEC};
            bins bin_op_shl   = {Prol16Opcode::Prol16Command::SHL};
            bins bin_op_shr   = {Prol16Opcode::Prol16Command::SHR};
            bins bin_op_shlc  = {Prol16Opcode::Prol16Command::SHLC};
            bins bin_op_shrc  = {Prol16Opcode::Prol16Command::SHRC};
        }
    endgroup

    // Entrypoint of simulation
    // Generates the reset, initializes DUV and model and asserts test cases
    initial begin : stimuli
        static Generator generator = new;
        static Driver driver = new(duv_if, commandStart);
        static Agent agent = new(model, driver, duv_if);

        static cov_grp cov_grp_inst = new;

        // Generate reset
        rst <= 0;
        #123ns;
        rst <= 1;


        // Initialize signal spy and reset CPU regs
        resetCpuRegs();
        setupSignalSpy();


        // Run all test cases
        while (generator.hasTests()) begin
            opc = generator.nextTest();
            agent.runTest(opc);
        end

        // Since the monitor and checker are triggered with the next command
        // this dummy opc is needed or otherwise the last test cases would not be checked
        agent.runTest(Prol16Opcode::create(NOP));

        $finish;
    end : stimuli


    // Process which is used to verify testcases
    initial begin : monitor_checker
        static Checker check = new(model);
        static Monitor monitor = new(duv_if, commandStart);
        static Prol16State state;

        // Ignore the first commandStart since it validates the output of the last (non-existent) command
        @(commandStart);

        forever begin
            model.executeNext();
            monitor.waitForTest(state, duv_state);
            check.checkResult(state);
        end
    end : monitor_checker

endprogram
