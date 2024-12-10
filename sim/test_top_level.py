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
    cocotb.start_soon(Clock(dut.clk_12mhz, 83, units="ns").start()) # 83 for 12MHz testing
    dut.btn.value = 3;
    await ClockCycles(dut.clk_12mhz, 1)
    dut.btn.value = 0;
    for i in range(10):
        dut.ir_tripped.value = 1
        await ClockCycles(dut.clk_12mhz, 3)
        dut.ir_tripped.value = 0
        await ClockCycles(dut.clk_12mhz, 4096)
    

    
def top_level_runner():
    """Runner function for frame_manager testbench."""
    hdl_toplevel_lang = os.getenv("HDL_TOPLEVEL_LANG", "verilog")
    sim = os.getenv("SIM", "icarus")  # You can switch to another simulator if needed
    proj_path = Path(__file__).resolve().parent.parent

    # Source files for the design
    sources = [proj_path / "hdl" / "top_level.sv"]
    sources += [proj_path / "hdl" / "hub75_output.sv"]
    sources += [proj_path / "hdl" / "ir_led_control.sv"]

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
    #sources += [proj_path / "hdl" / "clk_wiz.v"]
    sources += [proj_path / "hdl" / "detect_to_theta.sv"]
    sources += [proj_path / "hdl" / "debouncer.sv"]
    sources += [proj_path / "hdl" / "rfb_to_hub75.sv"]

    build_test_args = ["-Wall"]
    parameters = {
        "ROTATIONAL_RES": 1024,
        "NUM_COLS": 64,
        "NUM_ROWS": 64,
        "SCAN_RATE": 32,
        "RGB_RES": 9
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
    top_level_runner()
