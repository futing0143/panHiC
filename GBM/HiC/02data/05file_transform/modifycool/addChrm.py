import cooler, sys
import h5py

'''
This script adds chrM to the cooler file.
'''
in_cool = sys.argv[1]
clr = cooler.Cooler(in_cool)
binsize = 100000
#c = cooler.Cooler('no_chrM.cool')
chromsizes = cooler.util.fetch_chromsizes('hg38')   # includes chrM by default
bins_with_chrM = cooler.binnify(chromsizes, binsize)
chunksize = 10000000
spans = cooler.tools.partition(0, len(clr.pixels()), chunksize)
chunk_generator = (clr.pixels()[lo:hi] for lo, hi in spans)
cooler.io.create(sys.argv[2], bins_with_chrM, chunk_generator)
