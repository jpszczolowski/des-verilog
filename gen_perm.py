import sys

name = sys.argv[1]
filename_read = '{}.txt'.format(name)
filename_write = '{}.v'.format(name)
arr = []

with open(filename_read) as f:
    for line in f:
        arr.extend([int(x) for x in line.split()])

in_size = max(arr)
if in_size % 2 == 1:
    in_size += 1

with open(filename_write, 'w') as f:
    f.write('module {}(input [1:{}] in, output [1:{}] out);\n'.format(name, in_size, len(arr)))
    for idx, x in enumerate(arr):
        f.write('  assign out[{}] = in[{}];\n'.format(idx + 1, x))
    f.write('endmodule\n')
