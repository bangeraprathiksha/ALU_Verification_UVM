/*`include "defines.sv"
class my_driver extends uvm_driver #(my_item);
    virtual alu_interface vif;

    bit [3:0] cmd_fixed;
    bit ce_fixed;
    bit mode_fixed;

    uvm_analysis_port #(my_item) tlm_analysis_port_drv;

    `uvm_component_utils(my_driver)

    function new(string name = "my_driver", uvm_component parent);
        super.new(name, parent);
        tlm_analysis_port_drv = new("tlm_analysis_port_drv", this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db #(virtual alu_interface)::get(this,"","vif",vif))
            `uvm_fatal(get_type_name(), "failed to get interface signals");
    endfunction

    virtual task run_phase(uvm_phase phase);
        my_item req;
        forever begin
            seq_item_port.get_next_item(req);
            drive(req);
            seq_item_port.item_done();
        end
    endtask

    task drive(my_item req);
        cmd_fixed  = req.CMD;
        ce_fixed   = req.CE;
        mode_fixed = req.MODE;
        $display("DRIVER: started %0t", $time);
      for(int i=0; i<`no_of_trans ;i++) begin
                @(vif.drv_cb);
             if (((req.INP_VALID == 2'b01 || req.INP_VALID == 2'b10) &&
                 req.CE &&
                 ((req.MODE && (req.CMD inside {[0:3],[8:10]})) ||
                  (!req.MODE && (req.CMD inside {[0:5],[12:13]})))))
            begin
                for (int j=0; j<16; j++) begin
                    $display("time [%0t], inside loop j=%0d", $time, j);
                  @(vif.drv_cb);
                    if (req.randomize() with { CMD == cmd_fixed; MODE == mode_fixed; CE == ce_fixed; }) begin
                        if (req.INP_VALID == 2'b11) begin
                            vif.drv_cb.OPA       <= req.OPA;
                            vif.drv_cb.OPB       <= req.OPB;
                            vif.drv_cb.CMD       <= req.CMD;
                            vif.drv_cb.INP_VALID <= req.INP_VALID;
                            vif.drv_cb.MODE      <= req.MODE;
                            vif.drv_cb.CE        <= req.CE;
                            vif.drv_cb.CIN       <= req.CIN;
                            break;
                        end else begin
                            vif.drv_cb.OPA       <= req.OPA;
                            vif.drv_cb.OPB       <= req.OPB;
                            vif.drv_cb.CMD       <= cmd_fixed;
                            vif.drv_cb.INP_VALID <= req.INP_VALID;
                            vif.drv_cb.MODE      <= mode_fixed;
                            vif.drv_cb.CE        <= ce_fixed;
                            vif.drv_cb.CIN       <= req.CIN;
                        end
                    end
                end
                $display("time[%0t] DRIVER RANDOMIZING OPA=%0d,OPB=%0d,INP_VALID=%0d,CMD=%0d,MODE=%0d,CE=%0b,CIN=%0b",$time,vif.drv_cb.OPA,vif.drv_cb.OPB,vif.drv_cb.INP_VALID,vif.drv_cb.CMD,vif.drv_cb.MODE,vif.drv_cb.CE,vif.drv_cb.CIN);

            end
            else begin
                vif.drv_cb.OPA       <= req.OPA;
                vif.drv_cb.OPB       <= req.OPB;
                vif.drv_cb.CMD       <= req.CMD;
                vif.drv_cb.INP_VALID <= req.INP_VALID;
                vif.drv_cb.MODE      <= req.MODE;
                vif.drv_cb.CE        <= req.CE;
                vif.drv_cb.CIN       <= req.CIN;
                $display("time[%0t] normal ----------------DRIVER RANDOMIZING OPA=%0d,OPB=%0d,INP_VALID=%0d,CMD=%0d,MODE=%0d,CE=%0b,CIN=%0b",$time,vif.drv_cb.OPA,vif.drv_cb.OPB,vif.drv_cb.INP_VALID,vif.drv_cb.CMD,vif.drv_cb.MODE,vif.drv_cb.CE,vif.drv_cb.CIN);
            end
                //  @(vif.drv_cb);
        end
        tlm_analysis_port_drv.write(req);
    endtask
endclass
*/

`include "defines.sv"

class my_driver extends uvm_driver #(my_item);

    virtual alu_interface vif;
    bit [3:0] cmd_fixed;
    bit       ce_fixed;
    bit       mode_fixed;

    `uvm_component_utils(my_driver)

    function new(string name = "my_driver", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual alu_interface)::get(this, "", "vif", vif))
            `uvm_fatal(get_type_name(), "failed to get interface signals");
    endfunction

    virtual task run_phase(uvm_phase phase);
        my_item req;
        forever begin
            seq_item_port.get_next_item(req);
            drive(req);
            seq_item_port.item_done();
        end
    endtask

    task drive(my_item req);

        cmd_fixed  = req.CMD;
        ce_fixed   = req.CE;
        mode_fixed = req.MODE;

        $display("DRIVER: started %0t", $time);

        repeat(1) @(vif.drv_cb);

        // Special 16-cycle case
        if (((req.INP_VALID == 2'b01 || req.INP_VALID == 2'b10) &&
             req.CE &&
            ((req.MODE && (req.CMD inside {[0:3],[8:10]})) ||
             (!req.MODE && (req.CMD inside {[0:5],[12:13]}))))) begin

            for (int j = 0; j < 16; j++) begin

                // Randomize with fixed CMD/MODE/CE
                if (req.randomize() with {
                        CMD  == cmd_fixed;
                        MODE == mode_fixed;
                        CE   == ce_fixed;
                    }) begin

                    // Special exit if INP_VALID=11
                    if (req.INP_VALID == 2'b11) begin
                        vif.drv_cb.OPA       <= req.OPA;
                        vif.drv_cb.OPB       <= req.OPB;
                        vif.drv_cb.CMD       <= req.CMD;
                        vif.drv_cb.INP_VALID <= req.INP_VALID;
                        vif.drv_cb.MODE      <= req.MODE;
                        vif.drv_cb.CE        <= req.CE;
                        vif.drv_cb.CIN       <= req.CIN;

                        $display("time[%0t] DRIVER: Got INP_VALID=11 Exiting loop", $time);
                        $display("time[%0t] DRIVER DRIVING 16cycle...... OPA=%0d, OPB=%0d, INP_VALID=%0d, CMD=%0d, MODE=%0d, CE=%0b, CIN=%0b",
                                  $time, vif.drv_cb.OPA, vif.drv_cb.OPB, vif.drv_cb.INP_VALID,
                                  vif.drv_cb.CMD, vif.drv_cb.MODE, vif.drv_cb.CE, vif.drv_cb.CIN);
                        break;
                    end
                    else begin
                        vif.drv_cb.OPA       <= req.OPA;
                        vif.drv_cb.OPB       <= req.OPB;
                        vif.drv_cb.CMD       <= cmd_fixed;
                        vif.drv_cb.INP_VALID <= req.INP_VALID;
                        vif.drv_cb.MODE      <= mode_fixed;
                        vif.drv_cb.CE        <= ce_fixed;
                        vif.drv_cb.CIN       <= req.CIN;
                    end

                    $display("time[%0t] DRIVER DRIVING 16cycle...... OPA=%0d, OPB=%0d, INP_VALID=%0d, CMD=%0d, MODE=%0d, CE=%0b, CIN=%0b",
                              $time, vif.drv_cb.OPA, vif.drv_cb.OPB, vif.drv_cb.INP_VALID,
                              vif.drv_cb.CMD, vif.drv_cb.MODE, vif.drv_cb.CE, vif.drv_cb.CIN);
                end

                @(vif.drv_cb);
            end
        end
        else begin
            // Normal (non-16 cycle) drive
            vif.drv_cb.OPA       <= req.OPA;
            vif.drv_cb.OPB       <= req.OPB;
            vif.drv_cb.CMD       <= req.CMD;
            vif.drv_cb.INP_VALID <= req.INP_VALID;
            vif.drv_cb.MODE      <= req.MODE;
            vif.drv_cb.CE        <= req.CE;
            vif.drv_cb.CIN       <= req.CIN;

            $display("time[%0t] DRIVER DRIVING NORMAL ......... OPA=%0d, OPB=%0d, INP_VALID=%0d, CMD=%0d, MODE=%0d, CE=%0b, CIN=%0b",
                      $time, vif.drv_cb.OPA, vif.drv_cb.OPB, vif.drv_cb.INP_VALID,
                      vif.drv_cb.CMD, vif.drv_cb.MODE, vif.drv_cb.CE, vif.drv_cb.CIN);
        end

        repeat(1) @(vif.drv_cb);

    endtask

endclass
