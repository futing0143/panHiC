cat wgs.list | while read i
do
gatk --java-options "-Xmx100G -Djava.io.tmpdir=./" MarkDuplicates -I ${i}/bwa/${i}.new.bam \
	-O ${i}/bwa/${i}.sorted.MarkDuplicates.bam \
	-M ${i}/bwa/${i}.sorted.bam.metrics 
done 
