# Rerencia:
# args es una tupla que dice que significa cada argumentos de la instruccion:

# D:   registro D
# T:   registro T
# S:   registro S
# H:   shamt
# I:   valor inmediato
# (S): registro S operaciones de lectura/escritura
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
        'args' : ('T', 'I', '(S)')
    },
    'LH':
    {
        'bin'  : 0b100001,
        'func' : 0b000000,
        'args' : ('T', 'I', '(S)')
    },
    'LW':
    {
        'bin'  : 0b100011,
        'func' : 0b000000,
        'args' : ('T', 'I', '(S)')
    },
    'LBU':
    {
        'bin'  : 0b100100,
        'func' : 0b000000,
        'args' : ('T', 'I', '(S)')
    },
    'LHU':
    {
        'bin'  : 0b100101,
        'func' : 0b000000,
        'args' : ('T', 'I', '(S)')
    },
    'LWU':
    {
        'bin'  : 0b100111,
        'func' : 0b000000,
        'args' : ('T', 'I', '(S)')
    },
    'SB':
    {
        'bin'  : 0b101000,
        'func' : 0b000000,
        'args' : ('T', 'I', '(S)')
    },
    'SH':
    {
        'bin'  : 0b101001,
        'func' : 0b000000,
        'args' : ('T', 'I', '(S)')
    },
    'SW':
    {
        'bin'  : 0b101011,
        'func' : 0b000000,
        'args' : ('T', 'I', '(S)')
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
    },
    'HLT':
    {
        'bin'  : 0b111111,
        'func' : 0b000000,
        'args' : ()
    }
}

reg_dict = {
    '$0'  : 0,
    '$at' : 1,
    '$v0' : 2,
    '$v1' : 3,
    '$a0' : 4,
    '$a1' : 5,
    '$a2' : 6,
    '$a3' : 7,
    '$t0' : 8,
    '$t1' : 9,
    '$t2' : 10,
    '$t3' : 11,
    '$t4' : 12,
    '$t5' : 13,
    '$t6' : 14,
    '$t7' : 15,
    '$s0' : 16,
    '$s1' : 17,
    '$s2' : 18,
    '$s3' : 19,
    '$s4' : 20,
    '$s5' : 21,
    '$s6' : 22,
    '$s7' : 23,
    '$t8' : 24,
    '$t9' : 25,
    '$k0' : 26,
    '$k1' : 27,
    '$gp' : 28,
    '$sp' : 29,
    '$fp' : 30,
    '$ra' : 31
}
