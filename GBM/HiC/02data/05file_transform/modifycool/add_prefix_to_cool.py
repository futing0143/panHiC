#!/usr/bin/env python

import cooler, sys

in_cool = sys.argv[1]

clr = cooler.Cooler(in_cool)
chromlist = clr.chromnames
chrom_map = {c: 'chr' + c if not c.startswith('chr') else c for c in chromlist}
cooler.rename_chroms(clr, chrom_map)


###给cooler文件中染色体添加chr