#!/bin/bash

cd /cluster/home/futing/Project/GBM/RNA/
ls -d */ | while read -r dir; do
    dir=${dir%*/}
    dirn=$(basename $dir)
    echo -e "dir: $dir\ndirn: $dirn\n"
    samtools merge ${dirn}.bam $(find -L ./$dir -name "SRR*Aligned.sortedByCoord.out.bam")
    samtools flagstat ${dirn}.bam
	samtools index ${dirn}.bam
    bamCoverage -b ${dirn}.bam -o ${dirn}.bw #--scaleFactor 1 --minMappingQuality 20
done