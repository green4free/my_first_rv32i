import cocotb
from cocotb.triggers import Timer, RisingEdge
from cocotb.clock import Clock
import random


def reg_file_model_generator():
    register = [0 for _ in range(32)]
    def reg_file_model(rs1, rs2, rd, rd_v, we):
        nonlocal register
        rs1_v = register[rs1]
        rs2_v = register[rs2]
        if we:
            register[rd] = rd_v
        return rs1_v, rs2_v
    return reg_file_model


@cocotb.test()
async def reg_file_randomised_test(dut):
    model = reg_file_model_generator()

    dut.rs1.value = 0
    dut.rs2.value = 0
    dut.rd.value = 0
    dut.rd_v.value = 0
    dut.we.value = 0
    dut.rst_n.value = 0

    
    clock = Clock(dut.clk, 10, units="ns")  # Create a 10us period clock on port clk
    cocotb.start_soon(clock.start())  # Start the clock

    for reset_i in range(20):
        dut.rst_n.value = 0
        await Timer(random.randint(1, 50), units='ns')
        dut.rst_n.value = 1
        await RisingEdge(dut.clk_h)
        for input_i in range(500):
            
            rs1 = random.getrandbits(5)
            rs2 = random.getrandbits(5)
            rd = random.getrandbits(5)
            rd_v = random.getrandbits(32)
            we = random.getrandbits(1)

            m_rs1_v, m_rs2_v = model(rs1, rs2, rd, rd_v, we)

            dut.rs1.value = rs1
            dut.rs2.value = rs2
            dut.rd.value = rd
            dut.rd_v.value = rd_v
            dut.we.value = we

            await RisingEdge(dut.clk_h)
            await Timer(0, units='ps') #No idea why this is needed, problem with Icarus maybe?
            
            a, b, c, d = dut.rs1_v.value, m_rs1_v, dut.rs2_v.value, m_rs2_v 
            if not((a == b) and (c == d)): #Just using an assert made the actual error very hard to read in the wave form, so this way we get some sim time after the failure
                t = cocotb.utils.get_sim_time(units='ns')
                await Timer(50, units='ns')
                assert 0, f"At {t}ns Randomised test failed. Model: rs1 {b}, rs2 {d} DUT: rs1 {int(a)}, rs2 {int(c)}"
            