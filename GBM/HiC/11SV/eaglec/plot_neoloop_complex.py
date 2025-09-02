from neoloop.visualize.core import *
import cooler
clr = cooler.Cooler('../juicer_hind3/mergeall.mcool::resolutions/5000')
List = [line.rstrip() for line in open('allOnco-genes.txt')] # please find allOnco-genes.txt in the demo folder of this repository
assembly = 'C2	translocation,4,54200000,-,12,57730000,-	4,54410000	12,58020000'
vis = Triangle(clr, assembly, n_rows=5, figsize=(7, 5.2), track_partition=[5, 0.8, 0.8, 0.2, 0.5], correct='weight', span=300000, space=0.08)
vis.matrix_plot(vmin=0, cbr_fontsize=9)
vis.plot_chromosome_bounds(linewidth=2)
vis.plot_signal('ATAC-Seq', '/cluster/home/jialu/GBM/HiC/ABC/atac/SRR12055979.rmdup_sorted.rpkm.bw', label_size=10, data_range_size=9, max_value=0.5, color='#E31A1C')
vis.plot_signal('H3K27ac', '/cluster/home/jialu/GBM/HiC/ABC/ts543_h3k27ac/SRR12056338.rmdup_sorted.rpkm.bw', label_size=10, data_range_size=9, max_value=20, color='#6A3D9A')
vis.plot_loops('mergeall.neo-loops.txt', face_color='none', marker_size=40,
    cluster=False, filter_by_res=True, onlyneo=True)
vis.plot_genes(filter_=['PDGFRA','CTDSP2'],label_aligns={'PDGFRA':'right'}, fontsize=9)
vis.plot_chromosome_bar(name_size=13, coord_size=10)
vis.outfig('C2_new.png', dpi=300)
