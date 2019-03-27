import re

regexp = re.compile(r'^\s*(?:(\w+:?)\s+(?:(\$?\w+)(?:\s*,\s*(\$?\w+)(?:\s*,\s*(\$?\w+)|\s*\(\s*\($?\w+)\s*\))?)?)?)?\s*(?:#.*)?$')

labels = dict()

with open('fib.asm', 'r') as fp:

    foff = 0
    for nline, line in enumerate(fp):
        if line.isspace(): # linea en blanco
            foff += 1
            continue

        match = regexp.match(line)
        if not match: # linea mala
            raise ValueError

        parsed = match.groups()
        n_none = parsed.count(None)
        n_args = len(parsed) - n_none

        if parsed.count(None) == len(parsed): # comentario
            foff += 1
            continue

        op = parsed[0]

        if op[-1] == ':': # label
            # TODO: ojo aca con el valor de nline y foff
            labels[op[:-1]] = nline
            foff += 1
            continue
        elif op not in op_dict:
            raise ValueError
        elif len(asd2bin[op]['args']) != len(parsed) - n_none - 1:
            raise ValueError

        opdata = op_dict[op.upper()]
        opcode = opdata['bin']

        argcode = 0
        for n, arg in enumerate(opdata['args'], 1):
            if arg == 'D':
                regaddr = reg_dict[parsed[n]]
                argcode += regaddr << 11
            elif arg == 'T':
                regaddr = reg_dict[parsed[n]]
                argcode += regaddr << 16
            elif arg == 'S':
                regaddr = reg_dict[parsed[n]]
                argcode += regaddr << 21
            elif arg == 'H':
                argcode += (parsed[n] << 6) & ~(0b111111 << 26)
            elif arg in ('I', 'II'):
                argcode += (parsed[n]) & ~(0b111111 << 26)
            elif arg == '(I)':
                argcode += (parsed[n+1]) & ~(0b111111 << 26)
            elif arg == 'A':
                argcode += get_relative_addr(parsed[n]) & ~(0b111111 << 26)
            else:
                raise ValueError

        instrbits = (opcode << 26) + argcode






