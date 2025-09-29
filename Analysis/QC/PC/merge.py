#!/usr/bin/env python3
import os
import sys

if len(sys.argv) != 3:
    print(f"Usage: {sys.argv[0]} <meta_with_unique.tsv> <col_num>", file=sys.stderr)
    sys.exit(1)

outputmeta = sys.argv[1]
base_file = "/cluster2/home/futing/Project/panCancer/AML/GSE93995/HL-60/anno/HL-60_cis_100k.cis.vecs.tsv"
col_num = int(sys.argv[2]) - 1  # 转成 0-based index
outfile = f"merged_col{col_num+1}.tsv"

# 读取 meta 文件
meta = []
with open(outputmeta) as f:
    for line in f:
        if line.strip() == "" or line.startswith("cancer"):  # 跳过表头或空行
            continue
        cancer, gse, cell, ncell = line.strip().split("\t")[:4]
        file = f"/cluster2/home/futing/Project/panCancer/{cancer}/{gse}/{cell}/anno/{cell}_cis_100k.cis.vecs.tsv"
        if os.path.exists(file):
            meta.append((file, ncell))
        else:
            print(f"File not found: {file}", file=sys.stderr)

# 打开所有文件，跳过 header
fps = []
for file, ncell in meta:
    f = open(file)
    next(f)  # 跳过 header
    fps.append((f, ncell))

# 写输出
with open(outfile, "w") as out:
    # 表头
    header_base = "\t".join(open(base_file).readline().strip().split("\t")[:3])
    header_cols = "\t".join([ncell for _, ncell in fps])
    out.write(f"{header_base}\t{header_cols}\n")

    # 遍历 base 文件每一行
    with open(base_file) as bf:
        next(bf)  # 跳过 header
        for line in bf:
            parts = line.strip().split("\t")
            base_cols = "\t".join(parts[:3])

            extra_cols_list = []
            for f, _ in fps:
                try:
                    row = next(f).strip().split("\t")
                    if len(row) > col_num:
                        extra_cols_list.append(row[col_num])
                    else:
                        extra_cols_list.append("NA")  # 不够列数填NA
                except StopIteration:
                    extra_cols_list.append("NA")  # 文件提前结束也填NA

            extra_cols = "\t".join(extra_cols_list)
            out.write(f"{base_cols}\t{extra_cols}\n")


# 关闭所有文件
for f, _ in fps:
    f.close()

print(f"✅ Done! Output: {outfile}")
