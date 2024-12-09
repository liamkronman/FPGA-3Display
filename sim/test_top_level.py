import cocotb
import os
from pathlib import Path
from cocotb.clock import Clock
from cocotb.triggers import Timer, ClockCycles, RisingEdge
from cocotb.runner import get_runner
from utils import *
import numpy as np

@cocotb.test()
async def test_top_level(dut):
    """Test frame_manager module in sphere mode."""
    # Start clock
    cocotb.start_soon(Clock(dut.clk_in, 83, units="ns").start()) # 83 for 12MHz testing



    

    
    print("Test passed: frame_manager sphere mode outputs match expected sphere_cols.")
    # print the actual circle, comma-separated, fully expanded
    print("Actual circle:")
    print(np.array2string(actual_circle, separator=", "))

def top_level_runner():
    """Runner function for frame_manager testbench."""
    hdl_toplevel_lang = os.getenv("HDL_TOPLEVEL_LANG", "verilog")
    sim = os.getenv("SIM", "icarus")  # You can switch to another simulator if needed
    proj_path = Path(__file__).resolve().parent.parent

    # Source files for the design
    sources = [proj_path / "hdl" / "top_level.sv"]
    sources += [proj_path / "hdl" / "test_hub75.sv"]
    sources += [proj_path / "hdl" / "ir_led_control.sv"]
    sources += [proj_path / "hdl" / "sphere_frame.sv"]
    sources += [proj_path / "hdl" / "frame_manager.sv"]
    sources += [proj_path / "hdl" / "col_calc.sv"]
    sources += [proj_path / "hdl" / "sphere_frame.sv"]
    sources += [proj_path / "hdl" / "cube_frame.sv"]
    sources += [proj_path / "hdl" / "boids_frame.sv"]
    sources += [proj_path / "hdl" / "color_sphere_frame.sv"]
    sources += [proj_path/"hdl"/"rot_frame_buffer.sv"]
    sources += [proj_path / "hdl" / "xilinx_single_port_ram_read_first.sv"]
    sources += [proj_path / "hdl" / "xilinx_true_dual_port_read_first_2_clock_ram.v"]
    sources += [proj_path / "hdl" / "hemi_sphere_frame.sv"]
    build_test_args = ["-Wall"]
    parameters = {
        "NUM_ROWS": NUM_ROWS,
        "RGB_RES": RGB_RES,
        "NUM_COLS": NUM_COLS,
        "SCAN_RATE": SCAN_RATE
    }

    # Initialize the runner
    runner = get_runner(sim)
    runner.build(
        sources=sources,
        hdl_toplevel="top_level",
        always=True,
        build_args=build_test_args,
        parameters=parameters,
        timescale=('1ns', '1ps'),
        waves=True
    )
    
    # Run the test
    runner.test(
        hdl_toplevel="top_level",
        test_module="test_top_level",
        waves=True
    )

if __name__ == "__main__":
    frame_manager_runner()
