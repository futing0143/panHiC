cat wgs.list | while read i
do
bedtools bamtobed -i ${i}/bwa/${i}.sorted.MarkDuplicates.bam > ${i}/bwa/${i}.sorted.MarkDuplicates.bed 
done 
