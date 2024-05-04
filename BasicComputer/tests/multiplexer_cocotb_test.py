import cocotb
from cocotb.triggers import Timer
import random

@cocotb.test()
async def multiplexer_cocotb_test(dut):
    # Test for various select lines
    for select_value in range(8):
        dut.select.value = select_value

        # Set random values for inputs
        for i in range(8):
            setattr(dut, f"in{i}", random.randint(0, 255))

        await Timer(1, units='ns')  # Wait a short time for combinational logic to settle
        
        expected_output = getattr(dut, f"in{select_value}").value
        assert dut.out.value == expected_output, f"Output is {dut.out.value}, expected {expected_output}"
