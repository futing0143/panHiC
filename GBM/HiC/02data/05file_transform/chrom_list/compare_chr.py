import sys
import cooler
import pandas as pd
import numpy as np
data_path=sys.argv[1]
#c=cooler.Cooler(data_path)
#print(c.bins()[:]['chrom'].unique()).tolist()
chrlist=pd.read_csv('/cluster/home/futing/ref_genome/hg38.genome',sep='\t',header=None)[0].tolist()
chrlistlong=pd.read_csv('/cluster/home/futing/software/juicer_CPU/restriction_sites/hg38.genome',sep='\t',header=None)[0].tolist()
chrlist25=pd.read_csv('/cluster/home/futing/ref_genome/hg38_25.genome',sep='\t',header=None)[0].tolist()
chrlistchr=pd.read_csv('/cluster/home/futing/ref_genome/chrlistchr.txt',sep='\t',header=None)[0].tolist()
try:
    c = cooler.Cooler(data_path)
    bins = c.bins()[:]
    if 'chrom' in bins.columns:
        if data_path.endswith('.cool'):
            chroms = bins['chrom'].unique().tolist()
            cname=data_path.split('/')[-1].split('_')[0]
            if chroms != chrlist:
                print(cname)
                #print(f'Chromosome information mismatch in bins: {chroms}')
        else:
            chroms = bins['chrom'].unique().tolist()
            cname=data_path.split('/')[-3].split('.mcool')[0]
            if chroms != chrlist and chroms != chrlistlong and chroms != chrlist25 and chroms != chrlistchr:
                print(cname)
                print(f'Chromosome information mismatch in bins: {chroms}')
    else:
        print("Chromosome information missing in bins.")
except Exception as e:
    print(f"Error processing {data_path}: {e}")
