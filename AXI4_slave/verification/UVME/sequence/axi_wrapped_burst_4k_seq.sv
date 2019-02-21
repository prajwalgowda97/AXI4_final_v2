class axi_wrapped_burst_4k_seq extends uvm_sequence#(axi_seq_item);

  //factory registration
  `uvm_object_utils(axi_wrapped_burst_4k_seq)

    //creating sequence item handle
    axi_seq_item seq_item_inst;
    int scenario;

    // Variable to store randomized write address
    bit [31:0] rand_wr_addr; 
    bit [3: 0] rand_wr_id;
    bit [2:0] wr_size;
    bit [1:0] wr_burst;
    bit [7:0] wr_len;

  //constructor
  function new(string name="axi_wrapped_burst_4k_seq");
   super.new(name);
  endfunction
  
  //Build phase
  function build_phase(uvm_phase phase);
  seq_item_inst = axi_seq_item::type_id::create("seq_item_inst");
  endfunction


  //task body
  task body();

  //reset scenario
        `uvm_info (get_type_name(),"wrapped_burst_4k_seq: inside body", UVM_LOW);
       
       if (scenario == 23)
        begin
          `uvm_do_with(seq_item_inst,{
            seq_item_inst.RST       == 1'b0;
            seq_item_inst.AWADDR    == 32'h00000000;
            seq_item_inst.AWVALID   == 1'b0;
            seq_item_inst.WVALID    == 1'b0;
            seq_item_inst.WDATA[0]  == 32'h00000000;
            seq_item_inst.BREADY    == 1'b0;
            seq_item_inst.AWID      == 0;
            seq_item_inst.AWSIZE    == 0;
            seq_item_inst.ARID      == 0;
            seq_item_inst.ARSIZE    == 0;
            seq_item_inst.AWLEN     == 0;
            seq_item_inst.AWBURST   == 0;
            seq_item_inst.WSTRB     == 0;
            seq_item_inst.WLAST     == 0;
            seq_item_inst.ARVALID   == 0;
            seq_item_inst.ARADDR    == 0;
            seq_item_inst.ARLEN     == 0;
            seq_item_inst.ARBURST   == 0;
            seq_item_inst.RREADY    == 0;   });                     
            end

if (scenario == 24)
        begin  
            `uvm_do_with(seq_item_inst,{
            seq_item_inst.RST       == 1'b1;
            seq_item_inst.wr_rd     == 1'b1;
            seq_item_inst.AWVALID   == 1'b1;
            seq_item_inst.WVALID    == 1'b1;
            seq_item_inst.BREADY    == 1'b0;
            // Set up an address near 4K boundary to force crossing
            seq_item_inst.AWADDR    == 32'h00000FF0; // Close to 4K boundary (0x1000)
            seq_item_inst.WDATA[0]  inside {[32'h0000_0000 : 32'hFFFF_FFFF]};
            seq_item_inst.AWID      inside {[4'h0 : 4'hF]};
            // Use longer burst length to ensure boundary crossing
            seq_item_inst.AWLEN     == 8'h0F;        // 16 transfers
            seq_item_inst.AWSIZE    == 3'b010;       // 4 bytes per transfer
            seq_item_inst.AWBURST   == 2'b10;        // Wrapped burst
            seq_item_inst.WSTRB     == 4'b1111;
            seq_item_inst.WLAST     == 1'b0; 
            
            seq_item_inst.ARVALID   == 0;
            seq_item_inst.RREADY    == 0;
            seq_item_inst.ARID      == 0;
            seq_item_inst.ARADDR    == 0;
            seq_item_inst.ARSIZE    == 0;
            seq_item_inst.ARBURST   == 0;
            seq_item_inst.ARLEN     == 0; });
            
            `uvm_info("SEQ", $sformatf("Running 4K boundary crossing test - scenario = %0d", scenario), UVM_MEDIUM)    
            
            // Store the randomized AWADDR value into the class variable
            rand_wr_addr = seq_item_inst.AWADDR;
            rand_wr_id   = seq_item_inst.AWID;
            wr_size      = seq_item_inst.AWSIZE;
            wr_burst     = seq_item_inst.AWBURST;
            wr_len       = seq_item_inst.AWLEN;

            `uvm_info("SEQ", $sformatf("Boundary crossing AWADDR = 0x%0h, with burst length = %0d, size = %0d", 
                                        rand_wr_addr, wr_len+1, (1 << wr_size)), UVM_MEDIUM)
            
            // Calculate and display the boundary crossing information
            bit [31:0] last_addr;
            int bytes_per_transfer = (1 << wr_size);
            int total_bytes = bytes_per_transfer * (wr_len + 1);
            last_addr = rand_wr_addr + total_bytes - 1;
            
            `uvm_info("SEQ", $sformatf("Starting address: 0x%0h, Ending address: 0x%0h", 
                                        rand_wr_addr, last_addr), UVM_MEDIUM)
            
            if ((rand_wr_addr & 32'hFFFFF000) != (last_addr & 32'hFFFFF000)) begin
                `uvm_info("SEQ", $sformatf("4K BOUNDARY CROSSING DETECTED - from page 0x%0h to page 0x%0h", 
                                          (rand_wr_addr & 32'hFFFFF000), (last_addr & 32'hFFFFF000)), UVM_MEDIUM)
            end
        end

        if (scenario == 25)
        begin
              `uvm_do_with(seq_item_inst,{
            seq_item_inst.RST       == 1'b1;
            seq_item_inst.wr_rd     == 1'b0;
            seq_item_inst.ARVALID   == 1'b1;
            seq_item_inst.RREADY    == 1'b0;
            seq_item_inst.ARID      == rand_wr_id;
            seq_item_inst.ARADDR    == rand_wr_addr;
            seq_item_inst.ARSIZE    == wr_size;
            seq_item_inst.ARBURST   == wr_burst;
            seq_item_inst.ARLEN     == wr_len;   
            
            seq_item_inst.AWVALID   == 0;
            seq_item_inst.WVALID    == 0;
            seq_item_inst.BREADY    == 0;
            seq_item_inst.AWADDR    == 0;
            seq_item_inst.WDATA[0]  == 0;
            seq_item_inst.AWID      == 0;
            seq_item_inst.AWLEN     == 0;
            seq_item_inst.AWSIZE    == 0;
            seq_item_inst.AWBURST   == 0;
            seq_item_inst.WSTRB     == 0;
            seq_item_inst.WLAST     == 0; });
            
            `uvm_info("SEQ", $sformatf("Using boundary crossing ARADDR = 0x%0h", rand_wr_addr), UVM_MEDIUM)
            end

  endtask
endclass
