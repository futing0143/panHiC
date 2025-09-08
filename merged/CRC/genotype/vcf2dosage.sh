#!/bin/bash

vcf=/cluster2/home/futing/Project/HiCQTL/CRC/population2/snp.out.vcf
bcftools annotate --set-id '%CHROM\_%POS\_%REF\_%ALT' ./VCF/snp.out.vcf -o snp.out.annoATCG.vcf


# 去除2个样本，结果有问题
outsnp=${vcf%.vcf}.anno.vcf
awk 'BEGIN{OFS="\t"} 
     /^#/ {print; next} 
     $3=="." {$3 = $1"_"$2"_"$4"_"$5} 
     {print}' $vcf > $outsnp

# plink2 --vcf $outsnp --maf 0.05 --geno 0.1 \
# 	--chr 1-22 --hwe 1e-6 \
# 	--make-bed --out GBM_genotype

plink2 --vcf $outsnp \
	--chr 1-22 \
	--max-alleles 2 \
	--make-pgen \
	--out CRC

plink2 --vcf $outsnp \
	--chr 1-22 \
	--max-alleles 2 \
	--make-bed \
	--out CRC

plink2 \
  --pfile CRC \
  --maf 0.05 \         # 移除次要等位基因频率(MAF)<5%的SNP
  --geno 0.02 \        # 移除缺失率>2%的SNP
  --hwe 1e-6 \         # 移除偏离哈迪-温伯格平衡的SNP
  --mind 0.05 \        # 移除样本缺失率>5%的个体
  --make-bed \         # 输出二进制格式（可选）
  --out CRC_qc

plink2 --bfile CRC --pca 10 --out ../covariate/CRCgeno
plink2 --bfile CRC --pca 10 --out ../covariate/CRCgeno --small-sample
plink --bfile CRC --pca 5 --out ../covariate/CRCgeno5


# chr18   22048   chr18_22048_A_G_b38     A       G       100     PASS    AC=137;AF=0.153933;AN=890
# 1       277677  .       G       T       160.02  VQSRTrancheSNP99.90to100.00     AC=3;AF=0.5;AN=4;BaseQRankSum=0;DP=25;ExcessHet=0;FS=0;MLEAC=1;MLEAF=0.5;MQ=20.1;MQRankSum=-1.834;QD=22.86;ReadPosRankSum=0.623;SOR=0.941;VQSLOD=-3.318e+00;culprit=MQ