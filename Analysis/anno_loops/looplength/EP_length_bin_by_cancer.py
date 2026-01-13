#!/usr/bin/env python3
import pandas as pd

# =====================
# 输入
# =====================
len_file   = "/cluster2/home/futing/Project/panCancer/Analysis/anno_loops/looplength/EPloop_length.tsv"
meta_file  = "/cluster2/home/futing/Project/panCancer/check/meta/PanmergedMeta_0106.txt"
out_file   = "/cluster2/home/futing/Project/panCancer/Analysis/anno_loops/looplength/EP_length_bin_stat.tsv"

# =====================
# 读取数据
# =====================
df_len = pd.read_csv(len_file, sep="\t")
df_len["dist_bp"] = df_len["dist_bp"].astype(int)

meta = pd.read_csv(meta_file, sep="\t", dtype=str)

# =====================
# 用 (cancer,gse,cell) 匹配，替换成 Final
# =====================
df = df_len.merge(
    meta[["cancer","gse","cell","Final","Cancer_Category"]],
    on=["cancer","gse","cell"],
    how="left"
)

# 安全检查
if df["Final"].isna().any():
    print("WARNING: some samples not matched in Panmeta")

# =====================
# 使用 Final 作为癌种
# =====================
df["Cancer"] = df["Final"]

# =====================
# E–P length 分档
# =====================
def bin_len(x):
    if x < 200_000:
        return "Short (<200 kb)"
    elif x <= 500_000:
        return "Medium (200–500 kb)"
    else:
        return "Long (>500 kb)"

df["len_bin"] = df["dist_bp"].apply(bin_len)

# =====================
# 统计 1：癌种 × 分档
# =====================
stat_cancer = (
    df.groupby(["Cancer","len_bin"])
      .size()
      .reset_index(name="n")
)

stat_cancer["prop"] = stat_cancer.groupby("Cancer")["n"].transform(
    lambda x: x / x.sum()
)

# =====================
# 统计 2：Cancer_category × 分档
# =====================
stat_cat = (
    df.groupby(["Cancer_Category","len_bin"])
      .size()
      .reset_index(name="n")
)

stat_cat["prop"] = stat_cat.groupby("Cancer_Category")["n"].transform(
    lambda x: x / x.sum()
)

# =====================
# 输出
# =====================
stat_cancer.to_csv("EP_length_bin_by_cancer.tsv", sep="\t", index=False)
stat_cat.to_csv("EP_length_bin_by_category.tsv", sep="\t", index=False)

print("Done.")
