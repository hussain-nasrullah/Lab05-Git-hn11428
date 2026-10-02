`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/02/2026 09:28:41 AM
// Design Name: 
// Module Name: top_fsm_system
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


module top_fsm_system (
    input wire clk,
    input wire pbin,
    input wire [15:0] physical_sw,
    output wire [15:0] physical_leds
);

    // DEBOUNCER (Cleans up the physical reset button signal)
    wire rst_clean;
  	wire [31:0] switch_data; // hold the value read from the switches
  	reg [31:0] led_write_data = 32'd0; // counter value here
  	wire slow_clk;
  
    debouncer rst_db (
      			.clk(clk),
        		.pbin(pbin), 
      				.pbout(rst_clean)	//generated a clean signal
    ); 

    
    
    leds switch_reader (
      			.clk(clk), .rst(rst_clean),
                    .btns(16'd0),			// Not used for this FSM
                    .writeData(32'd0),			// We don't write to switches
                    .writeEnable(1'b0),			// Disabled
                    .readEnable(1'b1),			// Always ON so we can monitor switches
                    .memAddress(30'd0),       
                    .switches(physical_sw),		// Plug in the physical switches
                    .readData(switch_data)		// output data 
    );
    
    switches led_writer (
                    .clk(clk), .rst(rst_clean),
                    .writeData(led_write_data),
                    .writeEnable(1'b1),         	// Always ON so LEDs update instantly
                    .readEnable(1'b0), .memAddress(30'd0),
                    .readData(),                	// Ignored
                    .leds(physical_leds)      
    );
    
    clock_divider ticker (
                    .clk_in(clk),          		// Feed it the 100MHz fast clock
                    .rst(rst_clean),       		// Feed it the clean reset signal
                    .clk_out(slow_clk)     		// It spits out the 1Hz slow clock!
    );


	// State Encoding
    localparam S0 = 1'b0; // Input Waiting
    localparam S1 = 1'b1; // Countdown

    reg state;
    reg [15:0] counter;

    always @(posedge slow_clk or posedge rst_clean ) begin
        if (rst_clean) begin
            state <= S0;
            counter <= 16'd0;
            led_write_data <= 32'd0;
        end else begin
            case (state)
                S0: begin
                    led_write_data <= 32'd0;
                    
                    if (switch_data[15:0] != 16'd0) begin
                        counter <= switch_data[15:0];
                        state <= S1;
                    end else begin
                        state <= S0;
                    end
                end
                // s
                S1: begin
                    led_write_data <= {16'd0, counter};
                    
                    if (counter > 16'd0) begin
                        counter <= counter - 16'd1;
                        state <= S1;
                    end else begin
                        // Return to idle once counter reaches zero
                        state <= S0;
                    end
                end
                
                default: state <= S0;
            endcase
        end
    end

endmodule

