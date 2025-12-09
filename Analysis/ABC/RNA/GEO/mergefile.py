import pandas as pd
import glob
import os
import argparse

def merge_tpm_files(base_path, sep=',', end='_TPM.csv'):
    """
    合并指定目录下所有的TPM文件
    base_path: 基础路径
    sep: 文件分隔符，默认为','（逗号），也可以是'\t'（制表符）等
    end: 文件名结尾匹配模式，默认为'_TPM.csv'
    """
    # 查找所有匹配的文件
    pattern = os.path.join(base_path, f'**/*{end}')
    files = glob.glob(pattern, recursive=True)
    
    if not files:
        print(f"在 {base_path} 未找到 *{end} 文件")
        return None
    
    print(f"找到 {len(files)} 个文件:")
    for f in files:
        print(f"  - {os.path.basename(f)}")
    
    # 读取第一个文件
    print(f"\n开始合并... (分隔符: {repr(sep)})")
    merged_df = pd.read_csv(files[0], sep=sep, index_col=0)
    
    # 从文件名提取样本名称
    sample_name = os.path.basename(files[0]).replace(end, '')
    merged_df.columns = [f"{sample_name}_{col}" if col != 'GeneID' else col for col in merged_df.columns]
    
    # 如果GeneID是索引,重置为列
    if merged_df.index.name or 'GeneID' not in merged_df.columns:
        merged_df = merged_df.reset_index()
        if 'index' in merged_df.columns:
            merged_df = merged_df.rename(columns={'index': 'GeneID'})
    
    # 逐个合并其他文件
    for i, file in enumerate(files[1:], 1):
        print(f"合并第 {i+1}/{len(files)} 个文件: {os.path.basename(file)}")
        df = pd.read_csv(file, sep=sep, index_col=0).reset_index()
        
        # 重命名索引列为GeneID
        if 'index' in df.columns:
            df = df.rename(columns={'index': 'GeneID'})
        
        # 从文件名提取样本名称并重命名列
        sample_name = os.path.basename(file).replace(end, '')
        df.columns = [f"{sample_name}_{col}" if col != 'GeneID' else col for col in df.columns]
        
        # 合并 (outer join保留所有GeneID)
        merged_df = pd.merge(merged_df, df, on='GeneID', how='outer')
    
    print(f"\n合并完成!")
    print(f"结果维度: {merged_df.shape[0]} 行 × {merged_df.shape[1]} 列")
    
    return merged_df

# 使用示例
if __name__ == "__main__":
    # 创建命令行参数解析器
    parser = argparse.ArgumentParser(description='合并多个基因表达文件（按GeneID）')
    parser.add_argument('base_path', type=str, 
                        help='文件所在的基础路径')
    parser.add_argument('--sep', type=str, default=',', 
                        help='文件分隔符，默认为逗号(,)，制表符用\\t表示')
    parser.add_argument('--end', type=str, default='_TPM.csv', 
                        help='文件名结尾匹配模式，默认为_TPM.csv')
    parser.add_argument('-o', '--output', type=str, default='merged_output.csv',
                        help='输出文件名，默认为merged_output.csv')
    
    args = parser.parse_args()
    
    # 处理制表符的特殊情况
    sep = args.sep.replace('\\t', '\t')
    
    print(f"配置参数:")
    print(f"  路径: {args.base_path}")
    print(f"  分隔符: {repr(sep)}")
    print(f"  文件结尾: {args.end}")
    print(f"  输出文件: {args.output}\n")
    
    # 合并文件
    result = merge_tpm_files(args.base_path, sep=sep, end=args.end)
    
    if result is not None:
        # 保存结果（使用相同的分隔符）
        result.to_csv(args.output, sep=sep, index=False)
        print(f"\n结果已保存到: {args.output}")
        
        # 显示前几行
        print("\n前5行预览:")
        print(result.head())