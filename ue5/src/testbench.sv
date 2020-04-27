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

    // Declare the golden model and the DUV state struct
    Prol16Model model = new;
    duv_state_t duv_state;

    // Additional spy signals
    logic [5:0] reg_op_code;
    logic [4:0] reg_a_idx;
    logic [4:0] reg_b_idx;


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
        $init_signal_spy("/top/duv/datapath_inst/RegOpCode",                 "/top/TheTest/reg_op_code");
		$init_signal_spy("/top/duv/datapath_inst/RegAIdx",                   "/top/TheTest/reg_a_idx");
		$init_signal_spy("/top/duv/datapath_inst/RegBIdx",                   "/top/TheTest/reg_b_idx");
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

        // Define bins for all opcodes as well as bins for the unused operations
        // Invalid opcodes should cause the coverage to fail!
        pt_cmd : coverpoint model.lastOpc {
            bins op_nop          = {NOP};
            bins op_loadi        = {LOADI};
            bins op_jump         = {JUMP};
            bins op_jumpc        = {JUMPC};
            bins op_jumpz        = {JUMPZ};
            bins op_move         = {MOVE};
            bins op_and          = {AND};
            bins op_or           = {OR};
            bins op_xor          = {XOR};
            bins op_not          = {NOT};
            bins op_add          = {ADD};
            bins op_addc         = {ADDC};
            bins op_sub          = {SUB};
            bins op_subc         = {SUBC};
            bins op_comp         = {COMP};
            bins op_inc          = {INC};
            bins op_dec          = {DEC};
            bins op_shl          = {SHL};
            bins op_shr          = {SHR};
            bins op_shlc         = {SHLC};
            bins op_shrc         = {SHRC};
            ignore_bins op_sleep = {SLEEP};
            ignore_bins op_load  = {LOAD};
            ignore_bins op_store = {STORE};
            illegal_bins invalid = default;
        }

        // Define coverpoints for carry and zero bit.
        // These include all possible transitions as well.
        pt_carry : coverpoint duv_state.cpu_carry {
            bins carry[]            = {[0:1]};
            bins trans_change       = (0 => 1, 1 => 0);
            bins trans_no_change    = (0 => 0, 1 => 1);
        }

        pt_zero  : coverpoint duv_state.cpu_zero {
            bins zero[]             = {[0:1]};
            bins trans_change       = (0 => 1, 1 => 0);
            bins trans_no_change    = (0 => 0, 1 => 1);
        }

        // Define coverpoints for all possible register indices
        pt_reg_a_idx : coverpoint reg_a_idx {
            bins reg_a[]         = {[0:7]};
            illegal_bins invalid = default;
        }

        pt_reg_b_idx : coverpoint reg_b_idx {
            bins reg_b[]         = {[0:7]};
            illegal_bins invalid = default;
        }


        // Cross coverage
        // 1.) Each opcode should be executed with each possible combinations of registers
        // Operations which do not use either of the registers must have those register indices set to 0!
        cross_op_and_regs : cross pt_cmd, pt_reg_a_idx, pt_reg_b_idx {
            illegal_bins no_reg  = binsof(pt_cmd) intersect {
                NOP, SLEEP
            } with (pt_reg_a_idx != 0 || pt_reg_b_idx != 0);

            illegal_bins only_reg_a = binsof(pt_cmd) intersect {
                LOADI, JUMP, JUMPC, JUMPZ, NOT, INC, DEC, SHL, SHR, SHLC, SHRC
            } with (pt_reg_b_idx != 0);
        }

        // 2a.) Which operations has been called with what status flags set.
        // 2b.) Which operation caused which state transitions.
        cross_op_and_sf : cross pt_cmd, pt_carry, pt_zero {
            illegal_bins no_zero_change = binsof(pt_cmd) intersect {
                NOP, SLEEP, LOADI, LOAD, STORE, JUMP, JUMPC, JUMPZ, MOVE
            } && binsof(pt_zero.trans_change);

            illegal_bins no_carry_change = binsof(pt_cmd) intersect {
                NOP, SLEEP, LOADI, LOAD, STORE, JUMP, JUMPC, JUMPZ, MOVE
            } && binsof(pt_carry.trans_change);

            // illegal_bins carry_not_zero = binsof(pt_cmd) intersect {
            //     AND, OR, XOR, NOT
            // } && binsof(pt_carry.carry) intersect {1};
        }

    endgroup

    // Entrypoint of simulation
    // Generates the reset, initializes DUV and model and asserts test cases
    initial begin : stimuli
        static Generator generator = new;
        static Driver driver = new(duv_if, commandStart);
        static Agent agent = new(model, driver, duv_if);
        static Prol16Opcode opc;

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
