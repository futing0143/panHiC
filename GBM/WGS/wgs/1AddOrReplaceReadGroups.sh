#!/bin/bash
cat wgs.list | while read i
do
gatk --java-options "-Xmx100G -Djava.io.tmpdir=./" AddOrReplaceReadGroups -I ${i}/bwa/${i}.bam \
	-O ${i}/bwa/${i}.new.bam \
	-ID ${i} \
	-LB ${i} \
	-PL ILLUMINA \
	-PU flowcell-barcode.lane \
	-SM ${i}

samtools index ${i}/bwa/${i}.new.bam 
done 
