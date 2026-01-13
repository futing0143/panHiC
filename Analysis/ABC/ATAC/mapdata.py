import pandas as pd
import os

def fuzzy_match(sample_name, candidate_list):
    """
    模糊匹配函数：不区分大小写，支持包含关系
    返回匹配的候选项，如果没有匹配返回None
    """
    sample_lower = sample_name.lower()
    
    for candidate in candidate_list:
        candidate_lower = candidate.lower()
        # 检查是否存在包含关系（双向）
        if sample_lower in candidate_lower or candidate_lower in sample_lower:
            return candidate
    return None

def main():
    # 1. 读取Hi-C的meta.txt文件
    # 假设meta.txt是制表符或逗号分隔的文件，包含clcell列
    meta_file = '/cluster2/home/futing/Project/panCancer/check/meta/PanmergedMeta_0104.txt'
    
    # 尝试不同的分隔符
    try:
        meta_df = pd.read_csv(meta_file, sep='\t')
    except:
        try:
            meta_df = pd.read_csv(meta_file, sep=',')
        except:
            meta_df = pd.read_csv(meta_file, sep='\s+', engine='python')
    
    if 'clcell' not in meta_df.columns:
        raise ValueError("meta.txt中没有找到'clcell'列，请检查文件格式")
    
    print(f"Meta文件样本数（包含重复）: {len(meta_df)}")
    print(f"Meta文件唯一样本数: {meta_df['clcell'].nunique()}")
    
    # 2. 读取四个数据源的txt文件
    GEO_file = '/cluster2/home/futing/Project/panCancer/Analysis/ABC/ATAC/GEO/GEO.txt'
    ATACdb_file = '/cluster2/home/futing/Project/panCancer/Analysis/ABC/ATAC/ATACdb/ATACdb.txt'
    ENCODE_file = '/cluster2/home/futing/Project/panCancer/Analysis/ABC/ATAC/ENCODE/ENCODE.txt' 
    cistrome_file = '/cluster2/home/futing/Project/panCancer/Analysis/ABC/ATAC/cistrome/cistrome.txt'
    
    # 读取样本列表（假设每个文件只有一列，没有表头）
    def read_sample_list(filename):
        if os.path.exists(filename):
            with open(filename, 'r') as f:
                samples = [line.strip() for line in f if line.strip()]
            return samples
        else:
            print(f"警告: 文件 {filename} 不存在")
            return []
    
    geo_samples = read_sample_list(GEO_file)
    atacdb_samples = read_sample_list(ATACdb_file)
    encode_samples = read_sample_list(ENCODE_file)
    cistrome_samples = read_sample_list(cistrome_file)
    
    print(f"\nGEO样本数: {len(geo_samples)}")
    print(f"ATACdb样本数: {len(atacdb_samples)}")
    print(f"ENCODE样本数: {len(encode_samples)}")
    print(f"Cistrome样本数: {len(cistrome_samples)}")
    
    # 3. 对每个meta中的样本进行匹配（保留所有行，包括重复的clcell）
    geo_matches = []
    atacdb_matches = []
    encode_matches = []
    cistrome_matches = []
    has_any_list = []
    
    for idx, row in meta_df.iterrows():
        sample_name = row['clcell']
        
        # 匹配四个数据源
        geo_match = fuzzy_match(sample_name, geo_samples)
        atacdb_match = fuzzy_match(sample_name, atacdb_samples)
        encode_match = fuzzy_match(sample_name, encode_samples)
        cistrome_match = fuzzy_match(sample_name, cistrome_samples)
        
        # 判断是否存在（0或1）
        has_geo = 1 if geo_match else 0
        has_atacdb = 1 if atacdb_match else 0
        has_encode = 1 if encode_match else 0
        has_cistrome = 1 if cistrome_match else 0
        
        # 汇总：至少有一个数据源存在该样本
        has_any = 1 if (has_geo or has_atacdb or has_encode or has_cistrome) else 0
        
        geo_matches.append(has_geo)
        atacdb_matches.append(has_atacdb)
        encode_matches.append(has_encode)
        cistrome_matches.append(has_cistrome)
        has_any_list.append(has_any)
    
    # 4. 将新列添加到原始meta_df后面
    result_df = meta_df.copy()
    result_df['GEO'] = geo_matches
    result_df['ATACdb'] = atacdb_matches
    result_df['ENCODE'] = encode_matches
    result_df['Cistrome'] = cistrome_matches
    result_df['has_any_ATAC'] = has_any_list
    
    # 5. 保存结果
    output_file = 'meta_with_ATAC_matches.txt'
    result_df.to_csv(output_file, sep='\t', index=False)
    
    # 6. 打印统计信息
    print("\n" + "="*60)
    print("匹配结果统计:")
    print("="*60)
    print(f"总行数（包含重复样本）: {len(result_df)}")
    print(f"有GEO数据的行数: {result_df['GEO'].sum()}")
    print(f"有ATACdb数据的行数: {result_df['ATACdb'].sum()}")
    print(f"有ENCODE数据的行数: {result_df['ENCODE'].sum()}")
    print(f"有Cistrome数据的行数: {result_df['Cistrome'].sum()}")
    print(f"至少有一种ATAC数据的行数: {result_df['has_any_ATAC'].sum()}")
    print(f"四种ATAC数据都有的行数: {((result_df['GEO'] == 1) & (result_df['ATACdb'] == 1) & (result_df['ENCODE'] == 1) & (result_df['Cistrome'] == 1)).sum()}")
    
    # 按唯一样本统计
    print("\n" + "="*60)
    print("按唯一样本统计:")
    print("="*60)
    unique_stats = result_df.groupby('clcell')[['GEO', 'ATACdb', 'ENCODE', 'Cistrome', 'has_any_ATAC']].max()
    print(f"唯一样本数: {len(unique_stats)}")
    print(f"有GEO数据的唯一样本数: {unique_stats['GEO'].sum()}")
    print(f"有ATACdb数据的唯一样本数: {unique_stats['ATACdb'].sum()}")
    print(f"有ENCODE数据的唯一样本数: {unique_stats['ENCODE'].sum()}")
    print(f"有Cistrome数据的唯一样本数: {unique_stats['Cistrome'].sum()}")
    print(f"至少有一种ATAC数据的唯一样本数: {unique_stats['has_any_ATAC'].sum()}")
    
    print("\n" + "="*60)
    print(f"结果已保存到: {output_file}")
    print("="*60)
    
    return result_df

if __name__ == "__main__":
    result = main()
    
    # 显示前几行结果
    print("\n前10行匹配结果:")
    print(result.head(10))