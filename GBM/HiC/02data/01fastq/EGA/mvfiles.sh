#!/bin/bash

sourcedir=/cluster/home/futing/Project/GBM/HiC/02data/01fastq/EGA
cd /cluster/home/futing/Project/GBM/HiC/02data/01fastq/EGA
# cat name.txt | while read line;do
#     echo -e "\nProcessing $line...\n"
#     cd $line
#     rm splits
#     rm fastq
#     rm ./aligned/merged_sort.txt
#     rm ./aligned/merged_nodups.txt
#     rm ./aligned/opt_dups.txt
#     rm ./aligned/dups.txt
#     mv $sourcedir/$line/splits .
#     mv $sourcedir/$line/fastq .
#     mv $sourcedir/$line/aligned/merged_sort.txt ./aligned/merged_sort.txt
#     mv $sourcedir/$line/aligned/merged_nodups.txt ./aligned/merged_nodups.txt
#     mv $sourcedir/$line/aligned/opt_dups.txt ./aligned/opt_dups.txt
#     mv $sourcedir/$line/aligned/dups.txt ./aligned/dups.txt
#     mv $sourcedir/$line/liftOver .
#     mv $sourcedir/$line/juicer.log juicer_old.log
#     cd ..
# done

#cat name.txt | while read name;do
for name in P529.SF12794v1-1 P530.SF12822v4 P530.SF12822v5;do
    cd /cluster/home/futing/Project/GBM/HiC/02data/01fastq/EGA/${name}
    mkdir -p splits
    ln -s ./fastq/ ./splits/
    ln -s /cluster/home/tmp/GBM/HiC/02data/01fastq/EGA_hg19/${name}/splits/${name}.hic.bam.fastq_abnorm.sam \
        ./splits/${name}.fastq.gz_abnorm.sam
    ln -s /cluster/home/tmp/GBM/HiC/02data/01fastq/EGA_hg19/${name}/splits/${name}.hic.bam.fastq_linecount.txt \
        ./splits/${name}.fastq.gz_linecount.txt
    ln -s /cluster/home/tmp/GBM/HiC/02data/01fastq/EGA_hg19/${name}/splits/${name}.hic.bam.fastq_norm.txt.res.txt \
        ./splits/${name}.fastq.gz_norm.txt.res.txt
    ln -s /cluster/home/tmp/GBM/HiC/02data/01fastq/EGA_hg19/${name}/splits/${name}.hic.bam.fastq_unmapped.sam \
        ./splits/${name}.fastq.gz_unmapped.sam
    ln -s /cluster/home/tmp/GBM/HiC/02data/01fastq/EGA_hg19/${name}/splits/${name}.hic.bam.fastq.sam \
        ./splits/${name}.fastq.gz.sam
    ln -s /cluster/home/tmp/GBM/HiC/02data/01fastq/EGA_hg19/${name}/splits/${name}.hic.bam.fastq.sort.txt \
        ./splits/${name}.fastq.gz.sort.txt
done

cat /cluster/home/futing/Project/GBM/HiC/02data/01fastq/EGA/name.txt | while read name;do
    ln -s /cluster/home/futing/Project/GBM/HiC/02data/01fastq/EGA/${name}/aligned/inter_30.hic \
        /cluster/home/futing/Project/GBM/HiC/02data/02hic/GBM/${name}.hic
done