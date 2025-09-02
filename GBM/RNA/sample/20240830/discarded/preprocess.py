import numpy as np
import pandas as pd
import os,sys

datapath=sys.argv[1]
name=sys.argv[2]
RNA = pd.read_csv(datapath,sep='\t',header=None)
RNA_mean = RNA.iloc[:, 1:].mean(axis=1).round(3)

# 将基因名和均值保存到新的文件中
RNA_result = pd.DataFrame({
    'Gene': RNA.iloc[:, 0],  # 基因名
    'Mean': RNA_mean         # 对应的均值
})

RNA_result.to_csv(f'{name}_mean.bed',sep='\t',header=False,index=False)

