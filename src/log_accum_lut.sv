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
    parameter DSTEP = 0, // 1 step width = 2**DSTEP
    parameter NDSTEP = 20, // total number of steps
    parameter LUTDEPTH = NDSTEP,
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

logic [RESULTW-2:0] diff_raw;
assign diff_raw = (X_val > Y_val) ? (X_val - Y_val) : (Y_val - X_val);

logic diff_msb;
assign diff_msb = diff_raw[RESULTW-2];

logic [RESULTW-2:0] diff_saturated;
assign diff_saturated = diff_msb ? {1'b0, {(RESULTW-2){1'b1}}} : diff_raw;

logic [RESULTW-2:0] scaled_diff; //difference scaled to number of dsteps
assign scaled_diff = diff_saturated >> (RESULTFRACW + DSTEP);

logic [ADDRW-1:0] addr;

always_comb begin
    if (scaled_diff > (NDSTEP - 1)) begin
        addr = (NDSTEP - 1);
    end else begin
        addr = scaled_diff[ADDRW-1:0];
    end
    if (X_sign != Y_sign) begin
        addr = addr + LUTDEPTH;
    end
end


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
logic signed [RESULTW-1:0] R_val_tmp;

logic signed [RESULTW-2:0] max_val;
assign max_val = (X_val > Y_val) ? X_val : Y_val;

assign R_val_tmp = max_val + delta;

logic [1:0] sign_bits;
assign sign_bits = R_val_tmp[RESULTW-1 : RESULTW-2]; // Bits [31:30]

always_comb begin
    case (sign_bits)
        2'b01:   R_val = {1'b0, {(RESULTW-2){1'b1}}}; // Positive Overflow (Max Positive)
        2'b10:   R_val = {1'b1, {(RESULTW-2){1'b0}}}; // Negative Overflow (Max Negative)
        default: R_val = R_val_tmp[RESULTW-2:0];      // No Overflow: Normal result
    endcase
end

endmodule