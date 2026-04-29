import os

OPCODES = {
    'ADD': '0000', 'SUB': '0001', 'AND': '0010', 'OR': '0011',
    'SHL': '0100', 'SHR': '0101', 'LDI': '0110', 'LOAD': '0111',
    'STORE': '1000', 'JMP': '1001', 'JMPZ': '1010', 'RETI': '1011'
}

ADDRESSES = {'LEDS': '0xFD', 'DDR': '0xFE', 'PORT': '0xFF'}
REGISTERS = {f'R{i}': format(i, '04b') for i in range(16)}

def assemble_line(line, labels):
    line = line.split(';')[0].strip()
    if not line or line.endswith(':'): return None # Ignore empty lines and labels
    
    parts = line.replace(',', ' ').split()
    instr = parts[0].upper()
    
    if instr not in OPCODES:
        return None
        
    opcode_bin = OPCODES[instr]
    
    # 1. Immediate Format (Only LDI)
    if instr == 'LDI':
        reg_dest = REGISTERS[parts[1].upper()]
        raw_val = parts[2].upper()
        val = ADDRESSES[raw_val] if raw_val in ADDRESSES else raw_val
        val_imm = format(int(val, 0), '08b')
        return opcode_bin + reg_dest + val_imm
        
    # 2. Load/Store Format
    elif instr == 'STORE':
        reg_data = REGISTERS[parts[1].upper()]
        reg_addr = REGISTERS[parts[2].upper()]
        return opcode_bin + '0000' + reg_data + reg_addr
        
    elif instr == 'LOAD':
        reg_dest = REGISTERS[parts[1].upper()]
        reg_addr = REGISTERS[parts[2].upper()]
        return opcode_bin + reg_dest + '0000' + reg_addr
        
    # 3. Math Register Format
    elif instr in ['ADD', 'SUB', 'AND', 'OR', 'SHL', 'SHR']:
        reg_d  = REGISTERS[parts[1].upper()]
        reg_s1 = REGISTERS[parts[2].upper()]
        reg_s2 = REGISTERS[parts[3].upper()]
        return opcode_bin + reg_d + reg_s1 + reg_s2

    # 4. Jump Format
    elif instr in ['JMP', 'JMPZ']:
        raw_addr = parts[1].upper()
        if raw_addr in labels:
            addr_val = labels[raw_addr]
        elif raw_addr in ADDRESSES:
            addr_val = int(ADDRESSES[raw_addr], 0)
        else:
            addr_val = int(raw_addr, 0)
            
        addr_bin = format(addr_val, '08b')
        return opcode_bin + '0000' + addr_bin
    
    # 5. RETI Format
    elif instr == 'RETI':
        return opcode_bin + '000000000000'

    return None

def assemble_file(input_filename, output_filename):
    with open(input_filename, 'r') as f:
        lines = f.readlines()

    # --- STEP 1: Find label addresses ---
    labels = {}
    instruction_count = 0
    for line in lines:
        line = line.split(';')[0].strip()
        if not line: continue
        if line.endswith(':'):
            labels[line[:-1].upper()] = instruction_count
        else:
            instruction_count += 1 

    # --- STEP 2: Generate .mif binary ---
    with open(output_filename, 'w') as f_out:
        # Mandatory Quartus Header
        f_out.write("WIDTH=16;\n")
        f_out.write("DEPTH=256;\n")
        f_out.write("ADDRESS_RADIX=UNS;\n")
        f_out.write("DATA_RADIX=BIN;\n")
        f_out.write("CONTENT BEGIN\n")

        address = 0
        for line in lines:
            binary_line = assemble_line(line, labels)
            if binary_line:
                f_out.write(f"\t{address} : {binary_line};\n")
                address += 1
                
        # Fill the remaining empty memory with zeros (NOP instruction)
        if address < 256:
            f_out.write(f"\t[{address}..255] : 0000000000000000;\n")
            
        f_out.write("END;\n")
        
    return labels

if __name__ == '__main__':
    # Automatically resolve paths relative to the script's location
    script_dir = os.path.dirname(os.path.abspath(__file__))
    input_asm = os.path.join(script_dir, 'cod.asm')
    output_bin = os.path.join(script_dir, 'program.mif')

    try:
        rezultat_labels = assemble_file(input_asm, output_bin)
        print(f"Success! Quartus MIF file generated at: {output_bin}")
        print(f"Labels resolved: {list(rezultat_labels.keys())}")
    except FileNotFoundError:
        print(f"Error: Could not find '{input_asm}'. Make sure the assembly file is in the same folder.")