Reaction Timer Game Design Documentation
Design Overview

This project implements a single-player Reaction Timer Game in Verilog using a synchronous finite state machine (FSM). The design measures the number of clock cycles between a visual GO signal and a user button press, providing a hardware-based reaction time measurement. I got the idea for this originally from my CSE100 clas but tried to make it my own but making this a single player mode that only allows a user to test their own reaction time!

The system operates in a single clock domain and is suitable for FPGA or ASIC implementation.

Functional Description

The game operates as follows:
	1.	The user presses START, transitioning the system from IDLE to READY.
	2.	A pseudo-random delay between 50 and 200 clock cycles is generated.
	3.	After the delay expires, the GO LED is asserted.
	4.	The reaction counter begins incrementing.
	5.	When the user presses the reaction button, the counter value is stored as the reaction time.
	6.	The system enters DONE and waits for another START signal.


State Machine

The design uses a 6-state FSM:

IDLE       - Waiting for START input
READY      - Game initialized, preparing delay
WAIT       - Counting pseudo-random delay
GO         - Measuring reaction time
TOO_EARLY  - Reaction button pressed before GO
DONE       - Reaction time stored and displayed

State transitions occur on the rising edge of the clock.


Inputs and Outputs

Inputs:
	•	clk           : System clock
	•	reset         : Asynchronous reset
	•	start         : Begins a new round
	•	react_button  : User reaction input

Outputs:
	•	ready_led     : Indicates delay period
	•	go_led        : Indicates reaction measurement period
	•	result[7:0]   : Reaction time or error code
	•	state[2:0]    : Current FSM state (debugging)

Error Codes:
	•	255 : Too early (button pressed before GO)
	•	254 : Too slow (reaction counter timeout)


Key Design Components

Linear Feedback Shift Register (LFSR)

An 8-bit LFSR generates pseudo-random delays using feedback taps at bits 7, 5, 4, and 0. The generated value is scaled to produce a delay between 50 and 200 clock cycles. This prevents predictable timing between rounds.

Delay Counter

Counts from 0 to the generated delay target during the WAIT state.

Reaction Counter

Begins counting when the GO signal is asserted and stops when the user presses the reaction button or when the counter saturates.

Finite State Machine

Controls all state transitions, error handling, and output behavior.



Testbench Description

The testbench (reaction_timer_tb.v) verifies correct functionality through directed test cases.

Test Coverage:
	•	Reset initialization to IDLE state
	•	START transition to READY
	•	Proper delay generation and WAIT state operation
	•	Detection of early button press
	•	GO signal assertion after delay
	•	Accurate reaction time capture
	•	Timeout behavior
	•	Correct LED output behavior
	•	Multiple round operation

All six FSM states are exercised and state transitions are validated.


Test Sufficiency

The testbench provides full state coverage and validates:
	•	Normal gameplay flow
	•	Error conditions (too early and timeout)
	•	Counter functionality
	•	Output correctness
	•	Replay capability

All state transitions and edge cases are tested, providing confidence that the design operates correctly under expected use conditions.


Local Simulation

To simulate using Icarus Verilog:

iverilog -o reaction_timer_tb.vvp reaction_timer.v reaction_timer_tb.v
vvp reaction_timer_tb.vvp

A successful run reports all tests passing.


Hardware Integration (TinyTapeout)

Signal mapping:

ui_in[0]  -> START
ui_in[1]  -> Reaction button
uo_out[0] -> Ready LED
uo_out[1] -> GO LED
uo_out[7:2] -> Reaction time display

The design operates continuously using the provided clock and supports repeated gameplay.



GenAI Usage Statement

GenAI tools were used to assist with refining the overall game concept, structuring the FSM implementation, and organizing test cases. The final design and implementation details were reviewed and validated to ensure correctness.
