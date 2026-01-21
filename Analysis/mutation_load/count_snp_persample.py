mport pandas as pd

# 读取数据
df = pd.read_csv('BRCA_noncodeSNP.tsv', sep='\t',header=True)

# 统计每个sample的snp_id数量
result = df.groupby('sample')['snp_id'].count().reset_index()
result.columns = ['sample', 'snp_count']

# 输出结果
print(result)

# 如果需要保存到文件
result.to_csv('snp_count_result.txt', sep='\t', index=False)
