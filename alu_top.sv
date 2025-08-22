`include "uvm_macros.svh"
`include "design.sv"
`include "alu_pkg.sv"

`include "alu_interface.sv"
import uvm_pkg::*;
import alu_pkg::*;
module top;

   //import alu_pkg::*;

  bit CLK;
  bit RST;

  always #5 CLK = ~CLK;

  initial begin
    RST = 1;
    #5 RST =0;
  end
  alu_interface intf(CLK,RST);

  ALU_DESIGN #(`width, `cwidth) dut(
    .CLK(intf.CLK),
    .RST(intf.RST),
    .INP_VALID(intf.INP_VALID),
    .MODE(intf.MODE),
    .CIN(intf.CIN),
    .OPA(intf.OPA),
    .OPB(intf.OPB),
    .CE(intf.CE),
    .CMD(intf.CMD),
    .RES(intf.RES),
    .COUT(intf.COUT),
    .OFLOW(intf.OFLOW),
    .E(intf.E),
    .G(intf.G),
    .L(intf.L),
    .ERR(intf.ERR)
   );

  initial begin
   uvm_config_db#(virtual alu_interface)::set(uvm_root::get(),"*","vif",intf);
    $dumpfile("dump.vcd");
        $dumpvars;
  end

  initial begin
    run_test("alu_regression");
    //$display(">>> Simulation finished at time %0t", $time);
    #100; $finish();
  end
endmodule
