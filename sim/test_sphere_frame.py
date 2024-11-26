import cocotb
import os
from cocotb.clock import Clock
from cocotb.triggers import Timer, ClockCycles
from pathlib import Path
from cocotb.runner import get_runner

@cocotb.test()
async def test_sphere_frame(dut):
    """Test sphere_frame module functionality."""
    # Parameters for the test
    RADIUS = 32
    CENTER_Y = 32
    RGB_RES = 9  # Ensure it matches the DUT parameter

    # Test different column indices
    test_indices = [0, 16, 32, 48, 63]  # Cover edges and center of the range

    for col_idx1 in test_indices:
        for col_idx2 in test_indices:
            # Set the input column indices
            dut.column_index1.value = col_idx1
            dut.column_index2.value = col_idx2

            # Allow time for propagation
            await Timer(1, units="ns")

            # Validate column1 and column2
            for row in range(64):  # Assuming NUM_ROWS=64
                actual_column1 = dut.columns[(0 * 64 + row)].value  # Flattened access
                actual_column2 = dut.columns[(1 * 64 + row)].value  # Flattened access

                expected_column1 = (2**RGB_RES - 1) if (col_idx1 - RADIUS)**2 + (row - CENTER_Y)**2 <= RADIUS**2 else 0
                expected_column2 = (2**RGB_RES - 1) if (col_idx2 - RADIUS)**2 + (row - CENTER_Y)**2 <= RADIUS**2 else 0
                
                print(f"Row {row}: {actual_column1}, {actual_column2}")
                print(f"Expected: {expected_column1}, {expected_column2}")
                assert actual_column1 == expected_column1, f"Mismatch for column1 at row {row}, col_idx1={col_idx1}"
                assert actual_column2 == expected_column2, f"Mismatch for column2 at row {row}, col_idx2={col_idx2}"

            print(f"Test passed for column indices {col_idx1}, {col_idx2}")


def sphere_frame_runner():
    """Runner function for sphere frame testbench."""
    hdl_toplevel_lang = os.getenv("HDL_TOPLEVEL_LANG", "verilog")
    sim = os.getenv("SIM", "icarus")  # You can switch to another simulator if needed
    proj_path = Path(__file__).resolve().parent.parent

    # Source files for the design
    sources = [proj_path / "hdl" / "sphere_frame.sv"]
    build_test_args = ["-Wall"]
    parameters = {}

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