import pandas as pd
from typing import Tuple, List, Dict
from itertools import product
import argparse
import os
from pathlib import Path

# 寻找每个loopid两个anchor的特征，E-P P-P E-E other
# version 1 如果没有则丢弃这个loop

def read_files(bedpe_path: str, gene_bed_path: str, enhancer_bed_path: str) -> Tuple[pd.DataFrame, pd.DataFrame, pd.DataFrame]:
    """读取输入文件并确保正确的数据类型"""

    loops_df = pd.read_csv(bedpe_path, sep='\t', 
                          names=['chr1', 'start1', 'end1', 'chr2', 'start2', 'end2','cloop'])
    loops_df['loopid']=loops_df['chr1'].astype(str)+':'+loops_df['start1'].astype(str)+'-'+loops_df['end1'].astype(str)+'_'+loops_df['chr2'].astype(str)+':'+loops_df['start2'].astype(str)+'-'+loops_df['end2'].astype(str)
    position_cols = ['start1', 'end1', 'start2', 'end2']
    for col in position_cols:
        loops_df[col] = pd.to_numeric(loops_df[col], errors='coerce').astype('Int64')
    

    genes_df = pd.read_csv(gene_bed_path, sep='\t',
                          names=['chr', 'start', 'end', 'symbol'])
    genes_df['start'] = pd.to_numeric(genes_df['start'], errors='coerce').astype('Int64')
    genes_df['end'] = pd.to_numeric(genes_df['end'], errors='coerce').astype('Int64')
    
    # 读取enhancer文件
    enhancers_df = pd.read_csv(enhancer_bed_path, sep='\t',
                              names=['chr', 'start', 'end', 'weights','ebin'])
    enhancers_df['start'] = pd.to_numeric(enhancers_df['start'], errors='coerce').astype('Int64')
    enhancers_df['end'] = pd.to_numeric(enhancers_df['end'], errors='coerce').astype('Int64')
    
    return loops_df, genes_df, enhancers_df

def find_overlaps(region_chr: str, region_start: int, region_end: int, 
                 features_df: pd.DataFrame, flanking_size: int = 5000) -> pd.DataFrame:
    """查找给定区域与特征的重叠"""
    # 添加flanking region
    extended_start = max(0, region_start - flanking_size)
    extended_end = region_end + flanking_size
    
    # 查找重叠
    overlaps = features_df[
        (features_df['chr'] == region_chr) &
        (features_df['start'] < extended_end) &
        (features_df['end'] > extended_start)
    ]
    
    # 添加距离信息
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
    
    # 处理基因（P类型特征）
    if not overlaps_genes.empty:
        for _, gene in overlaps_genes.iterrows():
            features.append({
                'type': 'P',
                'id': gene['symbol'],
                'distance': gene['distance'],
                'in_region': gene['in_original_region'],
                'full_info': f"{gene['symbol']}(d={gene['distance']}bp{'in' if gene['in_original_region'] else ',flank'})"
            })
    
    # 处理增强子（E类型特征）
    if not overlaps_enhancers.empty:
        for _, enhancer in overlaps_enhancers.iterrows():
            features.append({
                'type': 'E',
                'id': f"E{enhancer['weights']}",
                'distance': enhancer['distance'],
                'in_region': enhancer['in_original_region'],
                'full_info': f"w={enhancer['weights']}(d={enhancer['distance']}bp{'in' if enhancer['in_original_region'] else ',flank'})"
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
        # 获取两个anchor的所有特征
        anchor1_genes = find_overlaps(loop['chr1'], loop['start1'], loop['end1'], 
                                    genes_df, flanking_size)
        anchor1_enhancers = find_overlaps(loop['chr1'], loop['start1'], loop['end1'], 
                                        enhancers_df,flanking_size=0)
        
        anchor2_genes = find_overlaps(loop['chr2'], loop['start2'], loop['end2'], 
                                    genes_df, flanking_size)
        anchor2_enhancers = find_overlaps(loop['chr2'], loop['start2'], loop['end2'], 
                                        enhancers_df, flanking_size=0)
        
        # 获取两个anchor的所有特征
        anchor1_features = get_anchor_features(anchor1_genes, anchor1_enhancers)
        anchor2_features = get_anchor_features(anchor2_genes, anchor2_enhancers)
        
        # 获取位置信息（用于bin1_info和bin2_info）
        bin1_info = get_anchor_info(anchor1_features)
        bin2_info = get_anchor_info(anchor2_features)
        
        # 生成所有可能的组合
        for f1 in anchor1_features:
            for f2 in anchor2_features:
                interaction_type = f"{f1['type']}-{f2['type']}"
                
                # 设置各类型的标志
                is_ee = 1 if interaction_type == "E-E" else 0
                is_ep = 1 if interaction_type in ["E-P", "P-E"] else 0
                is_pp = 1 if interaction_type == "P-P" else 0
                is_other = 1 if not any([is_ee, is_ep, is_pp]) else 0
                
                # 根据不同类型设置bin1、bin2和gene的值
                if is_pp:
                    # P-P类型：为每个基因创建一行
                    # 第一行 - 展示第一个基因
                    results.append({
                        'loopid': loop['loopid'],
                        'bin1': f1['id'],  # 第一个P
                        'bin2': f2['id'],  # 第二个P
                        'E-E': is_ee,
                        'E-P': is_ep,
                        'P-P': is_pp,
                        'other': is_other,
                        'bin1_info': bin1_info,
                        'bin2_info': bin2_info,
                        'gene': f1['id']  # 第一个基因
                    })
                    
                    # 第二行 - 展示第二个基因
                    results.append({
                        'loopid': loop['loopid'],
                        'bin1': f1['id'],  # 第一个P
                        'bin2': f2['id'],  # 第二个P
                        'E-E': is_ee,
                        'E-P': is_ep,
                        'P-P': is_pp,
                        'other': is_other,
                        'bin1_info': bin1_info,
                        'bin2_info': bin2_info,
                        'gene': f2['id']  # 第二个基因
                    })
                
                elif is_ep:
                    # E-P或P-E类型：只显示基因
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
                    # E-E和其他类型：gene为NA
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


def main():
    """主函数"""
    # 设置命令行参数解析
    parser = argparse.ArgumentParser(description='处理基因组数据文件')
    parser.add_argument('name', type=str, help='数据集的名称（替换GBM）')
    parser.add_argument('--base-dir', type=str, 
                       default='/cluster/home/futing/Project/GBM/HiC/hubgene/new/chip/cytoscape',
                       help='基础目录路径')
    parser.add_argument('--output', type=str, default='results.tsv',
                       help='输出文件名')
    parser.add_argument('--flanking-size', type=int, default=5000,
                       help='flanking区域大小')

    args = parser.parse_args()

    # 构建文件路径
    base_path = Path(args.base_dir)
    bedpe_path = base_path / f"{args.name}_flank0k.bedpe"
    gene_bed_path = base_path / f"{args.name}/gene.tss.bed"
    enhancer_bed_path = base_path / "Eweights.bed"
    output_path = args.output

    # 检查输入文件是否存在
    for file_path in [bedpe_path, gene_bed_path, enhancer_bed_path]:
        if not file_path.exists():
            raise FileNotFoundError(f"文件不存在: {file_path}")

    # 显示处理信息
    print(f"处理以下文件：")
    print(f"BEDPE文件: {bedpe_path}")
    print(f"Gene BED文件: {gene_bed_path}")
    print(f"Enhancer BED文件: {enhancer_bed_path}")
    print(f"输出文件: {output_path}")
    print(f"Flanking size: {args.flanking_size}")

    # 读取文件
    loops_df, genes_df, enhancers_df = read_files(
        str(bedpe_path), 
        str(gene_bed_path), 
        str(enhancer_bed_path)
    )
    
    # 处理数据
    results_df = process_loops(
        loops_df, 
        genes_df, 
        enhancers_df, 
        args.flanking_size
    )
    
    # 保存结果
    results_df.to_csv(output_path, sep='\t', index=False)
    print("处理完成！")

if __name__ == "__main__":
    main()
    