# parse_sv.py
import sys

cancer, cell, infile = sys.argv[1], sys.argv[2], sys.argv[3]

for i, line in enumerate(open(infile)):
    f = line.strip().split('\t')
    sv = f[1].split(",")

    print("\t".join([
        cancer,
        cell,
        f"SV{i}",
        sv[0],
        "chr"+sv[1], sv[2], sv[3],
        "chr"+sv[4], sv[5], sv[6]
    ]))
