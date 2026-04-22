module MAC_linear #(
    parameter IDATAW = 8,
    parameter IINTW = 3,
    parameter IFRACW = 4,
    parameter RESULTW = 32,
    parameter RESULTINTW = 5,
    parameter RESULTFRACW = 26,
    parameter ODATAW = 8,
    parameter DSTEP = 1,
    parameter DMAX = 20,
    parameter NUMOUTCHUNKS = int'($ceil(RESULTW/ODATAW)),
    parameter OUTSELW = $clog2(NUMOUTCHUNKS)

)(
    input clk,
    input rst_n,
    input [1:0] i_mode, // 00:linear, 10:log_lut, 11:log_shift
    input i_valid,
    input i_key, // a or b
    input [IDATAW-1:0] i_data,
    output logic signed [ODATAW-1:0] o_data,
    output logic [OUTSELW-1:0] o_section,// or a starting flag
);

logic r_valid, both_valid;
logic r_key;
logic [1:0] r_mode;
logic [IDATAW-1:0] r_i_data;
logic [IDATAW-1:0] r_valid_data_buffer, w_valid_data_buffer;
enum logic [1:0] {INIT=2'b00, A_VALID=2'b01, B_VALID=2'b10} state, nextstate;



always_ff @(posedge clk) begin
    if(!rst_n) begin
        r_valid <= 0;
        r_key <= 0;
        r_mode <= 0;
        r_i_data <= 0;
        state <= 0;
        r_valid_data_buffer <= 0;
    end else begin
        r_valid <= i_valid;
        r_key <= i_key;
        r_mode <= i_mode;
        r_i_data <= i_data;
        state <= nextstate;
        r_valid_data_buffer <= w_valid_data_buffer;
    end
end

logic [IDATAW-1:0] w_a_data, w_b_data; //data signals feeding to multiplier module

always_comb begin
    both_valid = 0;
    w_a_data = 0;
    w_b_data = 0;
    case(state)
        INIT: begin
            if(r_valid) begin
                w_valid_data_buffer = r_i_data;
                nextstate = (r_key == 0)? A_VALID : B_VALID;
            end else nextstate = INIT;
        end
        A_VALID: begin
            w_a_data = r_valid_data_buffer;
            if(r_valid && r_key == 1) begin
                w_b_data = r_i_data;
                both_valid = 1;
                nextstate = INIT;
            end
            else begin
                nextstate = A_VALID;
                w_valid_data_buffer = r_valid_data_buffer;
            end
        end
        B_VALID: begin
            w_b_data = r_valid_data_buffer;
            if(r_valid && r_key == 0) begin
                w_a_data = r_i_data;
                both_valid = 1;
                nextstate = INIT;
            end
            else begin
                nextstate = B_VALID;
                w_valid_data_buffer = r_valid_data_buffer;
            end
        end
        default: begin
            nextstate = INIT;
        end
    endcase
end

localparam PADDEDW = NUMOUTCHUNKS * ODATAW;
localparam PADBITS = PADDEDW - RESULTW;
logic [PADDEDW-1:0] padded_result;

logic [RESULTW-1:0] r_result, w_result;
assign padded_result = {{PADBITS{1'b0}}, r_result};

logic [OUTSELW-1] out_counter;

always_ff @(posedge clk) begin
    if(~rst_n) begin
        o_data <= 0;
        o_section <= 0;
        r_result <= 0;
        out_counter <= 0;
    end
    else begin
        r_result <= (out_counter == (NUMOUTCHUNKS - 1))? w_result : r_result;
        out_counter <= (out_counter < (NUMOUTCHUNKS - 1))? (out_counter + 1) : 0;
        o_section <= out_counter;
        o_data <= padded_result[(PADDEDW-1)-(out_counter*ODATAW) -: ODATAW];
    end
end




logic linear_mult_valid;
logic [IDATAW*2-1:0] linear_mult_result;

linear_mult #(
    .IDATAW(IDATAW)
)(
    .clk(clk),
    .rst_n(rst_n),
    .in_a(w_a_data),
    .in_b(w_b_data),
    .i_valid(both_valid),
    .result(linear_mult_result),
    .o_valid(linear_mult_valid)
)
linear_accum #(
    .IDATAW(2*IDATAW),
    .RESULTW(RESULTW),
)(
    .clk(clk),
    .rst_n(rst_n),
    .i_valid(linear_mult_valid),
    .in_data(linear_mult_result),
    .result(linear_result),
    .o_valid(),
)

logic log_mult_valid;
logic [IDATAW:0] log_mult_result;

log_mult #(
    .IINTW(IINTW),
    .IFRACW(IFRACW)
)(
    .clk(clk),
    .rst_n(rst_n),
    .in_a(w_a_data),
    .in_b(w_b_data),
    .i_valid(both_valid),
    .result(log_mult_result),
    .o_valid(log_mult_valid)
);
log_accum_lut #(
    .IINTW(IINTW),
    .IFRACW(IFRACW),
    .RESULTINTW(RESULTINTW),
    .RESULTFRACW(RESULTFRACW),
    .DEPTH(DEPTH)
)(
    .clk(clk),
    .rst_n(rst_n),
    .i_valid(log_mult_valid),
    .in_data(log_mult_result),
    .result(lut_result),
    .o_valid()
);
log_accum_shift #(
    .IINTW(IINTW),
    .IFRACW(IFRACW),
    .RESULTINTW(RESULTINTW),
    .RESULTFRACW(RESULTFRACW),
)(
    .clk(clk),
    .rst_n(rst_n),
    .i_valid(log_mult_valid),
    .in_data(log_mult_result),
    .result(shift_result),
    .o_valid()
);

endmodule