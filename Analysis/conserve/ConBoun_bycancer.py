#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import pandas as pd
import numpy as np
import argparse
from pathlib import Path

# =========================
# 参数
# =========================

SCORE_THRESHOLD = 0       # boundary score > 0 视为 boundary（可改）
PAN_CANCER_FRAC = 0.5     # 跨肿瘤 50%
MIN_CANCER_N = 10         # 参与跨肿瘤定义的最小样本数

def cancer_specific_threshold(n):
    """
    根据癌症样本量返回肿瘤内保守阈值
    """
    if n >= 20:
        return 0.5
    elif n >= 10:
        return 0.6
    elif n >= 5:
        return 0.7
    else:
        return None   # n < 5 不定义

# =========================
# 主程序
# =========================

def main(boundary_file, meta_file, outdir):
    outdir = Path(outdir)
    outdir.mkdir(parents=True, exist_ok=True)

    print(">>> Reading boundary matrix")
    bd = pd.read_csv(boundary_file, sep="\t")
    bin_cols = ["chr", "start", "end"]
    cell_cols = [c for c in bd.columns if c not in bin_cols]

    print(">>> Reading metadata")
    meta = pd.read_csv(meta_file, sep="\t",usecols=["ncell", "Cancer_Category"])
	meta = meta.rename(columns={"ncell": "cell", "Cancer_Category": "cancer"})
    meta = meta.set_index("cell")

    # 检查 cell 一致性
    missing = set(cell_cols) - set(meta.index)
    if missing:
        raise ValueError(f"Cells missing in metadata: {list(missing)[:5]}")

    print(">>> Long format")
    long = (
        bd
        .melt(id_vars=bin_cols, var_name="cell", value_name="score")
        .merge(meta, left_on="cell", right_index=True)
    )

    long["is_boundary"] = long["score"] > SCORE_THRESHOLD

    # =========================
    # 癌症内统计
    # =========================

    print(">>> Cancer-specific aggregation")
    cancer_bin = (
        long
        .groupby(bin_cols + ["cancer"])
        .agg(
            n=("cell", "nunique"),
            frac=("is_boundary", "mean")
        )
        .reset_index()
    )

    # 判定肿瘤内保守
    def is_cancer_conserved(row):
        thr = cancer_specific_threshold(row["n"])
        if thr is None:
            return False
        return row["frac"] >= thr

    cancer_bin["cancer_conserved"] = cancer_bin.apply(is_cancer_conserved, axis=1)

    # 保存癌症内结果
    cancer_bin.to_csv(outdir / "cancer_specific_boundary_stats.tsv",
                      sep="\t", index=False)

    # =========================
    # 跨肿瘤保守
    # =========================

    print(">>> Pan-cancer conservation")

    eligible = cancer_bin[cancer_bin["n"] >= MIN_CANCER_N]

    pan = (
        eligible
        .groupby(bin_cols)
        .agg(
            n_cancer=("cancer", "nunique"),
            n_conserved=("cancer_conserved", "sum")
        )
        .reset_index()
    )

    pan["frac_cancer"] = pan["n_conserved"] / pan["n_cancer"]
    pan["pan_cancer_conserved"] = pan["frac_cancer"] >= PAN_CANCER_FRAC

    pan.to_csv(outdir / "pan_cancer_boundaries.tsv",
               sep="\t", index=False)

    # =========================
    # 支持信息（所有癌症）
    # =========================

    print(">>> Support matrix")
    support = cancer_bin.pivot_table(
        index=bin_cols,
        columns="cancer",
        values="frac"
    )

    support.to_csv(outdir / "boundary_support_by_cancer.tsv", sep="\t")

    print("=== DONE ===")
    print(f"Results written to: {outdir}")

# =========================
# CLI
# =========================

if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Pan-cancer conserved boundary identification"
    )
    parser.add_argument("-b", "--boundary", required=False,default='/cluster2/home/futing/Project/panCancer/Analysis/conserve/BS537_col8_0104.tsv',
                        help="Boundary matrix: chr start end cell1 cell2 ...")
    parser.add_argument("-m", "--meta", required=False,default='/cluster2/home/futing/Project/panCancer/check/meta/PanmergedMeta_0106.txt',
                        help="Metadata: cell cancer")
    parser.add_argument("-o", "--outdir", required=False,default='/cluster2/home/futing/Project/panCancer/Analysis/conserve/midata/0111',
                        help="Output directory")

    args = parser.parse_args()
    main(args.boundary, args.meta, args.outdir)
