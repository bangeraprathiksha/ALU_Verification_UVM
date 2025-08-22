`include "defines.sv"
class my_test extends uvm_test;
  my_environment envh;

  `uvm_component_utils(my_test)

  function new(string name = "my_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    envh=my_environment::type_id::create("envh",this);
    uvm_config_db#(uvm_active_passive_enum)::set(this, "envh.active_agh", "is_active", UVM_ACTIVE);
    uvm_config_db#(uvm_active_passive_enum)::set(this, "envh.passive_agh", "is_active", UVM_PASSIVE);
  endfunction

  virtual task run_phase(uvm_phase phase);
    my_sequence seqh;
    phase.raise_objection(this);

    seqh = my_sequence::type_id::create("seqh");
    seqh.start(envh.active_agh.seqr);
    seqh.start(envh.passive_agh.seqr);

    //phase.phase_done.set_drain_time(this,20);
        //#1000ns;
    phase.drop_objection(this);
  endtask

endclass


class my_test1 extends my_test;
        `uvm_component_utils(my_test1)

        function new(string name = "my_test1", uvm_component parent = null);
                super.new(name, parent);
        endfunction

        virtual task run_phase(uvm_phase phase);
                my_sequence1 seq;
                phase.raise_objection(this);
                        seq = my_sequence1::type_id::create("seq");
                        seq.start(envh.active_agh.seqr);
                        seq.start(envh.passive_agh.seqr);

                phase.drop_objection(this);
        endtask
endclass


class my_test2 extends my_test;
        `uvm_component_utils(my_test2)

        function new(string name = "my_test2", uvm_component parent = null);
                super.new(name, parent);
        endfunction

        virtual task run_phase(uvm_phase phase);
                my_sequence2 seq;
                phase.raise_objection(this);
                        seq = my_sequence2::type_id::create("seq");
                        seq.start(envh.active_agh.seqr);
                        seq.start(envh.passive_agh.seqr);

                phase.drop_objection(this);
        endtask
endclass

class my_test3 extends my_test;
        `uvm_component_utils(my_test3)

        function new(string name = "my_test3", uvm_component parent = null);
                super.new(name, parent);
        endfunction

        virtual task run_phase(uvm_phase phase);
                my_sequence3 seq;
                phase.raise_objection(this);
                        seq = my_sequence3::type_id::create("seq");
                        seq.start(envh.active_agh.seqr);
                        seq.start(envh.passive_agh.seqr);

                phase.drop_objection(this);
        endtask
endclass


class my_test4 extends my_test;
        `uvm_component_utils(my_test4)

        function new(string name = "my_test4", uvm_component parent = null);
                super.new(name, parent);
        endfunction

        virtual task run_phase(uvm_phase phase);
                my_sequence4 seq;
                phase.raise_objection(this);
                        seq = my_sequence4::type_id::create("seq");
                        seq.start(envh.active_agh.seqr);
                        seq.start(envh.passive_agh.seqr);

                phase.drop_objection(this);
        endtask
endclass

class alu_regression extends my_test;
        `uvm_component_utils(alu_regression)

        function new(string name = "alu_regression", uvm_component parent = null);
                super.new(name, parent);
        endfunction

        virtual task run_phase(uvm_phase phase);
                alu_regression_sequence seq;
                phase.raise_objection(this);
                        seq = alu_regression_sequence::type_id::create("seq");
                        seq.start(envh.active_agh.seqr);
                        seq.start(envh.passive_agh.seqr);

                phase.drop_objection(this);
        endtask
endclass
