import cooler, sys
import h5py

in_cool = sys.argv[1]
clr = cooler.Cooler(in_cool)
binsize = 100000
#c = cooler.Cooler('DIPG-3810.mcool::::resolutions/100000')
chromsizes = cooler.util.fetch_chromsizes('hg38')[:'chrY'] 
print(chromsizes)
bins_without_chrM = cooler.binnify(chromsizes, binsize)
print(bins_without_chrM)
chunksize = 10000000
spans = cooler.tools.partition(0, len(c.pixels()), chunksize)
def chunk_generator(): 
    for i, (lo, hi) in enumerate(spans):
        print('chunk', i)
        pixels = clr.pixels()[lo:hi]
        # only necessary if there are chrM hits
        pixels = cooler.annotate(pixels, clr.bins()[['chrom']], replace=False)
        pixels = pixels[(pixels.chrom1 != 'chrM') & (pixels.chrom2 != 'chrM')]
        yield pixels
cooler.io.create(sys.argv[2], bins_without_chrM, chunk_generator())
