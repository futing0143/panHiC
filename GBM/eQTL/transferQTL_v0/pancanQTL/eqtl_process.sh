#!/bin/bash
# 01 处理eqtlGen
# 提取首行并添加新列名
awk -F'\t' 'BEGIN {OFS="\t"} NR==1 {
    print $3"\t"$5"\t"$6"\t"$7"\t"$8"\t"$9"\t"$10"\t"$11"\tstart\tend\tstrand"
    }' GBM_tumor.cis_eQTL.txt > GBM_fil.txt
# 处理数据行，跳过首行
awk -F'\t' 'BEGIN {OFS="\t"} NR>1 {
    split($10, a, "[:-]"); 
    print $3, $5,$6, $7, $8, $9, $10, $11, a[1], a[2], a[3]
    }' GBM_tumor.cis_eQTL.txt >> GBM_fil.txt


# 02 处理正负链
awk -F'\t' 'BEGIN {OFS="\t"} NR==1 {print $3, $5,$6, $7, $8, $9, $10, $11, "start", "end", "strand"}' GBM_tumor.cis_eQTL.txt > your_output_file.txt

awk -F'\t' 'BEGIN {OFS="\t"} NR>1 {
    # 替换第10列的第一个 "-" 为唯一字符 "§"（确保这个字符不会在你的数据中出现）
    sub(/-/, "§", $10);
    # 现在使用 "§" 分割第10列
    split($10, a, "§");
    # 使用 ":" 分割后半部分以获取 strand
    split(a[2], b, ":");
    # 确保所有字段都用 OFS 即 tab 分隔
    print $6, $7, $8, $9, $10, $11, a[1], b[1], b[2]
}' GBM_tumor.cis_eQTL.txt >> your_output_file.txt

# 03 转换 hg19 to hg38
# a. chr pos rs ref alt 五列，去重并按照rs号排序
awk -F'\t' 'BEGIN {OFS="\t"} NR>1 {print $6, $7, $5, "A", "T"}' GBM_tumor.cis_eQTL.txt > hg19.txt
sort -u -k3,3 hg19.txt | awk 'BEGIN{OFS="\t"} {print $0, NR,"PASS","SVTYPE=BND"}' > temp.txt

output="output_hg19.vcf"
echo "##fileformat=VCFv4.2" > $output
echo "##INFO=<ID=DP,Number=1,Type=Integer,Description=\"Total Depth\">" >> $output
echo "##FORMAT=<ID=GT,Number=1,Type=String,Description=\"Genotype\">" >> $output
echo "#CHROM POS ID REF ALT QUAL FILTER INFO" >> $output
tr '\t' ' ' < temp.txt >> $output
#看一下哪里有问题，输出行号
awk 'BEGIN{FS=OFS=" "} $1 ~ /^#/ {next} $2 !~ /^[0-9]+$/ {print NR, $0}' output_hg19.vcf

# b. 转换hg19到hg38 
CrossMap vcf /cluster/home/futing/ref_genome/liftover/hg19ToHg38.over.chain output_hg19.vcf \
    /cluster/home/futing/ref_genome/hg38_gencode/hg38.fa output_hg38.vcf --no-comp-allele
#看一下unmap的最后一列
awk 'BEGIN{FS=OFS=" "} $1 !~ /^#/ {print $9}' output_hg38.vcf.unmap | sort | uniq

# 03 提取结果txt和bed
result_hg38="result_hg38.txt"
echo "SNP s_chr s_pos" > $result_hg38
awk 'BEGIN{FS=OFS=" "} $1 ~ /^#/ {next} {print $3,$1,$2}' output_hg38.vcf >> $result_hg38

awk 'NR>=2 {printf "%s\t%s\t%s\n", $2, int($3-1), int($3)}' result_hg38.txt > ./gbm_eqtls.bed