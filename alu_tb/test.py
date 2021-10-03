import cocotb
from cocotb.triggers import Timer, RisingEdge
from cocotb.clock import Clock
import random



#def alu_model(funct3, mod, val1, val2):


    

#Verified by cheking waveforms manually for now.. Might create an automatic testbench later
@cocotb.test()
async def alu_randomised_test(dut):
    for i in range(64):
        dut.funct3.value = i % 8
        dut.mod.value = (i >> 3) % 2
        dut.val1.value = i
        dut.val2.value = 1 - 3*(i > 31)
        await Timer(5, units='ns')
    dut.val2.value = 0
    await Timer(5, units='ns')
    for i in range(64):
        dut.funct3.value = i % 8
        dut.mod.value = (i >> 3) % 2
        dut.val1.value = -i
        dut.val2.value = 1 - 3*(i > 31)
        await Timer(5, units='ns')
