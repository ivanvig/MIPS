import ctypes
import sys
import re
from asm_dicts import *

regexp = re.compile(r'^\s*(?:(\w+:?)(?:\s+(\$?\w+)(?:\s*,\s*(\$?\w+)(?:(?:\s*,\s*(\$?\w+))|(?:\s*\(\s*(\$?\w+)\s*\)\s*))?)?)?)?\s*(?:#.*)?$')


class LabelReplacer:
    def __init__(self, code_list):
        self.code_list = code_list
        self.label_dict = dict()
        self.reqlabel_dict = dict()

    def add_new_label(self, label, n):
        if label in self.label_dict:
            raise ValueError

        self.label_dict[label] = n

        if label in self.reqlabel_dict:
            for l in self.reqlabel_dict[label]:
                if __debug__:
                    print('\t\tPrevious reference to this label found at {}° instruction'.format(l))
                    print('\t\tUpdated\t->\ttype: A\t|\tvalue: {}\t|\tcode: {:016b}[{}] '.format(label, (n - l) & 0xFFFF, (n-l)))

                self.code_list[l] += (n - l) & 0xFFFF

            del self.reqlabel_dict[label]

    def get_addr_from_label(self, label, n):
        if label in self.label_dict:
            return (self.label_dict[label] - n) & 0xFFFF
        else:
            if __debug__:
                print("\t\t\t[*]Label '{}' not found, {}° instruction added to requester list".format(label, n))

            if label in self.reqlabel_dict:
                self.reqlabel_dict[label].append(n)
            else:
                self.reqlabel_dict[label] = [n]

            return 0

def toint(str):
    if str[0:3] == '0x':
        base = 16
    elif str[0:3] == '0b':
        base = 2
    else:
        base = 10
    return int(str, base)


code_list = list()
labels = LabelReplacer(code_list)

with open(sys.argv[1], 'r') as fp:


    if __debug__:
        print('[DEBUG MODE: ON] ASSEMBLING FILE '+fp.name)

    for ln, line in enumerate(fp, 1):

        if line.isspace(): # linea en blanco
            if __debug__:
                print('ln. {}: Empty line, ignoring.'.format(ln))

            continue

        match = regexp.match(line)
        if not match: # linea mala
            raise SyntaxError('Error: invalid syntax wacho at line {}'.format(ln))

        parsed = match.groups()
        n_none = parsed.count(None)
        n_args = len(parsed) - n_none

        if parsed.count(None) == len(parsed): # comentario
            if __debug__:
                print('ln. {}: Comment, ignoring.'.format(ln))
            continue

        op = parsed[0]

        if op[-1] == ':': # label
            if __debug__:
                print('ln. {}: Label found, reference to instr n°{}, on line {}.'.format(ln, len(code_list), ln+1))
            labels.add_new_label(op[:-1], len(code_list))
            continue
        elif op not in op_dict:
            raise SyntaxError("Error: instruction '{}' not found at line {}.".format(op, ln))
        elif len(op_dict[op]['args']) != len(parsed) - n_none - 1:
            raise SyntaxError("Error: invalid number of arguments. Expected {} got {} at ln. {}".format(len(op_dict['args']), len(parsed)-n_none-1), ln)

        opdata = op_dict[op.upper()]
        opcode = opdata['bin']
        if __debug__:
            print('ln. {}: {}° Instruction {} found -> {:06b}.'.format(ln, len(code_list), op.upper(), opcode))

        argcode = 0
        for n, arg in enumerate(opdata['args'], 1):
            if arg == 'D':
                if parsed[n] not in reg_dict:
                    raise SyntaxError("Error: invalid register name '{}' at {}".format(parsed[n], ln))
                regaddr = reg_dict[parsed[n]]
                argcode += regaddr << 11

                if __debug__:
                    print("\t\t{}° arg\t->\ttype: {}\t|\tvalue: {}\t|\tcode: {:05b}".format(n, arg, parsed[n], regaddr))

            elif arg == 'T':
                if parsed[n] not in reg_dict:
                    raise SyntaxError("Error: invalid register name '{}' at {}".format(parsed[n], ln))
                regaddr = reg_dict[parsed[n]]
                argcode += regaddr << 16

                if __debug__:
                    print("\t\t{}° arg\t->\ttype: {}\t|\tvalue: {}\t|\tcode: {:05b}".format(n, arg, parsed[n], regaddr))

            elif arg == 'S':
                if parsed[n] not in reg_dict:
                    raise SyntaxError("Error: invalid register name '{}' at {}".format(parsed[n], ln))
                regaddr = reg_dict[parsed[n]]
                argcode += regaddr << 21

                if __debug__:
                    print("\t\t{}° arg\t->\ttype: {}\t|\tvalue: {}\t|\tcode: {:05b}".format(n, arg, parsed[n], regaddr))

            elif arg == '(S)':
                if parsed[n+1] not in reg_dict:
                    raise SyntaxError("Error: invalid register name '{}' at {}".format(parsed[n+1], ln))
                regaddr = reg_dict[parsed[n+1]]
                argcode += regaddr << 21

                if __debug__:
                    print("\t\t{}° arg\t->\ttype:{}|\tvalue: {}\t|\tcode: {:05b}".format(n, arg, parsed[n+1], regaddr))

            elif arg == 'H':
                argcode += (toint(parsed[n]) & 0b11111) << 6

                if __debug__:
                    print("\t\t{}° arg\t->\ttype: {}\t|\tvalue: {}\t|\tcode: {:05b}".format(n, arg, parsed[n], toint(parsed[n]) & 0b11111))

            elif arg in ('I'):
                argcode += toint(parsed[n]) & 0xFFFF

                if __debug__:
                    print("\t\t{}° arg\t->\ttype: {}\t|\tvalue: {}\t|\tcode: {:016b}".format(n, arg, parsed[n], toint(parsed[n]) & 0xFFFF))

            elif arg in ('II'):
                argcode += toint(parsed[n]) & ~(0b111111 << 26)

                if __debug__:
                    print("\t\t{}° arg\t->\ttype: {}\t|\tvalue: {}\t|\tcode: {:026b}".format(n, arg, parsed[n], toint(parsed[n]) & ~(0b111111 << 26)))

            elif arg == 'A':
                offset = labels.get_addr_from_label(parsed[n], len(code_list))
                argcode += offset

                if __debug__:
                    print("\t\t{}° arg\t->\ttype: {}\t|\tvalue: {}\t|\tcode: {:016b}[{}]".format(n, arg, parsed[n], offset, ctypes.c_int16(offset).value))

            else:
                raise SystemError("We shouldn't even be here mate, wtf happened. >:v")


        if op.upper() == 'HLT':
            code_list.append(0)
            code_list.append(0)
            code_list.append(0)
            code_list.append(0)
            code_list.append(0)

        code_list.append((opcode << 26) + argcode + opdata['func'])
        if __debug__:
            print("\t\tfunc\t->\t{:06b}".format(opdata['func']))
            print("\t\tCodified instruction: {:032b}".format(code_list[-1]))


    if labels.reqlabel_dict:
        raise EOFError("WHERE'S THE LABEL LEBOWSKI?")

if len(sys.argv) > 2:
    with open(sys.argv[2], 'wb') as fo:
        # loquetepinte = ''
        # for code in code_list:
        #     loquetepinte += '{:032b} '.format(code)
        # fo.write(loquetepinte)
        for code in code_list:
            fo.write(code.to_bytes(4, byteorder='big', signed=False))
