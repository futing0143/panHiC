import cooler
from intervaltree import Interval, IntervalTree
import numpy as np
import pandas as pd

GBM_all = cooler.Cooler('/cluster/home/futing/Project/GBM/HiC/02data/04mcool/GBM_9reso.mcool::/resolutions/5000')
ABC = pd.read_csv("/cluster/home/futing/Project/GBM/HiC/12ABC_all/GBM_ABC/Predictions/EnhancerPredictions.txt", sep="\t")
SNP = pd.read_csv("/cluster/home/futing/Project/GBM/eqtl/eQTLGen/blood_hg38_final.txt",sep='\t')
pixels=GBM_all.pixels()[:]
bin_matrix = GBM_all.bins()[:]

# 01 build_interval_tree
def build_interval_tree(bin_matrix):
    tree = IntervalTree()
    for i, row in bin_matrix.iterrows():
        # Interval 的范围是左闭右开，这与题设匹配
        tree[row['start']:row['end']] = i  # 存储 bin_matrix 的索引作为值
    return tree
tree = build_interval_tree(bin_matrix)

# 02 get_bins
def get_bins(chr,pos,tree=tree):
    result = tree[pos]
    chrom= int(chr.split('chr')[1]) - 1
    return sorted(list(result))[chrom].data
print(f'Processing bin1_id and bin1...')
SNP['bin1_id']=SNP.apply(lambda x: get_bins(x['SNPChr'],x['SNPPos']),axis=1)
SNP['bin2_id']=SNP.apply(lambda x: get_bins(x['GeneChr'],(x['GeneStart']+x['GeneEnd'])/2),axis=1)
print(f'Processing bin1_id and bin1 done!')
SNP.to_csv("/cluster/home/futing/Project/GBM/eqtl/blood_hg38_hic.txt",sep='\t',index=False)


# 03 n为每一行找到对应的 count
print(f'Finding count for bin1_id and bin2_id...')
def find_count(bin1_id, bin2_id, pixels):
    if pd.isna(bin1_id) or pd.isna(bin2_id):
        print(f'No bin found for bin1_id {bin1_id} or bin2_id {bin2_id}')
        return None
    elif bin1_id >= bin2_id:
        bin1_id, bin2_id = bin2_id, bin1_id
        result = pixels.loc[(pixels['bin1_id'] == bin1_id) & (pixels['bin2_id'] == bin2_id),'count']
        return result.values if not result.empty else None
    else:
        result = pixels.loc[(pixels['bin1_id'] == bin1_id) & (pixels['bin2_id'] == bin2_id),'count']
        return result.values if not result.empty else None

# 向 blood 中添加第五列 count
SNP['count'] = SNP.apply(lambda row: find_count(row['bin1_id'], row['bin2_id'], pixels), axis=1)

SNP.to_csv("/cluster/home/futing/Project/GBM/eqtl/blood_hg38_hic_count.txt",sep='\t',index=False)