import cocotb
import os
import sys
from math import log
import logging
from pathlib import Path
from cocotb.clock import Clock
from cocotb.triggers import Timer, ClockCycles, RisingEdge, FallingEdge, ReadOnly,with_timeout
from cocotb.utils import get_sim_time as gst
from cocotb.runner import get_runner

async def apply_theta_detection(dut, cycles):
    for i in range(cycles):
        await ClockCycles(dut.clk_in, 1)
        print(f"Cycle {i}")
        print(f"Theta: {dut.theta.value}")
        assert dut.theta.value == i
    dut.ir_tripped.value = 1
    await ClockCycles(dut.clk_in, 1)
    dut.ir_tripped.value = 0
    await ClockCycles(dut.clk_in, 1)
    print(f"Period ready: {dut.period_ready.value}")
    assert dut.period_ready.value == 1
    assert dut.period.value == cycles


@cocotb.test()
async def test_detect_to_theta(dut):
    """Test detect to theta module functionality"""
    # Start clock
    cocotb.start_soon(Clock(dut.clk_in, 10, units="ns").start())
    dut.rst_in.value = 1
    dut.ir_tripped.value = 0
    await ClockCycles(dut.clk_in, 5)
    dut.rst_in.value = 0
    # test is tripping the IR on 10 cycles
    for i in [10, 11, 12, 13, 14, 15]:
        await apply_theta_detection(dut, i)
        dut.rst_in.value = 1
        await ClockCycles(dut.clk_in, 5)
        dut.rst_in.value = 0
    

def detect_to_theta_runner():
    """Runner function for detect to theta testbench."""
    hdl_toplevel_lang = os.getenv("HDL_TOPLEVEL_LANG", "verilog")
    sim = os.getenv("SIM", "icarus")  # You can switch to another simulator if needed
    proj_path = Path(__file__).resolve().parent.parent

    # Source files for the design
    sources = [proj_path / "hdl" / "detect_to_theta.sv"]
    build_test_args = ["-Wall"]
    parameters = {}

    # Initialize the runner
    runner = get_runner(sim)
    runner.build(
        sources=sources,
        hdl_toplevel="detect_to_theta",
        always=True,
        build_args=build_test_args,
        parameters=parameters,
        timescale=('1ns', '1ps'),
        waves=True
    )
    
    # Run the test
    runner.test(
        hdl_toplevel="detect_to_theta",
        test_module="test_detect_to_theta",
        waves=True
    )


if __name__ == "__main__":
    detect_to_theta_runner()