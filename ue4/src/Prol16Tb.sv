`include "model/Prol16Model.sv"
`include "generator.sv"


/*


entity cpu is

  port (
    clk_i : in std_ulogic;
    res_i : in std_ulogic;

    -- don't use user types (netlist)
    mem_addr_o : out std_ulogic_vector(data_vec_length_c - 1 downto 0);
    mem_data_o : out std_ulogic_vector(data_vec_length_c - 1 downto 0);
    mem_data_i : in  std_ulogic_vector(data_vec_length_c - 1 downto 0);
    mem_ce_no  : out std_ulogic;        -- chip enable (low active)
    mem_oe_no  : out std_ulogic;        -- output enable (low active)
    mem_we_no  : out std_ulogic;        -- write enable (low active)

    illegal_inst_o : out std_ulogic;
    cpu_halt_o     : out std_ulogic);

end cpu;



*/

module top;
    bit clk;
    bit reset;

    logic[gDataWidth-1:0] mem_addr;
    logic[gDataWidth-1:0] mem_data_o;
    logic[gDataWidth-1:0] mem_data_i;
    logic mem_ce_n;
    logic mem_oe_n;
    logic mem_we_n;
    logic illegal_inst;
    logic cpu_halt;

    test TheTest();


    cpu duv(
        .clk_i          = clk,
        .rst_i          = reset,
        .mem_addr_o     = mem_addr,
        .mem_data_o     = mem_data_o,
        .mem_data_i     = mem_data_i,
        .mem_ce_no      = mem_ce_n,
        .mem_oe_no      = mem_oe_n,
        .mem_we_no      = mem_we_n,
        .illegal_inst_o = illegal_inst,
        .cpu_halt_o     = cpu_halt
    );
endmodule

program test;

    initial begin : stimuli
        static Prol16OpcodeQueue ops = generateTests();
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
