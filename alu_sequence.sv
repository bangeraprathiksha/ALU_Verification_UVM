`include "defines.sv"
class my_sequence extends uvm_sequence#(my_item);
        `uvm_object_utils(my_sequence)

        function new(string name = "my_sequence");
                super.new(name);
        endfunction

        virtual task body();
                my_item req;
                for (int i = 0; i < `no_of_trans; i++) begin
                        req = my_item::type_id::create("req");

                        start_item(req);
                        assert (req.randomize());
                        finish_item(req);

                        //`uvm_info(get_type_name(), $sformatf("Sent transaction %0d at time %0t", i, $time),UVM_LOW)
                end

                //`uvm_info(get_type_name(), "@@@@@@@@@@@@@@@@@@@@@@@@@@@@Sent all transactions@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@", UVM_LOW);
        endtask

endclass


class my_sequence1 extends uvm_sequence#(my_item);
        `uvm_object_utils(my_sequence1)

        function new(string name = "my_sequence1");
                super.new(name);
        endfunction

        virtual task body();
  `uvm_do_with(req, { req.MODE == 1 && req.CMD inside {[4:7]} && (req.INP_VALID == 2'b11 || req.INP_VALID == 2'b01 || req.INP_VALID == 2'b10) ; })
endtask

endclass

class my_sequence2 extends uvm_sequence#(my_item);
        `uvm_object_utils(my_sequence2)

        function new(string name = "my_sequence2");
                super.new(name);
        endfunction

        virtual task body();
                `uvm_do_with(req,{req.MODE == 0 && req.CMD inside {[6:11]} && (req.INP_VALID == 2'b11 || req.INP_VALID == 2'b01 || req.INP_VALID == 2'b10);})

        endtask

endclass

class my_sequence3 extends uvm_sequence#(my_item);
        `uvm_object_utils(my_sequence3)

        function new(string name = "my_sequence3");
                super.new(name);
        endfunction

        virtual task body();

                `uvm_do_with(req,{req.MODE == 0 && req.CMD inside {[0:6],12,13} ;})

        endtask

endclass


class my_sequence4 extends uvm_sequence#(my_item);
        `uvm_object_utils(my_sequence4)

        function new(string name = "my_sequence4");
                super.new(name);
        endfunction

        virtual task body();

                `uvm_do_with(req,{req.MODE == 1 && req.CMD inside {[0:3],[8:10]} ;})

        endtask

endclass


class alu_regression_sequence extends uvm_sequence#(my_item);

  my_sequence1 m1;
  my_sequence2 m2;
  my_sequence3 m3;
  my_sequence4 m4;
  `uvm_object_utils(alu_regression_sequence)

  function new(string name = "alu_regression_sequence");
    super.new(name);
  endfunction

  virtual task body();
    for(int i=0; i< `no_of_trans; i++)begin
    `uvm_do(m1)
    `uvm_do(m2)
    `uvm_do(m3)
    `uvm_do(m4)
    end
  endtask
endclass
