#!/bin/bash

outdir=/cluster2/home/futing/Project/HiCQTL/CRC
outname=CRC
mkdir -p $outdir/population_CRC53hard
cd $outdir/population_CRC53hard
gatk=/cluster/home/futing/software/gatk-4.6.2.0/gatk
reference=/cluster/home/futing/ref_genome/hg38_primary_assembly/bwa/hg38.fa
GATK_bundle=/cluster/home/futing/ref_genome/hg38_gencode/GATK/bundle


# cat /cluster2/home/futing/Project/HiCQTL/CRCdone.txt | while read sample;do
# 	# bcftools view -h $outdir/${sample}/raw.vcf | grep 'END'
# 	f=$outdir/${sample}/raw.vcf
# 	ffil=$outdir/${sample}/raw_anno.vcf
# 	if [ ! -e "${f}.gz" ];then
# 		bgzip -c "${f}" > "${f}.gz"
# 		tabix -p vcf "${f}.gz"
# 	fi
# 	echo "${f}.gz" >> vcf_list.txt
# done
# bcftools merge -m all -O z -o merged.vcf.gz -l vcf_list.txt
# tabix -p vcf merged.vcf.gz
# if [ $? -ne 0 ]; then
# 	echo -e "merged.vcf.gz doesn't exits.. exiting.." >&2
# 	exit 1
# fi
# -------------- Genotype SNPs and Indels --------------
mergevcf=/cluster2/home/futing/Project/HiCQTL/CRC/population_CRC53/merged.vcf.gz
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

# method1 去掉 readpositionsum
# --filter 'hasAttribute("ReadPosRankSum") && ReadPosRankSum < -8.0'    --filter-name "ReadPosRankSum-8" \
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
#	 --filter "MQRankSum < -12.5" --filter-name "MQRankSum-12.5"

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


# bcftools query -f '%CHROM\t%POS\t%REF\t%ALT\t%INFO/AF\t%INFO/DP\n' /cluster2/home/futing/Project/HiCQTL/CRC/09-376/raw.vc
# bcftools annotate --set-id '%CHROM\_%POS\_%REF\_%ALT' ./VCF/snp.out.vcf -o snp.out.annoATCG.vcf

# -------------- Checking SNPs --------------
#CHROM  POS     ID      REF     ALT     QUAL    FILTER  INFO    FORMAT  U87     U118    U251    U343    GB176   GB180   GB182   GB183   GB238   42MGBA  A172    H4      SW1088



# chr1    2500129 .       G       A       62.64   PASS    AC=1;AF=0.5;AN=2;BaseQRankSum=0.674;DP=4;ExcessHet=0;FS=0;MLEAC=1;MLEAF=0.5;MQ=60;MQRankSum=0;QD=15.66;ReadPosRankSum=0;SOR=0.693;VQSLOD=6.84;culprit=FS        GT:AD:DP:GQ:PL  0/1:2,2:4:65:70,0,65

# samtools mpileup -r chr1:2500129-2500129 A172.sorted.bam | \
# 	awk '{print $1"\t"$2"\t"$5}' | \
# 	awk '{len=split($3,a,""); for(i=1;i<=len;i++) {b[a[i]]++}} END{for(k in b) print k,b[k]}'
# bcftools mpileup -r chr1:2500129 -f /cluster/home/futing/ref_genome/hg38_primary_assembly/bwa/hg38.fa \
# 	42MGBA.sorted.bam

# # method1
# samtools mpileup -r chr1:2500129-2500129 reads.sorted.bam -A -Q 0 | \
# 	awk '{gsub(/[\^].|\$/, "", $5); print $5}' | \
# 	tr -d '[:punct:]' | \
# 	awk '{split($0, a, ""); for (i in a) count[a[i]]++} END {for (b in count) print b, count[b]}'

# # method2
# samtools view reads.sorted.bam chr1:2500129-2500129 | \
# 	awk '$4 <= 2500129 && $4+length($10) > 2500129 {pos=2500129-$4+1; print substr($10, pos, 1)}' | \
# 	sort | uniq -c


# chr1    884220  .       T       G       49.64   PASS    AC=1;AF=0.5;AN=2;BaseQRankSum=-1.393;DP=17;ExcessHet=0;FS=0;MLEAC=1;MLEAF=0.5;MQ=46.52;MQRankSum=-0.23;QD=4.51;ReadPosRankSum=0;SOR=0.818;VQSLOD=0.842;culprit=QD       GT:AD:DP:GQ:PL  ./.:.:.:.:.     ./.:.:.:.:.     ./.:.:.:.:.     ./.:.:.:.:.   ./.:.:.:.:.      ./.:.:.:.:.     ./.:.:.:.:.     ./.:.:.:.:.     ./.:.:.:.:.     ./.:.:.:.:.     0/1:9,2:11:57:57,0,363  ./.:.:.:.:.     ./.:.:.:.:.
# chr1    783006  .       A       G       275.75  PASS    AC=4;AF=1;AN=4;DP=12;ExcessHet=0;FS=0;MLEAC=4;MLEAF=1;MQ=42.03;QD=25.07;SOR=1.27;VQSLOD=4.59;culprit=QD GT:AD:DP:GQ:PL  1/1:0,7:7:21:189,21,0   1/1:0,4:4:12:103,12,0