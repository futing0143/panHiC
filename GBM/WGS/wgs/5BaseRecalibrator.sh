cat wgs.list | while read i
do
gatk --java-options "-Xmx100G"  BaseRecalibrator -R /cluster/home/haojie/hg38/Homo_sapiens_assembly38.fasta \
	-I ${i}/bwa/${i}.sorted.MarkDuplicates.bam \
	--known-sites /cluster/home/haojie/hg38/1000G_phase1.snps.high_confidence.hg38.vcf.gz \
	--known-sites /cluster/home/haojie/hg38/Mills_and_1000G_gold_standard.indels.hg38.vcf.gz \
	--known-sites /cluster/home/haojie/hg38/dbsnp_146.hg38.vcf.gz \
	-L ${i}/bwa/${i}.sorted.MarkDuplicates.bed \
	-O ${i}/bwa/${i}.sorted.MarkDuplicates.base.table  
done 
