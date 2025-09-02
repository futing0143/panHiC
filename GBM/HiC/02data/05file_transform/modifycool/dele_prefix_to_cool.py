#!/usr/bin/env python

import cooler, sys




in_cool = sys.argv[1]

clr = cooler.Cooler(in_cool)
chromlist = clr.chromnames
chrom_map = {c:c.replace("chrchr","chr") for c in chromlist}
cooler.rename_chroms(clr, chrom_map)
