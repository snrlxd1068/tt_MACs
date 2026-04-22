module linear_accum #(
    parameter IDATAW = 16,
    parameter RESULTW = 32
)(
    input clk,
    input rst_n,
    input working,
    input i_valid,
    input [IDATAW-1:0] in_data,
    output logic signed [RESULTW-1:0] result
);

logic signed [IDATAW-1:0] r_in_data;
logic r_valid;
logic r_working;

always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
        r_working <= 0;
        r_in_data <= 0;
        r_valid <= 0;
        result <= 0;
    end else begin
        r_working <= working;
        if(r_working) begin
            r_valid <= i_valid;
            r_in_data <= in_data;
            if(r_valid) result <= result + r_in_data;
        end
    end
end

endmodule