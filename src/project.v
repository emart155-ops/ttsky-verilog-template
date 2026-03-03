// Project top-level for simulation in the TinyTapeout template test flow.
// This defines the same top module as specified in info.yaml and wraps
// the reaction timer design.

`default_nettype none

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

    // Active-low reset to active-high for the reaction timer
    assign reset = !rst_n;

    // Map input buttons
    assign start        = ui_in[0];
    assign react_button = ui_in[1];

    // Instantiate the actual reaction timer design
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
    assign uo_out[0] = ready_led;
    assign uo_out[1] = go_led;
    assign uo_out[7:2] = result[5:0];

    // Unused bidirectional IOs
    assign uio_out = 8'b0;
    assign uio_oe  = 8'b0;

endmodule
