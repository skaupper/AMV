interface wishbone_if # (
        parameter int gDataWidth = 32,
        parameter int gAddrWidth = 8
    ) (
        input bit clk
    );

    logic[gAddrWidth -1:0]  adr;
    logic[gDataWidth -1:0]  datM;     // data  coming  from  master
    logic[gDataWidth -1:0]  datS;     // data  coming  from  slave
    logic[gDataWidth /8 -1:0]  sel;
    logic cyc, stb, we, ack;

    clocking cb @(posedge clk);
        input  ack, datS;
        output stb, cyc, we, datM, adr, sel;
    endclocking

    modport master (clocking cb);
endinterface


class wishbone_bfm #(parameter int gDataWidth = 32, parameter int gAddrWidth = 8);
	virtual wishbone_if.master sigs;

	function new(virtual wishbone_if.master _sigs);
		sigs = _sigs;

		sigs.cb.adr  <= '0;
		sigs.cb.datM <= '0;
		sigs.cb.we   <= 0;
		sigs.cb.sel  <= '0;
		sigs.cb.cyc  <= 0;
		sigs.cb.stb  <= 0;
	endfunction

	// ------------------------------------------------------------------------

	virtual task singleRead(input logic [gAddrWidth-1:0] addr, output logic [gDataWidth-1:0] data);
		$display("singleRead @%0tns", $time);

		sigs.cb.adr <= addr;
		sigs.cb.sel <= '1;
		sigs.cb.we <= 0;
		sigs.cb.stb <= 1;
		sigs.cb.cyc <= 1;

		@(sigs.cb iff (sigs.cb.ack == 1));
		data = sigs.cb.datS;
		sigs.cb.stb <= 0;
		sigs.cb.cyc <= 0;
	endtask

	// ------------------------------------------------------------------------

	virtual task singleWrite(input logic [gAddrWidth-1:0] addr, logic [gDataWidth-1:0] data);
		$display("singleWrite @%0tns", $time);

		sigs.cb.adr <= addr;
		sigs.cb.datM <= data;
		sigs.cb.sel <= '1;
		sigs.cb.we <= 1;
		sigs.cb.stb <= 1;
		sigs.cb.cyc <= 1;

		@(sigs.cb iff (sigs.cb.ack == 1));
		sigs.cb.stb <= 0;
		sigs.cb.cyc <= 0;
	endtask

	// ------------------------------------------------------------------------

	virtual task automatic blockRead(input logic [gAddrWidth-1:0] addr, ref logic [gDataWidth-1:0] data[]);
        int curr_addr = 0;

		$display("blockRead @%0tns", $time);

		for (int i = 0; i < data.size(); i++) begin
			sigs.cb.adr <= curr_addr;
			sigs.cb.sel <= '1;
			sigs.cb.we <= 0;
			sigs.cb.stb <= 1;
			sigs.cb.cyc <= 1;

			@(sigs.cb iff (sigs.cb.ack == 1));
			data[i] = sigs.cb.datS;
			sigs.cb.stb <= 0;
			sigs.cb.cyc <= 0;

			curr_addr++;
		end

	endtask

	// ------------------------------------------------------------------------

	virtual task automatic blockWrite(input logic [gAddrWidth-1:0] addr, const ref logic [gDataWidth-1:0] data[]);
		int curr_addr = 0;

		$display("blockWrite @%0tns", $time);

		for (int i = 0; i < data.size(); i++) begin
			sigs.cb.adr <= curr_addr;
			sigs.cb.datM <= data[i];
			sigs.cb.sel <= '1;
			sigs.cb.we <= 1;
			sigs.cb.stb <= 1;
			sigs.cb.cyc <= 1;

			@(sigs.cb iff (sigs.cb.ack == 1));
			sigs.cb.stb <= 0;
			sigs.cb.cyc <= 0;

			curr_addr++;
		end
	endtask

	// ------------------------------------------------------------------------

	virtual task idle();
		$display("idle @%0tns", $time);

		sigs.cb.stb <= 0;
		sigs.cb.cyc <= 0;
		@sigs.cb;
	endtask
endclass

module top;
	logic clk = 0, rst;
	wishbone_if wb(clk);

	// clk generator
	always #10ns clk = ~clk;

	// RAM instantiation
	RAM TheRam(
        .clk_i(wb.clk),
        .rst_i(rst),
        .adr_i(wb.adr),
        .dat_i(wb.datM),
        .sel_i(wb.sel),
        .cyc_i(wb.cyc),
        .stb_i(wb.stb),
        .we_i(wb.we),
        .dat_o(wb.datS),
        .ack_o(wb.ack)
    );
	test TheTest(wb.master, rst);
endmodule

program test #(parameter int gDataWidth = 32, parameter int gAddrWidth = 8)(wishbone_if.master wb, output logic rst);
	initial begin : stimuli
        const int cEndAddress = (1 << gAddrWidth) - 1;
        int rdata;

        static logic [gDataWidth-1:0] wdataArr[] = new[cEndAddress+1];
        static logic [gDataWidth-1:0] rdataArr[] = new[cEndAddress+1];
		static wishbone_bfm#(gDataWidth, gAddrWidth) bfm = new(wb);


		// generate reset -----------------------------------------------------
		// ...
        rst <= 1;
        #123ns;
        rst <= 0;


		// stimuli ------------------------------------------------------------
		// ...

        // Test single read and single write routines
        for (int addr = 0; addr < cEndAddress; addr++) begin
		    bfm.singleWrite(addr, addr);
            bfm.singleRead(addr, rdata);
            assert (rdata == addr);
        end

        // Idle for some cycles
        for (int i = 0; i < 200; i++) begin
            bfm.idle();
        end


        // Initialize data array for block read/write test
        for (int addr = 0; addr < cEndAddress; addr++) begin
            wdataArr[addr] = addr*4;
        end

        // Write data block and read it back
        bfm.blockWrite(0, wdataArr);
        bfm.blockRead(0, rdataArr);

        // Compare read data with written data
        for (int addr = 0; addr < cEndAddress; addr++) begin
            assert (wdataArr[addr] == rdataArr[addr]);
        end


        $finish;
	end : stimuli
endprogram
