import pandas as pd
import numpy as np
import argparse
from collections import defaultdict
import time

# 读取loop(bedpe),enhancer(bed)，输出enhancer bin的occurrences和及其标准化的log2权重
# 输出{name}_enhancer_occurrences_summary.tsv
# by Futing using DeepSeek's code 2025/1/21

def read_bedpe_file(name):
    """
    读取bedpe文件
    :param name: 文件名中的标识符
    :return: 返回bedpe文件的DataFrame
    """
    file_path = f'/cluster/home/futing/Project/GBM/HiC/10loop/consensus/merged/flank0k/{name}_flank0k.bedpe'  
    bedpe_df = pd.read_csv(file_path, sep='\t', header=None, 
                           names=['chr1', 'start1', 'end1', 'chr2', 'start2', 'end2', 'cloop'])
    return bedpe_df

def read_bed_file(name):
    """
    读取bed文件
    :param name: 文件名中的标识符
    :return: 返回bed文件的DataFrame
    """
    file_path = f'/cluster/home/futing/Project/GBM/HiC/hubgene/new/chip/merge/{name}.merge_BS_detail.bed'  
    bed_df = pd.read_csv(file_path, sep='\t', header=None, 
                         names=['chr', 'start', 'end', 'patients', 'occurrences'])
    return bed_df

def preprocess_bed_data(bed_df):
    """
    预处理bed数据，按染色体分组
    :param bed_df: bed文件的DataFrame
    :return: 返回一个字典，键为染色体，值为该染色体的所有enhancer记录
    """
    bed_dict = defaultdict(list)
    for _, row in bed_df.iterrows():
        bed_dict[row['chr']].append((row['start'], row['end'], row['occurrences']))
    return bed_dict

def calculate_anchor_occurrences(bedpe_df, bed_dict):
    """
    计算每个anchor的enhancer occurrences和，只保留含有overlap的区间
    :param bedpe_df: bedpe文件的DataFrame
    :param bed_dict: 按染色体分组的bed数据
    :return: 返回一个字典，键为anchor坐标，值为enhancer occurrences和
    """
    anchor_occurrences = {}  # 存储每个anchor的enhancer occurrences和
    processed_anchors = set()  # 存储已经处理过的anchor，避免重复计算

    # 遍历bedpe文件中的每一行
    for index, row in bedpe_df.iterrows():
        # 获取anchor1和anchor2的坐标
        anchor1 = (row['chr1'], row['start1'], row['end1'])
        anchor2 = (row['chr2'], row['start2'], row['end2'])
        
        # 如果anchor1没有被处理过，则计算其enhancer occurrences
        if anchor1 not in processed_anchors:
            chr1 = anchor1[0]
            start1 = anchor1[1]
            end1 = anchor1[2]
            occurrences_sum = 0  # 初始化occurrences和为0
            
            # 只处理与anchor1染色体相同的enhancer
            if chr1 in bed_dict:
                for enhancer_start, enhancer_end, occurrences in bed_dict[chr1]:
                    # 检查enhancer是否与anchor1重叠
                    if enhancer_start < end1 and enhancer_end > start1:
                        occurrences_sum += occurrences
            
            # 如果anchor1有overlap，则保存结果
            if occurrences_sum > 0:
                anchor_occurrences[anchor1] = occurrences_sum
            # 将anchor1标记为已处理
            processed_anchors.add(anchor1)
        
        # 如果anchor2没有被处理过，则计算其enhancer occurrences
        if anchor2 not in processed_anchors:
            chr2 = anchor2[0]
            start2 = anchor2[1]
            end2 = anchor2[2]
            occurrences_sum = 0  # 初始化occurrences和为0
            
            # 只处理与anchor2染色体相同的enhancer
            if chr2 in bed_dict:
                for enhancer_start, enhancer_end, occurrences in bed_dict[chr2]:
                    # 检查enhancer是否与anchor2重叠
                    if enhancer_start < end2 and enhancer_end > start2:
                        occurrences_sum += occurrences
            
            # 如果anchor2有overlap，则保存结果
            if occurrences_sum > 0:
                anchor_occurrences[anchor2] = occurrences_sum
            # 将anchor2标记为已处理
            processed_anchors.add(anchor2)
    
    return anchor_occurrences

def save_results(anchor_occurrences, name):
    """
    将结果保存为文件
    :param anchor_occurrences: 包含anchor坐标和enhancer occurrences和的字典
    :param name: 文件名中的标识符
    """
    # 将结果保存为包含enhancer的bin坐标和occurrences和
    result = []
    for anchor, occurrences in anchor_occurrences.items():
        chr, start, end = anchor
        ebin = f"{chr}_{start}_{end}"
        result.append([chr, start, end, occurrences, ebin])

    # 将结果转换为DataFrame并保存到文件
    result_df = pd.DataFrame(result, columns=['chr', 'start', 'end','occurrences', 'ebin'])
    result_df['weights'] = np.log2(result_df['occurrences'] + 1).transform(lambda x: (x - x.mean()) / x.std())
    result_df = result_df.loc[:,['chr', 'start', 'end',  'weights','occurrences', 'ebin']]
    result_df = result_df.sort_values(by=['chr', 'start', 'end'], key=lambda col: col if col.name == 'chr' else pd.to_numeric(col))
    
    output_file = f'/cluster/home/futing/Project/GBM/HiC/10loop/consensus/cytoscape/{name}/{name}_enhancer_occurrences_summary.tsv'  # 根据name生成输出文件名
    result_df.to_csv(output_file, sep='\t', index=False)
    print(f"处理完成，结果已保存到 {output_file}")

def main(name):
	"""
	主函数，处理bedpe和bed文件
	:param name: 文件名中的标识符
	"""
	# start time
	start_time=time.time()

	# 读取bedpe和bed文件
	bedpe_df = read_bedpe_file(name)
	bed_df = read_bed_file(name)

	# 预处理bed数据，按染色体分组
	bed_dict = preprocess_bed_data(bed_df)

	# 计算每个anchor的enhancer occurrences和
	anchor_occurrences = calculate_anchor_occurrences(bedpe_df, bed_dict)

	# 保存结果
	save_results(anchor_occurrences, name)

	# end time
	end_time=time.time()
	elapsed_time = end_time - start_time
	print(f'Code elapsing time: {elapsed_time:.6f} s')

if __name__ == "__main__":
    # 设置命令行参数解析
    parser = argparse.ArgumentParser(description="计算每个anchor的enhancer occurrences和")
    # parser.add_argument('--name', type=str, required=True, help="文件名中的标识符")
    parser.add_argument('name', type=str, help="sample same")
    args = parser.parse_args()

    # 调用主函数
    main(args.name)