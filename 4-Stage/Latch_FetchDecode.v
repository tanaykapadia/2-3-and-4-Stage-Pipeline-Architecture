module Latch_FetchDecode (
    input clk,
    input reset,
    input wire [1:0] stall,
    input wire [31:0] instructionF,
    input wire [31:0] PCF,
    output reg [31:0] instructionD,
    output reg [31:0] PCD
);

always @(posedge clk or posedge reset) begin
    if(stall == 0) begin
        instructionD <= instructionF;
        PCD <= PCF;
    end
end

endmodule