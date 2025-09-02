
# from neoloop.visualize.core import *
# import cooler
# import pandas as pd

# def create_visualization(file, cooler_path, assembly, h3k27ac_path, loops_file):
#     List = [line.rstrip() for line in open('/cluster/home/tmp/GBM/HiC/11SV/eaglec/allOnco-genes.txt')]  # 读取基因列表
#     clr = cooler.Cooler(cooler_path)  # 读取cooler文件
#     vis = Triangle(clr, assembly, n_rows=5, figsize=(7, 5.2), track_partition=[5, 0.8, 0.8, 0.2, 0.5], correct='weight', span=300000, space=0.08)
#     vis.matrix_plot(vmin=0, cbr_fontsize=9)
#     vis.plot_chromosome_bounds(linewidth=2)
#     vis.plot_signal('H3K27ac', h3k27ac_path, label_size=10, data_range_size=9, max_value=20, color='#6A3D9A')
#     vis.plot_loops(loops_file, face_color='none', marker_size=40, cluster=False, filter_by_res=True, onlyneo=True)
#     vis.plot_genes(filter_=List, fontsize=9)
#     vis.plot_chromosome_bar(name_size=13, coord_size=10)
#     # 构建输出文件名，使用file和assembly参数
#     output_file = f"{file}_{neo}.png"
#     vis.outfig(output_file, dpi=300)

# def main(filelist_path):
#     # 读取文件列表
#     df = pd.read_csv(filelist_path, sep='~')  
#     for index, row in df.iterrows():
#         file = row['file']
#         cooler_path = row['cooler_path']
#         assembly = row['assembly']
#         h3k27ac_path = row['h3k27ac_path']
#         loops_file = row['loops_file']
#         neo = assembly.split('\t')[0] if '\t' in assembly else assembly
#         # 构建输出文件名
#         output_file = f"{file}_{neo}.png"  # 可以在这里构建输出文件名，如果需要的话
#         # 调用create_visualization函数

#         create_visualization(file, cooler_path, assembly, h3k27ac_path, loops_file)

# if __name__ == "__main__":
#     import sys
#     if len(sys.argv) != 2:
#         print("Usage: python draw.py assem.txt")
#         sys.exit(1)
#     filelist_path = sys.argv[1]  # 从命令行参数获取文件列表路径
#     main(filelist_path)

from neoloop.visualize.core import *
import cooler
import pandas as pd

def create_visualization(file, cooler_path, assembly, h3k27ac_path, loops_file):
    # 固定的基因列表
    try:
        gene_list = [line.strip() for line in open('/cluster/home/tmp/GBM/HiC/11SV/eaglec/allOnco-genes.txt')]  # 读取基因列表
    
        neo = assembly.split('\t')[0] if '\t' in assembly else assembly  # 从 assembly 提取 neo
        clr = cooler.Cooler(cooler_path)  # 读取 cooler 文件
        vis = Triangle(clr, assembly, n_rows=5, figsize=(7, 5.2), track_partition=[5, 0.8, 0.8, 0.2, 0.5], correct='weight', span=300000, space=0.08)
        vis.matrix_plot(vmin=0, cbr_fontsize=9)
        vis.plot_chromosome_bounds(linewidth=2)
        vis.plot_signal('H3K27ac', h3k27ac_path, label_size=10, data_range_size=9, max_value=20, color='#6A3D9A')
        vis.plot_loops(loops_file, face_color='none', marker_size=40, cluster=False, filter_by_res=True, onlyneo=True)
        vis.plot_genes(filter_=gene_list, fontsize=9)
        vis.plot_chromosome_bar(name_size=13, coord_size=10)
        vis.plot_arcs(lw=1.5, cutoff='top', gene_filter=gene_list, arc_color='#666666')
        
        # 构建输出文件名，使用 file 和 neo 参数
        output_folder = "/cluster/home/tmp/GBM/HiC/11SV/eaglec_new/result/EP_neoloop/CGC_label/pic"
        # 构建输出文件名，使用 file 和 neo 参数
        output_file = f"{output_folder}/{file}_{neo}.png"
        vis.outfig(output_file, dpi=300)

    except Exception as e:
            # 如果遇到错误，记录文件名和错误信息
        with open("/cluster/home/tmp/GBM/HiC/11SV/eaglec_new/result/EP_neoloop/CGC_label/error_log.txt", "a") as log_file:
            log_file.write(f"Error processing {file}: {str(e)}\n")
        print(f"Error processing {file}. Check error_log.txt for details.")

def main(filelist_path):
    # 读取文件列表
    df = pd.read_csv(filelist_path, sep='~')

    for index, row in df.iterrows():
        file = row['file']
        cooler_path = row['cooler_path']
        assembly = row['assembly']
        h3k27ac_path = row['h3k27ac_path']
        loops_file = row['loops_file']

        # 调用 create_visualization 函数
        create_visualization(file, cooler_path, assembly, h3k27ac_path, loops_file)

if __name__ == "__main__":
    import sys
    if len(sys.argv) != 2:
        print("Usage: python draw.py <filelist_path>")
        sys.exit(1)
    
    filelist_path = sys.argv[1]  # 从命令行参数获取文件列表路径
    main(filelist_path)

