// Reaction Timer Game - Test Your Reflexes!
// A fun interactive game that measures reaction time
// Inputs: clk, reset, start, react_button
// Outputs: ready_led, go_led, result[7:0], state[2:0]

module reaction_timer (
    input clk,
    input reset,
    input start,           // Start button - begins the game
    input react_button,    // Reaction button - user presses when they see GO
    output reg ready_led,  // LED: Ready to start
    output reg go_led,     // LED: GO signal (user should react)
    output reg [7:0] result,  // Reaction time in clock cycles (0-255)
    output reg [2:0] state    // Current game state (for debugging)
);

    // Game states
    localparam STATE_IDLE     = 3'b000;  // Waiting for start
    localparam STATE_READY    = 3'b001;  // Ready, waiting for random delay
    localparam STATE_WAIT      = 3'b010;  // Waiting for random delay to complete
    localparam STATE_GO        = 3'b011;  // GO signal active, measuring reaction
    localparam STATE_TOO_EARLY = 3'b100; // User pressed too early (before GO)
    localparam STATE_DONE      = 3'b101;  // Reaction time measured, display result

    // Internal signals
    reg [15:0] delay_counter;      // Counter for random delay
    reg [7:0] reaction_counter;   // Counter for reaction time
    reg [7:0] random_seed;         // Seed for pseudo-random delay
    reg delay_done;                // Flag when delay is complete
    reg [7:0] delay_target;        // Target delay value

    // State machine
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= STATE_IDLE;
            ready_led <= 1'b0;
            go_led <= 1'b0;
            result <= 8'b0;
            delay_counter <= 16'b0;
            reaction_counter <= 8'b0;
            delay_done <= 1'b0;
            random_seed <= 8'b10110101;  // Initial seed
            delay_target <= 8'b0;
        end else begin
            case (state)
                STATE_IDLE: begin
                    ready_led <= 1'b0;
                    go_led <= 1'b0;
                    result <= 8'b0;
                    delay_counter <= 16'b0;
                    reaction_counter <= 8'b0;
                    delay_done <= 1'b0;
                    
                    if (start) begin
                        state <= STATE_READY;
                        ready_led <= 1'b1;
                        // Generate random delay (using LFSR)
                        random_seed <= {random_seed[6:0], random_seed[7] ^ random_seed[5] ^ random_seed[4] ^ random_seed[0]};
                        // Delay between 50 and 200 clock cycles (adjustable)
                        delay_target <= 50 + (random_seed % 150);
                    end
                end

                STATE_READY: begin
                    ready_led <= 1'b1;
                    go_led <= 1'b0;
                    
                    // Check if user pressed too early
                    if (react_button) begin
                        state <= STATE_TOO_EARLY;
                        result <= 8'b11111111;  // Error code: 255 = too early
                        ready_led <= 1'b0;
                    end else begin
                        // Stay in READY for one cycle, then move to WAIT
                        state <= STATE_WAIT;
                        delay_counter <= 16'b0;
                    end
                end

                STATE_WAIT: begin
                    ready_led <= 1'b1;
                    go_led <= 1'b0;
                    
                    // Check if user pressed too early
                    if (react_button) begin
                        state <= STATE_TOO_EARLY;
                        result <= 8'b11111111;  // Error code: 255 = too early
                    end else if (delay_counter >= delay_target) begin
                        state <= STATE_GO;
                        go_led <= 1'b1;
                        ready_led <= 1'b0;
                        reaction_counter <= 8'b0;
                    end else begin
                        delay_counter <= delay_counter + 1;
                    end
                end

                STATE_GO: begin
                    ready_led <= 1'b0;
                    go_led <= 1'b1;
                    
                    if (react_button) begin
                        // User reacted! Record the time
                        state <= STATE_DONE;
                        result <= reaction_counter;
                        go_led <= 1'b0;
                    end else begin
                        // Still measuring reaction time
                        if (reaction_counter < 8'b11111111) begin
                            reaction_counter <= reaction_counter + 1;
                        end else begin
                            // Timeout - too slow
                            state <= STATE_DONE;
                            result <= 8'b11111110;  // Error code: 254 = too slow
                            go_led <= 1'b0;
                        end
                    end
                end

                STATE_TOO_EARLY: begin
                    ready_led <= 1'b0;
                    go_led <= 1'b0;
                    // Wait for start to be pressed again to reset
                    if (start) begin
                        state <= STATE_IDLE;
                    end
                end

                STATE_DONE: begin
                    ready_led <= 1'b0;
                    go_led <= 1'b0;
                    // Display result, wait for start to begin new game
                    if (start) begin
                        state <= STATE_READY;
                        ready_led <= 1'b1;
                        // Generate new random delay
                        random_seed <= {random_seed[6:0], random_seed[7] ^ random_seed[5] ^ random_seed[4] ^ random_seed[0]};
                        delay_target <= 50 + (random_seed % 150);
                        delay_counter <= 16'b0;
                        reaction_counter <= 8'b0;
                        delay_done <= 1'b0;
                    end
                end

                default: begin
                    state <= STATE_IDLE;
                end
            endcase
        end
    end

endmodule
