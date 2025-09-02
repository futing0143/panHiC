import cooler
from intervaltree import Interval, IntervalTree
import numpy as np
import pandas as pd

GBM_all = cooler.Cooler('/cluster/home/futing/Project/GBM/HiC/02data/04mcool/GBM_9reso.mcool::/resolutions/5000')
ABC = pd.read_csv("/cluster/home/futing/Project/GBM/HiC/12ABC_all/GBM_ABC/Predictions/EnhancerPredictions.txt", sep="\t")
blood_final = pd.read_csv("/cluster/home/futing/Project/GBM/eqtl/eQTLGen/blood_hg38_final.txt",sep='\t')

def build_interval_tree(bin_matrix):
    tree = IntervalTree()
    for i, row in bin_matrix.iterrows():
        # Interval 的范围是左闭右开，这与题设匹配
        tree[row['start']:row['end']] = i  # 存储 bin_matrix 的索引作为值
    return tree


def get_bins(SNP, bin_matrix, tree):
    # 初始化为 pd.Series，填充 NaN
    snp_bins = pd.Series(np.nan, index=SNP.index)
    gene_bins = pd.Series(np.nan, index=SNP.index)

    for index, row in SNP.iterrows():
        # 查询 SNP 位置
        snp_result = tree[row['SNPPos']]
        # 查询基因中点位置
        gene_mid = (row['GeneStart'] + row['GeneEnd']) / 2
        gene_result = tree[gene_mid]
        chrom= int(row['SNPChr'].split('chr')[1]) - 1
        chrom1= int(row['GeneChr'].split('chr')[1]) - 1
        if snp_result:
            snp_bins.at[index] = sorted(list(snp_result))[chrom].data # 取区间树查询结果的索引
        if gene_result:
            gene_bins.at[index] = sorted(list(gene_result))[chrom1].data  # 取区间树查询结果的索引

    return snp_bins, gene_bins

def result(SNP, bin_matrix, pixels):
    tree = build_interval_tree(bin_matrix)
    snp_bins, gene_bins = get_bins(SNP, bin_matrix, tree)


    SNP['contact'] = np.nan  # Initialize the contact column with NaNs
    for i, row in SNP.iterrows():
        if np.isnan(snp_bins[i]) or np.isnan(gene_bins[i]):
            print(f'No bin found for SNP {row["SNP"]} or gene {row["Gene"]}')
            SNP.iloc[i, 10] = np.nan
        else:
            bin1 = snp_bins[i]
            bin2 = gene_bins[i]
            SNP.iloc[i, 10] = pixels.loc[((pixels['bin1_id']== bin1) & (pixels['bin2_id'] == bin2)),'count']
    return SNP