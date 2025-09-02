from neoloop.visualize.core import *
import cooler
import pandas as pd

def create_visualization(filename, cooler_path, assembly, h3k27ac_path, RNA_path, loops_file):
	# 固定的基因列表
	try:
		gene_list = [line.strip() for line in open('/cluster/home/futing/Project/GBM/HiC/11SV/eaglec_new/result/EP_neoloop/all-genes.txt')]  # 读取基因列表
		neo = assembly.split('\t')[0] if '\t' in assembly else assembly  # 从 assembly 提取 neo
		print(f"Processing {filename} with {neo} neo")
		# 创建 Triangle 对象
		clr = cooler.Cooler(cooler_path)
		vis = Triangle(clr, assembly, n_rows=5, figsize=(7, 5.2), track_partition=[5, 0.8, 0.8, 0.2, 0.5], correct='weight', span=300000, space=0.08)
		vis.matrix_plot(vmin=0, cbr_fontsize=9)
		vis.plot_chromosome_bounds(linewidth=2)
		vis.plot_signal('H3K27ac', h3k27ac_path, label_size=10, data_range_size=9, max_value=20, color='#6A3D9A')
		vis.plot_signal('RNA', RNA_path, label_size=10, data_range_size=9, max_value=20, color='#E31A1C')
		vis.plot_loops(loops_file, face_color='none', marker_size=40, cluster=False, filter_by_res=True, onlyneo=True)
		vis.plot_genes(filter_=gene_list, fontsize=9)
		vis.plot_chromosome_bar(name_size=13, coord_size=10)
	#   vis.plot_arcs(cutoff='top', gene_filter=gene_list, arc_color='#666666')
		
		# 构建输出文件名，使用 file 和 neo 参数
		output_folder = "/cluster/home/futing/Project/GBM/HiC/HAR/HARs_gene/heatmap"
		# 构建输出文件名，使用 file 和 neo 参数
		output_file = f"{output_folder}/{filename}.png"
		vis.outfig(output_file, dpi=300)

	except Exception as e:
			# 如果遇到错误，记录文件名和错误信息
		with open("/cluster/home/futing/Project/GBM/HiC/HAR/HARs_gene/heatmap/error_log.txt", "a") as log_file:
			log_file.write(f"Error processing {filename}: {str(e)}\n")
		print(f"Error processing {filename}. Check error_log.txt for details.")

# def main(args):
#     create_visualization(args.file, args.cooler_path, args.assembly, 
#                          args.h3k27ac_path, args.RNA_path, args.loops_file)

# if __name__ == "__main__":
#     parser = argparse.ArgumentParser(description="Draw Hi-C visualizations")
    
#     # 添加命令行参数
#     parser.add_argument("file", type=str, help="File name")
#     parser.add_argument("cooler_path", type=str, help="Path to the cooler file")
#     parser.add_argument("assembly", type=str, help="Genome assembly (e.g., hg38)")
#     parser.add_argument("h3k27ac_path", type=str, help="Path to H3K27ac file")
#     parser.add_argument("RNA_path", type=str, help="Path to RNA file")
#     parser.add_argument("loops_file", type=str, help="Path to loops file")

#     args = parser.parse_args()  # 解析命令行参数
#     main(args)

# file=chr10_24728545_24728698
# assembly=
# cooler_path='/cluster/home/futing/Project/GBM/HiC/02data/03cool_order/1000/GBM_1000.cool'
# RNA='/cluster/home/futing/Project/GBM/RNA/sample/GSC/GSM7182056_G61_S_q20.bw'
# H3K27ac='/cluster/home/futing/Project/GBM/HiC/hubgene/new/H3K27ac/merge/GBM.merge_BS_detail.bw'
# loop_file='/cluster/home/futing/Project/GBM/HiC/10loop/consensus/merged/flank0k/GBM_flank0k.bedpe'

def main(filelist_path):
	# 读取文件列表
	df = pd.read_csv(filelist_path, sep='~')

	for index, row in df.iterrows():
		filename = row['file']
		cooler_path = row['cooler_path']
		assembly = row['assembly']
		h3k27ac_path = row['h3k27ac_path']
		RNA_path = row['RNA_path']
		loops_file = row['loops_file']

		# 调用 create_visualization 函数
		create_visualization(filename, cooler_path, assembly, h3k27ac_path, RNA_path, loops_file)

if __name__ == "__main__":
	import sys
	if len(sys.argv) != 2:
		print("Usage: python draw.py <filelist_path>")
		sys.exit(1)

	filelist_path = sys.argv[1]  # 从命令行参数获取文件列表路径
	main(filelist_path)



