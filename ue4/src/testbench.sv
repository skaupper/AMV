`include "model/Prol16Model.sv"
`include "generator.sv"
`include "driver.sv"
`include "agent.sv"
`include "monitor.sv"
`include "checker.sv"


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

    static Prol16Model model = new;

    static Generator generator = new;
    static Driver driver = new(dut_if);
    static Checker check = new(model);
    static Agent agent = new(model, driver, dut_if);
    static Monitor monitor = new(dut_if);


    initial begin : stimuli
        while generator.hasTests() begin
            opc = generator.nextTest();
            agent.runTest(opc);
        end

        $finish;
    end : stimuli

    initial begin : monitor_checker
        while true begin
            state = monitor.wait();
            checker.checkResult(state);
        end
    end : monitor_checker
endprogram
