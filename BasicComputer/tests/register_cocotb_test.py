import cocotb
from cocotb.triggers import FallingEdge, Timer
import random

# Clock generator
@cocotb.coroutine
async def clock_gen(signal):
    while True:
        signal.value = 0
        await Timer(1, units='ns')
        signal.value = 1
        await Timer(1, units='ns')

# Test the reset functionality
@cocotb.test()
async def test_reset(dut):
    cocotb.start_soon(clock_gen(dut.clk))
    await FallingEdge(dut.clk)
    dut.reset.value = 1
    await FallingEdge(dut.clk)
    assert dut.A.value == 0, f"Reset functionality failed: A = {dut.A.value}, expected 0"

# Test the parallel load functionality
@cocotb.test()
async def test_parallel_load(dut):
    cocotb.start_soon(clock_gen(dut.clk))
    dut.reset.value = 0
    dut.write.value = 1
    await FallingEdge(dut.clk)
    for _ in range(5):  # Test with multiple random values
        random_data = random.randint(0, 2**dut.WIDTH.value - 1)
        dut.DATA.value = random_data
        await FallingEdge(dut.clk)
        assert dut.A.value == random_data, f"Parallel load functionality failed: A = {dut.A.value}, expected {random_data}"

# Test the increment functionality
@cocotb.test()
async def test_increment(dut):
    cocotb.start_soon(clock_gen(dut.clk))
    dut.reset.value = 0
    dut.write.value = 1
    await FallingEdge(dut.clk)
    initial_value = random.randint(0, 2**dut.WIDTH.value - 2)
    dut.DATA.value = initial_value
    await FallingEdge(dut.clk)

    dut.write.value = 0
    dut.increment.value = 1
    await FallingEdge(dut.clk)
    expected_value = (initial_value + 1) & (2**dut.WIDTH.value - 1)
    assert dut.A.value == expected_value, f"Increment functionality failed: A = {dut.A.value}, expected {expected_value}"

    # Optionally, test multiple increments in a loop
    for _ in range(5):
        expected_value = (dut.A.value + 1) & (2**dut.WIDTH.value - 1)
        await FallingEdge(dut.clk)
        assert dut.A.value == expected_value, f"Increment functionality failed: A = {dut.A.value}, expected {expected_value}"

# Optionally, add tests for any other specific behaviors or edge cases your register might have
