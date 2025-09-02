import numpy as np
import pandas as pd
import re
import sys
import argparse


# 脚本作用：{name}_HARs.bedpe -> {name}_HARsgene.txt {name}_HARs_count.csv {name}_EPs.txt
# 输入是 HARs 和 EP 的交集，来源于/cluster/home/futing/Project/GBM/HiC/HAR/interSect_loop.sh
# 获取 HARs 是 Enhancer 的loop，储存对应的基因（HARs_gene.txt）和计数（HARs_count.csv）
# 获取 Enhancer 的loop，储存对应的loop（EPs.txt）

parser = argparse.ArgumentParser(description="Merge HARs data from multiple files.")
parser.add_argument("name", help="File pattern to match input files (e.g., '*_gene.txt')")

args = parser.parse_args()
name=args.name

GBM=pd.read_csv(f'/cluster/home/futing/Project/GBM/HiC/HAR/HARs_gene/EPs/GBMup/{name}_HARs.bedpe',sep='\t')
GBM['HAR']=GBM['chr_H']+'_'+GBM['start_H'].astype(str)+'_'+GBM['end_H'].astype(str)

# 挑选EPloop 并判断是否是Enhancer
GBM_EP=GBM.loc[GBM['E-P']==1,:]
GBM_EP.loc[:,'EHAR']=0
def is_exponential(value):
    return bool(re.fullmatch(r"^E\d+$", str(value)))
bin1_mask = GBM_EP["bin1"].astype(str).str.match(r"^E\d+$")
bin2_mask = GBM_EP["bin2"].astype(str).str.match(r"^E\d+$")

GBM_EP.loc[bin1_mask & ((GBM_EP["start1"] <= GBM_EP["end_H"]) & 
                      (GBM_EP["start_H"] <= GBM_EP["end1"])).astype(int),'EHAR']=1
GBM_EP.loc[bin2_mask & ((GBM_EP["start2"] <= GBM_EP["end_H"]) & 
                      (GBM_EP["start_H"] <= GBM_EP["end2"])).astype(int),'EHAR']=1

# 保证一个loop只有一个unique HAR，忽略不同的Enhancer
GBM_EPs=GBM_EP.drop(columns=['bin1','bin2','E-E','E-P','P-P','other']).drop_duplicates()
# 查看是否是looped Enhancer
HARs_count=GBM_EPs.loc[:,['HAR','EHAR']].drop_duplicates()
HARs_gene=GBM_EPs.loc[GBM_EPs['EHAR']==1,['gene','chr_H','start_H','end_H','HAR']].drop_duplicates()

HARs_gene.to_csv(f'/cluster/home/futing/Project/GBM/HiC/HAR/HARs_gene/genes/GBMup/{name}_HARsgene.txt',sep='\t',index=False)
HARs_count.to_csv(f'/cluster/home/futing/Project/GBM/HiC/HAR/HARs_gene/enhancer/GBMup/{name}_HARs_count.csv',sep='\t',index=False)
GBM_EPs.to_csv(f'/cluster/home/futing/Project/GBM/HiC/HAR/HARs_gene/EPs/GBMup/{name}_EPs.txt',sep='\t',index=False)



# for i in NHA iPSC NPC;do
# 	python filHARsgene.py ${i}
# done