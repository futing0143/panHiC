import sys
import cooler
import pandas as pd
from matplotlib.colors import LinearSegmentedColormap
sys.path.insert(0, '/cluster2/home/futing/Project/panCancer/Analysis/')

import neoloop.visualize.core as core
print(dir(core))


workdir = '/cluster2/home/futing/Project/panCancer/GBM/HiC/11SV/NeoLoopFinder-master'


region = "chr12:88039015-90965176"
s = "chr12_89349788_89350164"
parts = s.split("_")
result = (parts[0], int(parts[1]), int(parts[2]))
cell='GBM'
clr = cooler.Cooler('/cluster2/home/futing/Project/panCancer/GBM/HiC/02data/03cool_order/10000/A172_10000.cool')
GBM_RNA= '/cluster2/home/futing/Project/panCancer/GBM/RNA/sample/20240830/analysis/U87/U87_RPKM.bw'
GBM_H3K27ac='/cluster2/home/futing/Project/panCancer/GBM/ChIP/H3K27ac/U87_new/bigwig/SRR14862242_input.bw'

# Create the visualization
vis = core.GenomicRegionPlot(clr, "chr12:88039015-90965176", figsize=(7, 5.8),
			track_partition=[5, 0.8, 0.8, 0.3,0.5, 0.5],n_rows=6, correct=True)
# custom_cmap = LinearSegmentedColormap.from_list('custom_cmap', ['#1065ad', 'white', '#bc020f'])
vis.matrix_plot(vmin=1e-03,vmax=5e-02) #,colormap=custom_cmap)

vis.plot_signal('H3K27ac', GBM_H3K27ac, label_size=10, data_range_size=9, max_value='auto', color='#6A3D9A')
vis.plot_signal('RNA', GBM_RNA, label_size=10, data_range_size=9,  max_value='auto', color='#E31A1C')
vis.plot_loops('/cluster2/home/futing/Project/panCancer/GBM/HiC/UCSC/GBM/data/GBM.links', face_color='none', marker_size=40)
vis.plot_chromosome_bounds(linewidth=2)
vis.plot_genes(filter_=['KITLG'],fontsize=9) #, label_aligns={'MYC':'right'}
vis.plot_arcs(lw=1.5, cutoff='top', gene_filter=['KITLG'], arc_color='#666666')
vis.plot_chromosome_bar(name_size=10, coord_size=9)
vis.plot_vlines(result, color='blue', linewidth=1)
vis.outfig('/cluster2/home/futing/Project/panCancer/Analysis/test.pdf',dpi=500)