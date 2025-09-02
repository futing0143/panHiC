cat wgs.list | while read i
do
gatk --java-options "-Xmx200G -Djava.io.tmpdir=./" ApplyBQSR -R /cluster/home/haojie/hg38/Homo_sapiens_assembly38.fasta \
	-I ${i}/bwa/${i}.sorted.MarkDuplicates.bam \
	-bqsr ${i}/bwa/${i}.sorted.MarkDuplicates.base.table \
	-L ${i}/bwa/${i}.sorted.MarkDuplicates.bed \
	-O ${i}/bwa/${i}.sorted.MarkDuplicates.BQSR.bam
	
samtools sort ${i}/bwa/${i}.sorted.MarkDuplicates.BQSR.bam
done 
