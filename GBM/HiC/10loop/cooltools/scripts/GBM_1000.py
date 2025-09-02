import cooltools
import numpy as np
import cooler
import pandas as pd
import bioframe

def get_kernel(w, p, ktype):
    """
    Return typical kernels given size parameteres w, p,and kernel type.

    Parameters
    ----------
    w : int
        Outer kernel size (actually half of it).
    p : int
        Inner kernel size (half of it).
    ktype : str
        Name of the kernel type, could be one of the following: 'donut',
        'vertical', 'horizontal', 'lowleft', 'upright'.

    Returns
    -------
    kernel : ndarray
        A square matrix of int type filled with 1 and 0, according to the
        kernel type.

    """
    width = 2 * w + 1
    kernel = np.ones((width, width), dtype=np.int64)
    # mesh grid:
    y, x = np.ogrid[-w : w + 1, -w : w + 1]

    if ktype == "donut":
        # mask inner pXp square:
        mask = (((-p) <= x) & (x <= p)) & (((-p) <= y) & (y <= p))
        # mask vertical and horizontal
        # lines of width 1 pixel:
        mask += (x == 0) | (y == 0)
        # they are all 0:
        kernel[mask] = 0
    elif ktype == "vertical":
        # mask outside of vertical line
        # of width 3:
        mask = ((-1 > x) | (x > 1)) & ((y >= -w))
        # mask inner pXp square:
        mask += ((-p <= x) & (x <= p)) & ((-p <= y) & (y <= p))
        # kernel masked:
        kernel[mask] = 0
    elif ktype == "horizontal":
        # mask outside of horizontal line
        # of width 3:
        mask = ((-1 > y) | (y > 1)) & ((x >= -w))
        # mask inner pXp square:
        mask += ((-p <= x) & (x <= p)) & ((-p <= y) & (y <= p))
        # kernel masked:
        kernel[mask] = 0
    # ACHTUNG!!! UPRIGHT AND LOWLEFT ARE SWITCHED ...
    # IT SEEMS FOR UNKNOWN REASON THAT IT SHOULD
    # BE THAT WAY ...
    # OR IT'S A MISTAKE IN hIccups AS WELL ...
    elif ktype == "upright":
        # mask inner pXp square:
        mask = ((x >= -p)) & ((y <= p))
        mask += x >= 0
        mask += y <= 0
        # kernel masked:
        kernel[mask] = 0
    elif ktype == "lowleft":
        # mask inner pXp square:
        mask = ((x >= -p)) & ((y <= p))
        mask += x >= 0
        mask += y <= 0
        # reflect that mask to
        # make it upper-right:
        mask = mask[::-1, ::-1]
        # kernel masked:
        kernel[mask] = 0
    else:
        raise ValueError("Kernel-type {} has not been implemented yet".format(ktype))
    return kernel

w, p = 7, 4
kernel_types = ["donut", "vertical", "horizontal", "lowleft"]

# generate standard kernels - consider providing custom ones
kernels = {k: get_kernel(w, p, k) for k in kernel_types}

reso='1000'
name='GBM'
file=f'/cluster/home/futing/Project/GBM/HiC/02data/03cool_order/{reso}/{name}_{reso}.cool'
expected=pd.read_csv('/cluster/home/futing/Project/GBM/HiC/10loop/cooltools/results/GBM/expected.cis.1000.tsv',sep='\t')
hg38_arms=pd.read_csv('/cluster/home/futing/Project/GBM/HiC/10loop/cooltools/results/GBM/GBM_view_hg38.tsv',sep='\t')
clr=cooler.Cooler(file)


# define genomic view that will be used to call dots and pre-compute expected

# Use bioframe to fetch the genomic features from the UCSC.
hg38_chromsizes = bioframe.fetch_chromsizes('hg38')
hg38_cens = bioframe.fetch_centromeres('hg38')
hg38_arms = bioframe.make_chromarms(hg38_chromsizes, hg38_cens)

# Select only chromosomes that are present in the cooler.
hg38_arms = hg38_arms.set_index("chrom").loc[clr.chromnames].reset_index()

# ---- Running dots
dots_df_all = cooltools.dots(
    clr,
	kernels=kernels,
    expected=expected,
    view_df=hg38_arms,
    max_loci_separation=10_000_000,
    clustering_radius=None,  # None - implies no clustering
    cluster_filtering=False,  # ignored when clustering is off
    nproc=10,
)

#
dots_df_all.to_csv('/cluster/home/futing/Project/GBM/HiC/10loop/cooltools/results/GBM/dots.1000.tsv',sep='\t')