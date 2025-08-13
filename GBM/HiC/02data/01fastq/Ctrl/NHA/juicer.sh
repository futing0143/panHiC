#!/bin/bash

source /cluster/home/futing/miniforge-pypy3/bin/activate juicer
:<<'END'
name=SRR13238426
ext='.fastq.gz'
tmpdir=/cluster/home/futing/Project/GBM/HiC/02data/01fastq/NHA/HIC_tmp

sort -T $tmpdir -S 70% --parallel=20 -k2,2d -k6,6d -k4,4n -k8,8n -k1,1n -k5,5n -k3,3n ./splits/$name${ext}.frag.txt > ./splits/$name${ext}.sort.txt
if [ $? -ne 0 ]
then
        echo "***! Failure during sort of $name${ext}"
        exit 1
else
        rm ./splits/$name${ext}_norm.txt ./splits/$name${ext}.frag.txt
fi
done
END
/cluster/home/futing/software/juicer_CPU/scripts/juicer.sh \
    -g hg38 \
    -d /cluster/home/futing/Project/GBM/HiC/02data/01fastq/NHA \
    -S final \
    -s Arima \
    -p /cluster/home/futing/software/juicer_CPU/restriction_sites/hg38.genome \
    -y /cluster/home/futing/software/juicer_CPU/restriction_sites/hg38_Arima.txt \
    -z /cluster/home/futing/software/juicer_CPU/references/hg38.fa \
    -D /cluster/home/futing/software/juicer_CPU/ 