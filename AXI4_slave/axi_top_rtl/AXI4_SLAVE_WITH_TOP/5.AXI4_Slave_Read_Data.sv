module axi4_slave_read_data 
#(
//=========================PARAMETERS=============================
      parameter DATA_WIDTH = 32,
      parameter ADDR_WIDTH = 32,
      parameter ID_WIDTH   = 4,
      parameter BURST_LENGTH = 8
) (
//=========================INPUT SIGNALS===========================
      input      logic                              clk,
      input      logic                              rst,

      input logic [ADDR_WIDTH-1:0]                  latched_araddr,       
      input logic [ID_WIDTH-1:0]                    latched_arid,         
      input logic [7:0]                             latched_arlen,        
      input logic [2:0]                             latched_arsize,      
      input logic [1:0]                             latched_arburst,
    
      input       logic                              arvalid,
      input       logic                              arready,
      output      logic                              rvalid,      
      output      logic    [DATA_WIDTH - 1 : 0]      rdata,       
      output      logic    [ID_WIDTH  - 1 : 0]       rid,         
      output      logic                              rlast,       
      output      logic    [1:0]                     rresp,

//=========================OUTPUT SIGNALS==========================
    input  logic                   rready,
    output logic                   mem_rd_en,          
    output logic [ADDR_WIDTH-1:0]  mem_addr,           
    input  logic [DATA_WIDTH-1:0]  mem_rd_data 
       
);
//=========================FSM STATES==============================
      typedef enum logic   [1:0] {
                                    R_IDLE        = 2'b00,
                                    R_READ_MEM    = 2'b01,
                                    R_SEND_DATA   = 2'b10
                                  } FMS_STATE;
       FMS_STATE present_state,next_state;

   
    //===================== INTERNAL REGISTERS / LOGIC =====================
    logic [7:0]            beats_remaining;  
    logic [ADDR_WIDTH-1:0] current_addr;     
    logic [ID_WIDTH-1:0]   active_rid;       
    logic [2:0]            active_arsize;    
    logic [1:0]            active_arburst;   
    logic                  rvalid_reg;       
    logic                  rvalid_next;      
    logic [DATA_WIDTH-1:0] rdata_reg;        
    logic                  burst_active;     
    logic [1:0]            rresp_reg;        


    logic [ADDR_WIDTH-1:0] wrap_boundary;
    logic [ADDR_WIDTH-1:0] upper_addr_limit;
    logic [$clog2(DATA_WIDTH/8):0] num_bytes;
    logic                  is_last_beat;

    assign num_bytes = 1 << active_arsize;
    assign is_last_beat = (beats_remaining == 1) && burst_active;
    assign rid      = active_rid;      
    assign rdata    = rdata_reg;       
    assign rresp    = rresp_reg;       
    assign mem_addr = current_addr;
    assign rlast    = is_last_beat && rvalid_reg;

    always_comb begin
        next_state   = present_state; 
        rvalid_next    = 1'b0;        
        mem_rd_en      = 1'b0;        

        case (present_state)
            R_IDLE: begin
                rvalid_next = 1'b0;
                mem_rd_en   = 1'b0;
                if (arvalid && arready) begin
                    next_state = R_READ_MEM;
                end else begin
                    next_state = R_IDLE;
                end
            end

            R_READ_MEM: begin 
                rvalid_next = 1'b1;
                mem_rd_en   = 1'b0; 
                next_state = R_SEND_DATA; 
            end

            R_SEND_DATA: begin 
                mem_rd_en   = 1'b1; 
                rvalid_next = 1'b1; 

                if (rvalid_reg && rready) begin 
                    if (!is_last_beat) begin
                        next_state = R_READ_MEM;
                    end else begin
                        next_state = R_IDLE;
                    end
                end else begin
                    next_state = R_SEND_DATA;
                    rvalid_next  = 1'b1; 
                end
            end

            default: begin
                next_state = R_IDLE;
                rvalid_next  = 1'b0;
                mem_rd_en    = 1'b0;
            end
        endcase
    end // end always_comb


    //====================== SEQUENTIAL LOGIC ==========================

    // State Register
    always_ff @(posedge clk or negedge rst) begin
        if (!rst) begin
            present_state <= R_IDLE;
        end else begin
            present_state <= next_state;
        end
    end
    
always_ff @(posedge clk or negedge rst) begin
        if (!rst) begin
             active_rid      <= '0;
            end else if(rvalid_next) begin
            active_rid      <= latched_arid;
            end
            end



    // Burst Parameter Latching, Counter, Address Calculation, Data Latching
    always_ff @(posedge clk or negedge rst) begin
        if (!rst) begin
            burst_active    <= 1'b0;
            beats_remaining <= '0;
            active_arsize   <= '0;            
            rdata_reg       <= {DATA_WIDTH{1'b0}};
            active_arburst  <= '0;
            current_addr    <= '0;
            rresp_reg       <= 2'b00; 
            wrap_boundary   <= '0;
            upper_addr_limit<= '0;
        end else begin
                    rdata_reg       <= {DATA_WIDTH{1'b0}};

            if (arvalid && arready) begin
                           rdata_reg       <= {DATA_WIDTH{1'b0}};
 
                burst_active    <= 1'b1;
                beats_remaining <= latched_arlen + 1; 
                current_addr    <= latched_araddr;    
                active_arsize   <= latched_arsize;
                active_arburst  <= latched_arburst;
                rresp_reg       <= 2'b00; 
                
                if (latched_arburst == 2'b10) begin 
                    logic [$clog2(DATA_WIDTH/8):0] size_in_bytes; 
                    logic [ADDR_WIDTH:0]           burst_len_bytes;
                    size_in_bytes = 1 << latched_arsize;
                    burst_len_bytes = size_in_bytes * (latched_arlen + 1);
                    if (burst_len_bytes > 0) begin
                         wrap_boundary = (latched_araddr / burst_len_bytes) * burst_len_bytes;
                    end else begin
                         wrap_boundary = latched_araddr; 
                    end
                    upper_addr_limit = wrap_boundary + burst_len_bytes - size_in_bytes;
                end
            end

            if (present_state == R_READ_MEM) begin
                rdata_reg <= mem_rd_data;
            end

            if (present_state == R_SEND_DATA && rvalid_reg && rready) begin
                if (beats_remaining > 0) begin
                    beats_remaining <= beats_remaining - 1;
                end

                if (!is_last_beat) begin
                    case (active_arburst)
                        2'b00: current_addr <= current_addr;
                        2'b01: current_addr <= current_addr + num_bytes; 
                        2'b10: begin 
                             if (current_addr == upper_addr_limit) begin
                                 current_addr <= wrap_boundary;
                             end else begin
                                 current_addr <= current_addr + num_bytes;
                             end
                        end
                        default: begin 
                            current_addr <= current_addr;
                        end
                    endcase
                end 
            end 
              if (burst_active && next_state == R_IDLE && present_state == R_SEND_DATA) begin
                 if (rvalid_reg && rready) begin
                     burst_active <= 1'b0;
                 end
            end
            rvalid_reg <= rvalid_next;
        end 
    end 


    assign rvalid = rvalid_reg;

endmodule
