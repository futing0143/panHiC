cat wgs.list | while read i
do
samtools index ${i}/bwa/${i}.sorted.MarkDuplicates.bam 
done 
