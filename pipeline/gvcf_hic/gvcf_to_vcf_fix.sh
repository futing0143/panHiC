#!/bin/bash
set -euo pipefail

source activate /cluster/home/futing/miniforge-pypy3/envs/HiC
trimmomatic=/cluster/home/futing/miniforge-pypy3/envs/HiC/bin/trimmomatic
bwa=/cluster/home/futing/miniforge-pypy3/envs/HiC/bin/bwa
samtools=/cluster/home/futing/miniforge-pypy3/envs/HiC/bin/samtools
gatk=/cluster/home/futing/software/gatk-4.6.2.0/gatk

#reference
reference=/cluster/home/futing/ref_genome/hg38_gencode/bwa/hg38.fa
GATK_bundle=/cluster/home/futing/ref_genome/hg38_gencode/GATK/bundle


sample=$1
indir=$2  ## 输入目录的路径，这个输入路径要与fastq_to_gvcf.sh的输出路径完全相同
outname=$3 ## 设置输出文件名的前缀
outdir=$indir ## 输入和输出路径相同

# 设置群体变异检测结果的输出目录
if [ ! -d $outdir/population ]
then mkdir -p $outdir/population
fi

# ----- combine vcf
# 定义染色体列表
chrom=( chr1 chr2 chr3 chr4 chr5 chr6 chr7 chr8 chr9 chr10 chr11 chr12 chr13 chr14 chr15 chr16 chr17 chr18 chr19 chr20 chr21 chr22 chrX chrY chrM )
fixchrom=( chrX chrY )
# 处理每个染色体的函数
process_chromosome() {
    local i=$1
    echo "[$(date)] Start processing chromosome $i"
    
    # 第一步：为每个细胞系提取当前染色体的变异
    sample_gvcfs=()
    while read -r cell; do
        # 提取当前染色体的变异
        chr_outfile="$outdir/${cell}/gatk/${cell}.HC.${i}.g.vcf.gz"
        if [ ! -f "$outdir/${cell}/gatk/${cell}.HC.g.vcf.gz" ]; then
			echo "Error: GVCF file not found for cell line $cell at $outdir/${cell}/gatk/${cell}.HC.g.vcf.gz"
			return 1
		fi
        # 如果文件已存在且完整，则跳过提取步骤
        if [[ ! -f "$chr_outfile" || ! -f "$chr_outfile.tbi" ]]; then
            echo "Extracting chromosome $i for cell line $cell"
            time $gatk SelectVariants \
                -R "$reference" \
                -V "$outdir/${cell}/gatk/${cell}.HC.g.vcf.gz" \
                -L "$i" \
                -O "$chr_outfile" || return 1
        else
            echo "Chromosome $i for cell line $cell already exists, skipping extraction"
        fi
        
        # 检查文件是否存在
        if [[ ! -f "$chr_outfile" ]]; then
            echo "Error: File not found: $chr_outfile"
            return 1
        fi
        sample_gvcfs+=("-V" "$chr_outfile")
    done < "$sample"
    
    # 第二步：合并所有细胞系的GVCF
    combine_outfile="$outdir/population/${outname}.HC.${i}.g.vcf.gz"
    echo "Combining GVCFs for chromosome $i"
    time $gatk CombineGVCFs \
        -R "$reference" \
        "${sample_gvcfs[@]}" \
        -O "$combine_outfile" || return 1
    echo "** ${outname}.HC.${i}.g.vcf.gz done **"
    
    # 第三步：基因分型
    genotype_outfile="$outdir/population/${outname}.HC.${i}.vcf.gz"
    echo "Genotyping chromosome $i"
    time $gatk GenotypeGVCFs \
        -R "$reference" \
        -V "$combine_outfile" \
        -O "$genotype_outfile" || return 1
    echo "** ${outname}.HC.${i}.vcf.gz done **"
    
    # 可选：清理中间文件以节省空间
    # while read -r cell; do
    #     rm "$outdir/${cell}/gatk/${cell}.HC.${i}.g.vcf.gz"*
    # done < "$sample"
    
    echo "[$(date)] Finished processing chromosome $i"
}

# 导出函数和变量
export -f process_chromosome
export gatk reference outdir outname sample

# 使用 parallel 并行处理所有染色体
printf "%s\n" "${fixchrom[@]}" | parallel -j 2 --joblog "$outdir/population/parallel_joblog.txt" process_chromosome {} 

echo "All chromosomes processed successfully!"


# 合并所有染色体VCF
merge_vcfs=()
for i in "${chrom[@]}"; do
    merge_vcfs+=("-I" "$outdir/population/${outname}.HC.${i}.vcf.gz")
done

time $gatk MergeVcfs \
    "${merge_vcfs[@]}" \
    -O "$outdir/population/${outname}.HC.vcf.gz" && \
echo "** MergeVcfs done **"

# ----- hard filter ------
mergevcf=${outdir}/population/${outname}.HC.vcf.gz
echo "...No known SNPs are provided for variant recalibration. Opting out for hard-filtering."
gatk SelectVariants -V $mergevcf -select-type SNP -O snp.raw.vcf
gatk VariantFiltration -R $reference -V snp.raw.vcf \
  --filter-expression "QD < 2.0" --filter-name "QD2" \
  --filter-expression "FS > 60.0" --filter-name "FS60" \
  --filter-expression "MQ < 10.0" --filter-name "MQ10" \
  --filter-expression "ReadPosRankSum < -8.0" --filter-name "ReadPosRankSumLow" \
  --filter-expression "SOR > 3.0" --filter-name "SOR3" \
  --filter-expression "QUAL < 30.0" --filter-name "QUAL30" \
  --missing-values-evaluate-as-failing false \
  -O snp.out.vcf

gatk VariantFiltration \
  -R $reference \
  -V snp.raw.vcf \
  --filter "QD < 2.0" --filter-name "QD2" \
  --filter "FS > 60.0" --filter-name "FS60" \
  --filter "MQ < 10.0" --filter-name "MQ10" \
  --filter "SOR > 3.0" --filter-name "SOR3" \
  --filter "QUAL < 30.0" --filter-name "QUAL30" \
  -O snp2.out.vcf
rm snp.raw.vcf snp.raw.vcf.idx

# ---- 02 indel filter ----
echo "...No known InDels are provided for indel recalibration. Opting out for hard-filtering."
gatk SelectVariants -V ${mergevcf} -select-type INDEL -O indel.raw.vcf
gatk VariantFiltration -R $reference -V indel.raw.vcf \
  --filter "QD < 2.0" --filter-name "QD2" \
  --filter "FS > 200.0" --filter-name "FS200" \
  --filter "ReadPosRankSum < -20.0" --filter-name "ReadPosRandSum-20" \
  --filter "QUAL < 30.0" --filter-name "QUAL30" \
  --missing-values-evaluate-as-failing false \
  -O indel.out.vcf
rm indel.raw.vcf indel.raw.vcf.idx

# while read -r cell; do
# 	if [ ! -f "$outdir/${cell}/bwa/reads.prepped_1.bam" ]; then
# 		echo "Error: GVCF file not found for cell line $cell at $outdir/${cell}/bwa/reads.prepped_1.bam"
# 		echo "$cell" >> missing_bam.txt
# 	fi
# done < "$sample"