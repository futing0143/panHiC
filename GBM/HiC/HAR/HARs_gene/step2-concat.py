import pandas as pd
import glob

# 获取所有 *_HARsgene.txt 文件
files = glob.glob("*_HARsgene.txt")

# 存储所有数据的列表
dataframes = []

# 读取数据并处理
for file in files:
    df = pd.read_csv(file, sep='\t')  # 假设是 tab 分隔文件
    file_name = file.replace("_HARsgene.txt", "")  # 获取文件名作为列名
    df = df[['HAR', 'gene']].copy()  # 只保留 HAR 和 gene 列
    df[file_name] = df['gene']  # 创建新列，以文件名为列名
    df = df.drop(columns=['gene'])  # 删除原 gene 列
    dataframes.append(df)

# 进行多文件合并
merged_df = dataframes[0]  # 以第一个文件为初始 DataFrame
for df in dataframes[1:]:
    merged_df = pd.merge(merged_df, df, on="HAR", how="outer")  # 以 HAR 为 key 进行外连接

# **1. 统一转换所有基因列的格式（避免 float NaN）**
for col in merged_df.columns[1:]:
    merged_df[col] = merged_df[col].apply(lambda x: [x] if isinstance(x, str) else ([] if pd.isna(x) else x))

# **2. 找到最大基因数**
max_genes = merged_df.drop(columns=["HAR"]).applymap(len).max(axis=1)

# **3. 填充 NA 使所有 HAR 具有相同基因数**
for col in merged_df.columns[1:]:
    merged_df[col] = merged_df[col].apply(lambda x: x + [None] * (max_genes.max() - len(x)))

# **4. 按 HARs 展开多行**
final_df = merged_df.set_index("HAR").apply(pd.Series.explode).reset_index()

# **5. 保存结果**
final_df.to_csv("merged_output.tsv", sep="\t", index=False)
