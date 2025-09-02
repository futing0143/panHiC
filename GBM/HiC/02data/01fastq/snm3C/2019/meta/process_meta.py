#!/bin/python
import pandas as pd

merged=pd.read_csv('/cluster/home/futing/Project/GBM/HiC/02data/01fastq/snm3C/merged2.txt',header=None,sep=' ')
info=pd.read_csv('/cluster/home/futing/Project/GBM/HiC/02data/01fastq/snm3C/info.txt',header=None,sep=' ')
meta=pd.merge(merged,info,left_on=2,right_on=0)
meta.drop(columns=['2_x','0_y'],inplace=True)
meta.to_csv('/cluster/home/futing/Project/GBM/HiC/02data/01fastq/snm3C/2019/meta/GSE130711_m3C.txt',header=None,index=None,sep='\t')
meta=pd.read_csv('/cluster/home/futing/Project/GBM/HiC/02data/01fastq/snm3C/2019/meta/GSE130711_m3C.txt',header=None,sep='\t')
meta[3].value_counts()

#process OPC srr

OPC=meta[meta['1_y']=='OPC']
OPC['0_x'].to_csv('OPC.txt',header=None,index=None,sep='\t')