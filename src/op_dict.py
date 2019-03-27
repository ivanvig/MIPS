# Referencia:
# args es una tupla que dice que significa cada argumentos de la instruccion:

# D:   registro D
# T:   registro T
# S:   registro S
# H:   shamt
# I:   valor inmediato
# (I): valor inmediato pasado como offset (lectura/escritura memoria)
# II:  inmediato largo (instrucciones de tipo J)
# A:   Tag

op_dict = {
    'SLL'  :
    {
        'bin'  : 0b000000,
        'func' : 0b000000,
        'args' : ('D', 'T', 'H')
    },
    'SRL'  :
    {
        'bin'  : 0b000000,
        'func' : 0b000010,
        'args' : ('D', 'T', 'H')
    },
    'SRA'  :
    {
        'bin'  : 0b000000,
        'func' : 0b000011,
        'args' : ('D', 'T', 'H')
    },
    'SLLV' :
    {
        'bin'  : 0b000000,
        'func' : 0b000100,
        'args' : ('D', 'T', 'S')
    },
    'SRLV' :
    {
        'bin'  : 0b000000,
        'func' : 0b000110,
        'args' : ('D', 'T', 'S')
    },
    'SRAV' :
    {
        'bin'  : 0b000000,
        'func' : 0b000111,
        'args' : ('D', 'T', 'S')
    },
    'ADDU' :
    {
        'bin'  : 0b000000,
        'func' : 0b100001,
        'args' : ('D', 'T', 'S')
    },
    'SUBU' :
    {
        'bin'  : 0b000000,
        'func' : 0b100011,
        'args' : ('D', 'T', 'S')
    },
    'AND'  :
    {
        'bin'  : 0b000000,
        'func' : 0b100100,
        'args' : ('D', 'T', 'S')
    },
    'OR'   :
    {
        'bin'  : 0b000000,
        'func' : 0b100101,
        'args' : ('D', 'T', 'S')
    },
    'XOR'  :
    {
        'bin'  : 0b000000,
        'func' : 0b100110,
        'args' : ('D', 'T', 'S')
    },
    'NOR'  :
    {
        'bin'  : 0b000000,
        'func' : 0b100111,
        'args' : ('D', 'T', 'S')
    },
    'SLT'  :
    {
        'bin'  : 0b000000,
        'func' : 0b101010,
        'args' : ('D', 'S', 'T')
    },
    'JR'   :
    {
        'bin'  : 0b000000,
        'func' : 0b001000,
        'args' : ('S',)
    },
    'JALR' :
    {
        'bin'  : 0b000000,
        'func' : 0b001001,
        'args' : ('D', 'S')
    },
    'LB':
    {
        'bin'  : 0b100000,
        'func' : 0b000000,
        'args' : ('T', 'S', '(I)')
    },
    'LH':
    {
        'bin'  : 0b100001,
        'func' : 0b000000,
        'args' : ('T', 'S', '(I)')
    },
    'LW':
    {
        'bin'  : 0b100011,
        'func' : 0b000000,
        'args' : ('T', 'S', '(I)')
    },
    'LBU':
    {
        'bin'  : 0b100100,
        'func' : 0b000000,
        'args' : ('T', 'S', '(I)')
    },
    'LHU':
    {
        'bin'  : 0b100101,
        'func' : 0b000000,
        'args' : ('T', 'S', '(I)')
    },
    'LWU':
    {
        'bin'  : 0b100111,
        'func' : 0b000000,
        'args' : ('T', 'S', '(I)')
    },
    'SB':
    {
        'bin'  : 0b101000,
        'func' : 0b000000,
        'args' : ('T', 'S', '(I)')
    },
    'SH':
    {
        'bin'  : 0b101001,
        'func' : 0b000000,
        'args' : ('T', 'S', '(I)')
    },
    'SW':
    {
        'bin'  : 0b101011,
        'func' : 0b000000,
        'args' : ('T', 'S', '(I)')
    },
    'ADDI':
    {
        'bin'  : 0b001001,
        'func' : 0b000000,
        'args' : ('T', 'S', 'I')
    },
    'ANDI':
    {
        'bin'  : 0b001100,
        'func' : 0b000000,
        'args' : ('T', 'S', 'I')
    },
    'ORI':
    {
        'bin'  : 0b001101,
        'func' : 0b000000,
        'args' : ('T', 'S', 'I')
    },
    'XORI':
    {
        'bin'  : 0b001110,
        'func' : 0b000000,
        'args' : ('T', 'S', 'I')
    },
    'LUI':
    {
        'bin'  : 0b001111,
        'func' : 0b000000,
        'args' : ('T', 'S', 'I')
    },
    'SLTI':
    {
        'bin'  : 0b001010,
        'func' : 0b000000,
        'args' : ('T', 'S', 'I')
    },
    'BEQ':
    {
        'bin'  : 0b000100,
        'func' : 0b000000,
        'args' : ('T', 'S', 'A')
    },
    'BNE':
    {
        'bin'  : 0b000101,
        'func' : 0b000000,
        'args' : ('T', 'S', 'A')
    },
    'J':
    {
        'bin'  : 0b000010,
        'func' : 0b000000,
        'args' : ('II',)
    },
    'JAL':
    {
        'bin'  : 0b000011,
        'func' : 0b000000,
        'args' : ('II',)
    }
}
