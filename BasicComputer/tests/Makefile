CWD=$(shell pwd)

SIM ?= icarus
TOPLEVEL_LANG ?=verilog


VERILOG_SOURCES += $(CWD)/../hdl/datapath.v
VERILOG_SOURCES += $(PWD)/../hdl/register.v
VERILOG_SOURCES += $(PWD)/../hdl/ALU.v
VERILOG_SOURCES += $(PWD)/../hdl/multiplexer.v
VERILOG_SOURCES += $(PWD)/../hdl/memory_unit.v
VERILOG_SOURCES += $(CWD)/../hdl/controller.v
VERILOG_SOURCES += $(CWD)/../hdl/BC_I.v

TOPLEVEL = BC_I
MODULE = BC_I_cocotb_test
COCOTB_HDL_TIMEUNIT=1us
COCOTB_HDL_TIMEPRECISION=1us

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim
