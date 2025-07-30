#!/bin/bash



# samtools view -h -f 1024 DLD-12.bam > dup_reads.sam
# samtools view -Sb dup_reads.sam > dup_reads.bam
# samtools view dup_reads.bam | awk '($2==99 || $2==83 || $2==163 || $2==147) && $9!=0 {print $9}' > frag_lengths.txt
input="DLD-12.bam"
samtools index DLD-12_sorted.bam
picard MarkDuplicates \
    I=DLD-12_sorted.bam \
    O=marked_duplicates.bam \
    M=dup_metrics.txt \
    REMOVE_DUPLICATES=false

samtools view -F 4 -f 1024 marked_duplicates.bam | \
awk '{if (and($2, 0x10)) print $9*-1; else print $9}' | \
awk '{len=($1<0)?-$1:$1; print len}' | \
sort | uniq -c > duplicate_length_distribution.txt
