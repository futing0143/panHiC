import sys,os
import cooler
import numpy as np
import pandas as pd
# 读取所有 .cool 文件的染色体信息
# 生成一个表格，行为染色体，列为文件名，值为该文件的染色体信息
chrom_list=pd.DataFrame()
input_dir=sys.argv[1]
output=sys.argv[2]
is_mcool = sys.argv[3]

def pad_chrom_list(chroms, target_length=194, pad_value=np.nan):
    while len(chroms) < target_length:
        chroms.append(pad_value)
    return chroms


if is_mcool == 'True':
    for file_name in os.listdir(input_dir):
        if file_name.endswith(".mcool"):
            data_path = os.path.join(input_dir, file_name)
            print(f'Processing {data_path}')
            c=cooler.Cooler(f'{data_path}::/resolutions/50000')
            name = data_path.split('/')[-1].split('_')[0]
            chroms=c.bins()[:]['chrom'].unique().tolist()
            chrom_list[name] = pad_chrom_list(chroms)
else:
    for file_name in os.listdir(input_dir):
        if file_name.endswith(".cool"):
            data_path = os.path.join(input_dir, file_name)
            print(f'Processing {data_path}')
            c=cooler.Cooler(data_path)
            name = data_path.split('/')[-1].split('_')[0]
            chroms=c.bins()[:]['chrom'].unique().tolist()
            chrom_list[name] = pad_chrom_list(chroms)


chrom_list.to_csv(output,index=False)

print(chrom_list.T.value_counts())
part1=chrom_list.loc[:,chrom_list.iloc[7,:]=='chrX']
part2=chrom_list.loc[:,chrom_list.iloc[7,:]=='chr8']
print(part2.columns)