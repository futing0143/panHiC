import pandas as pd

# ======================
# 文件路径
# ======================
file1 = "/cluster2/home/futing/Project/panCancer/Analysis/ABC/ATAC/ATAC.txt"
file2 = "/cluster2/home/futing/public_data/ATACdb/t_human_sample_overview.tsv"   # ← 改成你的第二个文件

# ======================
# 读取第一个文件（主表）
# ======================
df1 = pd.read_csv(
    file1,
    sep="\t",
    header=None,
    names=["cancer", "cell","url"],
    dtype=str
)

df1["cell_lc"] = df1["cell"].str.lower()

# ======================
# 读取第二个文件（附表）
# ======================
df2 = pd.read_csv(
    file2,
    sep="\t",        # 如果是 CSV 改成 ","
    dtype=str
)

if "cell_type" not in df2.columns:
    raise ValueError("Second file must contain a 'cell_type' column")

df2["cell_type_lc"] = df2["cell_type"].str.lower()

# ======================
# 模糊匹配：cell ∈ cell_type
# ======================
rows = []

for _, r1 in df1.iterrows():
    cell = r1["cell_lc"]

    hit = df2[df2["cell_type_lc"].str.contains(cell, na=False)]

    if hit.empty:
        # 没匹配到 → 补 NA
        row = r1.drop("cell_lc").to_dict()
        for col in df2.columns:
            if col not in ["cell_type_lc"]:
                row[col] = pd.NA
        rows.append(row)
    else:
        # 多个命中 → 展开
        for _, r2 in hit.iterrows():
            row = r1.drop("cell_lc").to_dict()
            for col in df2.columns:
                if col != "cell_type_lc":
                    row[col] = r2[col]
            rows.append(row)

# ======================
# 输出
# ======================
out_df = pd.DataFrame(rows)
out_file = "ATAC_fuzzy_merged.tsv"
out_file_nonnan = out_df.loc[~out_df['sample_id'].isna(), :]
out_file_nonnan.to_csv("ATAC_fuzzy_merged_nonnan.tsv", sep="\t", index=False)
out_df.to_csv(out_file, sep="\t", index=False)

print("Done.")
print(out_df.head())
