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


@cocotb.test()
async def test_a(dut):
    """cocotb test for distance_3d"""
    dut._log.info("Starting...")

    cocotb.start_soon(Clock(dut.clk_in, 10, units="ns").start())

    dut.rst_in.value = 1
    await ClockCycles(dut.clk_in, 5)
    dut.rst_in.value = 0

    # test_points_a = [(31, 0, 0),
    #                  (0, 15, 0),
    #                  (15, 15, 15),
    #                  (0, 15, 15),]

    # test_points_b = [(0, 0, 0),
    #                 (0, 0, 0),
    #                 (0, 0, 0),
    #                 (0, 0, 0),]
    
    test_points_a = [(random.randint(0, 31), random.randint(0, 31), random.randint(0, 31)) 
                     for _ in range(1000)]
    test_points_b = [(random.randint(0, 31), random.randint(0, 31), random.randint(0, 31)) 
                     for _ in range(1000)]

    test_points_a.append((31, 31, 0))
    test_points_b.append((0, 0, 0))

    correct_distances = [np.linalg.norm(np.array(vector_a) - np.array(vector_b)) 
                         for vector_a, vector_b in zip(test_points_a, test_points_b)]

    correct_distances_copy = correct_distances.copy()

    distances = []
    exceeded_vals = []


    while correct_distances_copy:
        if test_points_a:
            x1, y1, z1 = test_points_a.pop(0)
            x2, y2, z2 = test_points_b.pop(0)

            dut.x1_in.value = x1
            dut.y1_in.value = y1
            dut.z1_in.value = z1

            dut.x2_in.value = x2
            dut.y2_in.value = y2
            dut.z2_in.value = z2

            dut.new_data.value = 1
        else:
            dut.new_data.value = 0

        await ClockCycles(dut.clk_in, 1)

        if dut.data_ready.value != 1:
            continue

        correct_distance = correct_distances_copy.pop(0)
        exceeded = int(dut.exceeded.value) == 1
        distance = int(dut.distance.value)

        if abs(distance - correct_distance) > 2 and not exceeded:
            raise ValueError(f"Distance: {distance}, correct distance: {correct_distance}")

        # print(f"{distance}, correct distance: {correct_distance}")
        # print(f"Exceeded: {exceeded}")
        # print("\n")

        distances.append(int(dut.distance.value))
        exceeded_vals.append(exceeded)


def is_runner():
    """Distance tester"""
    hdl_toplevel_lang = os.getenv("HDL_TOPLEVEL_LANG", "verilog")
    sim = os.getenv("SIM", "icarus")
    proj_path = Path(__file__).resolve().parent.parent
    sys.path.append(str(proj_path / "sim" / "model"))
    sources = [proj_path / "hdl" / "distance_3d.sv"]
    sources += [proj_path / "hdl" / "xilinx_single_port_ram_read_first.sv"]
    build_test_args = ["-Wall"]
    parameters = {}
    sys.path.append(str(proj_path / "sim"))
    runner = get_runner(sim)
    runner.build(
        sources=sources,
        hdl_toplevel="distance_3d",
        always=True,
        build_args=build_test_args,
        parameters=parameters,
        timescale = ('1ns','1ps'),
        waves=True
    )
    run_test_args = []
    runner.test(
        hdl_toplevel="distance_3d",
        test_module="test_distance_3d",
        test_args=run_test_args,
        waves=True
    )

if __name__ == "__main__":
    is_runner()

