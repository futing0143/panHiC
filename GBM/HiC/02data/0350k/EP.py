import glob
import numpy as np
import pandas as pd
import cooler
from intervaltree import Interval, IntervalTree

data_dir = "/cluster/home/futing/Project/GBM/HiC/02data/0350k"
cooler_file_list = glob.glob(f"{data_dir}/**/*.kr.cool", recursive=True)

bin_matrix = cooler.Cooler(cooler_file_list[0]).bins()[:]


def build_interval_tree(bin_matrix):
    tree = IntervalTree()
    for i, row in bin_matrix.iterrows():
        # Interval 的范围是左闭右开，这与题设匹配
        tree[row['start']:row['end']] = i  # 存储 bin_matrix 的索引作为值
    return tree
tree = build_interval_tree(bin_matrix)
def get_bins(chr,pos,tree=tree):
    result = tree[pos]
    chrom= int(chr.split('chr')[1]) - 1
    return sorted(list(result))[chrom].data
# 02 定义查找 'count' 值的函数
def find_count(bin1_id, bin2_id):
    if pd.isna(bin1_id) or pd.isna(bin2_id):
        return None
    if bin1_id > bin2_id:
        bin1_id, bin2_id = bin2_id, bin1_id
    key = (bin1_id, bin2_id)
    return pixels.at[key, 'count'] if key in pixels.index else None

# 03 EP and contact
EP= pd.read_csv('/cluster/home/futing/Project/GBM/HiC/02data/0350k/EP/EP.csv',usecols=[1,2])
for cooler_file in cooler_file_list:
    print(cooler_file)

    file=cooler_file.split('/')[-1].split('.')[0]
    c = cooler.Cooler(cooler_file)
    pixels=c.pixels()[:]
    pixels.set_index(['bin1_id', 'bin2_id'], inplace=True)

    print('Set index done..')
    EP[file] = EP.apply(lambda row: find_count(row['RNA'], row['enhancer']), axis=1)

EP.to_csv('/cluster/home/futing/Project/GBM/HiC/02data/0350k/EP_50k_raw.csv',index=False)