import pandas as pd
from typing import Tuple, List, Dict
from itertools import product
import argparse
import time


# 寻找每个loopid两个anchor的特征，E-P P-P E-E other，如果没有特征则记为NA
# Futing at Feb24

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
                              names=['chr', 'start', 'end', 'weights','occurrences','ebin'])
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
                'id': f"E{enhancer['occurrences']}",
                'distance': enhancer['distance'],
                'in_region': enhancer['in_original_region'],
                'full_info': f"w={enhancer['occurrences']}(d={enhancer['distance']}bp{'in' if enhancer['in_original_region'] else ',flank'})"
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
                                        enhancers_df, flanking_size)
        
        anchor2_genes = find_overlaps(loop['chr2'], loop['start2'], loop['end2'], 
                                    genes_df, flanking_size)
        anchor2_enhancers = find_overlaps(loop['chr2'], loop['start2'], loop['end2'], 
                                        enhancers_df, flanking_size)
        
        # 获取两个anchor的所有特征
        anchor1_features = get_anchor_features(anchor1_genes, anchor1_enhancers)
        anchor2_features = get_anchor_features(anchor2_genes, anchor2_enhancers)
        
        # 获取位置信息（用于bin1_info和bin2_info）
        bin1_info = get_anchor_info(anchor1_features)
        bin2_info = get_anchor_info(anchor2_features)
        
        # 如果两个anchor都没有任何特征，创建一个other类型的记录
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
        
        # 如果某一个anchor没有特征，则用空特征补充，以便生成组合
        if not anchor1_features:
            anchor1_features = [{
                'type': 'O',  # Other
                'id': 'NA',
                'distance': None,
                'in_region': False,
                'full_info': 'NA'
            }]
        
        if not anchor2_features:
            anchor2_features = [{
                'type': 'O',  # Other
                'id': 'NA',
                'distance': None,
                'in_region': False,
                'full_info': 'NA'
            }]
        
        # 生成所有可能的组合
        for f1 in anchor1_features:
            for f2 in anchor2_features:
                interaction_type = f"{f1['type']}-{f2['type']}"
                
                # 设置各类型的标志
                is_ee = 1 if interaction_type == "E-E" else 0
                is_ep = 1 if interaction_type in ["E-P", "P-E"] else 0
                is_pp = 1 if interaction_type == "P-P" else 0
                # 修改other的判断逻辑：如果任一type是O，或者没有其他类型匹配，就标记为other
                is_other = 1 if ('O' in interaction_type) or not any([is_ee, is_ep, is_pp]) else 0
                
                # 根据不同类型设置bin1、bin2和gene的值
                if is_pp:
                    # P-P类型：为每个基因创建一行
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


def main(bedpe_path: str, gene_bed_path: str, enhancer_bed_path: str, 
         output_path: str, flanking_size: int = 5000):

	# start time
	start_time=time.time()
	# 读取文件
	loops_df, genes_df, enhancers_df = read_files(bedpe_path, gene_bed_path, enhancer_bed_path)

	# 处理数据
	results_df = process_loops(loops_df, genes_df, enhancers_df, flanking_size)

	# 保存结果
	results_df.to_csv(output_path, sep='\t', index=False)

	# end time
	end_time=time.time()
	elapsed_time = end_time - start_time
	print(f'Classify_gene_all.py elapsing time: {elapsed_time:.6f} s')

if __name__ == "__main__":
    
	parser = argparse.ArgumentParser(description="传入name")
	parser.add_argument('name', type=str, help="sample same")
	args = parser.parse_args()
	name=args.name
	main(f"/cluster/home/futing/Project/GBM/HiC/10loop/consensus/merged/flank0k/{name}_flank0k.bedpe", 
			f"/cluster/home/futing/Project/GBM/HiC/10loop/consensus/cytoscape/gene.tss.bed", 
			f"/cluster/home/futing/Project/GBM/HiC/10loop/consensus/cytoscape/{name}/{name}_Eweights_bash.bed", 
			f"/cluster/home/futing/Project/GBM/HiC/10loop/consensus/cytoscape/{name}/{name}_loop.bed", flanking_size=5000)
    