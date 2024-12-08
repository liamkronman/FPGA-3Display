import cocotb
import os
from pathlib import Path
from cocotb.clock import Clock
from cocotb.triggers import Timer, ClockCycles, RisingEdge
from cocotb.runner import get_runner
from utils import *
import numpy as np

@cocotb.test()
async def test_frame_manager(dut):
    """Test frame_manager module in sphere mode."""
    # Start clock
    cocotb.start_soon(Clock(dut.clk_in, 83, units="ns").start()) # 83 for 12MHz testing

    # Reset DUT
    dut.rst_in.value = 1
    dut.mode.value = 2  # Initial mode
    dut.hub75_ready.value = 0
    dut.theta.value = 0
    await ClockCycles(dut.clk_in, 5)
    dut.rst_in.value = 0

    # Set mode to sphere (2'b01)
    dut.mode.value = 1

    actual_circle = np.zeros(NUM_ROWS**2).reshape(NUM_ROWS, NUM_ROWS)

    # Pulse hub75_ready and validate output
    for col_idx1 in range(SCAN_RATE):
        col_idx2 = col_idx1 + SCAN_RATE
        # Set hub75_ready high for one cycle
        dut.hub75_ready.value = 1
        dut.col_num1.value = col_idx1
        dut.col_num2.value = col_idx2
        await RisingEdge(dut.clk_in)
        dut.hub75_ready.value = 0

        # Allow propagation and validate output
        await Timer(1, units="ns")

        for row in range(NUM_ROWS):
            expected_column1 = (2**RGB_RES - 1) if (col_idx1 - RADIUS)**2 + (row - CENTER_Y)**2 <= RADIUS**2 else 0
            expected_column2 = (2**RGB_RES - 1) if (col_idx2 - RADIUS)**2 + (row - CENTER_Y)**2 <= RADIUS**2 else 0


            actual_column1 = access_index(dut, 0, row)
            actual_column2 = access_index(dut, 1, row)
            
            actual_circle[row][col_idx1] = actual_column1
            actual_circle[row][col_idx2] = actual_column2
            
            print(f"Row {row}: {actual_column1}, {actual_column2}")
            print(f"Expected: {expected_column1}, {expected_column2}")
            assert actual_column1 == expected_column1, f"Mismatch for column1 at row {row}, col_idx1={col_idx1}"
            assert actual_column2 == expected_column2, f"Mismatch for column2 at row {row}, col_idx2={col_idx2}"

        # Advance the clock
        await ClockCycles(dut.clk_in, 1)

    print("Test passed: frame_manager sphere mode outputs match expected sphere_cols.")
    # print the actual circle, comma-separated, fully expanded
    print("Actual circle:")
    print(np.array2string(actual_circle, separator=", "))

def frame_manager_runner():
    """Runner function for frame_manager testbench."""
    hdl_toplevel_lang = os.getenv("HDL_TOPLEVEL_LANG", "verilog")
    sim = os.getenv("SIM", "icarus")  # You can switch to another simulator if needed
    proj_path = Path(__file__).resolve().parent.parent

    # Source files for the design
    sources = [proj_path / "hdl" / "frame_manager.sv"]
    sources += [proj_path / "hdl" / "col_calc.sv"]
    sources += [proj_path / "hdl" / "sphere_frame.sv"]
    sources += [proj_path / "hdl" / "cube_frame.sv"]
    sources += [proj_path / "hdl" / "boids_frame.sv"]
    sources += [proj_path / "hdl" / "color_sphere_frame.sv"]
    sources += [proj_path/"hdl"/"rot_frame_buffer.sv"]
    sources += [proj_path / "hdl" / "xilinx_single_port_ram_read_first.sv"]
    sources += [proj_path / "hdl" / "xilinx_true_dual_port_read_first_2_clock_ram.v"]
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
        hdl_toplevel="frame_manager",
        always=True,
        build_args=build_test_args,
        parameters=parameters,
        timescale=('1ns', '1ps'),
        waves=True
    )
    
    # Run the test
    runner.test(
        hdl_toplevel="frame_manager",
        test_module="test_frame_manager",
        waves=True
    )

if __name__ == "__main__":
    frame_manager_runner()
