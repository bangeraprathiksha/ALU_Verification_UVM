
`include "defines.sv"
//`include "uvm_macros.svh"
`include "defines.sv"
`uvm_analysis_imp_decl(_monitor)
`uvm_analysis_imp_decl(_driver)

class my_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(my_scoreboard)
//  uvm_analysis_imp_driver  #(my_item, my_scoreboard) driver_export;
// uvm_analysis_imp_monitor #(my_item, my_scoreboard) item_collected_export;

uvm_tlm_analysis_fifo #(my_item) drv_fifo;
uvm_tlm_analysis_fifo #(my_item) mon_fifo;


  my_item drv_q[$];
  my_item mon_q[$];

 static  int MATCH, MISMATCH;
  virtual alu_interface vif;


  function new (string name = "my_scoreboard", uvm_component parent);
    super.new(name, parent);

  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    //item_collected_export = new("item_collected_export", this);
    //driver_export = new("driver_export",this);

        drv_fifo = new("drv_fifo", this);
        mon_fifo = new("mon_fifo", this);

        if(!uvm_config_db#(virtual alu_interface)::get(this,"","vif",vif))
      `uvm_fatal(get_type_name(),"Virtual interface not found in alu_scoreboard")
  endfunction

   //driver write


function void write_driver(my_item t);
  my_item c = my_item::type_id::create("drv_copy");
        `uvm_info("SCOREBOARD", "Got txn from DRIVER", UVM_LOW)
  c.copy(t);
  drv_fifo.write(c);
endfunction

function void write_monitor(my_item t);
  my_item c = my_item::type_id::create("mon_copy");
  `uvm_info("SCOREBOARD", "Got txn from MON", UVM_LOW)
  c.copy(t);
  mon_fifo.write(c);
endfunction


task run_phase(uvm_phase phase);
  my_item drv_item, mon_item, exp_item;
  forever begin
        `uvm_info("SCOREBOARD", "Waiting for drv/mon txn...", UVM_LOW)
    drv_fifo.get(drv_item); // waits until driver gives one
    mon_fifo.get(mon_item); // waits until monitor gives one
    exp_item = my_item::type_id::create("exp_item");
    exp_item.copy_inputs(drv_item);
    run_ref_model(drv_item, exp_item);
    compare_and_report(mon_item, exp_item);
  end
endtask


virtual task run_ref_model(input my_item tr, output my_item exp_item);
  int shift;
  if (tr == null) begin
    `uvm_error(get_full_name(), "Input transaction tr is null!")
    return;
  end

  // create exp_item fresh and copy inputs
  exp_item = my_item::type_id::create("exp_item");
  exp_item.copy_inputs(tr);            // copy inputs only
  // Clear outputs/defaults
  exp_item.RES   = '0;
  exp_item.COUT  = 0;
  exp_item.OFLOW = 0;
  exp_item.E     = 0;
  exp_item.G     = 0;
  exp_item.L     = 0;
  exp_item.ERR   = 0;

  // wait until not in reset (you already had this)
  @(posedge vif.CLK);
  while (vif.RST) @(posedge vif.CLK);

  shift = tr.OPB[2:0];

  // multiplier latency in DUT: handled by earlier logic; keep your existing repeat if needed
  if ((tr.CMD == 4'd9 || tr.CMD == 4'd10) && tr.CE && tr.INP_VALID == 2'b11) begin
    repeat(2) @(posedge vif.CLK);
  end

  `uvm_info(get_full_name(), $sformatf("Ref model start time[%0t] : OPA=%0d OPB=%0d CMD=%0b MODE=%0b INP_VALID=%0b CIN=%0d CE=%0d",$time,tr.OPA, tr.OPB, tr.CMD, tr.MODE, tr.INP_VALID, tr.CIN, tr.CE), UVM_LOW)

  if (tr.CE) begin
    case (tr.INP_VALID)
      2'b11: begin
        if (tr.MODE) begin // Arithmetic (MODE==1)
            case (tr.CMD)
            4'b0000: begin
              // ADD without CIN (DUT: RES = oprd1 + oprd2)
              exp_item.RES = tr.OPA + tr.OPB;
              exp_item.COUT = exp_item.RES[`width]; // top bit is carry-out
            end

            4'b0001: begin
              // SUB without CIN
              exp_item.RES = tr.OPA - tr.OPB;
              exp_item.OFLOW = (tr.OPA < tr.OPB) ? 1 : 0;
            end

            4'b0010: begin
              // ADD with CIN
              exp_item.RES = tr.OPA + tr.OPB + tr.CIN;
              exp_item.COUT = exp_item.RES[`width];
            end

            4'b0011: begin
              // SUB with CIN
              exp_item.RES = tr.OPA - tr.OPB - tr.CIN;
              exp_item.OFLOW = (tr.OPA < (tr.OPB + tr.CIN)) ? 1 : 0;
            end


            4'b1000: begin
              // compare
              if (tr.OPA == tr.OPB) exp_item.E = 1;
              else if (tr.OPA > tr.OPB) exp_item.G = 1;
              else exp_item.L = 1;
            end

            4'b1001: begin
              // multiply: DUT uses (oprd1+1)*(oprd2+1)
              exp_item.RES = (tr.OPA + 1) * (tr.OPB + 1);
            end

            4'b1010: begin
              exp_item.RES = ( (tr.OPA << 1) * tr.OPB );
            end

            default: zero_outputs(exp_item);
          endcase
        end

        else begin // MODE == 0 : Logical
            case (tr.CMD)
            4'b0000: exp_item.RES = {1'b0, tr.OPA & tr.OPB};
            4'b0001: exp_item.RES = {1'b0, ~(tr.OPA & tr.OPB)};
            4'b0010: exp_item.RES = {1'b0, tr.OPA | tr.OPB}; // confirm logical mapping in DUT
            4'b0011: exp_item.RES = {1'b0, ~(tr.OPA | tr.OPB)};
            4'b0100: exp_item.RES = {1'b0, tr.OPA ^ tr.OPB};
            4'b0101: exp_item.RES = {1'b0, ~(tr.OPA ^ tr.OPB)};
            4'b1100: begin         
                      exp_item.RES = (shift==0) ? {1'b0,tr.OPA} :{1'b0,(tr.OPA<<shift)|(tr.OPA>>(`width-shift))};                                 
                      exp_item.ERR = (`width > 3 && |tr.OPB[`width-1:4]);                                                                         
            end                                                                                                               
            4'b1101: begin
                      exp_item.RES = (shift==0) ? {1'b0,tr.OPA} : {1'b0,(tr.OPA>>shift)|(tr.OPA<<(`width-shift))};                                
                      exp_item.ERR = (`width > 3 && |tr.OPB[`width-1:4]);                                                                         
            end
            default: zero_outputs(exp_item);
          endcase
        end
      end

      2'b01: begin // only OPA valid
        if (tr.MODE) begin
          case (tr.CMD)
            4'b0100: exp_item.RES = tr.OPA + 1;
            4'b0101: exp_item.RES = tr.OPA - 1;
            default: zero_outputs(exp_item);
          endcase
        end else begin
          case (tr.CMD)
            4'b0110: exp_item.RES = {1'b0, ~tr.OPA};
            4'b1000: exp_item.RES = {1'b0, tr.OPA >> 1};
            4'b1001: exp_item.RES = {1'b0, tr.OPA << 1};
            default: zero_outputs(exp_item);
          endcase
        end
      end

      2'b10: begin // only OPB valid
        if (tr.MODE) begin
          case (tr.CMD)
            4'b0110: exp_item.RES = tr.OPB + 1;
            4'b0111: exp_item.RES = tr.OPB - 1;
            default: zero_outputs(exp_item);
          endcase
        end else begin
          case (tr.CMD)
            4'b0111: exp_item.RES = {1'b0, ~tr.OPB};
            4'b1010: exp_item.RES = {1'b0, tr.OPB >> 1};
            4'b1011: exp_item.RES = {1'b0, tr.OPB << 1};
            default: zero_outputs(exp_item);
          endcase
        end
      end

    endcase
  end // CE
endtask




  function void zero_outputs(my_item exp_item);
    exp_item.RES = 0; exp_item.COUT = 0; exp_item.OFLOW = 0;
    exp_item.E   = 0; exp_item.G = 0; exp_item.L = 0;
    exp_item.ERR = 0;
  endfunction


task compare_and_report(my_item dut, my_item exp_item);
  bit match;

  match = ((exp_item.RES    == dut.RES)   &&
           (exp_item.COUT   == dut.COUT)  &&
           (exp_item.OFLOW  == dut.OFLOW) &&
           (exp_item.E      == dut.E)     &&
           (exp_item.G      == dut.G)     &&
           (exp_item.L      == dut.L)     &&
           (exp_item.ERR    == dut.ERR));

  if (match) begin
    MATCH++;
    $display("\n--------------------------------------------------");
    $display(" SCOREBOARD MATCH [%0t] : SUCCESS", $time);
    $display("--------------------------------------------------");
  end
  else begin
    MISMATCH++;
    $display("\n==================================================");
    $display(" SCOREBOARD MISMATCH [%0t] : FAILURE", $time);
    $display("==================================================");
  end

  // Print both monitor(DUT) vs reference(EXP) side by side
  $display("  %-8s | %-8s | %-8s", "Signal", "DUT(mon)", "EXP(ref)");
  $display("  %-8s | %-8d | %-8d", "RES",   dut.RES,   exp_item.RES);
  $display("  %-8s | %-8d | %-8d", "COUT",  dut.COUT,  exp_item.COUT);
  $display("  %-8s | %-8d | %-8d", "OFLOW", dut.OFLOW, exp_item.OFLOW);
  $display("  %-8s | %-8d | %-8d", "ERR",   dut.ERR,   exp_item.ERR);
  $display("  %-8s | %-8d | %-8d", "E",     dut.E,     exp_item.E);
  $display("  %-8s | %-8d | %-8d", "G",     dut.G,     exp_item.G);
  $display("  %-8s | %-8d | %-8d", "L",     dut.L,     exp_item.L);
  $display("--------------------------------------------------\n");

endtask


endclass
