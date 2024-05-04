import cocotb
from cocotb.triggers import FallingEdge, Timer

# Clock generator
@cocotb.coroutine
async def clock_gen(signal):
    while True:
        signal.value = 0
        await Timer(1, units='ns')
        signal.value = 1
        await Timer(1, units='ns')

# Test the execution of the ADD instruction
@cocotb.test()
async def test_add_instruction_execution(dut):
    cocotb.start_soon(clock_gen(dut.clk))
    await FallingEdge(dut.clk)

    # Set the IR to the ADD opcode
    # Assuming opcode for ADD is 001 and it's located in the lower 3 bits of IR
    dut.IR.value = 0b001
    await FallingEdge(dut.clk)

    # Check if the controller sets the correct signals for the ADD operation
    assert dut.alu_op.value == 0b001, "ALU operation should be set for ADD"
    assert dut.write_ac.value == 1, "write_ac should be enabled for ADD"
    # ... assert other signals ...

    # Optionally, simulate additional clock cycles to observe the operation's progress
    for _ in range(5):
        await FallingEdge(dut.clk)

    # Assert the final state after the operation
    # This will depend on your controller's specific implementation
    # Example:
    # assert dut.AC.value == expected_result, "AC should hold the result of ADD"
