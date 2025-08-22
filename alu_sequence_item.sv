`include "defines.sv"
class my_item extends uvm_sequence_item;
        rand bit[1:0] INP_VALID;
        rand bit MODE;
        rand bit[`cwidth-1:0] CMD;
        rand bit CE;
        rand bit[`width-1:0] OPA,OPB;
        rand bit CIN;

                bit[`width+1:0] RES;
                bit E,G,L,OFLOW,COUT,ERR;

        `uvm_object_utils_begin(my_item)
                `uvm_field_int(INP_VALID,UVM_ALL_ON)
                `uvm_field_int(MODE,UVM_ALL_ON)
                `uvm_field_int(CMD,UVM_ALL_ON)
                `uvm_field_int(CE,UVM_ALL_ON)
                `uvm_field_int(OPA,UVM_ALL_ON)
                `uvm_field_int(OPB,UVM_ALL_ON)
                `uvm_field_int(CIN,UVM_ALL_ON)
        `uvm_object_utils_end

        function new(string name = "my_item");
                super.new(name);
        endfunction

                function void copy_inputs(my_item rhs);
                        this.INP_VALID = rhs.INP_VALID;
                        this.MODE      = rhs.MODE;
                        this.CMD       = rhs.CMD;
                        this.CE        = rhs.CE;
                        this.OPA       = rhs.OPA;
                        this.OPB       = rhs.OPB;
                        this.CIN       = rhs.CIN;

                    this.RES=0;
                this.E=0;
                this.G=0;
                this.L=0;
                this.OFLOW=0;
                this.COUT=0;
                this.ERR=0;
                endfunction


        //constriants if we want
        //constraint c1{INP_VALID == 2'b11;}

        constraint c2{(MODE == 0) -> CMD inside {[0:13]};}
        constraint c3{(MODE == 1) -> CMD inside {[0:10]};}

endclass
