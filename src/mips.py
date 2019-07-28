from enum import IntEnum

class MipsFrame(IntEnum):
    INIT                 = 0b1010_10 << 26
    START                = 0b0000_01 << 26
    RESET                = 0b0000_10 << 26
    MODE_GET             = 0b0010_00 << 26
    MODE_SET_CONT        = 0b0010_01 << 26
    GOT_DATA             = 0b1001_00 << 26
    MODE_SET_STEP        = 0b0010_10 << 26
    STEP                 = 0b1000_00 << 26
    LOAD_INSTR_LSB       = 0b0001_00 << 26
    LOAD_INSTR_MSB       = 0b0001_01 << 26
    REQ_MEM_DATA         = 0b0000_1100_0000_0001 << 16
    REQ_MEM_INSTR        = 0b0000_1100_0000_0010 << 16
    REQ_REG              = 0b0000_1100_0000_0100 << 16
    REQ_REG_PC           = 0b0000_1100_0000_0101 << 16
    REQ_LATCH_FETCH_DATA = 0b0000_1100_0000_1000 << 16
    REQ_LATCH_FETCH_CTRL = 0b0000_1100_0000_1001 << 16
    REQ_LATCH_DECO_DATA  = 0b0000_1100_0001_0000 << 16
    REQ_LATCH_DECO_CTRL  = 0b0000_1100_0001_0001 << 16
    REQ_LATCH_EXEC_DATA  = 0b0000_1100_0010_0000 << 16
    REQ_LATCH_EXEC_CTRL  = 0b0000_1100_0010_0001 << 16
    REQ_LATCH_MEM_DATA   = 0b0000_1100_0100_0000 << 16
    REQ_LATCH_MEM_CTRL   = 0b0000_1100_0100_0001 << 16

class Mips:
    def __init__(self, serial_port):
        self.port = serial_port
        self.frame = MipsFrame

    def start(self):
        self.send_msg(self.frame.START)

    def get_mode(self):
        return self.req_data(self.frame.MODE_GET, 0)

    def set_mode(self, mode):
        if (mode == 'SET_CONT'):
            self.send_msg(self.frame.MODE_SET_CONT)
        elif (mode == 'SET_STEP'):
            self.send_msg(self.frame.MODE_SET_STEP)
        else:
            raise(ValueError("que mode es ese?"))



    def reset(self):
        self.send_msg(self.frame.RESET)

    def step(self):
        self.send_msg(self.frame.STEP)

    def send_msg(self, msg):
        self.safe_write(msg.to_bytes(4, byteorder='little'))

    def load_instructions_from_file(self, file, check=True):
        with open(file, 'rb') as ff:
            addr = 0
            while True:
                word = ff.read(4)
                if not word:
                    break
                status = self.load_instruction(word, addr)
                if check and not status:
                    raise RuntimeError("Error en la escritura de la instruccion %s en la posicion %d"%(word.hex(), addr))
                addr += 1

    def load_instruction(self, instruction, address, check=True):
        msg = self.frame.LOAD_INSTR_LSB + (address << 16) + int.from_bytes(instruction[2:], byteorder='big')
        self.send_msg(msg)
        msg = self.frame.LOAD_INSTR_MSB + (address << 16) + int.from_bytes(instruction[:2], byteorder='big')
        self.send_msg(msg)
        if check:
            recv_data = self.req_data(self.frame.REQ_MEM_INSTR, address)
            return recv_data == int.from_bytes(instruction, byteorder='big')
        else:
            return True

    def req_data(self, frame_type, addr=0):
        msg = (frame_type + addr)
        self.send_msg(msg)
        while(self.port.read(size=4) != self.frame.GOT_DATA.to_bytes(4, byteorder='little')):
            pass
        ndata = self.port.read()
        data = self.port.read(size=int.from_bytes(ndata, byteorder='little'))
        return int.from_bytes(data, byteorder='little')

    def init(self):
        self.send_msg(self.frame.INIT)
        while(True):
            string = self.port.readline()
            string = string.rstrip('\n'.encode("utf-8"))

            if not string:
                break

            print(string.decode("utf-8"))

    def safe_write(self, msg):
        dsize = self.port.write(msg)
        if dsize is not len(msg):
            raise RuntimeError("Comunicacion UART no bien")







