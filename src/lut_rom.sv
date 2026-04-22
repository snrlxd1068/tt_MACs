module lut_rom #(
    parameter DATAW = 28,
    parameter DEPTH = 40,
    parameter ADDRW = $clog2(DEPTH)
)(
    input [ADDRw-1:0] addr,
    output [DATAW-1:0] data_out
);

logic [DATAW-1:0] mem [0:DEPTH-1];

initial begin
    $readmemh("log_lut.mem", mem);
end

assign data_out = mem[addr];

endmodule




