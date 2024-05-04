import cocotb
from cocotb.triggers import Timer
import random

# Helper function for sign extension to handle negative values correctly
def sign_extend(value, bits):
    sign_bit = 1 << (bits - 1)
    return (value & (sign_bit - 1)) - (value & sign_bit)

# Test the Addition operation
@cocotb.test()
async def test_addition(dut):
    dut.OP.value = 0b000  # Set operation to addition
    for _ in range(10):   # Test with 10 random values
        AC_val = random.randint(0, 2**dut.W.value - 1)
        DR_val = random.randint(0, 2**dut.W.value - 1)
        dut.AC.value = AC_val
        dut.DR.value = DR_val

        await Timer(2, units='ns')

        expected_result = AC_val + DR_val
        assert dut.Result.value == expected_result & ((2**dut.W.value) - 1), "Addition result error"

# Test the AND operation
@cocotb.test()
async def test_and(dut):
    dut.OP.value = 0b001  # Set operation to AND
    for _ in range(10):
        AC_val = random.randint(0, 2**dut.W.value - 1)
        DR_val = random.randint(0, 2**dut.W.value - 1)
        dut.AC.value = AC_val
        dut.DR.value = DR_val

        await Timer(2, units='ns')

        expected_result = AC_val & DR_val
        assert dut.Result.value == expected_result, "AND result error"

# Test the Transfer DR operation
@cocotb.test()
async def test_transfer_dr(dut):
    dut.OP.value = 0b010  # Set operation to Transfer DR
    for _ in range(10):
        DR_val = random.randint(0, 2**dut.W.value - 1)
        dut.DR.value = DR_val

        await Timer(2, units='ns')

        assert dut.Result.value == DR_val, "Transfer DR result error"

# Test the Complement AC operation
@cocotb.test()
async def test_complement_ac(dut):
    dut.OP.value = 0b011  # Set operation to Complement AC
    for _ in range(10):
        AC_val = random.randint(0, 2**dut.W.value - 1)
        dut.AC.value = AC_val

        await Timer(2, units='ns')

        expected_result = ~AC_val & ((2**dut.W.value) - 1)
        assert dut.Result.value == expected_result, "Complement AC result error"

# Test the Shift Right operation
@cocotb.test()
async def test_shift_right(dut):
    dut.OP.value = 0b100  # Set operation to Shift Right
    for _ in range(10):
        AC_val = random.randint(0, 2**dut.W.value - 1)
        E_val = random.randint(0, 1)
        dut.AC.value = AC_val
        dut.E.value = E_val

        await Timer(2, units='ns')

        expected_result = (E_val << (dut.W.value - 1)) | (AC_val >> 1)
        assert dut.Result.value == expected_result, "Shift Right result error"

# Test the Shift Left operation
@cocotb.test()
async def test_shift_left(dut):
    dut.OP.value = 0b101  # Set operation to Shift Left
    for _ in range(10):
        AC_val = random.randint(0, 2**dut.W.value - 1)
        E_val = random.randint(0, 1)
        dut.AC.value = AC_val
        dut.E.value = E_val

        await Timer(2, units='ns')

        expected_result = ((AC_val << 1) | E_val) & ((2**dut.W.value) - 1)
        assert dut.Result.value == expected_result, "Shift Left result error"

# Test the Addition operation and flags
@cocotb.test()
async def test_addition_and_flags(dut):
    dut.OP.value = 0b000  # Set operation to addition
    W = dut.W.value       # Bit width

    test_cases = [
        (0, 0),  # Zero addition
        (2**(W-1) - 1, 1),  # Overflow case
        (2**(W-1), 2**(W-1)),  # Negative result case
        # ... (add more cases as needed)
    ]

    for AC_val, DR_val in test_cases:
        dut.AC.value = AC_val
        dut.DR.value = DR_val

        await Timer(2, units='ns')

        expected_result = (AC_val + DR_val) & ((2**W) - 1)
        assert dut.Result.value == expected_result, "Addition result error"

        # Check flags
        expected_co = ((AC_val + DR_val) >> W) & 0x1
        expected_ovf = (AC_val >> (W-1)) == (DR_val >> (W-1)) and \
                       (dut.Result.value >> (W-1)) != (AC_val >> (W-1))
        expected_z = expected_result == 0
        expected_n = (expected_result >> (W-1)) & 0x1

        assert dut.CO.value == expected_co, "Carry-out flag error"
        assert dut.OVF.value == expected_ovf, "Overflow flag error"
        assert dut.Z.value == expected_z, "Zero flag error"
        assert dut.N.value == expected_n, "Negative flag error"