import os
import pandas as pd
import numpy as np
import argparse
import cooler
from datetime import datetime
# python3 hic_contact_split3.py ./blood_hg38_hic.txt ./split --chunk_size 100000
# 设置命令行参数
parser = argparse.ArgumentParser(description="分割大型文本文件，并处理每个块")
parser.add_argument("input_file", type=str, help="大型文本文件的路径")
#parser.add_argument("pixels_file", type=str, help="用于查找 'count' 值的像素数据文件")
parser.add_argument("output_dir", type=str, help="输出分割和处理后的文本文件的目录")
parser.add_argument("--chunk_size", type=int, default=100000, help="每个块的行数")
args = parser.parse_args()

# 确保输出目录存在
os.makedirs(args.output_dir, exist_ok=True)

# 01 为 'pixels' 数据框建立索引
GBM_all = cooler.Cooler('/cluster/home/futing/Project/GBM/HiC/02data/04mcool/GBM_9reso.mcool::/resolutions/5000')
pixels=GBM_all.pixels()[:]
#pixels = pd.read_csv(args.pixels_file, sep='\t')
pixels.set_index(['bin1_id', 'bin2_id'], inplace=True)
print("pixels set index done")

# 02 定义查找 'count' 值的函数
def find_count(bin1_id, bin2_id):
    if pd.isna(bin1_id) or pd.isna(bin2_id):
        return None
    if bin1_id > bin2_id:
        bin1_id, bin2_id = bin2_id, bin1_id
    key = (bin1_id, bin2_id)
    return pixels.at[key, 'count'] if key in pixels.index else None

# 03 分割大型文本文件
chunk_count = 0
current_chunk = []

def process_chunk(chunk_count, current_chunk):
    now = datetime.now()
    timestamp_str = now.strftime("%Y-%m-%d %H:%M:%S")
    print("格式化时间戳：", timestamp_str)
    chunk_filename = os.path.join(args.output_dir, f"chunk_{chunk_count}.txt")
    with open(chunk_filename, 'w') as outfile:
        outfile.writelines(current_chunk)
    print(f"Processing {chunk_count+1} chunk...")
    # 处理分割后的块
    SNP = pd.read_csv(chunk_filename, sep='\t',header=None)
    SNP.iloc[-2], SNP.iloc[-1] = np.minimum(SNP.iloc[-2], SNP.iloc[-1]), np.maximum(SNP.iloc[-2], SNP.iloc[-1])
    SNP['count'] = SNP.apply(lambda row: find_count(row.iloc[-2], row.iloc[-1]), axis=1)

    # 保存处理结果
    output_filename = os.path.join(args.output_dir, f"chunk_{chunk_count}_with_count.txt")
    SNP.to_csv(output_filename, sep='\t', index=False)

with open(args.input_file, 'r') as infile:
    # 跳过第一行
    infile.readline()
    for line in infile:
        current_chunk.append(line)
        
        if len(current_chunk) >= args.chunk_size:
            chunk_count += 1
            process_chunk(chunk_count, current_chunk)  # 处理当前块
            current_chunk = []  # 清空当前块

# 如果还有剩余的行，处理最后一个块
if current_chunk:
    chunk_count += 1
    process_chunk(chunk_count, current_chunk)  # 处理最后的块

print("文件分割和处理完成！")
