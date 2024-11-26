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
import numpy as np


# import random
import math



# Generate 64 points in a 64x64 grid

@cocotb.test()
async def test_a(dut):

    cocotb.start_soon(Clock(dut.clk_in, 10, units="ns").start())
    dut.rst_in.value = 0
    await ClockCycles(dut.clk_in,1)
    dut.rst_in.value = 1
    await ClockCycles(dut.clk_in,5)
    dut.rst_in.value = 0

    dut.col_index.value = 16

    dut.tvalid.value = 1
    for i in range(64*9):
        dut.column_data0[i].value = 1
        dut.column_data1[i].value = 1
    await ClockCycles(dut.clk_in,2)
    dut.tvalid.value = 0

        
    await ClockCycles(dut.clk_in,10000)
    await ReadOnly()



def is_runner():
    """Image Sprite Tester."""
    hdl_toplevel_lang = os.getenv("HDL_TOPLEVEL_LANG", "verilog")
    sim = os.getenv("SIM", "icarus")
    proj_path = Path(__file__).resolve().parent.parent
    sys.path.append(str(proj_path / "sim" / "model"))
    sources = [proj_path / "hdl" / "hub75_output.sv"]
    build_test_args = ["-Wall"]
    parameters = {}
    sys.path.append(str(proj_path / "sim"))
    runner = get_runner(sim)
    runner.build(
        sources=sources,
        hdl_toplevel="hub75_output",
        always=True,
        build_args=build_test_args,
        parameters=parameters,
        timescale = ('1ns','1ps'),
        waves=True
    )
    run_test_args = []
    runner.test(
        hdl_toplevel="hub75_output",
        test_module="test_hub75",
        test_args=run_test_args,
        waves=True
    )

if __name__ == "__main__":
    is_runner()

