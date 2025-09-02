#!/bin/bash

outdir=/cluster2/home/futing/Project/HiCQTL/CRC
outname=CRC
mkdir -p $outdir/population
cd $outdir/population
gatk=/cluster/home/futing/software/gatk-4.6.2.0/gatk
reference=/cluster/home/futing/ref_genome/hg38_primary_assembly/bwa/hg38.fa
GATK_bundle=/cluster/home/futing/ref_genome/hg38_gencode/GATK/bundle

# 33个岩本
# cat /cluster2/home/futing/Project/HiCQTL/merged/doneJun30.txt | while read sample;do
# 	# bcftools view -h $outdir/${sample}/raw.vcf | grep 'END'
# 	f=$outdir/${sample}/raw.vcf
# 	ffil=$outdir/${sample}/raw_anno.vcf
# 	# # 1. 提取已有 rsID 的记录
# 	# bcftools view -i 'ID!="."' ${f} -o $outdir/${sample}/rsid_records.vcf -O v
# 	# bcftools view -i 'ID=="."' $f -o tmp.noid.vcf -O v
# 	# bcftools annotate --set-id '%CHROM_%POS_%REF_%ALT' tmp.noid.vcf -O v -o $outdir/${sample}/filled.vcf
# 	# rm tmp.noid.vcf
# 	# bcftools concat -a -O v -o ${ffil} $outdir/${sample}/rsid_records.vcf $outdir/${sample}/filled.vcf

# 	bgzip -c "${f}" > "${f}.gz"
#   	tabix -p vcf "${f}.gz"
# 	echo "${f}.gz" >> vcf_list.txt
# done
bcftools merge -m all -O z -o merged.vcf.gz -l vcf_list.txt
tabix -p vcf merged.vcf.gz
if [ $? -ne 0 ]; then
	echo -e "merged.vcf.gz doesn't exits.. exiting.." >&2
	exit 1
fi
# -------------- Genotype SNPs and Indels --------------
snpRecalibrationArg="--resource:hapmap,known=false,training=true,truth=true,prior=15.0 /cluster/home/futing/ref_genome/hg38_gencode/GATK/bundle/hapmap_3.3.hg38.vcf --resource:omni,known=false,training=true,truth=true,prior=12.0 /cluster/home/futing/ref_genome/hg38_gencode/GATK/bundle/1000G_omni2.5.hg38.vcf --resource:dbsnp,known=true,training=false,truth=false,prior=7.0 /cluster/home/futing/ref_genome/hg38_gencode/GATK/bundle/dbsnp138.hg38.vcf"
gatk --java-options "-Xmx4G -XX:+UseParallelGC -XX:ParallelGCThreads=40" VariantRecalibrator \
	-V merged.vcf.gz -O out.recal -mode SNP --tranches-file out.tranches \
	-tranche 100.0 -tranche 99.9 -tranche 99.0 -tranche 90.0 -an QD -an FS \
	-an MQRankSum -an ReadPosRankSum -an SOR -an MQ --max-gaussians 6 ${snpRecalibrationArg}

gatk --java-options "-Xmx4G -XX:+UseParallelGC -XX:ParallelGCThreads=20" ApplyVQSR \
	-V merged.vcf.gz -O recalibrated_snps_raw_indels.vcf \
	--recal-file out.recal --tranches-file out.tranches \
	-truth-sensitivity-filter-level 99.5 \
	--create-output-variant-index true -mode SNP
vcf=recalibrated_snps_raw_indels.vcf
indelRecalibrationArg="	--resource:mills,known=true,training=true,truth=true,prior=12.0 $GATK_bundle/Mills_and_1000G_gold_standard.indels.hg38.vcf"
gatk --java-options "-Xmx4G -XX:+UseParallelGC -XX:ParallelGCThreads=40" VariantRecalibrator \
	-V ${vcf} -O out.recal -mode INDEL --tranches-file out.tranches \
	-tranche 100.0 -tranche 99.9 -tranche 99.0 -tranche 90.0 -an QD -an FS \
	-an MQRankSum -an ReadPosRankSum -an SOR --max-gaussians 4 ${indelRecalibrationArg}

gatk --java-options "-Xmx4G -XX:+UseParallelGC -XX:ParallelGCThreads=20" ApplyVQSR \
	-V ${vcf} -O out.vcf --recal-file out.recal --tranches-file out.tranches \
	-truth-sensitivity-filter-level 99.0 -mode INDEL --create-output-variant-index

gatk SelectVariants -V out.vcf -select-type INDEL -O indel.out.vcf
vcf=out.vcf
gatk SelectVariants -V ${vcf} -select-type SNP -O snp.out.vcf


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