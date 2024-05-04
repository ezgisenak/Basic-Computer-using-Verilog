import cocotb
from cocotb.triggers import FallingEdge, Timer
from cocotb.binary import BinaryValue

# Clock generator
async def clock_gen(signal, period=2):
    while True:
        signal.value = 0
        await Timer(period // 2, units='ns')
        signal.value = 1
        await Timer(period // 2, units='ns')

@cocotb.test()
async def test_memory_operations(dut):
    # Wait for the system to initialize
    await Timer(5, units='ns')
    
     # Check if the AC register is cleared to 0 after the CLA instruction
    assert dut.AC.value == 0, f"Test failed: AC expected to be 0, found {dut.AC.value}"

    await Timer(5, units='ns')
    
     # Check if the AC register is cleared to 0 after the CLA instruction
    assert dut.E.value == 0, f"Test failed: E expected to be 0, found {dut.E.value}"

    await Timer(5, units='ns')
    
     # Check if the AC register is cleared to 0 after the CLA instruction
    assert dut.AC.value == 1, f"Test failed: AC expected to be 1, found {dut.AC.value}"
