import numpy as np

with open("assembly.s","r") as f:
    mem = np.zeros((2**12,),dtype=np.uint16)
    lines = f.readlines()
    address = 0
    for i,line in enumerate(lines):
        line = line.split(";")[0].strip()
        args = line.split(" ")
        if len(args) == 3:
            if mem[address] != 0:
                raise SyntaxError(f"Line {i} overrides previous operation: \"{line}\"")
            mem[address] |= eval(args[0])*0x8000
            if args[1] == "AND":
                mem[address] |= 0x0000
            elif args[1] == "ADD":
                mem[address] |= 0x1000
            elif args[1] == "LDA":
                mem[address] |= 0x2000
            elif args[1] == "STA":
                mem[address] |= 0x3000
            elif args[1] == "BUN":
                mem[address] |= 0x4000
            elif args[1] == "BSA":
                mem[address] |= 0x5000
            elif args[1] == "ISZ":
                mem[address] |= 0x6000
            mem[address] += eval(args[2])&0x0FFF
        elif len(args) == 2:
            if args[0] == "ORG":
                address = eval(args[1])&0x0FFF
                continue
        elif len(args) == 1:
            if mem[address] != 0:
                raise SyntaxError(f"Line {i} overrides previous operation: \"{line}\"")
            if args[0] == "CLA":
                mem[address] = 0x7800
            elif args[0] == "CLE":
                mem[address] = 0x7400
            elif args[0] == "CMA":
                mem[address] = 0x7200
            elif args[0] == "CME":
                mem[address] = 0x7100
            elif args[0] == "CIR":
                mem[address] = 0x7080
            elif args[0] == "CIL":
                mem[address] = 0x7040
            elif args[0] == "INC":
                mem[address] = 0x7020
            elif args[0] == "SPA":
                mem[address] = 0x7010
            elif args[0] == "SNA":
                mem[address] = 0x7008
            elif args[0] == "SZA":
                mem[address] = 0x7004
            elif args[0] == "SZE":
                mem[address] = 0x7002
            elif args[0] == "HLT":
                mem[address] = 0x7001
            elif args[0] == "ION":
                mem[address] = 0xF080
            elif args[0] == "IOF":
                mem[address] = 0xF040
            elif args[0] == "":
                continue
            else:
                mem[address] = eval(args[0])&0xFFFF

        elif len(args) > 3:
            raise SyntaxError(f"Line {i} has too many arguments ({len(args)}): \"{line}\"")
        address += 1
    
with open("memory_content.hex", "w+") as f:
    for i in range(mem.shape[0]):
        f.write(f"{mem[i]:0>4X}\n")