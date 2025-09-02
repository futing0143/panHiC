import sys
import cooler
import pandas as pd
import logging
sys.path.insert(0, '/cluster/home/futing/Project/GBM/HiC/11SV/NeoLoopFinder-master')
import neoloop.visualize.core as core
# 画图 May08,2025 by futing

gene = '/cluster/home/futing/ref_genome/hg38_gencode/genebed/gencode.v43.annotation.gtf'
cell_paths = {
    "NHA": {
        "hic": "/cluster/home/futing/Project/GBM/HiC/02data/03cool_order/10000/astro_merge_10000.cool",
        "RNA": "/cluster/home/futing/Project/GBM/RNA/sample/20240830/analysis/NHA/NHA_RPKM.bw",
        "loops": "/cluster/home/futing/Project/GBM/HiC/UCSC/NHA/data/NHA.links",
        "H3K27ac": "/cluster/home/futing/Project/GBM/ChIP/H3K27ac/NHA3/bigwig/SRR25404260_input.bw"
    },
    "GBM": {
        "hic": "/cluster/home/futing/Project/GBM/HiC/02data/03cool_order/10000/GBM_10000.cool",
        "RNA": "/cluster/home/futing/Project/GBM/RNA/sample/20240830/analysis/U87/U87_RPKM.bw",
        "loops": "/cluster/home/futing/Project/GBM/HiC/UCSC/GBM/data/GBM.links",
        "H3K27ac": "/cluster/home/futing/Project/GBM/ChIP/H3K27ac/U87_new/bigwig/SRR14862242_input.bw"
    },
    "NPC": {
        "hic": "/cluster/home/futing/Project/GBM/HiC/02data/03cool_order/10000/NPC_merge_10000.cool",
        "RNA": "/cluster/home/futing/Project/GBM/RNA/sample/NPC/NPC_RPKM.bw",
        "loops": "/cluster/home/futing/Project/GBM/HiC/UCSC/NPC/data/NPC.links",
        "H3K27ac": "/cluster/home/futing/Project/GBM/ChIP/H3K27ac/NPC2/bigwig/SRR17882758_input.bw"
    }
}
genedir='/cluster/home/futing/Project/GBM/HiC/HAR/HARs_gene/genes'
HARregion = pd.read_csv(f'{genedir}/HARregion/GBMvsNPC/HARregion_GBMvsNPC_RNAbygenes.txt', sep='\t',index_col=0)
HARregion.columns = ['HAR','chr', 'start', 'end', 'gene']


def plot_hic(cell,df,save=False):
	'''
	cell_path是一个字典，储存了所有路径信息
	'''
	region = df['chr']+':'+str(df['start'])+'-'+str(df['end'])
	genes = [g.strip() for g in df['gene'].split(',')]  # S
	gene_list = list(set(genes))  # Convert to unique list (optional)
	s = df['HAR']
	parts = s.split("_")
	result = (parts[0], int(parts[1]), int(parts[2]))

	print(f'Plotting {cell} for {s} at {region}...')
	clr = cooler.Cooler(f'/cluster/home/futing/Project/GBM/HiC/02data/03cool_order/10000/{cell}_10000.cool')
	# Create the visualization
	vis = core.GenomicRegionPlot(clr, region, figsize=(7, 5.8),
				track_partition=[5, 0.8, 0.8, 0.3,0.5, 0.5],n_rows=6, correct=True)
	# custom_cmap = LinearSegmentedColormap.from_list('custom_cmap', ['#1065ad', 'white', '#bc020f'])
	vis.matrix_plot(vmin=1e-03,vmax=5e-02) #,colormap=custom_cmap)

	vis.plot_signal('H3K27ac', cell_paths[cell]["H3K27ac"], label_size=10, data_range_size=9, max_value='auto', color='#6A3D9A')
	vis.plot_signal('RNA', cell_paths[cell]["RNA"], label_size=10, data_range_size=9,  max_value='auto', color='#E31A1C')
	vis.plot_loops(cell_paths[cell]["loops"], face_color='none', marker_size=40)
	vis.plot_chromosome_bounds(linewidth=2)
	vis.plot_genes(filter_=gene_list,fontsize=9) #, label_aligns={'MYC':'right'}
	vis.plot_arcs(lw=1.5, cutoff='top', gene_filter=gene_list, arc_color='#666666')
	vis.plot_chromosome_bar(name_size=10, coord_size=9)
	vis.plot_vlines(result, color='blue', linewidth=1)
	# vis.outfig(f'{workdir}/{s}_{cell}_1k.region.pdf',dpi=500)
	if save:
		vis.outfig(f'/cluster/home/futing/Project/GBM/HiC/HAR/plot/heatmap/{s}_{cell}.pdf', dpi=300)

def safe_plot_hic(cell,x):
    try:
        plot_hic(cell, x, save=True)
    except Exception as e:
        print(f"Error processing HAR {x['HAR']} for {cell}: {str(e)}")
        return None  # 或返回标记（如 False）
    return True  # 成功时返回标记

# 应用函数并忽略错误
HARregion.apply(lambda x: safe_plot_hic('GBM',x), axis=1)	
HARregion.apply(lambda x: safe_plot_hic('NPC',x), axis=1)	
# HARregion.apply(lambda x: plot_hic('GBM',x,save=True), axis=1)	
# HARregion.apply(lambda x: plot_hic('NPC',x,save=True), axis=1)

logging.basicConfig(filename='/cluster/home/futing/Project/GBM/HiC/HAR/heatmap/plot_errors.log', level=logging.ERROR)

# for idx, row in HARregion.iterrows():
#     try:
#         plot_hic('NPC', row, save=True)
#     except Exception as e:
#         logging.error(f"Error in HAR {row['HAR']}: {str(e)}")