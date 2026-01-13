#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import pandas as pd
import numpy as np
import argparse
import time
import os
from typing import Tuple, Dict


# =========================================================
# IO
# =========================================================

def read_files(bedpe_path, gene_bed_path, enhancer_bed_path, is_public_db=False):

    print(f"    [INFO] Loading BEDPE: {bedpe_path}")
    loops_df = pd.read_csv(
        bedpe_path, sep='\t', header=None, usecols=[0,1,2,3,4,5,6]
    )
    loops_df.columns = ['chr1','start1','end1','chr2','start2','end2','cloop']

    for c in ['start1','end1','start2','end2']:
        loops_df[c] = pd.to_numeric(loops_df[c], errors='coerce')

    n0 = len(loops_df)
    loops_df = loops_df.dropna()
    if len(loops_df) < n0:
        print(f"    [WARN] Dropped {n0-len(loops_df)} invalid loops")

    loops_df[['start1','end1','start2','end2']] = loops_df[
        ['start1','end1','start2','end2']
    ].astype('int64')

    loops_df['loopid'] = (
        loops_df['chr1'] + ':' + loops_df['start1'].astype(str) + '-' + loops_df['end1'].astype(str) + '_' +
        loops_df['chr2'] + ':' + loops_df['start2'].astype(str) + '-' + loops_df['end2'].astype(str)
    )

    print(f"    [INFO] Loading gene BED: {gene_bed_path}")
    genes_df = pd.read_csv(
        gene_bed_path, sep='\t',
        names=['chr','start','end','symbol']
    )
    genes_df[['start','end']] = genes_df[['start','end']].apply(
        pd.to_numeric, errors='coerce'
    )
    genes_df = genes_df.dropna().astype({'start':'int64','end':'int64'})

    print(f"    [INFO] Loading enhancer BED ({'public' if is_public_db else 'cancer-specific'})")
    enhancers_df = pd.read_csv(
        enhancer_bed_path, sep='\t', header=None, usecols=[0,1,2]
    )
    enhancers_df.columns = ['chr','start','end']
    enhancers_df[['start','end']] = enhancers_df[['start','end']].apply(
        pd.to_numeric, errors='coerce'
    )
    enhancers_df = enhancers_df.dropna().astype({'start':'int64','end':'int64'})
    enhancers_df['enhancer_id'] = ['E'+str(i) for i in range(len(enhancers_df))]

    print(f"    [DONE] loops={len(loops_df)}, genes={len(genes_df)}, enhancers={len(enhancers_df)}")
    return loops_df, genes_df, enhancers_df


# =========================================================
# Index & overlap
# =========================================================

def build_chr_index(df):
    return {k: v.reset_index(drop=True) for k, v in df.groupby('chr')}


def find_overlaps_fast(chr_df, start, end, flank):
    if chr_df is None:
        return None

    ext_start = max(0, start - flank)
    ext_end   = end + flank

    mask = (chr_df['start'] < ext_end) & (chr_df['end'] > ext_start)
    if not mask.any():
        return None

    ov = chr_df.loc[mask].copy()
    s = ov['start'].values
    e = ov['end'].values

    ov['distance'] = np.minimum.reduce([
        np.abs(s - start),
        np.abs(e - start),
        np.abs(s - end),
        np.abs(e - end)
    ])
    ov['in_original_region'] = (s <= end) & (e >= start)
    return ov


# =========================================================
# Feature parsing
# =========================================================

def get_anchor_features(overlaps_genes, overlaps_enhancers):
    feats = []

    if overlaps_genes is not None:
        for r in overlaps_genes.itertuples():
            feats.append({
                'type': 'P',
                'id': r.symbol,
                'full': f"{r.symbol}(d={r.distance}bp,{'in' if r.in_original_region else 'flank'})"
            })

    if overlaps_enhancers is not None:
        for r in overlaps_enhancers.itertuples():
            feats.append({
                'type': 'E',
                'id': r.enhancer_id,
                'full': f"{r.enhancer_id}(d={r.distance}bp,{'in' if r.in_original_region else 'flank'})"
            })

    return feats


def get_anchor_info(features):
    return "NA" if not features else "|".join(f['full'] for f in features)


# =========================================================
# Core loop processing
# =========================================================

def process_loops_fast(loops_df, genes_df, enhancers_df, flanking_size):

    print("    [INFO] Building chromosome indices")
    genes_by_chr = build_chr_index(genes_df)
    enh_by_chr   = build_chr_index(enhancers_df)

    results = []
    t0 = time.time()

    for loop in loops_df.itertuples(index=False):

        g1 = find_overlaps_fast(genes_by_chr.get(loop.chr1), loop.start1, loop.end1, flanking_size)
        e1 = find_overlaps_fast(enh_by_chr.get(loop.chr1), loop.start1, loop.end1, flanking_size)
        g2 = find_overlaps_fast(genes_by_chr.get(loop.chr2), loop.start2, loop.end2, flanking_size)
        e2 = find_overlaps_fast(enh_by_chr.get(loop.chr2), loop.start2, loop.end2, flanking_size)

        a1 = get_anchor_features(g1, e1)
        a2 = get_anchor_features(g2, e2)

        bin1_info = get_anchor_info(a1)
        bin2_info = get_anchor_info(a2)

        if not a1:
            a1 = [{'type':'O','id':'NA'}]
        if not a2:
            a2 = [{'type':'O','id':'NA'}]

        for f1 in a1:
            for f2 in a2:
                t = f"{f1['type']}-{f2['type']}"
                is_ee = int(t == 'E-E')
                is_ep = int(t in ('E-P','P-E'))
                is_pp = int(t == 'P-P')
                is_other = int(not (is_ee or is_ep or is_pp))

                gene = (
                    f1['id'] if f1['type']=='P' else
                    f2['id'] if f2['type']=='P' else 'NA'
                )

                results.append({
                    'loopid': loop.loopid,
                    'bin1': f1['id'] if f1['type'] in 'EP' else 'NA',
                    'bin2': f2['id'] if f2['type'] in 'EP' else 'NA',
                    'E-E': is_ee,
                    'E-P': is_ep,
                    'P-P': is_pp,
                    'other': is_other,
                    'bin1_info': bin1_info,
                    'bin2_info': bin2_info,
                    'gene': gene
                })

    print(f"    [DONE] Annotation finished in {time.time()-t0:.2f}s "
          f"(records={len(results)})")
    return pd.DataFrame(results)


# =========================================================
# Single & batch
# =========================================================

def process_single_sample(cancer, gse, cell, atac_path, gene_bed_path,
                          base_dir, output_dir, public_db, flank):

    print(f"  [INFO] Processing {cancer} | {gse} | {cell}")

    bedpe = f"{base_dir}/{cancer}/{gse}/{cell}/anno/mustache/{cell}_10kb_mustache.bedpe"
    if not os.path.exists(bedpe):
        print(f"    [WARN] BEDPE not found")
        return False

    nline = sum(1 for _ in open(bedpe))
    if nline <= 1000:
        print(f"    [SKIP] Only {nline} loops")
        return 'skipped'

    print(f"    [INFO] BEDPE lines = {nline}")

    enhancer = atac_path if atac_path and os.path.exists(atac_path) else public_db
    use_public = enhancer == public_db
    print(f"    [INFO] Enhancer source = {'public_db' if use_public else 'cancer_specific'}")

    loops, genes, enh = read_files(bedpe, gene_bed_path, enhancer, use_public)

    res = process_loops_fast(loops, genes, enh, flank)

    out = f"{output_dir}/{cancer}/{gse}/{cell}/anno/mustache/{cell}_loop_annotation_down5k.tsv"
    os.makedirs(os.path.dirname(out), exist_ok=True)
    res.to_csv(out, sep='\t', index=False)

    print(f"    [DONE] Output -> {out}")
    return True


def batch_process(meta_file, atac_bed, gene_bed, base_dir, output_dir,
                  public_db, flank):

    print("[INFO] Loading ATAC mapping")
    atac = dict(pd.read_csv(atac_bed, sep='\t', header=None).values)

    print("[INFO] Loading meta file")
    meta = pd.read_csv(meta_file, sep='\t',
                       names=['cancer','gse','cell','enzyme'])

    print(f"[INFO] Total samples = {len(meta)}\n")

    for i, r in enumerate(meta.itertuples(index=False), 1):
        print(f"[{i}/{len(meta)}]")
        process_single_sample(
            r.cancer, r.gse, r.cell,
            atac.get(r.cancer),
            gene_bed, base_dir, output_dir,
            public_db, flank
        )
        print("")


# =========================================================
# CLI
# =========================================================

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--meta-file', required=False,default='/cluster2/home/futing/Project/panCancer/check/meta/panCan_meta.txt')
    ap.add_argument('--atac-bed', required=False,default='/cluster2/home/futing/Project/panCancer/Analysis/anno_loops/ATAC_bedlist_dsample_ds50000.txt')
    ap.add_argument('--gene-bed', type=str, required=False,
		                default="/cluster2/home/futing/ref_genome/hg38_gencode/genebed/gencode.v43.gene.tss.4col.bed",
                       help='基因TSS BED文件路径')
    ap.add_argument('--base-dir', type=str, required=False,
	                   default='/cluster2/home/futing/Project/panCancer',
                       help='Hi-C数据基础目录（如: /cluster2/home/futing/Project/panCancer）')
    ap.add_argument('--output-dir', type=str, required=False,
		                default='/cluster2/home/futing/Project/panCancer',
                       help='输出目录')
    ap.add_argument('--public-enhancer-db', type=str, required=False,
                       default='/cluster2/home/futing/Project/panCancer/Analysis/anno_loops/downsampled_ATAC/ES.ds50000.bed',
                       help='公共enhancer数据库路径')
    ap.add_argument('--flanking-size', type=int, default=10000)
    args = ap.parse_args()

    batch_process(
        args.meta_file, args.atac_bed, args.gene_bed,
        args.base_dir, args.output_dir,
        args.public_enhancer_db, args.flanking_size
    )


if __name__ == "__main__":
    main()
