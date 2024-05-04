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

# Test write and read functionality
@cocotb.test()
async def test_write_read(dut):
    cocotb.start_soon(clock_gen(dut.clk))
    await FallingEdge(dut.clk)

    for _ in range(10):  # Test with multiple random values and addresses
        address = random.randint(0, 4095)
        write_data = random.randint(0, 65535)

        # Write data to memory
        dut.address.value = address
        dut.write_data.value = write_data
        dut.write_enable.value = 1
        await FallingEdge(dut.clk)

        # Disable write for next cycle
        dut.write_enable.value = 0
        await FallingEdge(dut.clk)  # Wait for one more clock cycle for data to settle

        # Read data from memory
        dut.address.value = address
        await FallingEdge(dut.clk)

        # Check if read data matches written data
        read_value = dut.read_data.value
        assert read_value == write_data, f"Data mismatch: read {read_value}, expected {write_data}"
