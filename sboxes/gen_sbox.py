import sys

name = sys.argv[1]
filename_read = '{}.txt'.format(name)
filename_write = '{}.v'.format(name)
arr = []

with open(filename_read) as f:
    for line in f:
        arr.append([int(x) for x in line.split()])

def sbox_value(sbox, num):
    row = ((num & 0b100000) >> 4) | (num & 0b000001)
    column = (num & 0b011110) >> 1
    return arr[row][column]

with open(filename_write, 'w') as f:
    f.write('module {}(input [6:1] in, output reg [4:1] out);\n'.format(name))
    f.write('  always @* case (in)\n')
    for i in range(2 ** 6):
        f.write('    {} : out = {};\n'.format(i, sbox_value(arr, i)))
    f.write('  endcase\n')
    f.write('endmodule\n')
