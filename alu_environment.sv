
`include "defines.sv"
class my_environment extends uvm_env;
        my_agent active_agh;
        my_agent passive_agh;
        my_scoreboard sch;
        my_coverage covh;

        `uvm_component_utils(my_environment)

  function new(string name = "my_environment", uvm_component parent);
                super.new(name,parent);
        endfunction

        function void build_phase(uvm_phase phase);
                super.build_phase(phase);
                active_agh = my_agent::type_id::create("active_agh",this);
                passive_agh = my_agent::type_id::create("passive_agh", this);
                sch = my_scoreboard::type_id::create("sch",this);
                covh = my_coverage::type_id::create("covh",this);
        endfunction

        function void connect_phase(uvm_phase phase);

                active_agh.monh.item_collected_port.connect(sch.mon_fifo.analysis_export);
                //agh.drvh.tlm_analysis_port_drv.connect(sch.drv_fifo.analysis_export);


                passive_agh.monh.item_collected_port.connect(covh.aport_mon1);
                active_agh.monh.item_collected_port.connect(covh.aport_drv1);
        endfunction
endclass
