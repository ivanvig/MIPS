import cmd
from asm_dicts import reg_dict

commands = [
    'START',
    'RESET',
    'MODE',
    'STEP',
    'LOAD',
    'REQ'
]

mode_commands = [
    'GET',
    'SET_CONT',
    'SET_STEP'
]

load_commands = [
    'INSTR',
    'FILE'
]
req_commands = [
    'MEM_DATA',
    'MEM_INSTR',
    'REG',
    'REG_PC',
    'LATCH_FETCH_DATA',
    'LATCH_FETCH_CTRL',
    'LATCH_DECO_DATA',
    'LATCH_DECO_CTRL',
    'LATCH_EXEC_DATA',
    'LATCH_EXEC_CTRL',
    'LATCH_MEM_DATA',
    'LATCH_MEM_CTRL'
]

watch_list = []

class MipsCli(cmd.Cmd):
    prompt = 'MIPS>> '

    def __init__(self, mips):
        super().__init__()
        self.mips = mips

    def do_START(self, line):
        self.mips.start()

    def do_RESET(self,line):
        self.mips.reset()

    def do_MODE(self, line):
        if line == mode_commands[0]:
            print('0x{:08x}'.format((self.mips.get_mode())))
        elif line in mode_commands[1:]:
            self.mips.set_mode(line)
        else:
            print('quiacé?')

    def do_INIT(self, line):
        self.mips.init()

    def do_WATCH(self, line):
        global watch_list
        if line == 'CLEAR':
            watch_list = []
        else:
            watch_list.append(line)

    def do_STEP(self, line):
        it = int(line) if line else 1

        for i in range(int(it)):
            self.mips.step()
            for var in watch_list:
                print("-" + var + ':')
                self.do_REQ(var)

    def do_LOAD(self, line):
        comm = line.split(' ')
        if comm[0] == load_commands[0]:
            if not self.mips.load_instruction(bytearray.fromhex(comm[1]), int(comm[2])):
                print('LOAD INSTRUCTION FAILED')
        elif comm[0] == load_commands[1]:
            self.mips.load_instructions_from_file(comm[1])
        else:
            print('quiacé?')

    def do_REQ(self, line):
        comm = line.split(' ')
        comm = [comm[0], ''.join(comm[1:])]

        if comm[0] in req_commands:
            frame = self.mips.frame['REQ_'+comm[0]]
        else:
            print('quiacé?')
            return

        #MEM_DATA & MEM_INSTR
        if comm[0] == req_commands[0] or comm[0] == req_commands[1]:
            if len(comm) < 2:
                print('quiacé?')
                return

            if ':' in comm[1]:
                memrange = comm[1].split(':')
                for addr in range(int(memrange[0]), int(memrange[1])):
                    print('addr {}: 0x{:08x}'.format(addr, (self.mips.req_data(frame, addr))))
            else:
                addr = int(addr)
                print('addr {}: 0x{:08x}'.format(addr, (self.mips.req_data(frame, addr))))
        # REG
        elif comm[0] == req_commands[2]:
            if len(comm) < 2:
                print('quiacé?')
                return

            if ',' in comm[1]:
                for reg in comm[1].split(','):
                    if reg not in reg_dict.keys():
                        print('quiacé?')
                        return
                    addr = reg_dict[reg.strip()]
                    print('reg {}: 0x{:08x}'.format(reg.strip(), (self.mips.req_data(frame, addr))))
            else:
                if comm[1] not in reg_dict.keys():
                    print('quiacé?')
                    return
                addr = reg_dict[comm[1]]
                print('reg {}: 0x{:08x}'.format(comm[1].strip(), (self.mips.req_data(frame, addr))))

        # LATCH_FETCH_DATA
        elif comm[0] == req_commands[4]:
            print('IR: 0x{:08x}'.format((self.mips.req_data(frame))))

        # LATCH_FETCH_CTRL
        elif comm[0] == req_commands[5]:
            data = self.mips.req_data(frame)
            # print('PC+4: 0x{:08x}'.format((data & 0xFFFF)))
            print('PC: 0x{:08x}'.format((data & (0xFFFFFFFF << 32))))

        # LATCH_DECO_DATA
        elif comm[0] == req_commands[6]:
            data = self.mips.req_data(frame)
            print('SHAMT: 0x{:02x}'.format((data & (0x1F << (16+32+32)))))
            print('A: 0x{:08x}'.format((data & (0xFFFFFFFF << (16+32)))))
            print('B: 0x{:08x}'.format((data & (0xFFFFFFFF << 16))))
            print('INM: 0x{:04x}'.format((data & (0xFFFF))))

        # LATCH_DECO_CTRL
        elif comm[0] == req_commands[7]:
            data = self.mips.req_data(frame)
            print('EX_CTRL: 0x{:02x}'.format((data & (0x7F << (8+5+32)))))
            print('MEM_CTRL: 0x{:02x}'.format((data & (0x1F << (8+32)))))
            print('WB_CTRL: 0x{:02x}'.format((data & (0xFF << 32))))
            print('PC: 0x{:08x}'.format((data & (0xFFFFFFFF))))

        # LATCH_EXEC_DATA
        elif comm[0] == req_commands[8]:
            data = self.mips.req_data(frame)
            print('ALU: 0x{:08x}'.format((data & (0xFFFFFFFF << 32))))
            print('B: 0x{:08x}'.format((data & (0xFFFFFFFF))))

        # LATCH_EXEC_CTRL
        elif comm[0] == req_commands[9]:
            data = self.mips.req_data(frame)
            print('MEM_CTRL: 0x{:02x}'.format((data & (0x1F << (32+8)))))
            print('WB_CTRL: 0x{:02x}'.format((data & (0xFF << 32))))
            print('PC: 0x{:08x}'.format((data & (0xFFFFFFFF))))

        # LATCH_MEM_DATA
        elif comm[0] == req_commands[10]:
            data = self.mips.req_data(frame)
            print('REG_VAL: 0x{:08x}'.format((data & (0xFFFFFFFF << 32))))
            print('EXTENDED_MEM: 0x{:08x}'.format((data & (0xFFFFFFFF))))
        # LATCH_MEM_CTRL
        elif comm[0] == req_commands[11]:
            data = self.mips.req_data(frame)
            print('WB_CTRL: 0x{:02x}'.format((data & (0xFF << 32))))
            print('PC: 0x{:08x}'.format((data & (0xFFFFFFFF))))
        else:
            print('quiacé?')
            return

    def complete_START(self, text, line, start_index, end_index):
        pass

    def complete_RESET(self, text, line, start_index, end_index):
        pass

    def complete_MODE(self, text, line, start_index, end_index):
        if text:
            return [
                comm for comm in mode_commands
                if comm.startswith(text)
            ]
        else:
            return mode_commands

    def complete_STEP(self, text, line, start_index, end_index):
        pass
    def complete_LOAD(self, text, line, start_index, end_index):
        if text:
            return [
                comm for comm in load_commands
                if comm.startswith(text)
            ]
        else:
            return load_commands

    def complete_WATCH(self, text, line, start_index, end_index):
        return self.complete_REQ(text, line, start_index, end_index)

    def complete_REQ(self, text, line, start_index, end_index):
        if text:
            return [
                comm for comm in req_commands
                if comm.startswith(text)
            ]
        else:
            return req_commands

if __name__ == '__main__':
    my_cmd = MyCmd()
    my_cmd.cmdloop()
