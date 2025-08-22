`include "defines.sv"
class my_agent extends uvm_agent;
        my_driver drvh;
        my_sequencer seqr;
        my_monitor monh;

        `uvm_component_utils(my_agent)

        function new(string name = "my_agent",uvm_component parent);
                super.new(name,parent);
        endfunction

        function void build_phase(uvm_phase phase);
                super.build_phase(phase);
                if(get_is_active() == UVM_ACTIVE) begin
                        drvh = my_driver::type_id::create("drvh",this);
                        seqr = my_sequencer::type_id::create("seqr",this);
                end
                monh = my_monitor::type_id::create("monh",this);
        endfunction

        function void connect_phase(uvm_phase phase);
                super.connect_phase(phase);
                if(get_is_active()==UVM_ACTIVE) begin
                        drvh.seq_item_port.connect(seqr.seq_item_export);
                end
        endfunction
endclass
