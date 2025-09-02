from munual import SNPExpressionAnalyzer
import os
os.chdir('/cluster/home/futing/Project/GBM/HiCQTL/tensorqtl/merged')
import pandas as pd
import torch
import tensorqtl
import matplotlib.pyplot as plt
from tensorqtl import pgen, cis, trans, post
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
print(f"torch: {torch.__version__} (CUDA {torch.version.cuda}), device: {device}")
print(f"pandas: {pd.__version__}")


# 01 read genotype, variant, phenotype and covariate dataframe
# define paths to data
plink_prefix_path = '/cluster/home/futing/Project/GBM/HiCQTL/tensorqtl/merged/GBM_genotype'
expression_bed = './GBM_merged.filter.bed'
# covariates_file = 'genotype_pc5.eigenvec.txt'
covariates_file ='/cluster/home/futing/Project/GBM/HiCQTL/tensorqtl/merged/covariates.txt'
prefix = 'GBM'
# load phenotypes and covariates
phenotype_df, phenotype_pos_df = tensorqtl.read_phenotype_bed(expression_bed)
covariates_df = pd.read_csv(covariates_file, sep='\t', index_col=0).T

# PLINK reader for genotypes
pgr = pgen.PgenReader(plink_prefix_path)
genotype_df = pgr.load_genotypes()
variant_df = pgr.variant_df


# 02 mapping genotype to phenotype with covariates
cis.map_nominal(genotype_df, variant_df, phenotype_df, phenotype_pos_df, prefix, covariates_df=covariates_df)
# all genes
cis_df = cis.map_cis(genotype_df, variant_df, phenotype_df, phenotype_pos_df, covariates_df=covariates_df)


# 03 preprocess
# 把 cismap phenotypedf 中的 phenotype_id 添加insul前缀
cismap = cis_df.reset_index()
cismap = cismap.loc[:,[ 'variant_id','phenotype_id']]
cismapdf= cismap.copy()
cismapdf['phenotype_id'] = "insul"+cismapdf['phenotype_id'].astype(str)

phenotypedf=phenotype_df.copy()
phenotypedf = phenotypedf.reset_index()
phenotypedf['gene']= "insul"+ phenotypedf['gene'].astype(str)
phenotypedf.set_index('gene', inplace=True)


# 04 actual running
analyzer = SNPExpressionAnalyzer()
analyzer.set_data_directly(genotype_df,phenotypedf, cismapdf)
# analyzer.preprocess_genotype()
# 批量分析
print("\n=== 批量分析 ===")
analyzer.batch_analysis(method='t_test')

# 显示汇总统计
print("\n=== 汇总统计 ===")
analyzer.get_summary_statistics()