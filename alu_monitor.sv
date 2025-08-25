`include "defines.sv"
class my_monitor extends uvm_monitor;
        virtual alu_interface vif;

        //analysis port for coverage
        uvm_analysis_port #(my_item) item_collected_port;

        //sequence item handle for assigning the output
        my_item item;

        `uvm_component_utils(my_monitor)

        function new(string name = "my_monitor", uvm_component parent);
                super.new(name,parent);
                item = new();
                item_collected_port = new("item_collected_port",this);
        endfunction

        function void build_phase(uvm_phase phase);
                super.build_phase(phase);
                if(!uvm_config_db #(virtual alu_interface) :: get(this,"","vif",vif))
                        `uvm_fatal(get_type_name(),"failed to get output signals ");
        endfunction

         function bit multiplication_check();
                if( vif.mon_cb.CMD inside { 'd9, 'd10 } && vif.mon_cb.MODE )
                        return 1;
                else
                        return 0;
        endfunction


   virtual task run_phase(uvm_phase phase);
                repeat(2) @(vif.mon_cb);   // wait some extra setup time

          forever begin
                        repeat(1)@(vif.mon_cb);

                        if (multiplication_check())begin
                                repeat(1) @(vif.mon_cb)
                                #0;
                                item.OPA   = vif.mon_cb.OPA;
                                item.OPB = vif.mon_cb.OPB;
                                item.CMD  = vif.mon_cb.CMD;
                                item.INP_VALID   = vif.mon_cb.INP_VALID;
                                item.CIN     = vif.mon_cb.CIN;
                                item.CE     = vif.mon_cb.CE;
                                item.MODE   = vif.mon_cb.MODE;
                                item.RES   = vif.mon_cb.RES;
                                item.OFLOW = vif.mon_cb.OFLOW;
                                item.COUT  = vif.mon_cb.COUT;
                                item.G     = vif.mon_cb.G;
                                item.L     = vif.mon_cb.L;
                                item.E     = vif.mon_cb.E;
                                item.ERR   = vif.mon_cb.ERR;

                                $display("time[%0t] MONITOR PASSING THE DATA TO SCOREBOARD OPA=%0d | OPB=%0d |INP_VALID = %0d | CMD=%0d | MODE=%0d | CE=%0d | CIN=%0d | RES = %0d | OFLOW = %0d | COUT = %0d | G = %0d | L = %0d | E = %0d | ERR = %0d ",$time, item.OPA, item.OPB,item.INP_VALID, item.CMD, item.MODE, item.CE, item.CIN, item.RES, item.OFLOW, item.COUT, item.G, item.L, item.E, item.ERR);
                        end
                        else begin

                                #0;
                                item.OPA   = vif.mon_cb.OPA;
                                item.OPB = vif.mon_cb.OPB;
                                item.CMD  = vif.mon_cb.CMD;
                                item.INP_VALID   = vif.mon_cb.INP_VALID;
                                item.CIN     = vif.mon_cb.CIN;
                                item.CE     = vif.mon_cb.CE;
                                item.MODE   = vif.mon_cb.MODE;
                                item.RES   = vif.mon_cb.RES;
                                item.COUT  = vif.mon_cb.COUT;
                                item.OFLOW = vif.mon_cb.OFLOW;
                                item.ERR   = vif.mon_cb.ERR;
                                item.E     = vif.mon_cb.E;
                                item.G     = vif.mon_cb.G;
                                item.L     = vif.mon_cb.L;
                                $display("time[%0t] MONITOR PASSING THE DATA TO SCOREBOARD OPA=%0d | OPB=%0d | INP_VALID=%0d | CMD=%0d | MODE=%0d | CE=%0d | CIN=%0d | RES = %0d | OFLOW = %0d | COUT = %0d | G = %0d | L = %0d | E = %0d | ERR = %0d ",$time, item.OPA, item.OPB,item.INP_VALID, item.CMD, item.MODE, item.CE, item.CIN, item.RES, item.OFLOW, item.COUT, item.G, item.L, item.E, item.ERR);
                        end
                  item_collected_port.write(item);
                repeat(1) @(vif.mon_cb);
                end
                $display("monitor task done");
                //repeat(1) @(vif.mon_cb);
        endtask


endclass
