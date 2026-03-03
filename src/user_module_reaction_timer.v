// TinyTapeout Wrapper for Reaction Timer Game
// This module wraps the reaction_timer to match TinyTapeout's interface
// Interface: io_in[7:0] = inputs, io_out[7:0] = outputs

module user_module_reaction_timer (
    input [7:0] io_in,
    output [7:0] io_out
);

    // Map TinyTapeout interface to reaction timer
    // io_in[0] = clk (will be provided by TinyTapeout)
    // io_in[1] = reset
    // io_in[2] = start button
    // io_in[3] = react_button
    // io_in[7:4] = unused
    
    // io_out[0] = ready_led
    // io_out[1] = go_led
    // io_out[7:2] = result[5:0] (lower 6 bits of result)
    // Note: Full 8-bit result would need more outputs, using 6 bits here
    
    wire clk;
    wire reset;
    wire start;
    wire react_button;
    wire ready_led;
    wire go_led;
    wire [7:0] result;
    wire [2:0] state;
    
    // Extract inputs (assuming clk comes from TinyTapeout separately)
    assign clk = io_in[0];  // May need adjustment based on TinyTapeout's clock routing
    assign reset = io_in[1];
    assign start = io_in[2];
    assign react_button = io_in[3];
    
    // Instantiate reaction timer
    reaction_timer u_reaction_timer (
        .clk(clk),
        .reset(reset),
        .start(start),
        .react_button(react_button),
        .ready_led(ready_led),
        .go_led(go_led),
        .result(result),
        .state(state)
    );
    
    // Map outputs
    assign io_out[0] = ready_led;
    assign io_out[1] = go_led;
    assign io_out[7:2] = result[5:0];  // Lower 6 bits of result
    
endmodule
