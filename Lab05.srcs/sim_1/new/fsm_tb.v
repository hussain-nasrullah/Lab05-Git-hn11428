`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/02/2026 09:32:34 AM
// Design Name: 
// Module Name: fsm_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module fsm_tb();

    // Inputs
    reg clk;
    reg pbin;
    reg [15:0] physical_sw;

    // Outputs
    wire [15:0] physical_leds;

    top_fsm_system uut (
        .clk(clk), 
        .pbin(pbin), 
        .physical_sw(physical_sw), 
        .physical_leds(physical_leds)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        pbin = 1;             
        physical_sw = 16'd0; 
        
        #50;
        pbin = 0;             // Release reset
        
        #100;
        
        physical_sw = 16'd4;
        
        // Wait
        #100;
        
        physical_sw = 16'd0;
        
        #1000;
        
        physical_sw = 16'd10; 
        #100;                
        physical_sw = 16'd0;  
        
        #150;                
        
        pbin = 1;             // reset
        #50;
        pbin = 0;             // Release reset
        
        #200;
        
        $finish;
    end
    
endmodule
