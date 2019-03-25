import re

regexp = re.compile(r'^\s*(?:(\w+:?)\s+(?:(\$?\w+)(?:\s*,\s*(\$?\w+)(?:\s*,\s*(\$?\w+)|\s*\(\s*\($?\w+)\s*\))?)?)?)?\s*(?:#.*)?$')

labels = dict()

with open('fib.asm', 'r') as fp:

    for n, line in enumerate(fp):
        if line.isspace(): # linea en blanco
            continue

        match = regexp.match(line)
        if not match: # linea mala
            raise ValueError

        parsed = match.groups()
        n_none = parsed.count(None)
        n_args = len(parsed) - n_none
        if parsed.count(None) == len(parsed): # comentario
            continue

        op = parsed[0]
        if op[-1] == ':': # label
            labels[op[:-1]] = n
        else:

            opcode = asm2bin[op]['bin']





