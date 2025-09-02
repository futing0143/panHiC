import sys
import cooler
import pandas as pd
import numpy as np
data_path=sys.argv[1]
# 检查染色体信息是否与参考基因组一致
#c=cooler.Cooler(data_path)
#print(c.bins()[:]['chrom'].unique()).tolist()
chrlist=pd.read_csv('/cluster/home/futing/ref_genome/hg38.genome',sep='\t',header=None)[0].tolist()
try:
    c = cooler.Cooler(data_path)
    bins = c.bins()[:]
    if 'chrom' in bins.columns:
        chroms = bins['chrom'].unique().tolist()
        cname=data_path.split('/')[-1].split('.')[0]
        if chroms != chrlist:
            print(cname)
            print(f'Chromosome information mismatch in bins: {chroms}')
    else:
        print("Chromosome information missing in bins.")
except Exception as e:
    print(f"Error processing {data_path}: {e}")
