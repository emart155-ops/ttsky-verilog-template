// TinyTapeout Wrapper for Reaction Timer Game
module tt_um_emart155_reaction_timer (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path
    input  wire       ena,      // always 1 when the design is powered
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

    // Internal wires
    wire reset;
    wire start;
    wire react_button;
    wire ready_led;
    wire go_led;
    wire [7:0] result;
    wire [2:0] state;

    // TinyTapeout uses active-low reset (rst_n). 
    // If your reaction_timer module expects active-high, we invert it here:
    assign reset = !rst_n; 

    // Mapping inputs from ui_in
    assign start        = ui_in[0]; 
    assign react_button = ui_in[1];

    // Instantiate your reaction timer
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

    // Mapping outputs to uo_out
    assign uo_out[0] = ready_led;
    assign uo_out[1] = go_led;
    assign uo_out[7:2] = result[5:0]; // Lower 6 bits of result

    // Unused bidirectional pins - set to inputs to be safe
    assign uio_out = 8'b0;
    assign uio_oe  = 8'b0;

endmodule