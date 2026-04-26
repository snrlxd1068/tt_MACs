module log_accum_lut #(
    parameter IINTW = 4,
    parameter IFRACW = 4,
    parameter IDATAW = 1 + IINTW + IFRACW,
    parameter RESULTINTW = 5,
    parameter RESULTFRACW = 26,
    parameter RESULTW = 1 + RESULTINTW + RESULTFRACW,
    parameter LUTINTW = 2,
    parameter LUTFRACW = 26,
    parameter LUTW = LUTINTW + LUTFRACW,
    parameter DSTEP = 1,
    parameter DMAX = 20,
    parameter LUTDEPTH = DMAX,
    parameter MEMDEPTH = 2*LUTDEPTH,
    parameter ADDRW = $clog2(MEMDEPTH)

)(
    input clk,
    input rst_n,
    input i_valid,
    input [IDATAW-1:0] in_data,
    input working,
    output logic [RESULTW-1:0] result
);

logic [IDATAW-1:0] r_in_data;
logic r_valid;
logic [RESULTW-1:0] w_result;
logic r_working;

logic R_sign;
logic signed [RESULTW-2:0] R_val;
assign w_result = {R_sign, R_val};


always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
        r_in_data <= 0;
        result <= 0;
        r_valid <= 0;
        r_working <= 0;
    end else begin
        r_working <= working;
        if(r_working) begin
            r_valid <= i_valid;
            r_in_data <= in_data;
            if(r_valid) begin
                result <= w_result;
            end
        end
    end
end

logic signed [RESULTW-2:0] X_val; // log value of absolute(X)
assign X_val = result[RESULTW-2:0];

logic X_sign; // sign of X
assign X_sign = result[RESULTW-1];


logic signed [RESULTW-2:0] Y_val; // log value of absolute(Y)
assign Y_val = {{(RESULTINTW - IINTW){r_in_data[IDATAW-2]}},r_in_data[IDATAW-2:0],{(RESULTFRACW - IFRACW){1'b0}}}; // input data aligned

logic Y_sign; // sign of Y
assign Y_sign = r_in_data[IDATAW-1];

assign R_sign = (X_val > Y_val)? X_sign: Y_sign;

logic [RESULTW-2:0] diff;
logic [RESULTW-2:0] scaled_diff;

always_comb begin
    if (X_val > Y_val) begin
        diff = (X_val - Y_val);
    end else begin
        diff = (Y_val - X_val);
    end
    if (diff[RESULTW-2] == 1) diff = {1'b0,{(RESULTW-2){1'b1}}}; //overflow
    scaled_diff = diff >> RESULTFRACW;
    diff = (scaled_diff > (DMAX-1)*DSTEP)? (DMAX-1)*DSTEP : scaled_diff[4:0];
end
logic [ADDRW-1:0] addr;

assign addr = (X_sign == Y_sign)? (diff) : (diff + LUTDEPTH);// ? delta_plus : delta_minus

logic signed [RESULTW-2:0] delta;
logic signed [LUTW-1:0] lut_delta;
assign delta = {{(RESULTW-LUTW-1){lut_delta[LUTW-1]}},lut_delta};

lut_rom #(
    .DATAW(LUTW),
    .DEPTH(MEMDEPTH)
) lut_rom_inst (
    .addr(addr),
    .data(lut_delta)
);
always_comb begin
    R_val = (X_val > Y_val)? (X_val + delta) : (Y_val + delta);
    if (R_val[RESULTW-2] == 1 && X_val[RESULTW-2] == 0 && delta[RESULTW-2] == 0) begin
        R_val = {1'b0, {(RESULTW-2){1'b1}}};
    end else if (R_val[RESULTW-2] == 0 && X_val[RESULTW-2] == 1 && delta[RESULTW-2] == 1) begin
        R_val = {1'b1, {(RESULTW-2){1'b0}}};
    end
end

endmodule