module MAC_linear #(
    parameter IDATAWIDTH = 8,
    parameter RESULTWIDTH = 32,
    parameter ODATAWIDTH = 8,
    parameter OUTSELECT = int'($ceil(RESULTWIDTH/ODATAWIDTH)),
    parameter OUTSELECTWIDTH = $clog2(OUTSELECT)

)(
    input clk,
    input rst_n,
    input i_valid,
    input signed [IDATAWIDTH-1 : 0] in,
    output logic signed [ODATAWIDTH-1 : 0] out,
    output o_valid,
    output o_ready,
    output [OUTSELECTWIDTH-1:0] section,
    
    // output [IDATAWIDTH-1 : 0] ar, 
    // output [IDATAWIDTH-1 : 0] br
    
);
logic valid [0:2];
logic [OUTSELECT-1:0] o_valid_pipe;
logic signed [IDATAWIDTH-1 : 0] a_reg;
logic signed [IDATAWIDTH-1 : 0] b_reg;
logic signed [IDATAWIDTH*2-1 : 0] mult_reg, mult_wire;
logic signed [RESULTWIDTH-1 : 0] result_reg, result_wire;
logic [OUTSELECTWIDTH-1 : 0] select_id;


always_ff @(posedge clk)begin
    if(!rst_n) begin
        a_reg <= 0; b_reg <= 0; mult_reg <= 0; result_reg <= 0; select_id <= 0;
        valid <= '{default: 0}; o_valid_pipe <= 0;
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
    mult_wire = a_reg * b_reg;
    result_wire = result_reg + mult_reg;

end

logic [ODATAWIDTH-1:0] result_array [0:OUTSELECT-1];
always_comb begin
    for (int j = 0; j < OUTSELECT; j++) begin
        result_array[j] = result_reg[(OUTSELECT-1-j)*ODATAWIDTH +: ODATAWIDTH];//MSB first
    end

    out = result_array[select_id];
end

assign section = select_id;
assign o_valid = |o_valid_pipe;
assign o_ready = !(valid[1]|valid[2]);
assign ar = a_reg;
assign br = b_reg;

endmodule