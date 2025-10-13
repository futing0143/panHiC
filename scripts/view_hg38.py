import pandas as pd
import bioframe
import cooler
import numpy as np
from optparse import OptionParser


desc="ger view_hg38_10k.tsv"

parser = OptionParser(description=desc)

parser.add_option("-i", "--input", action="store", type="string",
                  dest="input", help="Input cool or mcool file.", metavar="<file>")
parser.add_option("-n", "--name", action="store", type="string",
                  dest="name", help="Output file name.")

(opt, args) = parser.parse_args()
file =  opt.input
name = opt.name


# create a view of hg38 chromosome arms using chromosome sizes and definition of centromeres
hg38_chromsizes = bioframe.fetch_chromsizes('hg38')
hg38_cens = bioframe.fetch_centromeres('hg38')
view_hg38 = bioframe.make_chromarms(hg38_chromsizes,  hg38_cens)

# select only those chromosomes available in cooler

clr = cooler.Cooler(file)
view_hg38 = view_hg38.set_index("chrom").loc[clr.chromnames].reset_index()
view_hg38.to_csv(f"{name}_view_hg38.tsv", index=False, header=False, sep='\t')