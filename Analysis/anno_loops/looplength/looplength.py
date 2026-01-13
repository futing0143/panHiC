#!/usr/bin/env python3
import os
import re
import pandas as pd

# ========= 参数 =========
meta_file = "/cluster2/home/futing/Project/panCancer/check/meta/panCan_meta383.txt"   # 三列：cancer gse cell
base_dir  = "/cluster2/home/futing/Project/panCancer/"   # 你的根目录
out_file  = "/cluster2/home/futing/Project/panCancer/Analysis/anno_loops/looplength/EPloop_lengthp2.tsv"

# ========= 读取 meta =========
meta = pd.read_csv(meta_file, sep="\t", header=None,
                   names=["cancer","gse","cell","enzyme"], dtype=str)

# loopid 解析：chr1:111-222_chr1:333-444
pat = re.compile(r'^(chr[^:]+):(\d+)-(\d+)_(chr[^:]+):(\d+)-(\d+)$')

def calc_dist(loopid):
    m = pat.match(loopid)
    if not m:
        return None
    c1,s1,e1,c2,s2,e2 = m.group(1),int(m.group(2)),int(m.group(3)),m.group(4),int(m.group(5)),int(m.group(6))
    if c1 != c2:
        return None
    mid1 = (s1 + e1)//2
    mid2 = (s2 + e2)//2
    return abs(mid2 - mid1)

rows = []

for _, r in meta.iterrows():
    
    f = os.path.join(
        base_dir, r.cancer, r.gse, r.cell,
        "anno/mustache",
        f"{r.cell}_loop_category_down5w.tsv"
    )
    if not os.path.exists(f):
        continue

    try:
        df = pd.read_csv(f, sep="\t", usecols=["loopid","category"])
    except Exception:
        continue

    df = df[df["category"] == "E-P"]
    if df.empty:
        continue
    print(f"Processing {r.cancer} | {r.gse} | {r.cell}...")
    df["dist_bp"] = df["loopid"].map(calc_dist)
    df = df.dropna(subset=["dist_bp"])

    for d in df["dist_bp"].values:
        rows.append({
            "cancer": r.cancer,
            "gse": r.gse,
            "cell": r.cell,
            "dist_bp": int(d)
        })

out = pd.DataFrame(rows)
out.to_csv(out_file, sep="\t", index=False)
print("Wrote:", out_file, " n=", len(out))
