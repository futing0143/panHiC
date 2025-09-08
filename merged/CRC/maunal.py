

import pandas as pd
import numpy as np
from scipy import stats
import matplotlib.pyplot as plt
import seaborn as sns
from scipy.stats import mannwhitneyu, ttest_ind
import warnings
warnings.filterwarnings('ignore')

class SNPExpressionAnalyzer:
	def __init__(self, genotype_file=None, expression_file=None, mapping_file=None):
		"""
		初始化SNP-Expression分析器
		
		Parameters:
		genotype_file: str, genotype矩阵文件路径 (可选，也可以直接传入DataFrame)
		expression_file: str, expression矩阵文件路径 (可选，也可以直接传入DataFrame)
		mapping_file: str, 对应关系文件路径 (可选，也可以直接传入DataFrame)
		"""
		self.genotype_data = None
		self.expression_data = None
		self.mapping_data = None
		self.results = []
		
		# 如果提供了文件路径，则读取数据
		if genotype_file:
			self.load_genotype_data(genotype_file)
		if expression_file:
			self.load_expression_data(expression_file)
		if mapping_file:
			self.load_mapping_data(mapping_file)

	def load_genotype_data(self, file_path):
		"""读取genotype数据"""
		try:
			self.genotype_data = pd.read_csv(file_path, index_col=0)
			print(f"成功读取genotype数据: {self.genotype_data.shape}")
		except Exception as e:
			print(f"读取genotype数据失败: {e}")

	def load_expression_data(self, file_path):
		"""读取expression数据"""
		try:
			self.expression_data = pd.read_csv(file_path, index_col=0)
			print(f"成功读取expression数据: {self.expression_data.shape}")
		except Exception as e:
			print(f"读取expression数据失败: {e}")

	def load_mapping_data(self, file_path):
		"""读取对应关系数据"""
		try:
			self.mapping_data = pd.read_csv(file_path)
			print(f"成功读取mapping数据: {self.mapping_data.shape}")
		except Exception as e:
			print(f"读取mapping数据失败: {e}")

	def set_data_directly(self, genotype_df, expression_df, mapping_df):
		"""直接设置DataFrame数据"""
		self.genotype_data = genotype_df
		self.expression_data = expression_df
		self.mapping_data = mapping_df
		print("数据设置完成")

	def preprocess_genotype(self):
		"""预处理genotype数据，将-9替换为NaN"""
		if self.genotype_data is not None:
			self.genotype_data = self.genotype_data.replace(-9, np.nan)
			print("genotype数据预处理完成")

	def analyze_snp_expression_association(self, snp_id, gene_id, method='t_test'):
		"""
		分析单个SNP与基因表达的关联
		
		Parameters:
		snp_id: str, SNP的ID
		gene_id: str, 基因的ID
		method: str, 统计检验方法 ('t_test', 'mann_whitney')
		
		Returns:
		dict: 包含分析结果的字典
		"""
		try:
			# 检查SNP和基因是否存在
			if snp_id not in self.genotype_data.index:
				return {'error': f'SNP {snp_id} 不存在于genotype数据中'}
			
			if gene_id not in self.expression_data.index:
				return {'error': f'基因 {gene_id} 不存在于expression数据中'}
			
			# 获取SNP基因型数据
			snp_genotype = self.genotype_data.loc[snp_id]
			# 获取基因表达数据
			gene_expression = self.expression_data.loc[gene_id]
			
			# 找到共同的样本
			common_samples = snp_genotype.index.intersection(gene_expression.index)
			
			if len(common_samples) == 0:
				return {'error': '没有共同样本'}
			
			# 获取共同样本的数据
			snp_values = snp_genotype[common_samples]
			expr_values = gene_expression[common_samples]
			
			# 移除缺失值
			valid_mask = (~snp_values.isna()) & (~expr_values.isna())
			snp_values = snp_values[valid_mask]
			expr_values = expr_values[valid_mask]
			if len(snp_values) < 3:
				return {'error': '有效样本数量不足'}
			
			# 检查基因型值的分布
			genotype_counts = snp_values.value_counts()
			
			# 将基因型分为两组：有SNP (1,2) vs 没有SNP (0)
			# 注意：根据您的描述，2表示有2个SNP，1表示有1个SNP，0表示没有SNP
			has_snp_mask = snp_values > 0
			no_snp_mask = snp_values < 0
			
			has_snp_expr = expr_values[has_snp_mask]
			no_snp_expr = expr_values[no_snp_mask]
			print(f"有SNP样本数: {len(has_snp_expr)}, 无SNP样本数: {len(no_snp_expr)}")
			# print(snp_values)
			
			if len(has_snp_expr) == 0:
				return {'error': '有SNP组样本数为0'}
			if len(no_snp_expr) == 0:
				return {'error': '无SNP组样本数为0'}
			
			# 统计检验
			if method == 't_test':
				stat, p_value = ttest_ind(has_snp_expr, no_snp_expr)
			elif method == 'mann_whitney':
				stat, p_value = mannwhitneyu(has_snp_expr, no_snp_expr, alternative='two-sided')
			
			# 计算基本统计量
			result = {
				'snp_id': snp_id,
				'gene_id': gene_id,
				'n_has_snp': len(has_snp_expr),
				'n_no_snp': len(no_snp_expr),
				'mean_has_snp': np.mean(has_snp_expr),
				'mean_no_snp': np.mean(no_snp_expr),
				'std_has_snp': np.std(has_snp_expr),
				'std_no_snp': np.std(no_snp_expr),
				'fold_change': np.mean(has_snp_expr) / np.mean(no_snp_expr) if np.mean(no_snp_expr) != 0 else np.inf,
				'log2_fold_change': np.log2(np.mean(has_snp_expr) / np.mean(no_snp_expr)) if np.mean(no_snp_expr) != 0 else np.inf,
				'test_statistic': stat,
				'p_value': p_value,
				'method': method,
				'genotype_counts': genotype_counts.to_dict(),
				'has_snp_expr': has_snp_expr.tolist(),
				'no_snp_expr': no_snp_expr.tolist()
			}
			
			return result
			
		except Exception as e:
			return {'error': f'分析失败: {str(e)}'}

	def batch_analysis(self, method='t_test', p_threshold=0.05, snp_col=0, gene_col=1):
		"""
		批量分析所有SNP-基因对
		
		Parameters:
		method: str, 统计检验方法
		p_threshold: float, p值阈值
		snp_col: int, SNP ID所在列的索引
		gene_col: int, 基因ID所在列的索引
		"""
		if self.mapping_data is None:
			print("错误：需要提供mapping数据")
			return
		
		print(f"Mapping数据形状: {self.mapping_data.shape}")
		print(f"Mapping数据列名: {list(self.mapping_data.columns)}")
		print(f"前5行mapping数据:")
		print(self.mapping_data.head())
		
		self.results = []
		error_count = 0
		error_details = {}
		
		print("开始批量分析...")
		for idx, row in self.mapping_data.iterrows():
			try:
				snp_id = row.iloc[snp_col]
				gene_id = row.iloc[gene_col]
				
				# 调试信息
				if idx < 5:  # 只打印前5个
					print(f"处理第 {idx} 行: SNP={snp_id}, Gene={gene_id}")
				
				result = self.analyze_snp_expression_association(snp_id, gene_id, method)
				
				if 'error' not in result:
					self.results.append(result)
				else:
					error_count += 1
					error_type = result['error']
					if error_type not in error_details:
						error_details[error_type] = 0
					error_details[error_type] += 1
					
					# 打印前几个错误的详细信息
					if error_count <= 5:
						print(f"错误 {error_count}: SNP={snp_id}, Gene={gene_id}, 错误={error_type}")
				
			except Exception as e:
				error_count += 1
				print(f"处理第 {idx} 行时出错: {e}")
				continue
			
			if (idx + 1) % 100 == 0:
				print(f"已处理 {idx + 1} 个SNP-基因对，成功 {len(self.results)} 个，错误 {error_count} 个")
		
		print(f"\n=== 处理完成 ===")
		print(f"总处理对数: {len(self.mapping_data)}")
		print(f"成功分析: {len(self.results)}")
		print(f"失败分析: {error_count}")
		
		if error_details:
			print("\n错误类型统计:")
			for error_type, count in error_details.items():
				print(f"  {error_type}: {count} 个")
		
		# 转换为DataFrame
		self.results_df = pd.DataFrame(self.results)
		
		# 多重检验校正
		if len(self.results_df) > 0:
			from statsmodels.stats.multitest import multipletests
			_, p_corrected, _, _ = multipletests(self.results_df['p_value'], method='fdr_bh')
			self.results_df['p_adjusted'] = p_corrected
			
			# 显示显著结果
			significant_results = self.results_df[self.results_df['p_adjusted'] < p_threshold]
			print(f"发现 {len(significant_results)} 个显著关联 (调整后p < {p_threshold})")
		else:
			print("没有成功的分析结果")

	def plot_expression_comparison(self, snp_id, gene_id, save_path=None):
		"""
		绘制表达量比较图
		
		Parameters:
		snp_id: str, SNP ID
		gene_id: str, 基因ID
		save_path: str, 保存路径
		"""
		result = self.analyze_snp_expression_association(snp_id, gene_id)
		
		if 'error' in result:
			print(f"绘图失败: {result['error']}")
			return
		
		fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))
		
		# 箱线图
		data_to_plot = [result['no_snp_expr'], result['has_snp_expr']]
		labels = ['No SNP', 'Has SNP']
		
		ax1.boxplot(data_to_plot, labels=labels)
		ax1.set_title(f'{snp_id} vs {gene_id}\nBoxplot Comparison')
		ax1.set_ylabel('Expression Level')
		ax1.grid(True, alpha=0.3)
		
		# 添加统计信息
		ax1.text(0.02, 0.98, 
				f'p-value: {result["p_value"]:.2e}\n'
				f'Mean No SNP: {result["mean_no_snp"]:.3f}\n'
				f'Mean Has SNP: {result["mean_has_snp"]:.3f}\n'
				f'Log2 FC: {result["log2_fold_change"]:.3f}',
				transform=ax1.transAxes, verticalalignment='top',
				bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.8))
		
		# 密度图
		ax2.hist(result['no_snp_expr'], alpha=0.7, label='No SNP', density=True, bins=20)
		ax2.hist(result['has_snp_expr'], alpha=0.7, label='Has SNP', density=True, bins=20)
		ax2.set_title(f'{snp_id} vs {gene_id}\nExpression Distribution')
		ax2.set_xlabel('Expression Level')
		ax2.set_ylabel('Density')
		ax2.legend()
		ax2.grid(True, alpha=0.3)
		
		plt.tight_layout()
		
		if save_path:
			plt.savefig(save_path, dpi=300, bbox_inches='tight')
			print(f"图片已保存到: {save_path}")
		
		plt.show()

	def get_summary_statistics(self):
		"""获取分析结果的汇总统计"""
		if not hasattr(self, 'results_df') or len(self.results_df) == 0:
			print("没有分析结果")
			return
		
		print("=== 分析结果汇总 ===")
		print(f"总分析对数: {len(self.results_df)}")
		print(f"显著关联数 (p < 0.05): {len(self.results_df[self.results_df['p_value'] < 0.05])}")
		print(f"显著关联数 (调整后p < 0.05): {len(self.results_df[self.results_df['p_adjusted'] < 0.05])}")
		print(f"平均样本数 (有SNP): {self.results_df['n_has_snp'].mean():.1f}")
		print(f"平均样本数 (无SNP): {self.results_df['n_no_snp'].mean():.1f}")
		print(f"Log2 fold change 范围: {self.results_df['log2_fold_change'].min():.3f} ~ {self.results_df['log2_fold_change'].max():.3f}")
		
		return self.results_df.describe()

	def check_data_compatibility(self):
		"""检查数据兼容性和基本信息"""
		print("=== 数据兼容性检查 ===")
		
		if self.genotype_data is not None:
			print(f"Genotype数据形状: {self.genotype_data.shape}")
			print(f"Genotype行名(SNP)前5个: {list(self.genotype_data.index[:5])}")
			print(f"Genotype列名(样本)前5个: {list(self.genotype_data.columns[:5])}")
			print(f"Genotype值的分布: {self.genotype_data.stack().value_counts().sort_index()}")
		else:
			print("Genotype数据未加载")
		
		if self.expression_data is not None:
			print(f"\nExpression数据形状: {self.expression_data.shape}")
			print(f"Expression行名(基因)前5个: {list(self.expression_data.index[:5])}")
			print(f"Expression列名(样本)前5个: {list(self.expression_data.columns[:5])}")
		else:
			print("Expression数据未加载")
		
		if self.mapping_data is not None:
			print(f"\nMapping数据形状: {self.mapping_data.shape}")
			print(f"Mapping列名: {list(self.mapping_data.columns)}")
			print("Mapping前5行:")
			print(self.mapping_data.head())
		else:
			print("Mapping数据未加载")
		
		# 检查样本重叠
		if self.genotype_data is not None and self.expression_data is not None:
			common_samples = set(self.genotype_data.columns).intersection(set(self.expression_data.columns))
			print(f"\n共同样本数: {len(common_samples)}")
			if len(common_samples) < 10:
				print(f"共同样本: {list(common_samples)}")
		
		# 检查ID匹配
		if self.mapping_data is not None and self.genotype_data is not None and self.expression_data is not None:
			mapping_snps = set(self.mapping_data.iloc[:, 0])  # 假设第一列是SNP
			mapping_genes = set(self.mapping_data.iloc[:, 1])  # 假设第二列是基因
			
			genotype_snps = set(self.genotype_data.index)
			expression_genes = set(self.expression_data.index)
			
			snp_overlap = len(mapping_snps.intersection(genotype_snps))
			gene_overlap = len(mapping_genes.intersection(expression_genes))
			
			print(f"Mapping中的SNP与genotype数据匹配: {snp_overlap}/{len(mapping_snps)}")
			print(f"Mapping中的基因与expression数据匹配: {gene_overlap}/{len(mapping_genes)}")
			
			if snp_overlap < len(mapping_snps):
				missing_snps = mapping_snps - genotype_snps
				print(f"缺失的SNP前5个: {list(missing_snps)[:5]}")
			
			if gene_overlap < len(mapping_genes):
				missing_genes = mapping_genes - expression_genes
				print(f"缺失的基因前5个: {list(missing_genes)[:5]}")


	# 使用示例
def example_usage():
	"""使用示例"""
	print("=== SNP-Expression 关联分析工具使用示例 ===")

	# 创建模拟数据
	np.random.seed(42)

	# 模拟genotype数据 (SNP x Sample)
	n_snps = 100
	n_samples = 200
	sample_names = [f'Sample_{i}' for i in range(n_samples)]
	snp_names = [f'SNP_{i}' for i in range(n_snps)]

	# 生成基因型数据 (0, 1, 2, -9)
	genotype_data = np.random.choice([0, 1, 2, -9], size=(n_snps, n_samples), p=[0.5, 0.3, 0.15, 0.05])
	genotype_df = pd.DataFrame(genotype_data, index=snp_names, columns=sample_names)

	# 模拟expression数据 (Gene x Sample)
	n_genes = 50
	gene_names = [f'Gene_{i}' for i in range(n_genes)]

	# 生成表达数据，部分基因的表达与SNP相关
	expression_data = np.random.lognormal(2, 1, size=(n_genes, n_samples))

	# 为前10个基因添加与SNP的关联
	for i in range(10):
		snp_effect = genotype_data[i] * 0.5  # SNP效应
		snp_effect[genotype_data[i] == -9] = 0  # 缺失值不加效应
		expression_data[i] = expression_data[i] * (1 + snp_effect)

	expression_df = pd.DataFrame(expression_data, index=gene_names, columns=sample_names)

	# 创建mapping数据 (每个基因对应一个SNP)
	mapping_df = pd.DataFrame({
		'SNP_ID': snp_names[:n_genes],
		'Gene_ID': gene_names
	})

	print("模拟数据创建完成")
	print(f"Genotype数据形状: {genotype_df.shape}")
	print(f"Expression数据形状: {expression_df.shape}")
	print(f"Mapping数据形状: {mapping_df.shape}")

	# 创建分析器
	analyzer = SNPExpressionAnalyzer()
	analyzer.set_data_directly(genotype_df, expression_df, mapping_df)
	analyzer.preprocess_genotype()

	# 单个分析示例
	print("\n=== 单个SNP-基因对分析 ===")
	result = analyzer.analyze_snp_expression_association('SNP_0', 'Gene_0')
	if 'error' not in result:
		print(f"SNP_0 vs Gene_0:")
		print(f"  有SNP样本数: {result['n_has_snp']}")
		print(f"  无SNP样本数: {result['n_no_snp']}")
		print(f"  有SNP平均表达: {result['mean_has_snp']:.3f}")
		print(f"  无SNP平均表达: {result['mean_no_snp']:.3f}")
		print(f"  Log2 fold change: {result['log2_fold_change']:.3f}")
		print(f"  p-value: {result['p_value']:.2e}")

	# 批量分析
	print("\n=== 批量分析 ===")
	analyzer.batch_analysis(method='t_test')

	# 显示汇总统计
	print("\n=== 汇总统计 ===")
	analyzer.get_summary_statistics()

	# 绘制示例图
	print("\n=== 绘制比较图 ===")
	analyzer.plot_expression_comparison('SNP_0', 'Gene_0')

	return analyzer

# 运行示例
# if __name__ == "__main__":
    # analyzer = example_usage()