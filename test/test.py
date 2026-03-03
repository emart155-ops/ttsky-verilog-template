# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


@cocotb.test()
async def test_project(dut):
    dut._log.info("Start")

    # Set the clock period to 10 us (100 KHz)
    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())

    # Reset
    dut._log.info("Reset")
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1

    dut._log.info("Test project behavior")

    # After reset, reaction timer should be in IDLE state
    # ui_in[0] = start button, ui_in[1] = react_button
    dut.ui_in.value = 0  # No buttons pressed
    dut.uio_in.value = 0

    # Wait for a few clock cycles to ensure reset is complete
    await ClockCycles(dut.clk, 5)

    # After reset in IDLE state, outputs should be:
    # uo_out[0] = ready_led = 0
    # uo_out[1] = go_led = 0
    # uo_out[7:2] = result[5:0] = 0
    # So uo_out should be 0
    assert dut.uo_out.value == 0, f"Expected 0 after reset, got {dut.uo_out.value}"

    # Test: Press start button (ui_in[0] = 1)
    dut.ui_in.value = 1  # Start button pressed
    await ClockCycles(dut.clk, 2)
    
    # Ready LED should turn on (uo_out[0] = 1)
    assert dut.uo_out.value & 0x01 == 1, f"Expected ready_led on, got {dut.uo_out.value}"

    dut._log.info("Test completed successfully")
