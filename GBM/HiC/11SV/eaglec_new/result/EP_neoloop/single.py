from neoloop.visualize.core import *
import cooler
gene_list = [line.strip() for line in open('/cluster/home/futing/Project/GBM/HiC/11SV/eaglec_new/result/EP_neoloop/all-genes.txt')]
clr = cooler.Cooler('/cluster/home/futing/Project/GBM/HiC/02data/04mcool/01GBM/G148.mcool::/resolutions/10000')
assembly = 'C48	translocation,7,128205000,-,X,124075000,+	7,128585000	X,123390000'
vis = Triangle(clr, assembly, n_rows=5, figsize=(7, 5.2), track_partition=[5, 0.8, 0.8, 0.2, 0.5], correct='weight', span=300000, space=0.08)
vis.matrix_plot(vmin=0, cbr_fontsize=9)
vis.plot_chromosome_bounds(linewidth=2)
vis.plot_signal('H3K27ac', '/cluster/home/futing/Project/GBM/ChIP/H3K27ac/GSC/GSM7182024_G148_H3K27ac_RPGC.bw', label_size=10, data_range_size=9, max_value=20, color='#6A3D9A')
vis.plot_signal('RNA', '/cluster/home/futing/Project/GBM/RNA/GSC/GSM7182033_G148_S_q20.bw', label_size=10, data_range_size=9, max_value=20, color='#E31A1C')
vis.plot_loops('/cluster/home/futing/Project/GBM/HiC/11SV/eaglec_new/G148/G148.neo-loops.txt', face_color='none', marker_size=40,
    cluster=False, filter_by_res=True, onlyneo=True)
vis.plot_genes(filter_=gene_list, fontsize=9)
vis.plot_chromosome_bar(name_size=13, coord_size=10)
#vis.plot_arcs(lw=1.5, cutoff='top', gene_filter=gene_list, arc_color='#666666')
vis.outfig('G148.C48_2.png', dpi=300)

# from pyensembl import EnsemblRelease

# data = EnsemblRelease(97)  # 对应 GRCh38
# gene = data.genes_by_name("SOX2")
# print(gene)

# gene_list = [line.strip() for line in open('/cluster/home/futing/Project/GBM/HiC/11SV/eaglec/allOnco-genes.txt')]
# clr = cooler.Cooler('/cluster/home/futing/Project/GBM/HiC/02data/04mcool/02NPC/NPC_new.mcool::/resolutions/10000')
# assembly = 'C48 translocation,7,128205000,-,X,124075000,+   7,128585000 X,123390000'
# vis = Triangle(clr, assembly, n_rows=5, figsize=(7, 5.2), track_partition=[5, 0.8, 0.8, 0.2, 0.5], correct='weight', span=300000, space=0.08)
# vis.matrix_plot(vmin=0, cbr_fontsize=9)
# vis.plot_chromosome_bounds(linewidth=2)
# vis.plot_signal('H3K27ac', '/cluster/home/futing/Project/GBM/ChIP/H3K27ac/NPC/bigwig/NPC_H3K27ac.bw', label_size=10, data_range_size=9, max_value=20, color='#6A3D9A')
# vis.plot_loops('/cluster/home/futing/Project/GBM/HiC/11SV/eaglec_new/NPC/NPC.neo-loops1.txt', face_color='none', marker_size=40,
#     cluster=False, filter_by_res=True, onlyneo=True)
# vis.plot_genes(filter_=['XIAP','STAG2'], fontsize=9)
# vis.plot_chromosome_bar(name_size=13, coord_size=10)
# vis.plot_arcs(lw=1.5, cutoff='top', gene_filter=['XIAP','STAG2'], arc_color='#666666')
# vis.outfig('NPC.C48.png', dpi=300)
