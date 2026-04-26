module lut_rom #(
    parameter DATAW = 28,
    parameter DEPTH = 40,
    parameter ADDRW = $clog2(DEPTH)
)(
    input [ADDRW-1:0] addr,
    output logic [DATAW-1:0] data
);

always_comb begin
    case (addr)
        // Positive Results (Indices 0-19)
        6'd0  : data = 'h3161212;
        6'd1  : data = 'h1BF3BDD;
        6'd2  : data = 'h0F07A0D;
        6'd3  : data = 'h07D2045;
        6'd4  : data = 'h03FE32B;
        6'd5  : data = 'h02049FD;
        6'd6  : data = 'h0103B94;
        6'd7  : data = 'h008237F;
        6'd8  : data = 'h004132F;
        6'd9  : data = 'h00209F3;
        6'd10 : data = 'h0010511;
        6'd11 : data = 'h000828E;
        6'd12 : data = 'h0004149;
        6'd13 : data = 'h00020A5;
        6'd14 : data = 'h0001052;
        6'd15 : data = 'h0000829;
        6'd16 : data = 'h0000415;
        6'd17 : data = 'h000020A;
        6'd18 : data = 'h0000105;
        6'd19 : data = 'h0000083;

        // Negative Results (Indices 20-39)
        6'd20 : data = 'h8E9EDEE;
        6'd21 : data = 'hD7B7F63;
        6'd22 : data = 'hEE09ECA;
        6'd23 : data = 'hF77497D;
        6'd24 : data = 'hFBD3973;
        6'd25 : data = 'hFDEFD4D;
        6'd26 : data = 'hFEF9641;
        6'd27 : data = 'hFF7D0F6;
        6'd28 : data = 'hFFBE9EF;
        6'd29 : data = 'hFFDF554;
        6'd30 : data = 'hFFEFAC1;
        6'd31 : data = 'hFFF7D66;
        6'd32 : data = 'hFFFBEB5;
        6'd33 : data = 'hFFFDF5B;
        6'd34 : data = 'hFFFEFAD;
        6'd35 : data = 'hFFFF7D7;
        6'd36 : data = 'hFFFFBEB;
        6'd37 : data = 'hFFFFDF6;
        6'd38 : data = 'hFFFFEFB;
        6'd39 : data = 'hFFFFF7D;
        default : data = 'h0000000;
    endcase
end

endmodule




