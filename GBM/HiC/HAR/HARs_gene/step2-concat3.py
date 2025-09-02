import pandas as pd

# 脚本作用：在filHARsgene.py的基础上，合并四个文件，按照HAR分组，按照最长的gene补齐
# 输出：HARs_gene.txt

# 读取四个文件
file1 = pd.read_csv('/cluster/home/futing/Project/GBM/HiC/HAR/HARs_gene/genes/GBMup/GBM_HARsgene.txt',sep='\t')
file2 = pd.read_csv('/cluster/home/futing/Project/GBM/HiC/HAR/HARs_gene/genes/GBMup/NPC_HARsgene.txt',sep='\t')
file3 = pd.read_csv('/cluster/home/futing/Project/GBM/HiC/HAR/HARs_gene/genes/GBMup/iPSC_HARsgene.txt',sep='\t')
file4 = pd.read_csv('/cluster/home/futing/Project/GBM/HiC/HAR/HARs_gene/genes/GBMup/NHA_HARsgene.txt',sep='\t')

# 假设每个文件都有 'HARs' 列和 'gene' 列
# 将每个文件的 'gene' 列按 'HARs' 分组，并将基因转换为列表
file1_grouped = file1.groupby('HAR')['gene'].apply(list).reset_index()
file2_grouped = file2.groupby('HAR')['gene'].apply(list).reset_index()
file3_grouped = file3.groupby('HAR')['gene'].apply(list).reset_index()
file4_grouped = file4.groupby('HAR')['gene'].apply(list).reset_index()

# 合并四个文件，以 'HAR' 为键
merged = pd.merge(file1_grouped, file2_grouped, on='HAR', how='outer', suffixes=('_1', '_2'))
merged = pd.merge(merged, file3_grouped, on='HAR', how='outer')
merged = pd.merge(merged, file4_grouped, on='HAR', how='outer')

# 重命名列
merged.columns = ['HAR', 'GBM', 'NPC', 'iPSC', 'NHA']

# 将 NaN 替换为空列表
for col in ['GBM', 'NPC', 'iPSC', 'NHA']:
    merged[col] = merged[col].apply(lambda x: x if isinstance(x, list) else [])

# 填充不足的基因列表为 NA
def fill_na(genes, max_len):
    return genes + [None] * (max_len - len(genes))

# 展开每个 HAR 的基因列表为多行
expanded_data = []
for _, row in merged.iterrows():
    max_len = max(len(row['GBM']), len(row['NPC']), len(row['iPSC']), len(row['NHA']))
    GBM = fill_na(row['GBM'], max_len)
    NPC = fill_na(row['NPC'], max_len)
    iPSC = fill_na(row['iPSC'], max_len)
    NHA = fill_na(row['NHA'], max_len)
    
    for i in range(max_len):
        expanded_data.append({
            'HAR': row['HAR'],
            'GBM': GBM[i],
            'NPC': NPC[i],
            'iPSC': iPSC[i],
            'NHA': NHA[i]
        })

# 转换为 DataFrame
expanded_df = pd.DataFrame(expanded_data)

# 保存结果到新的 CSV 文件
expanded_df.to_csv('/cluster/home/futing/Project/GBM/HiC/HAR/HARs_gene/genes/GBMup/HARs_gene.txt', sep='\t',index=False)