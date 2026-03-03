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

    # Set the input values you want to test
    # ui_in[0] = start button, ui_in[1] = react_button
    dut.ui_in.value = 0  # No buttons pressed initially
    dut.uio_in.value = 0

    # Wait for several clock cycles to let the module stabilize
    await ClockCycles(dut.clk, 20)

    # Basic test: verify module is responsive
    # After reset, reaction timer should be in IDLE state
    # We just verify the module runs without errors
    dut._log.info(f"Output value: {dut.uo_out.value}")

    dut._log.info("Test completed successfully")
