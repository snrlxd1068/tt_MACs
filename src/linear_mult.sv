module linear_mult #(
    parameter IDATAW = 8,
    parameter ODATAW = 2*IDATAW
)(
    input clk,
    input rst_n,
    input [IDATAW-1:0] in_a,
    input [IDATAW-1:0] in_b,
    input i_valid,
    input working,
    output logic signed [ODATAW-1:0] result,
    output logic o_valid
);

logic signed [IDATAW-1:0] r_a, r_b;
logic valid;
logic r_working;

always_ff @ (posedge clk, negedge rst_n) begin
    if(!rst_n) begin
        r_working <= 0;
        r_a <= 0;
        r_b <= 0;
        result <= 0;
        o_valid <= 0;
        valid <= 0;
    end else begin
        r_working <= working;
        if(r_working) begin
            r_a <= in_a;
            r_b <= in_b;
            result <= r_a * r_b;
            valid <= i_valid;
            o_valid <= valid;
        end
    end
end


endmodule
