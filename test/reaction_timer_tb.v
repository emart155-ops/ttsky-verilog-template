// Comprehensive testbench for Reaction Timer Game
// Tests all game states and scenarios

`timescale 1ns / 1ps

module reaction_timer_tb;

    // Test signals
    reg clk;
    reg reset;
    reg start;
    reg react_button;
    wire ready_led;
    wire go_led;
    wire [7:0] result;
    wire [2:0] state;

    // Instantiate the reaction timer
    reaction_timer uut (
        .clk(clk),
        .reset(reset),
        .start(start),
        .react_button(react_button),
        .ready_led(ready_led),
        .go_led(go_led),
        .result(result),
        .state(state)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // 100MHz clock (10ns period)
    end

    // Test tracking
    integer test_count = 0;
    integer pass_count = 0;
    integer fail_count = 0;
    integer wait_count;  // Counter for waiting loops

    // Task to check state
    task check_state;
        input [2:0] expected_state;
        input [255:0] test_name;
        begin
            test_count = test_count + 1;
            #10; // Wait for state update
            
            if (state === expected_state) begin
                $display("PASS: %s - State: %b", test_name, state);
                pass_count = pass_count + 1;
            end else begin
                $display("FAIL: %s - Expected state: %b, Got: %b", test_name, expected_state, state);
                fail_count = fail_count + 1;
            end
        end
    endtask

    // Task to check LED output
    task check_leds;
        input expected_ready;
        input expected_go;
        input [255:0] test_name;
        begin
            test_count = test_count + 1;
            #10;
            
            if (ready_led === expected_ready && go_led === expected_go) begin
                $display("PASS: %s - Ready: %b, GO: %b", test_name, ready_led, go_led);
                pass_count = pass_count + 1;
            end else begin
                $display("FAIL: %s - Expected Ready: %b, GO: %b, Got Ready: %b, GO: %b", 
                         test_name, expected_ready, expected_go, ready_led, go_led);
                fail_count = fail_count + 1;
            end
        end
    endtask

    initial begin
        $display("========================================");
        $display("Reaction Timer Game Testbench");
        $display("========================================\n");

        // Initialize signals
        reset = 0;
        start = 0;
        react_button = 0;

        // Test 1: Reset functionality
        $display("--- Testing Reset ---");
        reset = 1;
        #20;
        check_state(3'b000, "Reset - should be IDLE");
        check_leds(0, 0, "Reset - LEDs should be off");
        reset = 0;
        #10;

        // Test 2: Start game - should enter READY state
        $display("\n--- Testing Game Start ---");
        start = 1;
        #20;
        // READY state transitions quickly to WAIT, so check immediately
        if (state == 3'b001 || state == 3'b010) begin
            $display("PASS: Start game - entered READY/WAIT state: %b", state);
            test_count = test_count + 1;
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: Start game - Expected READY/WAIT, Got: %b", state);
            test_count = test_count + 1;
            fail_count = fail_count + 1;
        end
        check_leds(1, 0, "READY/WAIT state - Ready LED on, GO LED off");
        start = 0;
        #10;

        // Test 3: Wait for delay - should enter WAIT state
        $display("\n--- Testing Delay Wait ---");
        start = 1;
        #20;
        start = 0;
        #20;
        // Should transition to WAIT state
        if (state == 3'b010 || state == 3'b001) begin
            $display("PASS: Transitioned to READY/WAIT state");
            test_count = test_count + 1;
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: Unexpected state: %b", state);
            test_count = test_count + 1;
            fail_count = fail_count + 1;
        end

        // Test 4: Too early reaction (press before GO)
        $display("\n--- Testing Too Early Reaction ---");
        reset = 1;
        #20;
        reset = 0;
        #10;
        start = 1;
        #20;
        start = 0;
        #20;  // Wait a bit to ensure we're in READY or WAIT state
        // Press button before GO signal
        react_button = 1;
        #50;
        check_state(3'b100, "Too early - should be TOO_EARLY state");
        if (result == 8'b11111111) begin
            $display("PASS: Too early result code: %d (255)", result);
            test_count = test_count + 1;
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: Expected result 255, got: %d", result);
            test_count = test_count + 1;
            fail_count = fail_count + 1;
        end
        react_button = 0;
        // Press start to reset from TOO_EARLY state
        start = 1;
        #20;
        start = 0;
        #20;

        // Test 5: Normal reaction (wait for GO, then react)
        $display("\n--- Testing Normal Reaction ---");
        reset = 1;
        #20;
        reset = 0;
        #10;
        start = 1;
        #20;
        start = 0;
        
        // Wait for GO signal (wait up to 300 cycles for delay + reaction)
        wait_count = 0;
        while (go_led == 0 && wait_count < 300) begin
            #10;
            wait_count = wait_count + 1;
        end
        
        if (go_led == 1) begin
            $display("PASS: GO signal appeared after delay");
            test_count = test_count + 1;
            pass_count = pass_count + 1;
            
            // Now react quickly
            #20;  // Small delay to measure some reaction time
            react_button = 1;
            #30;
            
            if (state == 3'b101) begin  // DONE state
                $display("PASS: Reacted successfully, entered DONE state");
                $display("  Reaction time: %d clock cycles", result);
                if (result > 0 && result < 255) begin
                    $display("PASS: Valid reaction time recorded: %d", result);
                    test_count = test_count + 1;
                    pass_count = pass_count + 1;
                end else begin
                    $display("FAIL: Invalid reaction time: %d", result);
                    test_count = test_count + 1;
                    fail_count = fail_count + 1;
                end
            end else begin
                $display("FAIL: Did not enter DONE state, current state: %b", state);
                test_count = test_count + 1;
                fail_count = fail_count + 1;
            end
            react_button = 0;
        end else begin
            $display("FAIL: GO signal did not appear within timeout");
            test_count = test_count + 1;
            fail_count = fail_count + 1;
        end

        // Test 6: State transitions
        $display("\n--- Testing State Transitions ---");
        reset = 1;
        #20;
        reset = 0;
        #10;
        check_state(3'b000, "After reset - IDLE");
        
        start = 1;
        #20;
        // READY transitions quickly, so check for READY or WAIT
        if (state == 3'b001 || state == 3'b010) begin
            $display("PASS: After start - READY/WAIT state: %b", state);
            test_count = test_count + 1;
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: After start - Expected READY/WAIT, Got: %b", state);
            test_count = test_count + 1;
            fail_count = fail_count + 1;
        end
        start = 0;
        #20;
        
        // Should transition through states
        if (state == 3'b001 || state == 3'b010) begin
            $display("PASS: State transition working");
            test_count = test_count + 1;
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: Unexpected state transition: %b", state);
            test_count = test_count + 1;
            fail_count = fail_count + 1;
        end

        // Test 7: Multiple game rounds
        $display("\n--- Testing Multiple Rounds ---");
        reset = 1;
        #20;
        reset = 0;
        #10;
        
        // Play first round
        start = 1;
        #20;
        start = 0;
        
        // Wait for GO and react
        wait_count = 0;
        while (go_led == 0 && wait_count < 300) begin
            #10;
            wait_count = wait_count + 1;
        end
        
        if (go_led == 1) begin
            #30;
            react_button = 1;
            #30;
            react_button = 0;
            #20;
            
            // Start second round
            if (state == 3'b101) begin
                // Release start first, then press again
                start = 0;
                #20;
                start = 1;
                #20;
                if (state == 3'b001 || state == 3'b010) begin
                    $display("PASS: Can start new round after completion");
                    test_count = test_count + 1;
                    pass_count = pass_count + 1;
                end else begin
                    $display("FAIL: Cannot start new round, state: %b", state);
                    test_count = test_count + 1;
                    fail_count = fail_count + 1;
                end
                start = 0;
            end else begin
                $display("FAIL: Did not reach DONE state, current state: %b", state);
                test_count = test_count + 1;
                fail_count = fail_count + 1;
            end
        end

        // Test 8: LED behavior in different states
        $display("\n--- Testing LED Behavior ---");
        reset = 1;
        #20;
        reset = 0;
        #10;
        check_leds(0, 0, "IDLE state - both LEDs off");
        
        start = 1;
        #20;
        check_leds(1, 0, "READY state - Ready LED on");
        start = 0;

        // Summary
        $display("\n========================================");
        $display("Test Summary");
        $display("========================================");
        $display("Total tests: %d", test_count);
        $display("Passed:      %d", pass_count);
        $display("Failed:      %d", fail_count);
        $display("========================================");
        
        if (fail_count == 0) begin
            $display("SUCCESS: All tests passed!");
        end else begin
            $display("FAILURE: Some tests failed!");
        end
        $display("========================================\n");
        
        #100;
        $finish;
    end

endmodule
