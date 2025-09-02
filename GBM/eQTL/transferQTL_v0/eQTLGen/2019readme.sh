This README accompanies the files with cis-eQTL results from eQTLGen

Files
-----
File with full cis-eQTL results: 2019-12-11-cis-eQTLsFDR-ProbeLevel-CohortInfoRemoved-BonferroniAdded.txt.gz
File with significant (FDR<0.05) cis-eQTL results: 2019-12-11-cis-eQTLsFDR0.05-ProbeLevel-CohortInfoRemoved-BonferroniAdded.txt.gz

Column Names
------------
Pvalue - P-value
SNP - SNP rs ID
SNPChr - SNP chromosome
SNPPos - SNP position
AssessedAllele - Assessed allele, the Z-score refers to this allele
OtherAllele - Not assessed allele
Zscore - Z-score
Gene - ENSG name (Ensembl v71) of the eQTL gene
GeneSymbol - HGNC name of the gene
GeneChr - Gene chromosome
GenePos - Centre of gene position
NrCohorts - Total number of cohorts where this SNP-gene combination was tested
NrSamples - Total number of samples where this SNP-gene combination was tested
FDR - False discovery rate estimated based on permutations
BonferroniP - P-value after Bonferroni correction

Additional information
----------------------
These files contain all cis-eQTL results from eQTLGen, accompanying the article.
19,250 genes that showed expression in blood were tested.
Every SNP-gene combination with a distance <1Mb from the center of the gene and  tested in at least 2 cohorts was included.
Associations where SNP/proxy positioned in Illumina probe were not removed from combined analysis.



UPDATE LOG
----------

2018-10-19: Initial data release

2018-12-19: In the current README, following file names have been fixed and updated:

2019-12-20: Cis-eQTLs are now updated to have a 2-cohort filter: every cis-eQTL must be tested in at least 2 cohorts to be reported



awk '{print $3,$4,$10,$11,$8,$7}' 2019-12-11-cis-eQTLsFDR0.05-ProbeLevel-CohortInfoRemoved-BonferroniAdded.txt >2019-12-11-cis-eQTLsFDR0.05-ProbeLevel-CohortInfoRemoved-BonferroniAdded1.txt
sort -u -k5,5 -o 2019-12-11-cis-eQTLsFDR0.05-ProbeLevel-CohortInfoRemoved-BonferroniAdded2.txt 2019-12-11-cis-eQTLsFDR0.05-ProbeLevel-CohortInfoRemoved-BonferroniAdded1.txt

awk -F'\t' 'BEGIN {OFS="\t"}{print $3,$4,$2,$10,$11,$8,$9,$7}' 2019-12-11-cis-eQTLsFDR0.05-ProbeLevel-CohortInfoRemoved-BonferroniAdded.txt >fil_eqtl.txt
sort -u -k5,5 fil_eqtl.txt -o fil_eqtl_dedup.txt

###-------- 转换 hg19 to hg38 ------------#
# 得到 hg38 坐标的rs，不包含eGene的信息，结果是 merged.txt blood_eqtls.bed 
# 01 提取 chr pos rs ref alt 五列，去重并按照rs号排序
awk -F'\t' 'BEGIN {OFS="\t"}{print $3,$4,$2,$5,$6}' 2019-12-11-cis-eQTLsFDR0.05-ProbeLevel-CohortInfoRemoved-BonferroniAdded.txt >hg19.txt
# 提取标题行和排序去重内容行
sort -u -k3,3 hg19.txt > hg19_dedup.txt
awk 'BEGIN{OFS="\t"} {print $0, NR,"PASS","SVTYPE=BND"}' hg19_dedup.txt > temp.txt
head -n -1 temp.txt > temp1.txt && mv temp1.txt temp.txt #去掉最后一行，不知道为什么标题跑到最后

#把第三列不是rs开始的行的第三列改成.
#awk 'BEGIN{FS=OFS="\t"} $3 !~ /^rs/ {$3="."} {print}' temp.txt > temp1.txt && mv temp1.txt temp.txt

# 02 转换txt为vcf
output="output_hg19.vcf"
echo "##fileformat=VCFv4.2" > $output
echo "##INFO=<ID=DP,Number=1,Type=Integer,Description=\"Total Depth\">" >> $output
echo "##FORMAT=<ID=GT,Number=1,Type=String,Description=\"Genotype\">" >> $output
echo "#CHROM POS ID REF ALT QUAL FILTER INFO" >> $output
tr '\t' ' ' < temp.txt >> $output
#看一下哪里有问题，输出行号
awk 'BEGIN{FS=OFS=" "} $1 ~ /^#/ {next} $2 !~ /^[0-9]+$/ {print NR, $0}' output_hg19.vcf

CrossMap vcf /cluster/home/futing/ref_genome/liftover/hg19ToHg38.over.chain output_hg19.vcf \
    /cluster/home/futing/ref_genome/hg38_gencode/hg38.fa output_hg38.vcf --no-comp-allele
#看一下unmap的最后一列
awk 'BEGIN{FS=OFS=" "} $1 !~ /^#/ {print $9}' output_hg38.vcf.unmap | sort | uniq

# 03 提取结果txt
result_hg38="result_hg38.txt"
awk 'BEGIN{FS=OFS="\t"} $1 ~ /^#/ {next} {print $3,$1,$2,$6,$1"_"$2}' output_hg38.vcf > $result_hg38
# 04 合并结果
sort -k4,4 result_hg38.txt -o result_hg381.txt && mv result_hg381.txt result_hg38.txt
sort -k6,6 temp.txt -o temp1.txt && mv temp1.txt temp.txt
echo -e "num\tchr_hg19\tpos_hg19\tSNP\tchr_hg38\tpos_hg38" > merged.txt
join -t $'\t' -1 4 -2 6 -a 1 -o "2.6,2.1,2.2,2.3,1.2,1.3" result_hg38.txt temp.txt | sort -k2,2 >> merged.txt
#去掉chrX的行 不然python读进去chr会有问题
awk -F'\t' '$5 != "X"' merged.txt > merged1.txt && mv merged1.txt merged.txt
awk 'NR>=2 {printf "%s\t%s\t%s\n", $2, int($3-1), int($3)}' merged.txt > ./blood_eqtls.bed

#看一下某一列不重复的值
awk -F'\t' '{print $5}' merged.txt | sort | uniq
awk -F'\t' '{print $1}' temp.txt | sort | uniq
awk -F'\t' '{print $2}' result_hg38.txt | sort | uniq
#看一下chr转换后不相同的行
awk -F'\t' '$2 == "X"' result_hg38.txt
awk -F'\t' '$6 == "21164"' temp.txt
awk -F'\t' '$2 != $5' merged.txt
awk -F'\t' '$2 != $5' result_hg38.txt
#只取有rs号的行
awk 'BEGIN {FS=OFS="\t"} $1 ~ /^rs/ {print $1}' result_hg38.txt > rsID.txt