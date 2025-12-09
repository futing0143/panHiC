import pandas as pd
import sys

# 获取文件路径
if len(sys.argv) != 4:
    print("用法: python merge_files.py 文件1 文件2")
    sys.exit(1)

file1 = sys.argv[1]
file2 = sys.argv[2]
outfile =sys.argv[3]

# 读取文件
df1 = pd.read_csv(file1, sep="\t")
df2 = pd.read_csv(file2, sep="\t")


result = pd.merge(df1, df2, on="GeneID", how='outer')
result = result.sort_values(by="GeneID")

result.to_csv(outfile,sep='\t',index=False)