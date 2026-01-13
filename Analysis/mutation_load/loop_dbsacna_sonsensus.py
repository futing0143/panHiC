#!/usr/bin/env python3

import argparse
import pandas as pd
import numpy as np
from sklearn.cluster import DBSCAN
from collections import defaultdict

def parse_args():
    ap = argparse.ArgumentParser(
        description="DBSCAN-based consensus clustering for BEDPE loops"
    )
    ap.add_argument(
        "-i", "--input", required=True,
        help="Merged tagged BEDPE file"
    )
    ap.add_argument(
        "-d", "--dist", type=int, default=10000,
        help="Max anchor distance (default: 10000)"
    )
    ap.add_argument(
        "-o", "--outprefix", default="loops",
        help="Output prefix"
    )
    return ap.parse_args()


def main():
    args = parse_args()

    # -------- read BEDPE --------
    df = pd.read_csv(
        args.input,
        sep="\t",
        header=None,
        comment="#"
    )

    if df.shape[1] < 7:
        raise ValueError("BEDPE must have at least 7 columns (with sample_id).")

    df.columns = (
        ["chrA", "startA", "endA",
         "chrB", "startB", "endB"]
        + [f"col{i}" for i in range(7, df.shape[1] + 1)]
    )

    sample_col = df.columns[-1]

    # midpoints
    df["midA"] = ((df["startA"] + df["endA"]) // 2).astype(int)
    df["midB"] = ((df["startB"] + df["endB"]) // 2).astype(int)

    # -------- clustering --------
    cluster_id = np.full(len(df), -1, dtype=int)
    cid = 0

    for (chrA, chrB), sub_idx in df.groupby(["chrA", "chrB"]).groups.items():
        sub = df.loc[sub_idx]

        X = sub[["midA", "midB"]].values

        # Chebyshev distance = max(|ΔA|, |ΔB|)
        db = DBSCAN(
            eps=args.dist,
            min_samples=1,
            metric="chebyshev"
        ).fit(X)

        labels = db.labels_
        for l in np.unique(labels):
            mask = labels == l
            cluster_id[sub_idx[mask]] = cid
            cid += 1

    df["cluster_id"] = cluster_id

    # -------- support statistics --------
    support = (
        df.groupby("cluster_id")[sample_col]
        .nunique()
        .reset_index()
        .rename(columns={sample_col: "support"})
    )

    support.to_csv(
        f"{args.outprefix}.loop_support.tsv",
        sep="\t",
        index=False
    )

    # -------- consensus loops --------
    cons = (
        df.groupby("cluster_id")
        .agg(
            chrA=("chrA", "first"),
            startA=("startA", "median"),
            endA=("endA", "median"),
            chrB=("chrB", "first"),
            startB=("startB", "median"),
            endB=("endB", "median")
        )
        .reset_index()
    )

    cons = cons.merge(support, on="cluster_id")

    cons[["startA", "endA", "startB", "endB"]] = \
        cons[["startA", "endA", "startB", "endB"]].astype(int)

    cons.to_csv(
        f"{args.outprefix}.consensus_loops.bedpe",
        sep="\t",
        header=False,
        index=False
    )

    print(f"[DONE] {cid} consensus loops generated.")
    print(f"  - {args.outprefix}.consensus_loops.bedpe")
    print(f"  - {args.outprefix}.loop_support.tsv")


if __name__ == "__main__":
    main()
