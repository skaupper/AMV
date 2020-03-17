class wishbone_bfm #(parameter int gDataWidth = 32, parameter int gAddrWidth = 8);
	virtual wishbone_if.master sigs;

	function new(virtual wishbone_if.master _sigs);
		sigs = _sigs;

		sigs.cb.adr <= 0;
		sigs.cb.datM <= 0;
		sigs.cb.we <= 0;
		sigs.cb.sel <= '0;
		sigs.cb.cyc <= 0;
		sigs.cb.stb <= 0;
	endfunction

	// ------------------------------------------------------------------------

	virtual task singleRead(input logic [gAddrWidth-1:0] addr, output logic [gDataWidth-1:0] data);
		$display("singleRead @%0tns", $time);
		// ...
	endtask

	// ------------------------------------------------------------------------

	virtual task singleWrite(input logic [gAddrWidth-1:0] addr, logic [gDataWidth-1:0] data);
		$display("singleWrite @%0tns", $time);
		// ...
	endtask

	// ------------------------------------------------------------------------

	virtual task blockRead(input logic [gAddrWidth-1:0] addr, ref logic [gDataWidth-1:0] data[]);
		$display("blockRead @%0tns", $time);
		// ...
	endtask

	// ------------------------------------------------------------------------

	virtual task blockWrite(input logic [gAddrWidth-1:0] addr, const ref logic [gDataWidth-1:0] data[]);
		$display("blockWrite @%0tns", $time);
		// ...
	endtask

	// ------------------------------------------------------------------------

	virtual task idle();
		$display("idle @%0tns", $time);

		@sigs.cb;
	endtask
endclass

module top;
	logic clk = 0, rst;
	wishbone_if wb(clk);
	
	// clk generator
	always #10 clk = ~clk;

	// RAM instantiation
	RAM TheRam(wb.clk, rst, wb.adr, wb.datM, wb.sel, wb.cyc, wb.stb, wb.we, wb.datS, wb.ack);
	test TheTest(wb.master, rst);
endmodule

program test #(parameter int gDataWidth = 32, parameter int gAddrWidth = 8)(wishbone_if.master wb, output logic rst);
	initial begin : stimuli
		wishbone_bfm#(gDataWidth, gAddrWidth) bfm = new(wb);
		
		// generate reset -----------------------------------------------------
		// ...

		// stimuli ------------------------------------------------------------
		// ...
	end : stimuli
endprogram
