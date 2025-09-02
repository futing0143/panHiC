#!/bin/bash
cd /cluster/home/futing/Project/GBM/HiC/02data/01fastq/EGA
# ln -s /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/42MGBA/aligned ./42MGBA
# ln -s /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/A172/aligned ./A172
# ln -s /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/GB176/aligned ./GB176
# ln -s /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/GB180/aligned ./GB180
# ln -s /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/GB183/aligned ./GB183
# ln -s /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/GB182/aligned ./GB182
# ln -s /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/GB238/aligned ./GB238
# ln -s /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/H4/aligned ./H4
# ln -s /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/SW1088/aligned ./SW1088
# ln -s /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/ts543/mega/aligned ./ts543
# ln -s /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/ts667/mega/aligned ./ts667
# ln -s /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/U251/aligned ./U251
# ln -s /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/U87/aligned ./U87
# ln -s /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/U118/aligned ./U118
# ln -s /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/U343/aligned ./U343


/cluster/home/futing/software/juicer_CPU/scripts/common/mega.sh \
    -g hg38 \
    -s Arima \
    -d /cluster/home/futing/Project/GBM/HiC/02data/01fastq/EGA \
    -D /cluster/home/futing/software/juicer_CPU