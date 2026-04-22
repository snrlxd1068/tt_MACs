module log_mult #(
    parameter IINTW = 3,
    parameter IFRACW = 4,
    parameter IDATAW = 1 + IINTW + IFRACW,
    parameter ODATAW = 1 + IDATAW
)(
    input clk,
    input rst_n,
    input [IDATAW-1:0] in_a,
    input [IDATAW-1:0] in_b,
    input i_valid,
    output logic [ODATAW-1:0] result,
    output logic o_valid
); //1bit sign + Q3.4 unsigned

logic [IDATAW-1:0] r_a, r_b;
logic valid;

logic sign_a, sign_b, sign_result;
logic [IDATAW-2:0] val_a, val_b;
logic [IDATAW-1:0] val_result;

assign sign_a = r_a[IDATAW-1];
assign sign_b = r_b[IDATAW-1];
assign val_a = r_a[IDATAW-2:0];
assign val_b = r_b[IDATAW-2:0];

assign sign_result = ~(sign_a ^ sign_b);
assign val_result = val_a + val_b;


always_ff @ (posedge clk) begin
    if(!rst_n) begin
        r_a <= 0;
        r_b <= 0;
        result <= 0;
        o_valid <= 0;
        valid <= 0;
    end else begin
        r_a <= in_a;
        r_b <= in_b;
        result <= {sign_result, val_result};
        valid <= i_valid;
        o_valid <= valid;
    end
end


endmodule
