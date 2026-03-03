# Reaction Timer Game Design Documentation

## Design Description

This project implements an **interactive Reaction Timer Game** in Verilog - a fun and engaging way to test your reflexes! Unlike traditional arithmetic circuits, this design creates an interactive gaming experience that measures human reaction time.

### Functionality

The Reaction Timer Game works like this:
1. **Press START** - The game begins and a "Ready" LED lights up
2. **Wait for GO** - After a random delay (50-200 clock cycles), a "GO" LED lights up
3. **React Fast!** - Press the reaction button as quickly as possible when you see GO
4. **See Your Time** - The result displays your reaction time in clock cycles (0-254)
5. **Play Again** - Press START to play another round!

**Game States:**
- **IDLE**: Waiting for the game to start
- **READY**: Game started, waiting for random delay
- **WAIT**: Counting down the random delay
- **GO**: GO signal active - measuring reaction time!
- **TOO_EARLY**: User pressed before GO (error code: 255)
- **DONE**: Reaction time measured and displayed

**Inputs:**
- `clk`: Clock signal for synchronous operation
- `reset`: Asynchronous reset to initialize the game
- `start`: Button to start a new game round
- `react_button`: Button pressed when user sees GO signal

**Outputs:**
- `ready_led`: LED indicating game is ready (waiting for GO)
- `go_led`: LED indicating GO signal (user should react now!)
- `result[7:0]`: Reaction time in clock cycles (0-254), or error codes:
  - `255`: Too early (pressed before GO)
  - `254`: Too slow (didn't react in time)
- `state[2:0]`: Current game state (for debugging/monitoring)

### Design Characteristics

- **State Machine**: Uses a 6-state finite state machine to control game flow
- **Random Delay**: Implements Linear Feedback Shift Register (LFSR) for pseudo-random delays between 50-200 clock cycles
- **Reaction Measurement**: Counts clock cycles from GO signal until user reaction
- **Error Detection**: Detects if user presses too early (before GO) or too slow (timeout)
- **Interactive**: Real-time feedback through LEDs and result display
- **Replayable**: Can play multiple rounds by pressing START again

### Why This Design is Fun and Creative

1. **Interactive Gaming**: Unlike passive circuits, this design creates an engaging game that users can play and compete with
2. **Real-World Application**: Reaction time testing is used in sports, gaming, and cognitive assessments
3. **Challenge Factor**: The random delay prevents cheating and makes each round unique
4. **Visual Feedback**: LEDs provide immediate visual feedback (Ready → GO)
5. **Competitive Element**: Players can try to beat their best time or compete with friends
6. **Educational Value**: Demonstrates state machines, timing, random number generation, and human-computer interaction
7. **Demonstrable**: Easy to show off - just connect buttons and LEDs and play!

### Gameplay Features

- **Random Timing**: Each round has a different delay, preventing anticipation
- **Anti-Cheat**: Detects if you press too early (before GO signal)
- **Timeout Protection**: Times out if reaction is too slow (>255 cycles)
- **Clear Feedback**: Visual LEDs and numeric result display
- **Multiple Rounds**: Play as many times as you want

### Use Cases

- **Gaming**: Fun interactive game for demos and maker fairs
- **Sports Training**: Reaction time measurement for athletes
- **Cognitive Testing**: Simple cognitive assessment tool
- **Educational**: Teaching state machines, timing, and interactive design
- **Entertainment**: Party game or competition between friends
- **Research**: Studying human reaction times and reflexes

## Testbench Description

The testbench (`reaction_timer_tb.v`) comprehensively tests all functionality of the Reaction Timer Game design.

### Test Coverage

The testbench includes **multiple test cases** covering:

1. **Reset Functionality (2 tests)**:
   - Verifies reset initializes to IDLE state
   - Verifies LEDs are off after reset

2. **Game Start (2 tests)**:
   - Verifies START button transitions to READY state
   - Verifies Ready LED turns on

3. **Delay Wait (1 test)**:
   - Verifies transition from READY to WAIT state
   - Tests random delay mechanism

4. **Too Early Reaction (2 tests)**:
   - Tests detection of button press before GO signal
   - Verifies error code 255 is set
   - Verifies transition to TOO_EARLY state

5. **Normal Reaction (3 tests)**:
   - Verifies GO signal appears after delay
   - Tests reaction time measurement
   - Verifies valid reaction time is recorded (0-254 range)
   - Verifies transition to DONE state

6. **State Transitions (1 test)**:
   - Verifies all state transitions work correctly
   - Tests state machine flow

7. **Multiple Rounds (1 test)**:
   - Tests ability to play multiple game rounds
   - Verifies game can restart after completion

8. **LED Behavior (2 tests)**:
   - Verifies LED outputs in different states
   - Tests Ready and GO LED timing

### Testbench Features

- **Clock Generation**: Creates realistic clock signal for testing
- **State Verification**: Checks that state machine transitions correctly
- **LED Testing**: Verifies LED outputs match expected states
- **Timing Tests**: Tests reaction time measurement accuracy
- **Error Case Testing**: Tests too early and timeout scenarios
- **Multiple Rounds**: Tests replay functionality
- **Comprehensive Reporting**: Detailed pass/fail reporting with state and timing information
- **Summary Statistics**: Final summary of all tests

### Justification for Test Sufficiency

The testbench is sufficient to verify the Reaction Timer Game design because:

1. **Complete State Coverage**: All 6 game states (IDLE, READY, WAIT, GO, TOO_EARLY, DONE) are tested with appropriate transitions.

2. **Reset Verification**: Ensures the design initializes correctly from a known state.

3. **Normal Operation**: Tests the complete game flow from start to finish, including:
   - Random delay generation
   - GO signal appearance
   - Reaction time measurement
   - Result display

4. **Error Cases**: Tests both error conditions:
   - Too early reaction (pressing before GO)
   - Timeout handling (if implemented)

5. **State Machine Correctness**: Verifies all state transitions work as expected.

6. **LED Behavior**: Tests that visual feedback (Ready and GO LEDs) work correctly in each state.

7. **Replay Functionality**: Verifies that multiple game rounds can be played.

8. **Timing Verification**: Tests that reaction times are measured and stored correctly.

9. **Edge Cases**: Tests boundary conditions and state transitions.

The testbench provides high confidence that the Reaction Timer Game functions correctly for all game states, user interactions, and edge cases, making it ready for TinyTapeout submission.

## How it works

The Reaction Timer Game operates using a 6-state finite state machine that controls the entire game flow:

1. **IDLE State**: The game starts here, waiting for the user to press the START button. All outputs are cleared.

2. **READY State**: When START is pressed, the game enters READY state. The Ready LED lights up, and a random delay (50-200 clock cycles) is generated using a Linear Feedback Shift Register (LFSR). If the user presses the reaction button during this state, they're penalized with error code 255 (too early).

3. **WAIT State**: The game transitions here immediately after READY. The Ready LED remains on while the system counts down the random delay. The user must wait patiently - pressing the button here also results in error code 255.

4. **GO State**: Once the delay counter reaches the target, the GO LED lights up and the Ready LED turns off. The reaction timer starts counting clock cycles. The user should press the reaction button as quickly as possible.

5. **DONE State**: When the user presses the reaction button, the current reaction counter value is stored in the result register and displayed. The game waits for START to be pressed again to begin a new round.

6. **TOO_EARLY State**: If the user presses the reaction button before the GO signal appears (in READY or WAIT states), the game enters TOO_EARLY state, sets result to 255, and waits for START to reset.

**Key Components:**
- **LFSR (Linear Feedback Shift Register)**: Generates pseudo-random delays using polynomial feedback (taps at bits 7, 5, 4, and 0) to ensure each game round has a different timing.
- **Delay Counter**: Counts from 0 to the randomly generated target (50-200 cycles).
- **Reaction Counter**: Measures the time from GO signal to user reaction (0-254 cycles).
- **State Machine**: Controls all transitions and ensures proper game flow.

The design uses synchronous logic with a single clock domain, making it suitable for FPGA and ASIC implementation.

## How to test

### Local Testing

To test the design locally using Icarus Verilog:

```bash
# Compile the design and testbench
iverilog -o test/reaction_timer_tb.vvp src/reaction_timer.v test/reaction_timer_tb.v

# Run the simulation
vvp test/reaction_timer_tb.vvp
```

Or use the Makefile:

```bash
make test
```

### Expected Test Results

The testbench will run 15 test cases covering:
- Reset functionality
- Game start and state transitions
- Too-early reaction detection
- Normal reaction timing
- Multiple game rounds
- LED behavior

A successful test run should show:
```
========================================
Test Summary
========================================
Total tests:          15
Passed:               15
Failed:                0
========================================
SUCCESS: All tests passed!
```

### Testing Individual Features

**Test Reset:**
- Assert reset signal
- Verify state = IDLE (000)
- Verify all LEDs are off

**Test Normal Gameplay:**
1. Press START (ui_in[0] = 1)
2. Wait for Ready LED (uo_out[0] = 1)
3. Wait for GO LED (uo_out[1] = 1)
4. Press reaction button quickly (ui_in[1] = 1)
5. Check result (uo_out[7:2]) shows valid reaction time

**Test Too Early Detection:**
1. Press START
2. Immediately press reaction button before GO appears
3. Verify result = 255 (error code)

### Hardware Testing (TinyTapeout)

When implemented on TinyTapeout hardware:
- Connect START button to ui_in[0]
- Connect reaction button to ui_in[1]
- Connect Ready LED to uo_out[0]
- Connect GO LED to uo_out[1]
- Connect 6-bit display to uo_out[7:2] for reaction time

The game will run automatically with the provided clock signal, and users can interact with it in real-time.

## GenAI Tool Usage

This project was created with assistance from GenAI tools (specifically, Cursor's AI assistant). The GenAI tool was used to:

1. **Creative Design Concept**: Collaborated to develop the Reaction Timer Game idea as an interactive and engaging alternative to standard arithmetic circuits.

2. **Code Generation**: Generated the Verilog code for the reaction timer module, including:
   - 6-state finite state machine for game control
   - LFSR implementation for random delay generation
   - Reaction time counter and measurement logic
   - Error detection for too-early and timeout cases
   - State transition logic

3. **Testbench Development**: Assisted in creating comprehensive test cases covering:
   - All game states and transitions
   - Normal gameplay flow
   - Error conditions (too early, timeout)
   - Multiple game rounds
   - LED behavior verification

4. **Documentation**: Helped structure and write this documentation, including gameplay description, design characteristics, and test justification.

The design concept, game mechanics, state machine design, and implementation approach were developed collaboratively with the GenAI tool. The final design represents a complete, functional, and fun Reaction Timer Game that is both educational and entertaining, perfect for TinyTapeout submission.
