import cocotb
import os
from pathlib import Path
from cocotb.clock import Clock
from cocotb.triggers import Timer, ClockCycles, RisingEdge
from cocotb.runner import get_runner

@cocotb.test()
async def test_frame_manager(dut):
    """Test frame_manager module in sphere mode."""

    # Parameters
    NUM_ROWS = 64
    RGB_RES = 9

    # Start clock
    cocotb.start_soon(Clock(dut.clk_in, 10, units="ns").start())

    # Reset DUT
    dut.rst_in.value = 1
    dut.mode.value = 0  # Initial mode
    dut.hub75_ready.value = 0
    dut.theta.value = 0
    await ClockCycles(dut.clk_in, 5)
    dut.rst_in.value = 0

    # Set mode to sphere (2'b01)
    dut.mode.value = 1

    # Pulse hub75_ready and validate output
    for cycle in range(10):
        # Set hub75_ready high for one cycle
        dut.hub75_ready.value = 1
        await RisingEdge(dut.clk_in)
        dut.hub75_ready.value = 0

        # Allow propagation and validate output
        await Timer(1, units="ns")

        for col_idx in range(2):  # Validate both columns
            for row in range(NUM_ROWS):
                print(f"col_idx={col_idx}, row={row}")
                expected_value = 1  # Expected value for sphere_cols
                flat_index = col_idx * NUM_ROWS + row
                actual_value = dut.columns[flat_index].value
                assert actual_value == expected_value, (
                    f"Mismatch in sphere mode: col_idx={col_idx}, row={row}, "
                    f"expected={expected_value}, actual={actual_value}"
                )

        # Advance the clock
        await ClockCycles(dut.clk_in, 1)

    print("Test passed: frame_manager sphere mode outputs match expected sphere_cols.")

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

    build_test_args = ["-Wall"]
    parameters = {}

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
