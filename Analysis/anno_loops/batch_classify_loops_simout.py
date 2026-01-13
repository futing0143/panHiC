#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
批量处理Loop分类脚本 - 简化输出版 (Output: loopid, category)
Batch processing script for classifying loops (P-P, E-P, E-E, Other)
Author: Modified for simplified output
Date: January 2026
"""

import pandas as pd
from typing import Tuple, List, Dict
import argparse
import time
import os
import sys

# ==========================================
# 辅助函数：按染色体拆分数据以加速查找
# ==========================================
def split_dataframe_by_chr(df: pd.DataFrame) -> Dict[str, pd.DataFrame]:
    """
    将DataFrame按'chr'列拆分为字典，key为染色体名，value为对应的子DataFrame。
    这大大减少了查找overlap时的搜索空间。
    """
    if df.empty:
        return {}
    return {k: v for k, v in df.groupby('chr')}

def read_files(bedpe_path: str, gene_bed_path: str, enhancer_bed_path: str, 
               is_public_db: bool = False) -> Tuple[pd.DataFrame, pd.DataFrame, pd.DataFrame]:
    """读取输入文件并确保正确的数据类型"""
    
    # --- 1. 读取 Loop (BEDPE) ---
    # 为了兼容性，强制读取前6列
    loops_df = pd.read_csv(bedpe_path, sep='\t', header=None, usecols=[0,1,2,3,4,5], comment='#')
    loops_df.columns = ['chr1', 'start1', 'end1', 'chr2', 'start2', 'end2']
    
    # 清洗数据
    position_cols = ['start1', 'end1', 'start2', 'end2']
    for col in position_cols:
        loops_df[col] = pd.to_numeric(loops_df[col], errors='coerce')
    
    loops_df = loops_df.dropna(subset=position_cols)
    
    for col in position_cols:
        loops_df[col] = loops_df[col].astype('int64')
    
    # 生成 loopid
    loops_df['loopid'] = loops_df['chr1'].astype(str) + ':' + loops_df['start1'].astype(str) + '-' + \
                         loops_df['end1'].astype(str) + '_' + loops_df['chr2'].astype(str) + ':' + \
                         loops_df['start2'].astype(str) + '-' + loops_df['end2'].astype(str)
    
    # --- 2. 读取 Gene BED ---
    genes_df = pd.read_csv(gene_bed_path, sep='\t', header=None, usecols=[0,1,2,3],
                          names=['chr', 'start', 'end', 'symbol'])
    
    genes_df['start'] = pd.to_numeric(genes_df['start'], errors='coerce').astype('Int64')
    genes_df['end'] = pd.to_numeric(genes_df['end'], errors='coerce').astype('Int64')
    genes_df = genes_df.dropna(subset=['start', 'end'])
    
    # --- 3. 读取 Enhancer BED ---
    # 无论是特异性ATAC还是公共DB，都只取前3列坐标
    enhancers_df = pd.read_csv(enhancer_bed_path, sep='\t', header=None, usecols=[0,1,2])
    enhancers_df.columns = ['chr', 'start', 'end']
    
    enhancers_df['start'] = pd.to_numeric(enhancers_df['start'], errors='coerce').astype('Int64')
    enhancers_df['end'] = pd.to_numeric(enhancers_df['end'], errors='coerce').astype('Int64')
    enhancers_df = enhancers_df.dropna(subset=['start', 'end'])
    
    return loops_df, genes_df, enhancers_df


def find_overlaps_optimized(region_chr: str, region_start: int, region_end: int, 
                          features_dict: Dict[str, pd.DataFrame], flanking_size: int = 5000) -> pd.DataFrame:
    """
    查找重叠 (优化版：直接从字典获取对应染色体的DataFrame)
    """
    if region_chr not in features_dict:
        return pd.DataFrame()
    
    subset_df = features_dict[region_chr]
    
    extended_start = max(0, region_start - flanking_size)
    extended_end = region_end + flanking_size
    
    # 查找重叠
    overlaps = subset_df[
        (subset_df['start'] < extended_end) &
        (subset_df['end'] > extended_start)
    ]
    
    return overlaps # 对于简化输出，只需要知道有没有overlap，不需要计算详细距离


def process_loops(loops_df: pd.DataFrame, genes_df: pd.DataFrame, 
                 enhancers_df: pd.DataFrame, flanking_size: int = 5000) -> pd.DataFrame:
    """处理所有loops并生成简化结果 (loopid, category)"""
    results = []
    
    # --- 性能优化：预先按染色体分割数据 ---
    # print("    Pre-indexing features...", end="", flush=True)
    genes_by_chr = split_dataframe_by_chr(genes_df)
    enhancers_by_chr = split_dataframe_by_chr(enhancers_df)
    # print(" Done.")
    
    total_loops = len(loops_df)
    print_interval = max(1, total_loops // 5) # 进度条
    
    for idx, (_, loop) in enumerate(loops_df.iterrows()):
        if idx % print_interval == 0 and idx > 0:
            print(f"    Processed {idx}/{total_loops} loops...")

        # 1. 查找左锚点 (Anchor 1) 的重叠
        # Gene 使用参数指定的 flanking_size
        a1_genes = find_overlaps_optimized(loop['chr1'], loop['start1'], loop['end1'], 
                                         genes_by_chr, flanking_size)
        # Enhancer 使用 flanking_size=0 (根据您的要求)
        a1_enhancers = find_overlaps_optimized(loop['chr1'], loop['start1'], loop['end1'], 
                                             enhancers_by_chr, flanking_size=0)
        
        # 2. 查找右锚点 (Anchor 2) 的重叠
        a2_genes = find_overlaps_optimized(loop['chr2'], loop['start2'], loop['end2'], 
                                         genes_by_chr, flanking_size)
        a2_enhancers = find_overlaps_optimized(loop['chr2'], loop['start2'], loop['end2'], 
                                             enhancers_by_chr, flanking_size=0)
        
        # 3. 确定每个Anchor的属性集合 {'P', 'E', 'O'}
        features1 = set()
        if not a1_genes.empty: features1.add('P')
        if not a1_enhancers.empty: features1.add('E')
        if not features1: features1.add('O')

        features2 = set()
        if not a2_genes.empty: features2.add('P')
        if not a2_enhancers.empty: features2.add('E')
        if not features2: features2.add('O')
        
        # 4. 组合判断类别
        loop_categories = set()
        for f1 in features1:
            for f2 in features2:
                pair = sorted([f1, f2]) # 排序，保证 P-E 和 E-P 一致
                pair_str = "-".join(pair)
                
                if pair_str == "P-P":
                    loop_categories.add("P-P")
                elif pair_str == "E-P": # sorted后 E在前
                    loop_categories.add("E-P")
                elif pair_str == "E-E":
                    loop_categories.add("E-E")
                else:
                    loop_categories.add("Other")
        
        # 5. 优先级清洗
        # 如果一个Loop既是 E-P 又是 Other (因为某端可能同时是空和E)，保留更有意义的分类
        # 优先级: P-P > E-P > E-E > Other
        final_category = "Other"
        if "P-P" in loop_categories:
            final_category = "P-P"
        elif "E-P" in loop_categories:
            final_category = "E-P"
        elif "E-E" in loop_categories:
            final_category = "E-E"
        
        results.append({
            'loopid': loop['loopid'],
            'category': final_category
        })
    
    return pd.DataFrame(results)


def process_single_sample(cancer: str, gse: str, cell: str, atac_path: str,
                         gene_bed_path: str, base_dir: str, output_dir: str,
                         public_enhancer_db: str, flanking_size: int = 5000):
    """处理单个样本"""
    try:
        print(f"  Processing: {cancer} - {cell}")
        
        bedpe_path = f"{base_dir}/{cancer}/{gse}/{cell}/anno/mustache/{cell}_10kb_mustache.bedpe"
        
        # 检查BEDPE文件
        if not os.path.exists(bedpe_path):
            print(f"    Warning: BEDPE file not found: {bedpe_path}")
            return False
        
        # 检查行数
        with open(bedpe_path, 'r') as f:
            line_count = sum(1 for _ in f)
        if line_count <= 1000:
            print(f"    Skipped: BEDPE file has only {line_count} lines (threshold: 1000)")
            return 'skipped'
        
        # 检查Gene文件
        if not os.path.exists(gene_bed_path):
            print(f"    Error: Gene BED file not found: {gene_bed_path}")
            return False
        
        # 确定Enhancer文件
        use_public_db = False
        enhancer_path = atac_path
        
        if atac_path and os.path.exists(atac_path):
            print(f"    Using cancer-specific ATAC bed: {os.path.basename(atac_path)}")
            use_public_db = False
        else:
            print(f"    Cancer-specific ATAC bed not found/provided, checking public database...")
            enhancer_path = public_enhancer_db
            use_public_db = True
            if not os.path.exists(enhancer_path):
                print(f"    Error: Public enhancer database not found: {enhancer_path}")
                return False
        
        # 读取文件
        loops_df, genes_df, enhancers_df = read_files(bedpe_path, gene_bed_path, 
                                                       enhancer_path, use_public_db)
        
        # 处理数据
        results_df = process_loops(loops_df, genes_df, enhancers_df, flanking_size)
        print(f"    Generated {len(results_df)} categorized loops")
        
        # 构建输出路径 (注意文件名可能需要区分是新的格式)
        output_path = f"{output_dir}/{cancer}/{gse}/{cell}/anno/mustache/{cell}_loop_category_down5w.tsv"
        os.makedirs(os.path.dirname(output_path), exist_ok=True)
        
        # 保存结果
        results_df.to_csv(output_path, sep='\t', index=False)
        print(f"    Output saved to: {output_path}")
        
        return True
        
    except Exception as e:
        print(f"    Error processing {cancer}-{cell}: {str(e)}")
        import traceback
        traceback.print_exc()
        return False


def batch_process(meta_file: str, atac_bed_file: str, gene_bed_path: str,
                 base_dir: str, output_dir: str, 
                 public_enhancer_db: str,
                 flanking_size: int = 5000):
    
    start_time = time.time()
    
    # 1. 读取ATAC List
    print(f"Reading ATAC bed file: {atac_bed_file}")
    atac_dict = {}
    if os.path.exists(atac_bed_file):
        with open(atac_bed_file, 'r') as f:
            for line in f:
                parts = line.strip().split('\t')
                if len(parts) >= 2:
                    cancer_type, atac_path = parts[0], parts[1]
                    atac_dict[cancer_type] = atac_path
    else:
        print(f"Warning: ATAC bed file list not found: {atac_bed_file}")

    print(f"Loaded {len(atac_dict)} ATAC bed paths")
    
    # 2. 读取 Meta Data
    print(f"Reading meta file: {meta_file}")
    if not os.path.exists(meta_file):
        print(f"Error: Meta file not found: {meta_file}")
        return

    meta_df = pd.read_csv(meta_file, sep='\t', names=['cancer', 'gse', 'cell', 'enzyme'])
    
    print(f"\n{'='*70}")
    print(f"Batch Loop Classification (Simplified Output)")
    print(f"{'='*70}")
    print(f"Total samples: {len(meta_df)}")
    print(f"Flanking size: {flanking_size} bp (Genes only)")
    print(f"Output dir: {output_dir}")
    print(f"{'='*70}\n")
    
    successful = 0
    failed = 0
    skipped = 0
    
    for i, row in meta_df.iterrows():
        cancer = row['cancer']
        gse = row['gse']
        cell = row['cell']
        
        print(f"[{i+1}/{len(meta_df)}] {cancer} - {gse} - {cell}")
        
        atac_path = atac_dict.get(cancer, None)
        
        # 执行处理
        result = process_single_sample(cancer, gse, cell, atac_path, gene_bed_path,
                                      base_dir, output_dir, public_enhancer_db, flanking_size)
        
        if result == True:
            successful += 1
        elif result == 'skipped':
            skipped += 1
        else:
            failed += 1
        
        print()
    
    elapsed_time = time.time() - start_time
    
    print(f"{'='*70}")
    print(f"Batch Processing Summary")
    print(f"{'='*70}")
    print(f"Total: {len(meta_df)}")
    print(f"Success: {successful}")
    print(f"Skipped: {skipped}")
    print(f"Failed: {failed}")
    print(f"Time: {elapsed_time:.2f}s")
    print(f"{'='*70}\n")


def main():
    parser = argparse.ArgumentParser(
        description="批量处理Loop分类 (输出简化的 loopid, category)",
        formatter_class=argparse.RawDescriptionHelpFormatter
    )
    
    # 必需参数
    parser.add_argument('--meta-file', type=str, required=True, help='panCan_meta.txt路径')
    parser.add_argument('--atac-bed', type=str, required=True, help='ATAC_bed.txt路径')
    
    # 路径参数
    parser.add_argument('--gene-bed', type=str, required=False,
		                default="/cluster2/home/futing/ref_genome/hg38_gencode/genebed/gencode.v43.gene.tss.4col.bed",
                       help='基因TSS BED文件路径')
    parser.add_argument('--base-dir', type=str, required=False,
	                   default='/cluster2/home/futing/Project/panCancer',
                       help='Hi-C数据基础目录（如: /cluster2/home/futing/Project/panCancer）')
    parser.add_argument('--output-dir', type=str, required=False,
		                default='/cluster2/home/futing/Project/panCancer',
                       help='输出目录')
    
    # 可选参数
    parser.add_argument('--flanking-size', type=int, default=10000,
                       help='基因侧翼区域大小（默认: 5000 bp）。注意：Enhancer侧翼固定为0。')
    parser.add_argument('--public-enhancer-db', type=str, required=False,
                       default='/cluster2/home/futing/Project/panCancer/Analysis/anno_loops/downsampled_ATAC/ES.ds50000.bed',
                       help='公共enhancer数据库路径')
    
    args = parser.parse_args()
    
    batch_process(
        meta_file=args.meta_file,
        atac_bed_file=args.atac_bed,
        gene_bed_path=args.gene_bed,
        base_dir=args.base_dir,
        output_dir=args.output_dir,
        public_enhancer_db=args.public_enhancer_db,
        flanking_size=args.flanking_size
    )


if __name__ == "__main__":
    main()