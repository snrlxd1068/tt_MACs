module MAC_log #(
    parameter IINTWIDTH = 3,
    parameter IFRACWIDTH = 4,
    parameter IDATAWIDTH = 1 + IINTWIDTH + IFRACWIDTH,
    parameter RESULTINTWIDTH = 5,
    parameter RESULTFRACWIDTH = 18,
    parameter RESULTWIDTH = 1 + RESULTINTWIDTH + RESULTFRACWIDTH,
    parameter ODATAWIDTH = 8,
    parameter OUTSELECT = int'($ceil(RESULTWIDTH/ODATAWIDTH)),
    parameter OUTSELECTWIDTH = $clog2(OUTSELECT),
    parameter ADDR_WIDTH = 7
)(
    input clk,
    input rst_n,
    input i_valid,
    input signed [IDATAWIDTH-1 : 0] in,
    output logic signed [ODATAWIDTH-1 : 0] out,
    output o_valid,
    output o_ready,
    output [OUTSELECTWIDTH-1:0] section
);

logic valid [0:2];
logic [OUTSELECT-1:0] o_valid_pipe;
logic signed [IDATAWIDTH-1 : 0] a_reg;
logic signed [IDATAWIDTH-1 : 0] b_reg;
logic signed [IDATAWIDTH : 0] mult_reg, mult_wire;
logic signed [RESULTWIDTH-1 : 0] result_reg, result_wire;
logic [OUTSELECTWIDTH-1 : 0] select_id;
logic [ADDR_WIDTH-1 : 0] lut_addr;

always_ff @ (posedge clk) begin
    if(!rst_n) begin
        valid <= '{default:0}; o_valid_pipe <= 0; a_reg <= 0;
        b_reg <= 0; mult_reg <= 0; result_reg <= 0; select_id <= 0;
    end else begin
        if (i_valid && (valid[0] == 0)) a_reg <= in;
        else if (i_valid && (valid[0] == 1)) b_reg <= in;
        if(valid[1]) mult_reg <= mult_wire;
        if(valid[2]) result_reg <= result_wire;
        valid[0] <= valid[0] ^ i_valid;
        valid[1] <= valid[0] & i_valid;
        valid[2] <= valid[1];
        o_valid_pipe <= {o_valid_pipe[OUTSELECT-2:0], valid[2]};
        
        if(|o_valid_pipe == 0) select_id <= 0;
        else select_id <= select_id + 1;
    end
end

always_comb begin
    logic [RESULTWIDTH-2:0] mult_reg_value;
    logic [RESULTWIDTH-2:0] diff;
    logic [ADDR_WIDTH-1:0] temp_addr;
    mult_reg_value = mult_reg[IDATAWIDTH-1:0] << (RESULTFRACWIDTH - IFRACWIDTH);

    mult_wire[IDATAWIDTH] = !(a_reg[IDATAWIDTH-1] ^ b_reg[IDATAWIDTH-1]);
    mult_wire[IDATAWIDTH-1:0] = a_reg[IDATAWIDTH-2:0] + b_reg[IDATAWIDTH-2:0];

    
    if(result_reg[RESULTWIDTH-2:0] > mult_reg_value) begin
        result_wire[RESULTWIDTH-1] = result_reg[RESULTWIDTH-1];
        diff = result_reg[RESULTWIDTH-2:0] - mult_reg_value;
        

        if(result_reg[RESULTWIDTH-1] == mult_reg[IDATAWIDTH])begin
            temp_addr = diff >> (RESULTFRACWIDTH-1);
            lut_addr = (temp_addr > 39)? 39 : temp_addr;
        end else begin
            temp_addr = diff >> (RESULTFRACWIDTH-1) + 40;
            lut_addr = (temp_addr > 79)? 79 : temp_addr;
        end

        result_wire[RESULTWIDTH-2:0] = result_reg[RESULTWIDTH-2:0] + lut_data;

    end else begin
        result_wire[RESULTWIDTH-1] = mult_reg[IDATAWIDTH];
        diff = mult_reg_value - result_reg[RESULTWIDTH-2:0];

        if(result_reg[RESULTWIDTH-1] == mult_reg[IDATAWIDTH])begin
            temp_addr = diff >> (RESULTFRACWIDTH-1);
            lut_addr = (temp_addr > 39)? 39 : temp_addr;
        end else begin
            temp_addr = diff >> (RESULTFRACWIDTH-1) + 40;
            lut_addr = (temp_addr > 79)? 79 : temp_addr;
        end
        
        result_wire[RESULTWIDTH-2:0] = mult_reg_value + lut_data;
    end
end

logic [ODATAWIDTH-1:0] result_array [0:OUTSELECT-1];
always_comb begin
    for (int j = 0; j < OUTSELECT; j++) begin
        result_array[j] = result_reg[(OUTSELECT-1-j)*ODATAWIDTH +: ODATAWIDTH];//MSB first
    end

    out = result_array[select_id];
end

MAC_log_ROM mem (
    .addr(lut_addr),
    .data_out(lut_data)
);

assign section = select_id;
assign o_valid = |o_valid_pipe;
assign o_ready = !valid[1];

endmodule