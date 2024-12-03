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

from mock_display import Display
import random
import math
import numpy as np


def get_columns(columns):
    """
    This function takes a n-bit number and returns the two n//2 numbers
    that make it up
    """
    bits_in_cols = len(columns)
    column_1 = columns&((1<<(bits_in_cols//2))-1)
    column_2 = columns>>bits_in_cols//2
    return column_1, column_2


@cocotb.test()
async def test_a(dut):
    """cocotb test for rot_frame_buffer"""
    dut._log.info("Starting...")

    cocotb.start_soon(Clock(dut.clk_in, 10, units="ns").start())

    dut.rst_in.value = 1
    await ClockCycles(dut.clk_in, 5)
    dut.rst_in.value = 0

    test_points = [(random.randint(0, 31), random.randint(0, 31), random.randint(0, 63)) for _ in range(10)]

    for i in range(32):
        dut.theta_read.value = i
        await ClockCycles(dut.clk_in, 2)
        await FallingEdge(dut.clk_in)
        columns = dut.columns.value

        column_1, column_2 = get_columns(columns)

        print(f"The columns are {column_1} and {column_2}, theta is {i}")

    for r, theta, z in test_points:
        dut.radius.value = r
        dut.theta_write.value = theta
        dut.z.value = z

    ## Testing Flush

    print("Flushing....")
    dut.flush.value = 1
    await FallingEdge(dut.busy)

    for i in range(32):
        dut.theta_read.value = i
        await ClockCycles(dut.clk_in, 2)
        columns = dut.columns.value

        column_1, column_2 = get_columns(columns)

        print(f"The columns are {column_1} and {column_2}, theta is {i}")

    print("Writing....")

    for r, theta, z in test_points:
        dut.radius.value = r
        dut.theta_write.value = theta
        dut.z.value = z
    



        


def is_runner():
    """Distance tester"""
    hdl_toplevel_lang = os.getenv("HDL_TOPLEVEL_LANG", "verilog")
    sim = os.getenv("SIM", "icarus")
    proj_path = Path(__file__).resolve().parent.parent
    sys.path.append(str(proj_path / "sim" / "model"))
    sources = [proj_path / "hdl" / "rot_frame_buffer.sv"]
    sources += [proj_path / "hdl" / "xilinx_single_port_ram_read_first.sv"]
    build_test_args = ["-Wall"]
    parameters = {}
    sys.path.append(str(proj_path / "sim"))
    runner = get_runner(sim)
    runner.build(
        sources=sources,
        hdl_toplevel="rot_frame_buffer",
        always=True,
        build_args=build_test_args,
        parameters=parameters,
        timescale = ('1ns','1ps'),
        waves=True
    )
    run_test_args = []
    runner.test(
        hdl_toplevel="rot_frame_buffer",
        test_module="test_rot_frame_buffer",
        test_args=run_test_args,
        waves=True
    )

if __name__ == "__main__":
    is_runner()

