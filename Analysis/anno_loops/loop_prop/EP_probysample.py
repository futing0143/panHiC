#!/usr/bin/env python3
import os, pandas as pd

meta = pd.read_csv("/cluster2/home/futing/Project/panCancer/check/meta/panCan_meta.txt", sep="\t", dtype=str)  # cancer gse cell enzyme
OUT = []
base = "/cluster2/home/futing/Project/panCancer/Analysis/anno_loops/midata"

for _, r in meta.iterrows():
    f = os.path.join(base, r.cancer, r.gse, r.cell, "anno/mustache",
                     f"{r.cell}_loop_annotation.tsv")
    if not os.path.exists(f): continue
    df = pd.read_csv(f, sep="\t", usecols=["category"])
    tot = len(df)
    ep  = (df["category"]=="E-P").sum()
    OUT.append({
        "cancer": r.cancer, "gse": r.gse, "cell": r.cell, "enzyme": r.enzyme,
        "EP_prop": ep/tot if tot>0 else 0, "total": tot
    })

pd.DataFrame(OUT).to_csv("EP_prop_by_sample.tsv", sep="\t", index=False)
