`include "defines.sv"
// Declare macros OUTSIDE any class, in global scope
`uvm_analysis_imp_decl(_mon_cg)
`uvm_analysis_imp_decl(_drv_cg)

class my_coverage extends uvm_component;
    `uvm_component_utils(my_coverage)

    // Create analysis imps for monitor and driver
        uvm_analysis_imp_mon_cg #(my_item, my_coverage) aport_mon1;
        uvm_analysis_imp_drv_cg #(my_item, my_coverage) aport_drv1;
        my_item drv_trans, mon_trans;
        real mon_cov,drv_cov;

        //driver
        covergroup drv_cg;
                option.per_instance = 1;
                // OPA Coverpoint
                cp_opa: coverpoint drv_trans.OPA {
                        bins opa_bins[50] = {[0:255]};
                }
                // OPB Coverpoint
                cp_opb: coverpoint drv_trans.OPB {
                        bins opb_bins[10] = {[0:255]};
                }
                // CE Coverpoint
                cp_ce: coverpoint drv_trans.CE {
                        bins ce_0 = {0};
                        bins ce_1 = {1};
                }
                // CIN Coverpoint
                cp_cin: coverpoint drv_trans.CIN {
                        bins cin_0 = {0};
                        bins cin_1 = {1};
                }

                // MODE Coverpoint
                cp_mode: coverpoint drv_trans.MODE {
                        bins mode_0 = {0};
                        bins mode_1 = {1};
                }

                // INP_VALID Coverpoint
                cp_inp_valid: coverpoint drv_trans.INP_VALID {
                        bins no_valid   = {2'b00};
                        bins only_a     = {2'b01};
                        bins only_b     = {2'b10};
                        bins both_valid = {2'b11};
                }
                // CMD Coverpoint
                cp_cmd: coverpoint drv_trans.CMD {
                        bins add_and          = {0};
                        bins sub_nand         = {1};
                        bins add_cin_or       = {2};
                        bins sub_cin_nor      = {3};
                        bins inc_a_xor        = {4};
                        bins dec_a_xnor       = {5};
                        bins inc_b_not_a      = {6};
                        bins dec_b_not_b      = {7};
                        bins cmp_shr1_a       = {8};
                        bins inc_mul_shl1_a   = {9};
                        bins shift_mul_shr1_b = {10};
                        bins shl1_            = {11};
                        bins rol_a_b          = {12};
                        bins ror_a_b          = {13};
                }

                // Cross Coverages
                cross cp_inp_valid, cp_cmd;
                cross cp_cmd, cp_mode;
                cross cp_mode, cp_inp_valid;

        endgroup

        //monitor
        covergroup mon_cg;
                option.per_instance = 1;
                cp_res: coverpoint mon_trans.RES {
                        bins res_vals[50] = {[0:255]};
                        }
                cp_cout: coverpoint mon_trans.COUT {
                        bins cout_0 = {0};
                        bins cout_1 = {1};
                        }
                cp_oflow: coverpoint mon_trans.OFLOW{
                        bins oflow_0 = {0};
                        bins oflow_1 = {1};
                        }
                cp_err: coverpoint mon_trans.ERR {
                        bins err_0 = {0};
                        bins err_1 = {1};
                        }
                cp_e: coverpoint mon_trans.E {
                        bins e_0 = {0};
                        bins e_1 = {1};
                        }
                cp_g: coverpoint mon_trans.G {
                        bins g_0 = {0};
                        bins g_1 = {1};
                        }
                cp_l: coverpoint mon_trans.L {
                        bins l_0 = {0};
                        bins l_1 = {1};
                        }
        endgroup

        function new(string name ="",uvm_component parent);
                super.new(name,parent);
                drv_cg = new();
                mon_cg = new();
                aport_drv1 = new("aport_drv1",this);
                aport_mon1 = new("aport_mon1",this);
        endfunction

        function void write_drv_cg(my_item t);
                drv_trans = t;
                drv_cg.sample();
                `uvm_info(get_type_name, $sformatf("[DRIVER]  INP_VALID=%0d CMD=%0d MODE=%0d CIN=%0d CE=%0d OPA=%0d OPB=%0d ", drv_trans.INP_VALID, drv_trans.CMD, drv_trans.MODE, drv_trans.CIN, drv_trans.CE, drv_trans.OPA, drv_trans.OPB), UVM_MEDIUM);
        endfunction

        function void write_mon_cg(my_item t);
                mon_trans = t;
                mon_cg.sample();
                `uvm_info(get_type_name, $sformatf("[MONITOR]  RES=%0d E=%0d G=%0d L=%0d OFLOW=%0d COUT=%0d ERR=%0d", mon_trans.RES, mon_trans.E, mon_trans.G, mon_trans.L, mon_trans.OFLOW, mon_trans.COUT, mon_trans.ERR), UVM_MEDIUM);
        endfunction

        function void extract_phase(uvm_phase phase);
                super.extract_phase(phase);
                drv_cov = drv_cg.get_coverage();
                mon_cov = mon_cg.get_coverage();
        endfunction

        function void report_phase(uvm_phase phase);
                super.report_phase(phase);
                `uvm_info(get_type_name, $sformatf("[DRIVER] Coverage ------> %0.2f%%,", drv_cov), UVM_MEDIUM);
                `uvm_info(get_type_name, $sformatf("[MONITOR] Coverage ------> %0.2f%%", mon_cov), UVM_MEDIUM);
        endfunction

endclass
