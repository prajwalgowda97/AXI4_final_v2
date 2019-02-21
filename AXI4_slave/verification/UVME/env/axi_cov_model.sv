// Coverage model class
/* class axi_cov_model extends uvm_subscriber #(axi_seq_item);
  `uvm_component_utils(axi_cov_model)
  
  axi_seq_item item;
  
  // Coverage instances
  covergroup axi_write_cg;
    // AW Channel coverage
    AWID: coverpoint item.AWID {
      bins id[] = {[0:15]};
      illegal_bins invalid = {[16:$]};
    }
    
    AWADDR: coverpoint item.AWADDR {
      bins addr_word_aligned     = {[0:32'hFFFFFFFF]} with (item.AWADDR % 4 == 0);
      bins addr_halfword_aligned = {[0:32'hFFFFFFFF]} with (item.AWADDR % 2 == 0 && item.AWADDR % 4 != 0);
      bins addr_byte_aligned     = {[0:32'hFFFFFFFF]} with (item.AWADDR % 2 != 0);
      bins addr_4k_boundary      = {[0:32'hFFFFFFFF]} with (item.AWADDR[11:0] == 0);
    }
    
    AWLEN: coverpoint item.AWLEN {
      bins single_beat  = {0};
      bins short_burst  = {[1:7]};
      bins medium_burst = {[8:15]};
      bins long_burst   = {[16:255]};
    }
    
    AWSIZE: coverpoint item.AWSIZE {
     // bins byte      = {0};  // 1 byte
     // bins halfword  = {1};  // 2 bytes
      bins word      = {2};  // 4 bytes
     // bins dword     = {3};  // 8 bytes 
    }
    
    AWBURST: coverpoint item.AWBURST {
      bins fixed  = {0};
      bins incr   = {1};
      bins wrap   = {2};
      ignore_bins reserved = {3};
    }
    
    // W Channel coverage
    WSTRB: coverpoint item.WSTRB {
      bins full_word = {4'b1111};
      bins lower_half = {4'b0011};
      //bins upper_half = {4'b1100};
      //bins upper_byte = {4'b1000};
      //bins upper_mid_byte = {4'b0100};
      //bins lower_mid_byte = {4'b0010};
      //bins lower_byte = {4'b0001};
      //bins other_combinations = default;
    }
    
    WLAST: coverpoint item.WLAST {
      bins asserted = {1};
      bins not_asserted = {0};
    }
    
    // B Channel coverage
    BRESP: coverpoint item.BRESP {
      bins okay = {0};
    //  bins exokay = {1};
    //  bins slverr = {2};
    //  bins decerr = {3};
    }
    
    // Cross coverage for common scenarios
    BURST_SIZE_CROSS: cross AWBURST, AWSIZE {
      // Interesting combinations
      bins fixed_byte = binsof(AWBURST.fixed) && binsof(AWSIZE.word);
      bins incr_word  = binsof(AWBURST.incr) && binsof(AWSIZE.word);
      bins wrap_dword = binsof(AWBURST.wrap) && binsof(AWSIZE.word);
    }
    
    ADDR_BURST_CROSS: cross AWBURST, AWADDR {
      // Only sample when interesting
      ignore_bins not_interesting = binsof(AWBURST.reserved);
    }
    
    LEN_BURST_CROSS: cross AWLEN, AWBURST {
      // Single beat transfers shouldn't use WRAP
      illegal_bins single_wrap = binsof(AWLEN.single_beat) && binsof(AWBURST.wrap);
    }
  endgroup
  
  covergroup axi_read_cg;
    // AR Channel coverage
    ARID: coverpoint item.ARID {
      bins id[] = {[0:15]};
      illegal_bins invalid = {[16:$]};
    }
    
    ARADDR: coverpoint item.ARADDR {
      bins addr_word_aligned     = {[0:32'hFFFFFFFF]} with (item.ARADDR % 4 == 0);
      bins addr_halfword_aligned = {[0:32'hFFFFFFFF]} with (item.ARADDR % 2 == 0 && item.ARADDR % 4 != 0);
      bins addr_byte_aligned     = {[0:32'hFFFFFFFF]} with (item.ARADDR % 2 != 0);
      bins addr_4k_boundary      = {[0:32'hFFFFFFFF]} with (item.ARADDR[11:0] == 0);
    }
    
    ARLEN: coverpoint item.ARLEN {
      bins single_beat  = {0};
      bins short_burst  = {[1:7]};
      bins medium_burst = {[8:15]};
      bins long_burst   = {[16:255]};
    }
    
    ARSIZE: coverpoint item.ARSIZE {
     // bins byte      = {0};  // 1 byte
     // bins halfword  = {1};  // 2 bytes
      bins word      = {2};  // 4 bytes
     // bins dword     = {3};  // 8 bytes 
    }
    
    ARBURST: coverpoint item.ARBURST {
      bins fixed  = {0};
      bins incr   = {1};
      bins wrap   = {2};
      ignore_bins reserved = {3};
    }
    
    // R Channel coverage
    RID: coverpoint item.RID {
      bins id[] = {[0:15]};
    }
    
    RRESP: coverpoint item.RRESP {
      bins okay = {0};
     // bins exokay = {1};
     // bins slverr = {2};
     // bins decerr = {3};
    }
    
    RLAST: coverpoint item.RLAST {
      bins asserted = {1};
      bins not_asserted = {0};
    }
    
    // Cross coverage for common scenarios
    BURST_SIZE_CROSS: cross ARBURST, ARSIZE {
      // Interesting combinations
      bins fixed_byte = binsof(ARBURST.fixed) && binsof(ARSIZE.word);
      bins incr_word  = binsof(ARBURST.incr) && binsof(ARSIZE.word);
      bins wrap_dword = binsof(ARBURST.wrap) && binsof(ARSIZE.word);
    }
    
    ADDR_BURST_CROSS: cross ARBURST, ARADDR {
      // Only sample when interesting
      ignore_bins not_interesting = binsof(ARBURST.reserved);
    }
    
    LEN_BURST_CROSS: cross ARLEN, ARBURST {
      // Single beat transfers shouldn't use WRAP
      illegal_bins single_wrap = binsof(ARLEN.single_beat) && binsof(ARBURST.wrap);
    }
  endgroup
  
  // Constructor
  function new(string name, uvm_component parent);
    super.new(name, parent);
    
    // Initialize covergroups
    axi_write_cg = new();
    axi_read_cg = new();
  endfunction
  
  // Build phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    // Create analysis exports and FIFOs
  endfunction

//write method
function void write(input axi_seq_item t);
	    item = new();	 
	 	$cast(item,t);
	 	axi_write_cg.sample();
	 	axi_read_cg.sample();
    endfunction 

endclass*/

// Coverage model class
class axi_cov_model extends uvm_subscriber #(axi_seq_item);
  `uvm_component_utils(axi_cov_model)
  
  axi_seq_item item;
  
  // Coverage instances
  covergroup axi_write_cg with function sample(axi_seq_item item);
    // AW Channel coverage
    AWID: coverpoint item.AWID {
      bins id[] = {[0:15]};
      illegal_bins invalid = {[16:$]};
    }
    
    AWADDR: coverpoint item.AWADDR {
      bins addr_word_aligned     = {[0:32'hFFFFFFFF]};
      bins addr_halfword_aligned = {[0:32'hFFFFFFFF]};
      bins addr_byte_aligned     = {[0:32'hFFFFFFFF]};
      bins addr_4k_boundary      = {[0:32'hFFFFFFFF]};
      
      // Add special sampling conditions in the covergroup option
      option.at_least = 1;
      option.comment = "Address alignment coverage";
    }
    
    AWLEN: coverpoint item.AWLEN {
      bins single_beat  = {0};
      bins short_burst  = {[1:7]};
      bins medium_burst = {[8:15]};
      bins long_burst   = {[16:255]};
    }
    
    AWSIZE: coverpoint item.AWSIZE {
     // bins byte      = {0};  // 1 byte
     // bins halfword  = {1};  // 2 bytes
      bins word      = {2};  // 4 bytes
     // bins dword     = {3};  // 8 bytes 
    }
    
    AWBURST: coverpoint item.AWBURST {
      bins fixed  = {0};
      bins incr   = {1};
      bins wrap   = {2};
      ignore_bins reserved = {3};
    }
    
    // W Channel coverage
    WSTRB: coverpoint item.WSTRB {
      bins full_word = {4'b1111};
      bins lower_half = {4'b0011};
      //bins upper_half = {4'b1100};
      //bins upper_byte = {4'b1000};
      //bins upper_mid_byte = {4'b0100};
      //bins lower_mid_byte = {4'b0010};
      //bins lower_byte = {4'b0001};
      //bins other_combinations = default;
    }
    
    WLAST: coverpoint item.WLAST {
      bins asserted = {1};
      bins not_asserted = {0};
    }
    
    // B Channel coverage
    BRESP: coverpoint item.BRESP {
      bins okay = {0};
    //  bins exokay = {1};
    //  bins slverr = {2};
    //  bins decerr = {3};
    }
    
    // Cross coverage for common scenarios
    BURST_SIZE_CROSS: cross AWBURST, AWSIZE {
      // Interesting combinations
      bins fixed_byte = binsof(AWBURST.fixed) && binsof(AWSIZE.word);
      bins incr_word  = binsof(AWBURST.incr) && binsof(AWSIZE.word);
      bins wrap_dword = binsof(AWBURST.wrap) && binsof(AWSIZE.word);
    }
    
    ADDR_BURST_CROSS: cross AWBURST, AWADDR {
      // Only sample when interesting
      ignore_bins not_interesting = binsof(AWBURST.reserved);
    }
    
    LEN_BURST_CROSS: cross AWLEN, AWBURST {
      // Single beat transfers shouldn't use WRAP
      illegal_bins single_wrap = binsof(AWLEN.single_beat) && binsof(AWBURST.wrap);
    }
  endgroup
  
  covergroup axi_read_cg with function sample(axi_seq_item item);
    // AR Channel coverage
    ARID: coverpoint item.ARID {
      bins id[] = {[0:15]};
      illegal_bins invalid = {[16:$]};
    }
    
    ARADDR: coverpoint item.ARADDR {
      bins addr_word_aligned     = {[0:32'hFFFFFFFF]};
      bins addr_halfword_aligned = {[0:32'hFFFFFFFF]};
      bins addr_byte_aligned     = {[0:32'hFFFFFFFF]};
      bins addr_4k_boundary      = {[0:32'hFFFFFFFF]};
      
      // Add special sampling conditions in the covergroup option
      option.at_least = 1;
      option.comment = "Address alignment coverage";
    }
    
    ARLEN: coverpoint item.ARLEN {
      bins single_beat  = {0};
      bins short_burst  = {[1:7]};
      bins medium_burst = {[8:15]};
      bins long_burst   = {[16:255]};
    }
    
    ARSIZE: coverpoint item.ARSIZE {
     // bins byte      = {0};  // 1 byte
     // bins halfword  = {1};  // 2 bytes
      bins word      = {2};  // 4 bytes
     // bins dword     = {3};  // 8 bytes 
    }
    
    ARBURST: coverpoint item.ARBURST {
      bins fixed  = {0};
      bins incr   = {1};
      bins wrap   = {2};
      ignore_bins reserved = {3};
    }
    
    // R Channel coverage
    RID: coverpoint item.RID {
      bins id[] = {[0:15]};
    }
    
    RRESP: coverpoint item.RRESP {
      bins okay = {0};
     // bins exokay = {1};
     // bins slverr = {2};
     // bins decerr = {3};
    }
    
    RLAST: coverpoint item.RLAST {
      bins asserted = {1};
      bins not_asserted = {0};
    }
    
    // Cross coverage for common scenarios
    BURST_SIZE_CROSS: cross ARBURST, ARSIZE {
      // Interesting combinations
      bins fixed_byte = binsof(ARBURST.fixed) && binsof(ARSIZE.word);
      bins incr_word  = binsof(ARBURST.incr) && binsof(ARSIZE.word);
      bins wrap_dword = binsof(ARBURST.wrap) && binsof(ARSIZE.word);
    }
    
    ADDR_BURST_CROSS: cross ARBURST, ARADDR {
      // Only sample when interesting
      ignore_bins not_interesting = binsof(ARBURST.reserved);
    }
    
    LEN_BURST_CROSS: cross ARLEN, ARBURST {
      // Single beat transfers shouldn't use WRAP
      illegal_bins single_wrap = binsof(ARLEN.single_beat) && binsof(ARBURST.wrap);
    }
  endgroup
  
  // Constructor
  function new(string name, uvm_component parent);
    super.new(name, parent);
    
    // Initialize covergroups
    axi_write_cg = new();
    axi_read_cg = new();
  endfunction
  
  // Build phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    // Create analysis exports and FIFOs
  endfunction

  // Alignment and boundary checking functions
  function bit is_word_aligned(bit [31:0] addr);
    return (addr % 4 == 0);
  endfunction
  
  function bit is_halfword_aligned(bit [31:0] addr);
    return (addr % 2 == 0 && addr % 4 != 0);
  endfunction
  
  function bit is_byte_aligned(bit [31:0] addr);
    return (addr % 2 != 0);
  endfunction
  
  function bit is_4k_boundary(bit [31:0] addr);
    return (addr[11:0] == 0);
  endfunction

  // Write method
  function void write(input axi_seq_item t);
    bit [31:0] awaddr, araddr;
    item = t;
    
    // Sample covergroups
    axi_write_cg.sample(item);
    axi_read_cg.sample(item);
    
    // Manual tracking for address alignments
    awaddr = item.AWADDR;
    araddr = item.ARADDR;
    
    // You can add code here to update custom counters or perform additional checks
    // based on alignment if needed
  endfunction

endclass
