import cocotb
import os
from cocotb.clock import Clock
from cocotb.triggers import Timer, ClockCycles
from pathlib import Path
from cocotb.runner import get_runner
import matplotlib.pyplot as plt
import numpy as np
from utils import *

# unused but useful for debugging
def circle_image(image_width, radius):
  circle = np.zeros(image_width**2).reshape(image_width, image_width)
  center = (image_width//2, image_width//2)
  # for all indices where dist(point_i, center) <= radius, point_i = 1
  rad_squared = radius**2
  for i in range(image_width):
    for j in range(image_width):
      if (i-center[0])**2 + (j-center[1])**2 <= rad_squared:
        circle[i][j] = 1
  return circle

@cocotb.test()
async def test_sphere_frame(dut):
    """Test sphere_frame module functionality."""
    # build up an array which can be plotted for testing
    actual_circle = np.zeros(NUM_ROWS**2).reshape(NUM_ROWS, NUM_ROWS)

    for col_idx1 in range(SCAN_RATE):
        # for col_idx2 in test_indices:
        col_idx2 = col_idx1+SCAN_RATE
        # Set the input column indices
        dut.column_index1.value = col_idx1
        dut.column_index2.value = col_idx2

        # Allow time for propagation
        await Timer(1, units="ns")
        
        # Validate column1 and column2
        for row in range(NUM_ROWS):
            expected_column1 = (2**RGB_RES - 1) if (col_idx1 - CENTER_X)**2 + (row - CENTER_Y)**2 <= RADIUS**2 else 0
            expected_column2 = (2**RGB_RES - 1) if (col_idx2 - CENTER_X)**2 + (row - CENTER_Y)**2 <= RADIUS**2 else 0


            actual_column1 = access_index(dut, 0, row)
            actual_column2 = access_index(dut, 1, row)
            
            actual_circle[row][col_idx1] = actual_column1
            actual_circle[row][col_idx2] = actual_column2
            
            print(f"Row {row}: {actual_column1}, {actual_column2}")
            print(f"Expected: {expected_column1}, {expected_column2}")
            assert actual_column1 == expected_column1, f"Mismatch for column1 at row {row}, col_idx1={col_idx1}"
            assert actual_column2 == expected_column2, f"Mismatch for column2 at row {row}, col_idx2={col_idx2}"

        print(f"Test passed for column indices {col_idx1}, {col_idx2}")

    # print the actual circle, comma-separated
    print("Actual circle:")
    print(np.array2string(actual_circle, separator=", "))

def sphere_frame_runner():
    """Runner function for sphere frame testbench."""
    hdl_toplevel_lang = os.getenv("HDL_TOPLEVEL_LANG", "verilog")
    sim = os.getenv("SIM", "icarus")  # You can switch to another simulator if needed
    proj_path = Path(__file__).resolve().parent.parent

    # Source files for the design
    sources = [proj_path / "hdl" / "sphere_frame.sv"]
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
        hdl_toplevel="sphere_frame",
        always=True,
        build_args=build_test_args,
        parameters=parameters,
        timescale=('1ns', '1ps'),
        waves=True
    )
    
    # Run the test
    runner.test(
        hdl_toplevel="sphere_frame",
        test_module="test_sphere_frame",
        waves=True
    )


if __name__ == "__main__":
    sphere_frame_runner()