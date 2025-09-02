import pandas as pd
import numpy as np
import argparse
import time
from intervaltree import IntervalTree, Interval
from collections import defaultdict

# 用于 loop 和 enhancer 取交集，并将Enhancer peak储存为loop anchor的形式
# 输入 loop bedpe enhancer bed
# 输出 {name}_Eweights.bed


def process_files(bedpe_file, bed_file):
    # 读取bedpe文件
    bedpe_df = pd.read_csv(bedpe_file, sep='\t', header=None,
                          names=['chr1', 'start1', 'end1', 'chr2', 'start2', 'end2', 'cloop'])
    
    # 读取bed文件
    bed_df = pd.read_csv(bed_file, sep='\t', header=None,
                        names=['chr', 'start', 'end', 'patients', 'occurrences'])
    
    # 创建区间树来存储enhancer信息
    enhancer_trees = defaultdict(IntervalTree)
    for _, row in bed_df.iterrows():
        enhancer_trees[row['chr']].add(Interval(row['start'], row['end'], row['occurrences']))
    
    # 存储所有有overlap的anchor的结果
    anchor_results = defaultdict(int)
    anchor_coords = set()
    
    # 处理每个anchor
    def process_anchor(chrom, start, end):
        key = f"{chrom}_{start}_{end}"
        if key not in anchor_results:
            # 查找与当前anchor重叠的enhancer
            overlapping = enhancer_trees[chrom].overlap(start, end)
            # 将overlapping转换为列表以检查是否为空
            overlapping_list = list(overlapping)
            if overlapping_list:  # 只有当存在重叠时才处理
                total_occurrences = sum(interval.data for interval in overlapping_list)
                anchor_results[key] = total_occurrences
                anchor_coords.add((chrom, start, end))
    
    # 处理bedpe文件中的每一行的两个anchor
    for _, row in bedpe_df.iterrows():
        process_anchor(row['chr1'], row['start1'], row['end1'])
        process_anchor(row['chr2'], row['start2'], row['end2'])
    
    # 准备结果
    results_list = []
    for chrom, start, end in sorted(anchor_coords):
        key = f"{chrom}_{start}_{end}"
        results_list.append([chrom, start, end, anchor_results[key], key])
    
    # 转换为DataFrame以便计算权重
    results_df = pd.DataFrame(results_list, columns=['chr', 'start', 'end', 'occurrences', 'ebin'])
    
    # 计算标准化的log2权重
    results_df['weights'] = np.log2(results_df['occurrences'] + 1)
    results_df['weights'] = (results_df['weights'] - results_df['weights'].mean()) / results_df['weights'].std()
    results_df=results_df.loc[:,['chr','start','end','weights','occurrences','ebin']]
    # results_df.rename(columns={'key':'ebin'})
    
    # 转换回列表格式，但这次包含列名
    return results_df

def write_results(results_df, output_file):
    results_df.to_csv(output_file, sep='\t', index=False)


def main(name):
    """
    主函数，处理bedpe和bed文件
    :param name: 文件名中的标识符
    """
    bedpe_file = f'/cluster/home/futing/Project/GBM/HiC/10loop/consensus/merged/flank0k/{name}_flank0k.bedpe'
    bed_file = f'/cluster/home/futing/Project/GBM/HiC/hubgene/new/chip/merge/{name}.merge_BS_detail.bed'
    output_file = f'/cluster/home/futing/Project/GBM/HiC/10loop/consensus/cytoscape/{name}/{name}_Eweights.bed'
    
	# start time
    start_time=time.time()
    
	# main 
    results = process_files(bedpe_file, bed_file)
    write_results(results, output_file)
    
	# end time
    end_time=time.time()
    elapsed_time= end_time - start_time
    print(f'Eprocess.py running time: {elapsed_time:.6fs} s')

if __name__ == "__main__":
    
	parser = argparse.ArgumentParser(description="传入name")
	parser.add_argument('name', type=str, help="sample same")
	args = parser.parse_args()

	# 调用主函数
	main(args.name)
