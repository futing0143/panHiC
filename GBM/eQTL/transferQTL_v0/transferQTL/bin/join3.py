#!/usr/bin/env python

import argparse, sys

parser = argparse.ArgumentParser()
parser = argparse.ArgumentParser(description='Process some integers.')
parser.add_argument("-a", "--file1", type=str, 
		help="file name or stdin. This is the file that is stored in memory")
parser.add_argument("-b", "--file2", type=str, help="file name or stdin")
parser.add_argument("-x", type=str, default="1", help="index of the field you want file a to be joined on. Accept multiple indices comma-separated")
parser.add_argument("-y", type=str, default="1", help="index of the field you want file b to be joined on. Accept multiple indices comma-separated")
parser.add_argument("--a_header", action="store_true", help="file 'a' has a header")
parser.add_argument("--b_header", action="store_true", help="file 'b' has a header")
parser.add_argument("-u", "--unmatched", action="store_true", help="output lines in file 'b' with no correspondence in file 'a'")
parser.add_argument("-p", "--placeholder", type=str, default="-", help="Placeholder character for unmatched lines in file 'a' - only works in combination with '--unmatched'")
args = parser.parse_args()

# @@@ CHECK OPTIONS @@@

if args.file1 == "stdin" and args.file2 == "stdin":
    print("ERROR: Cannot read both files from stdin!")
    exit()

x_indices = list(map(int, args.x.split(",")))
y_indices = list(map(int, args.y.split(",")))

file1 = sys.stdin if args.file1 == "stdin" else open(args.file1)
file2 = sys.stdin if args.file2 == "stdin" else open(args.file2)

# @@@ READ FILE1 @@@

d = {}
for i, line in enumerate(file1):
    if line.strip() == "":
        continue
    if args.unmatched:
        if i == 0:
            ph = "\t".join((args.placeholder for i, el in enumerate(line.strip().split("\t")) if i + 1 not in x_indices))
    if args.a_header:
        if i == 0:
            h1 = "\t".join((el for i, el in enumerate(line.strip().split("\t")) if i + 1 not in x_indices))
            continue
    line_sp = line.strip().split("\t")
    x_fields = len(line_sp) - len(x_indices)
    k = "_".join(line_sp[x_index - 1].strip() for x_index in x_indices)
    d[k] = "\t".join((el for i, el in enumerate(line.strip().split("\t")) if i + 1 not in x_indices))

# @@@ READ FILE2 AND INTERSECT WITH FILE1 @@@

for i, line in enumerate(file2):
    if line.strip() == "":
        continue
    line_sp = line.strip().split("\t")
    if args.b_header and args.a_header:
        if i == 0:
            h2 = line.strip()
            print(f"{h2}\t{h1}")
            continue
    if args.b_header and not args.a_header:
        if i == 0:
            h2 = line.strip()
            h1 = "\t".join(f"V{n + 1}" for n in range(x_fields))
            print(f"{h2}\t{h1}")
            continue
    if not args.b_header and args.a_header:
        if i == 0:
            h2 = "\t".join(f"V{n + 1}" for n in range(len(line_sp)))
            print(f"{h2}\t{h1}")
    if not args.b_header and not args.a_header:
        if i == 0:
            h1 = "\t".join(f"V{n + 1}" for n in range(len(line_sp) + 1, x_fields))
            h2 = "\t".join(f"V{n + 1}" for n in range(len(line_sp)))
    k = "_".join(line_sp[y_index - 1] for y_index in y_indices)
    if k in d:
        print(f"{line.strip()}\t{d[k]}")
    elif args.unmatched:
        print(f"{line.strip()}\t{ph}")

file1.close()
file2.close()