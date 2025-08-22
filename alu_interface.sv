`include "defines.sv"
interface alu_interface(input logic CLK,RST);

        //input signals
        logic [1:0] INP_VALID;
        logic MODE;
        logic CIN;
        logic CE;
        logic [`width-1:0] OPA,OPB;
        logic [`cwidth-1:0] CMD;

        //output signals
        logic [`width+1:0] RES;
        logic E,G,L,ERR,OFLOW,COUT;

        //clocking_block for driver
        clocking drv_cb@(posedge CLK);
                output INP_VALID,MODE,CIN,CE,OPA,OPB,CMD;
                input RST;
        endclocking

        //clocking_block for monitor
        clocking mon_cb@(posedge CLK);
                default input #0 output #0;
                input INP_VALID,MODE,CIN,CE,OPA,OPB,CMD;
                input RES,E,G,L,ERR,COUT,OFLOW;
        endclocking

        modport DRV(clocking drv_cb, input CLK,RST);
        modport MON(clocking mon_cb, input CLK,RST);


        //1.2 Operand wait timeout
        property ppt_2;
                @(posedge CLK)
                disable iff (RST)
                (INP_VALID inside {2'b01, 2'b10}) &&((MODE && CMD inside {0, 1, 2, 3, 8, 9, 10}) ||(!MODE && CMD inside {0, 1, 2, 3, 4, 5, 12, 13})) |-> (##[1:15] INP_VALID == 2'b11) or (##16 ERR == 1);
        endproperty

        assert property (ppt_2)
        else $error("ERR not raised at 17th cycle when second operand missing, time=%0t", $time);

        //1.3
        property ppt_3;
                @(posedge CLK)
                disable iff (RST)
                (INP_VALID == 2'b11 && MODE == 1) |-> (CMD inside {[0:10]});
        endproperty
        assert property (ppt_3)
        else $error("Invalid CMD=%0d in Arithmetic MODE at time %0t", CMD, $time);

        //1.3_1
        property ppt_3_1;
                @(posedge CLK)
                disable iff (RST)
                (INP_VALID == 2'b11 && MODE == 0) |-> (CMD inside {[0:13]});
        endproperty
        assert property (ppt_3_1)
        else $error("Invalid CMD=%0d in Logical MODE at time %0t", CMD, $time);

        //1.6
        property ppt_6;
                @(posedge CLK)
                disable iff (RST)
                (!CE) |=> (RES == 0 && COUT == 0 && OFLOW == 0 && ERR == 0 && G == 0 && L == 0 && E == 0);
        endproperty

        assert property (ppt_6)
        else $error("Outputs is not 0 when CE is low at time %0t", $time);


        //1.8
        // Greater-than (G)
        assert property (@(posedge CLK)
                (INP_VALID && MODE == 1 && CMD == 8 && OPA > OPB) |=> (G == 1 && E == 0 && L == 0));

        // Equal (E)
        assert property (@(posedge CLK)
                (INP_VALID && MODE == 1 && CMD == 8 && OPA == OPB) |=> (G == 0 && E == 1 && L == 0));

        // Less-than (L)
        assert property (@(posedge CLK)
                (INP_VALID && MODE == 1 && CMD == 8 && OPA < OPB) |=> (G == 0 && E == 0 && L == 1));

endinterface
