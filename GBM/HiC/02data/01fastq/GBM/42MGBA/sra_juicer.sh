#!/bin/bash

cd /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/42MGBA
# 01 ascp
/cluster/home/futing/pipeline/Ascp/ascp.sh ./srr.txt /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/42MGBA  20M
mkdir -p fastq
find ./ -name "*.fastq.gz" -exec mv {} ./fastq \;

rename _1 _R1 ./fastq/*fastq.gz
rename _2 _R2 ./fastq/*fastq.gz
rename .R1 _R1 ./fastq/*fastq.gz
rename .R2 _R2 ./fastq/*fastq.gz   

# 02 sra
# ascp 不行还是得用prefetch
cat srr.txt | while read i;do
    name=${i}
    prefetch -p -X 60GB ${name}
    source activate /cluster/home/futing/anaconda3/envs/download
    echo -e "parallel-fastq-dump --sra-id ${name} --threads 40 --outdir ./ --split-3 --gzip"
    parallel-fastq-dump --sra-id ${name} --threads 40 --outdir ./ --split-3 --gzip

done

# ----- juicer -----
source activate /cluster/home/futing/anaconda3/envs/juicer
/cluster/home/futing/software/juicer_CPU/scripts/juicer.sh \
-D /cluster/home/futing/software/juicer_CPU/ \
-d /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/42MGBA -g hg38 \
-p /cluster/home/futing/software/juicer_CPU/restriction_sites/hg38.genome \
-z /cluster/home/futing/software/juicer_CPU/references/hg38.fa -s Arima > juicer.log 2>&1 &


# ----- postprocessing -----
source activate /cluster/home/futing/anaconda3/envs/hic
resolutions=(5000 10000 50000 100000 500000 1000000)
#01 hic 2 mcool
hicConvertFormat -m ./aligned/inter_30.hic --inputFormat hic --outputFormat cool -o /cluster/home/futing/Project/GBM/HiC/02data/04mcool/42MGBA.mcool
for resolution in "${resolutions[@]}";do
    echo -e "\n Processing /cluster/home/futing/Project/GBM/HiC/02data/04mcool/42MGBA.mcool at ${resolution} resolution \n"
    cooler balance /cluster/home/futing/Project/GBM/HiC/02data/04mcool/42MGBA.mcool::resolutions/${resolution}
done


#02 mcool 2 cool 
for resolution in "${resolutions[@]}";do
    python /cluster/home/futing/Project/GBM/HiC/02data/05file_transform/add_prefix_to_cool.py /cluster/home/futing/Project/GBM/HiC/02data/04mcool/42MGBA.mcool::resolutions/${resolution}
    echo "Processing 42MGBA at ${resolution}..."
    cooler dump --join /cluster/home/futing/Project/GBM/HiC/02data/04mcool/42MGBA.mcool::resolutions/${resolution} | \
    cooler load --format bg2 /cluster/home/futing/ref_genome/hg38_24.chrom.sizes:${resolution} \
    - /cluster/home/futing/Project/GBM/HiC/02data/03cool/${resolution}/42MGBA_${resolution}.cool
    cooler balance /cluster/home/futing/Project/GBM/HiC/02data/03cool/${resolution}/42MGBA_${resolution}.cool
done

cooltools insulation /cluster/home/futing/Project/GBM/HiC/02data/03cool_KR/50000/42MGBA.50000.KR.cool \
-o /cluster/home/futing/Project/GBM/HiC/09insulation/insul_futing/50k/42MBGA_insul.tsv  --ignore-diags 2 --verbose 800000
