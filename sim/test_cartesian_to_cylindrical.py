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

from test_display import Display
# import random
import math


def generate_spiral_pattern(size, num_points):
    center = size // 2
    points = []
    for i in range(num_points):
        angle = 0.1 * i
        x = int(center + (center - 1) * math.cos(angle) * (i / num_points))
        y = int(center + (center - 1) * math.sin(angle) * (i / num_points))
        z = i  # Keeping z constant for simplicity
        points.append((x, y, z))
    return points

# Generate 64 points in a 64x64 grid

@cocotb.test()
async def test_a(dut):
    """cocotb test for cartesian_to_cylindrical"""
    dut._log.info("Starting...")

    # test_points = [(63, 31, 20), ]
    
    test_points = [(4*i, 4*i, 0)
                   for i in range(0, 4)]

    test_points.extend([(16, 4*i, 0) 
                        for i in range(0, 4)])
    
    test_points.extend([(31, 4*i, 0)
                   for i in range(0, 4)])
    
    test_points = generate_spiral_pattern(64, 64)

    test_display = Display()

    cocotb.start_soon(Clock(dut.clk_in, 10, units="ns").start())
    dut.rst_in.value = 0
    await ClockCycles(dut.clk_in,1)
    dut.rst_in.value = 1
    await ClockCycles(dut.clk_in,5)
    dut.rst_in.value = 0


    for x, y, z in test_points:
        dut.x_in.value = x
        dut.y_in.value = y
        dut.z_in.value = z

        dut.new_data.value = 1

        test_display.plot_cartesian(x, y, z)
        # await ClockCycles(dut.clk_in, 2)
        await RisingEdge(dut.data_ready)
        dut.new_data.value = 0
        await FallingEdge(dut.clk_in)

        theta, r, z_out = dut.theta.value, dut.radius.value, dut.z_out.value
        theta, r, z_out = int(theta), int(r), int(z_out)

        print(f"Radius {r}, Theta {theta}")

        test_display.plot_cylindrical(r, theta, z_out)

        await ClockCycles(dut.clk_in, 1)

        
    await ClockCycles(dut.clk_in,10)
    test_display.show()


def is_runner():
    """Image Sprite Tester."""
    hdl_toplevel_lang = os.getenv("HDL_TOPLEVEL_LANG", "verilog")
    sim = os.getenv("SIM", "icarus")
    proj_path = Path(__file__).resolve().parent.parent
    sys.path.append(str(proj_path / "sim" / "model"))
    sources = [proj_path / "hdl" / "cartesian_to_cylindrical.sv"]
    sources += [proj_path / "hdl" / "xilinx_single_port_ram_read_first.sv"]
    build_test_args = ["-Wall"]
    parameters = {}
    sys.path.append(str(proj_path / "sim"))
    runner = get_runner(sim)
    runner.build(
        sources=sources,
        hdl_toplevel="cartesian_to_cylindrical",
        always=True,
        build_args=build_test_args,
        parameters=parameters,
        timescale = ('1ns','1ps'),
        waves=True
    )
    run_test_args = []
    runner.test(
        hdl_toplevel="cartesian_to_cylindrical",
        test_module="test_cartesian_to_cylindrical",
        test_args=run_test_args,
        waves=True
    )

if __name__ == "__main__":
    is_runner()

