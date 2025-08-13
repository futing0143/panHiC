import cooler
import numpy
c = cooler.Cooler('/cluster/home/futing/Project/GBM/Corigami/corigami_data/data/hg38/gbm/hic_matrix/GBM_9reso.mcool::/resolutions/50000')
for chrom in c.chromnames:
    contacts = c.matrix(balance=False).fetch(chrom)
    # contacts即为该染色体的contact计数矩阵
    numpy.savez_compressed(f'{chrom}.npz', contacts)