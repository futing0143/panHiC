cat nomal_left2.list | while read i
do
gatk --java-options "-Xmx200G -Djava.io.tmpdir=./" Mutect2 -R /cluster/home/haojie/hg38/Homo_sapiens_assembly38.fasta \
	-I ${i}/bwa/${i}.sorted.MarkDuplicates.BQSR.bam -max-mnp-distance 0 \
	-O pon/${i}.normal.vcf.gz
done
