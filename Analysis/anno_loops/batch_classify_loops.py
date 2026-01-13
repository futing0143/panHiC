#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
批量处理多个癌症样本的Loop分类脚本
Batch processing script for classifying loops across multiple cancer samples
Author: Modified from original classify_gene_all.py
Date: January 2026
"""

import pandas as pd
from typing import Tuple, List, Dict
import argparse
import time
import os
from pathlib import Path


def read_files(bedpe_path: str, gene_bed_path: str, enhancer_bed_path: str, 
               is_public_db: bool = False) -> Tuple[pd.DataFrame, pd.DataFrame, pd.DataFrame]:
    """读取输入文件并确保正确的数据类型"""
    
    # 读取bedpe文件，只使用前7列，不指定列名让pandas自动处理
    loops_df = pd.read_csv(bedpe_path, sep='\t', header=None, usecols=[0,1,2,3,4,5])
    loops_df.columns = ['chr1', 'start1', 'end1', 'chr2', 'start2', 'end2']
    
    # 先转换为数值类型，将无效值转为NaN
    position_cols = ['start1', 'end1', 'start2', 'end2']
    for col in position_cols:
        loops_df[col] = pd.to_numeric(loops_df[col], errors='coerce')
    
    # 删除包含NaN的行（即包含无效数据的行）
    original_len = len(loops_df)
    loops_df = loops_df.dropna(subset=position_cols)
    dropped = original_len - len(loops_df)
    if dropped > 0:
        print(f"    Warning: Dropped {dropped} loops with invalid position values")
    
    # 转换为整数类型
    for col in position_cols:
        loops_df[col] = loops_df[col].astype('int64')
    
    # 生成loopid
    loops_df['loopid'] = loops_df['chr1'].astype(str) + ':' + loops_df['start1'].astype(str) + '-' + \
                         loops_df['end1'].astype(str) + '_' + loops_df['chr2'].astype(str) + ':' + \
                         loops_df['start2'].astype(str) + '-' + loops_df['end2'].astype(str)
    
    genes_df = pd.read_csv(gene_bed_path, sep='\t',
                          names=['chr', 'start', 'end', 'symbol'])
    genes_df['start'] = pd.to_numeric(genes_df['start'], errors='coerce')
    genes_df['end'] = pd.to_numeric(genes_df['end'], errors='coerce')
    genes_df = genes_df.dropna(subset=['start', 'end'])
    genes_df['start'] = genes_df['start'].astype('int64')
    genes_df['end'] = genes_df['end'].astype('int64')
    
    # 根据文件类型读取enhancer数据，只读取前3列
    if is_public_db:
        # 公共数据库格式：只读取前3列
        enhancers_df = pd.read_csv(enhancer_bed_path, sep='\t', header=None, usecols=[0,1,2])
        enhancers_df.columns = ['chr', 'start', 'end']
    else:
        # ATAC narrowPeak格式：只读取前3列
        enhancers_df = pd.read_csv(enhancer_bed_path, sep='\t', header=None, usecols=[0,1,2])
        enhancers_df.columns = ['chr', 'start', 'end']
    
    enhancers_df['start'] = pd.to_numeric(enhancers_df['start'], errors='coerce')
    enhancers_df['end'] = pd.to_numeric(enhancers_df['end'], errors='coerce')
    enhancers_df = enhancers_df.dropna(subset=['start', 'end'])
    enhancers_df['start'] = enhancers_df['start'].astype('int64')
    enhancers_df['end'] = enhancers_df['end'].astype('int64')
    # 添加一个简单的ID列
    enhancers_df['enhancer_id'] = ['E' + str(i) for i in range(len(enhancers_df))]
    
    return loops_df, genes_df, enhancers_df


def find_overlaps(region_chr: str, region_start: int, region_end: int, 
                 features_df: pd.DataFrame, flanking_size: int = 5000) -> pd.DataFrame:
    """查找给定区域与特征的重叠"""
    extended_start = max(0, region_start - flanking_size)
    extended_end = region_end + flanking_size
    
    overlaps = features_df[
        (features_df['chr'] == region_chr) &
        (features_df['start'] < extended_end) &
        (features_df['end'] > extended_start)
    ]
    
    if not overlaps.empty:
        overlaps = overlaps.copy()
        overlaps['distance'] = overlaps.apply(
            lambda row: min(
                abs(row['start'] - region_start),
                abs(row['end'] - region_start),
                abs(row['start'] - region_end),
                abs(row['end'] - region_end)
            ),
            axis=1
        )
        overlaps['in_original_region'] = (
            (overlaps['start'] <= region_end) &
            (overlaps['end'] >= region_start)
        )
    
    return overlaps


def get_anchor_features(overlaps_genes: pd.DataFrame, overlaps_enhancers: pd.DataFrame):
    """获取anchor的所有特征（E和P）及其详细信息"""
    features = []
    
    if not overlaps_genes.empty:
        for _, gene in overlaps_genes.iterrows():
            features.append({
                'type': 'P',
                'id': gene['symbol'],
                'distance': gene['distance'],
                'in_region': gene['in_original_region'],
                'full_info': f"{gene['symbol']}(d={gene['distance']}bp,{'in' if gene['in_original_region'] else 'flank'})"
            })
    
    if not overlaps_enhancers.empty:
        for _, enhancer in overlaps_enhancers.iterrows():
            features.append({
                'type': 'E',
                'id': enhancer['enhancer_id'],
                'distance': enhancer['distance'],
                'in_region': enhancer['in_original_region'],
                'full_info': f"{enhancer['enhancer_id']}(d={enhancer['distance']}bp,{'in' if enhancer['in_original_region'] else 'flank'})"
            })
    
    return features


def get_anchor_info(features: List[Dict]) -> str:
    """将特征列表转换为信息字符串"""
    return "|".join(f['full_info'] for f in features) if features else "NA"


def process_loops(loops_df: pd.DataFrame, genes_df: pd.DataFrame, 
                 enhancers_df: pd.DataFrame, flanking_size: int = 5000) -> pd.DataFrame:
    """处理所有loops并生成结果"""
    results = []
    
    for _, loop in loops_df.iterrows():
        anchor1_genes = find_overlaps(loop['chr1'], loop['start1'], loop['end1'], 
                                    genes_df, flanking_size)
        anchor1_enhancers = find_overlaps(loop['chr1'], loop['start1'], loop['end1'], 
                                        enhancers_df, flanking_size)
        
        anchor2_genes = find_overlaps(loop['chr2'], loop['start2'], loop['end2'], 
                                    genes_df, flanking_size)
        anchor2_enhancers = find_overlaps(loop['chr2'], loop['start2'], loop['end2'], 
                                        enhancers_df, flanking_size)
        
        anchor1_features = get_anchor_features(anchor1_genes, anchor1_enhancers)
        anchor2_features = get_anchor_features(anchor2_genes, anchor2_enhancers)
        
        bin1_info = get_anchor_info(anchor1_features)
        bin2_info = get_anchor_info(anchor2_features)
        
        if not anchor1_features and not anchor2_features:
            results.append({
                'loopid': loop['loopid'],
                'bin1': 'NA',
                'bin2': 'NA',
                'E-E': 0,
                'E-P': 0,
                'P-P': 0,
                'other': 1,
                'bin1_info': bin1_info,
                'bin2_info': bin2_info,
                'gene': 'NA'
            })
            continue
        
        if not anchor1_features:
            anchor1_features = [{
                'type': 'O',
                'id': 'NA',
                'distance': None,
                'in_region': False,
                'full_info': 'NA'
            }]
        
        if not anchor2_features:
            anchor2_features = [{
                'type': 'O',
                'id': 'NA',
                'distance': None,
                'in_region': False,
                'full_info': 'NA'
            }]
        
        for f1 in anchor1_features:
            for f2 in anchor2_features:
                interaction_type = f"{f1['type']}-{f2['type']}"
                
                is_ee = 1 if interaction_type == "E-E" else 0
                is_ep = 1 if interaction_type in ["E-P", "P-E"] else 0
                is_pp = 1 if interaction_type == "P-P" else 0
                is_other = 1 if ('O' in interaction_type) or not any([is_ee, is_ep, is_pp]) else 0
                
                if is_pp:
                    results.append({
                        'loopid': loop['loopid'],
                        'bin1': f1['id'],
                        'bin2': f2['id'],
                        'E-E': is_ee,
                        'E-P': is_ep,
                        'P-P': is_pp,
                        'other': is_other,
                        'bin1_info': bin1_info,
                        'bin2_info': bin2_info,
                        'gene': f1['id']
                    })
                    
                    results.append({
                        'loopid': loop['loopid'],
                        'bin1': f1['id'],
                        'bin2': f2['id'],
                        'E-E': is_ee,
                        'E-P': is_ep,
                        'P-P': is_pp,
                        'other': is_other,
                        'bin1_info': bin1_info,
                        'bin2_info': bin2_info,
                        'gene': f2['id']
                    })
                
                elif is_ep:
                    gene = f1['id'] if f1['type'] == 'P' else f2['id']
                    results.append({
                        'loopid': loop['loopid'],
                        'bin1': f1['id'] if f1['type'] in ['E', 'P'] else 'NA',
                        'bin2': f2['id'] if f2['type'] in ['E', 'P'] else 'NA',
                        'E-E': is_ee,
                        'E-P': is_ep,
                        'P-P': is_pp,
                        'other': is_other,
                        'bin1_info': bin1_info,
                        'bin2_info': bin2_info,
                        'gene': gene
                    })
                
                else:
                    results.append({
                        'loopid': loop['loopid'],
                        'bin1': f1['id'] if f1['type'] in ['E', 'P'] else 'NA',
                        'bin2': f2['id'] if f2['type'] in ['E', 'P'] else 'NA',
                        'E-E': is_ee,
                        'E-P': is_ep,
                        'P-P': is_pp,
                        'other': is_other,
                        'bin1_info': bin1_info,
                        'bin2_info': bin2_info,
                        'gene': 'NA'
                    })
    
    return pd.DataFrame(results)


def process_single_sample(cancer: str, gse: str, cell: str, atac_path: str,
                         gene_bed_path: str, base_dir: str, output_dir: str,
                         public_enhancer_db: str, flanking_size: int = 5000):
    """处理单个样本"""
    try:
        print(f"  Processing: {cancer} - {cell}")
        
        # 构建bedpe文件路径
        bedpe_path = f"{base_dir}/{cancer}/{gse}/{cell}/anno/mustache/{cell}_10kb_mustache.bedpe"
        
        # 检查bedpe文件是否存在且行数大于1000
        if not os.path.exists(bedpe_path):
            print(f"    Warning: BEDPE file not found: {bedpe_path}")
            return False
        
        # 检查bedpe文件行数
        with open(bedpe_path, 'r') as f:
            line_count = sum(1 for _ in f)
        
        if line_count <= 1000:
            print(f"    Skipped: BEDPE file has only {line_count} lines (threshold: 1000)")
            return 'skipped'
        
        print(f"    BEDPE file OK: {line_count} lines")
        
        # 检查gene bed文件
        if not os.path.exists(gene_bed_path):
            print(f"    Warning: Gene BED file not found: {gene_bed_path}")
            return False
        
        # 检查enhancer文件，决定使用ATAC bed还是公共数据库
        use_public_db = False
        enhancer_path = atac_path
        
        if atac_path and os.path.exists(atac_path):
            print(f"    Using cancer-specific ATAC bed")
            use_public_db = False
        else:
            print(f"    Cancer-specific ATAC bed not found, using public database")
            enhancer_path = public_enhancer_db
            use_public_db = True
            
            if not os.path.exists(enhancer_path):
                print(f"    Error: Public enhancer database not found: {enhancer_path}")
                return False
        
        # 读取文件
        loops_df, genes_df, enhancers_df = read_files(bedpe_path, gene_bed_path, 
                                                       enhancer_path, use_public_db)
        print(f"    Loaded {len(loops_df)} loops, {len(genes_df)} genes, {len(enhancers_df)} enhancers")
        
        # 处理数据
        results_df = process_loops(loops_df, genes_df, enhancers_df, flanking_size)
        print(f"    Generated {len(results_df)} annotations")
        
        # 构建输出路径
        output_path = f"{output_dir}/{gse}/{cancer}/{cell}_loop_annotation.tsv"
        
        # 创建输出目录
        os.makedirs(os.path.dirname(output_path), exist_ok=True)
        
        # 保存结果，添加数据源信息
        results_df['enhancer_source'] = 'public_db' if use_public_db else 'cancer_specific'
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
                 public_enhancer_db: str = '/cluster2/home/futing/Project/panCancer/Analysis/anno_loops/enh2target-1.0.2.txt',
                 flanking_size: int = 5000):
    """
    批量处理多个样本
    
    参数:
        meta_file: panCan_meta.txt文件路径
        atac_bed_file: ATAC_bed.txt文件路径
        gene_bed_path: 基因TSS BED文件路径
        base_dir: Hi-C数据基础目录 (/cluster2/home/futing/Project/panCancer)
        output_dir: 输出目录
        public_enhancer_db: 公共enhancer数据库路径
        flanking_size: 侧翼区域大小
    """
    
    start_time = time.time()
    
    # 读取ATAC文件路径映射
    print(f"Reading ATAC bed file: {atac_bed_file}")
    atac_dict = {}
    with open(atac_bed_file, 'r') as f:
        for line in f:
            parts = line.strip().split('\t')
            if len(parts) == 2:
                cancer_type, atac_path = parts
                atac_dict[cancer_type] = atac_path
    
    print(f"Loaded {len(atac_dict)} ATAC bed paths")
    
    # 检查公共数据库是否存在
    if not os.path.exists(public_enhancer_db):
        print(f"Warning: Public enhancer database not found: {public_enhancer_db}")
        print(f"Will only process samples with cancer-specific ATAC beds")
    else:
        print(f"Public enhancer database available: {public_enhancer_db}")
    
    # 读取meta文件
    print(f"Reading meta file: {meta_file}")
    meta_df = pd.read_csv(meta_file, sep='\t', names=['cancer', 'gse', 'cell', 'enzyme'])
    
    print(f"\n{'='*70}")
    print(f"Batch Loop Classification")
    print(f"{'='*70}")
    print(f"Total samples to process: {len(meta_df)}")
    print(f"Flanking size: {flanking_size} bp")
    print(f"Gene bed file: {gene_bed_path}")
    print(f"Base directory: {base_dir}")
    print(f"Output directory: {output_dir}")
    print(f"Public enhancer DB: {public_enhancer_db}")
    print(f"{'='*70}\n")
    
    # 处理统计
    successful = 0
    failed = 0
    skipped_no_loops = 0
    skipped_no_atac = 0
    used_public_db = 0
    
    # 处理每个样本
    for i, row in meta_df.iterrows():
        cancer = row['cancer']
        gse = row['gse']
        cell = row['cell']
        
        print(f"[{i+1}/{len(meta_df)}] {cancer} - {gse} - {cell}")
        
        # 获取ATAC路径（如果不存在则为None）
        atac_path = atac_dict.get(cancer, None)
        
        # 如果没有cancer-specific ATAC且没有公共数据库，跳过
        if atac_path is None and not os.path.exists(public_enhancer_db):
            print(f"    Warning: No ATAC bed for {cancer} and no public database available")
            skipped_no_atac += 1
            print()
            continue
        
        # 处理样本
        result = process_single_sample(cancer, gse, cell, atac_path, gene_bed_path,
                                      base_dir, output_dir, public_enhancer_db, flanking_size)
        
        if result == True:
            successful += 1
            if atac_path is None or not os.path.exists(atac_path):
                used_public_db += 1
        elif result == 'skipped':
            skipped_no_loops += 1
        else:
            failed += 1
        
        print()
    
    # 总结
    end_time = time.time()
    elapsed_time = end_time - start_time
    
    print(f"{'='*70}")
    print(f"Batch Processing Summary")
    print(f"{'='*70}")
    print(f"Total samples: {len(meta_df)}")
    print(f"Successful: {successful}")
    print(f"  - Used cancer-specific ATAC: {successful - used_public_db}")
    print(f"  - Used public database: {used_public_db}")
    print(f"Skipped (loops < 1000): {skipped_no_loops}")
    print(f"Skipped (no enhancer data): {skipped_no_atac}")
    print(f"Failed: {failed}")
    print(f"Total time: {elapsed_time:.2f} seconds ({elapsed_time/60:.2f} minutes)")
    if len(meta_df) > 0:
        print(f"Average time per sample: {elapsed_time/len(meta_df):.2f} seconds")
    print(f"{'='*70}\n")


def main():
    parser = argparse.ArgumentParser(
        description="批量处理多个癌症样本的Loop分类（基于panCan_meta.txt和ATAC_bed.txt）",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
示例用法:

python batch_classify_loops.py \\
    --meta-file panCan_meta.txt \\
    --atac-bed ATAC_bed.txt \\
    --gene-bed /path/to/gene.tss.bed \\
    --base-dir /cluster2/home/futing/Project/panCancer \\
    --output-dir /path/to/output \\
    --flanking-size 5000

输入文件格式:
- panCan_meta.txt: 包含 cancer, gse, cell, enzyme 四列，制表符分隔
- ATAC_bed.txt: 包含 cancer_type 和 atac_path 两列，制表符分隔
        """
    )
    
    # 必需参数
    parser.add_argument('--meta-file', type=str, required=True,
                       help='panCan_meta.txt文件路径（包含cancer, gse, cell, enzyme信息）')
    parser.add_argument('--atac-bed', type=str, required=True,
                       help='ATAC_bed.txt文件路径（包含cancer type到ATAC bed路径的映射）')
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
                       help='侧翼区域大小（默认: 5000 bp）')
    parser.add_argument('--public-enhancer-db', type=str, 
                       default='/cluster2/home/futing/Project/panCancer/Analysis/anno_loops/enh2target-1.0.2.txt',
                       help='公共enhancer数据库路径（当癌症特异性ATAC bed不存在时使用）')
    
    args = parser.parse_args()
    
    # 执行批量处理
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