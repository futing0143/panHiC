import cooler
import numpy as np
import pandas as pd
import argparse

GBM_all = cooler.Cooler('/cluster/home/futing/Project/GBM/HiC/02data/04mcool/GBM_9reso.mcool::/resolutions/5000')
pixels=GBM_all.pixels()[:]
bin_matrix = GBM_all.bins()[:]
# 为 pixels 数据框建立索引
pixels = pd.read_csv("./pixels.txt", sep='\t')
pixels.set_index(['bin1_id', 'bin2_id'], inplace=True)
print("pixels 索引建立完成")

def find_count(bin1_id, bin2_id):
    if pd.isna(bin1_id) or pd.isna(bin2_id):
        return None
    if bin1_id > bin2_id:  # 确保 bin1_id 小于 bin2_id
        bin1_id, bin2_id = bin2_id, bin1_id
    
    # 使用索引来查找 count
    key = (bin1_id, bin2_id)
    return pixels.at[key, 'count'] if key in pixels.index else None

parser = argparse.ArgumentParser(description="处理数据文件并添加 'count' 列")
parser.add_argument("input_file", type=str, help="输入文件路径")
parser.add_argument("output_dir", type=str, help="输出文件夹路径")
args = parser.parse_args()

# 读取输入文件
SNP = pd.read_csv(args.input_file, sep='\t')
# 确保 bin1_id 小于等于 bin2_id
SNP['bin1_id'], SNP['bin2_id'] = np.minimum(SNP['bin1_id'], SNP['bin2_id']), np.maximum(SNP['bin1_id'], SNP['bin2_id'])
# 添加 'count' 列
SNP['count'] = SNP.apply(lambda row: find_count(row['bin1_id'], row['bin2_id']), axis=1)

# 输出文件路径
output_file = f"{args.output_dir}/{args.input_file.split('/')[-1].replace('.txt', '_with_count.txt')}"
# 保存结果
SNP.to_csv(output_file, sep='\t', index=False)
print(f"处理完成，结果保存在 {output_file}")