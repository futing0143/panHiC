#!/bin/bash

# 坏掉的文件
# /cluster/home/tmp/GBM/HiC/02data/01fastq/GBM/5GBM_d/SRR3586209
# /cluster/home/tmp/GBM/HiC/02data/01fastq/GBM/5GBM_d/SRR3586212
# /cluster/home/tmp/GBM/HiC/02data/01fastq/GBM/5GBM_d/SRR3586216_2.fastq.gz
# /cluster/home/tmp/GBM/HiC/02data/01fastq/GBM/5GBM_d/GB182/fastq/SRR3586213.fastq.gz

cd /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/5GBM_d
source /cluster/home/futing/miniforge-pypy3/etc/profile.d/conda.sh
conda activate RNA

# SRR3586212
# SRR3586209

sh /cluster/home/futing/pipeline/Ascp/ascp2.sh srr_debug.txt . 20M
# SRR3586213
for name in SRR3586216;do

    echo -e "parallel-fastq-dump --sra-id ${name} --threads 40 --outdir ./ --split-3 --gzip"
    parallel-fastq-dump --sra-id ${name} --threads 40 --outdir ./ --split-3 --gzip
done



while IFS=$'\t' read -r name srr;do
    echo "mving ${srr}.fastq.gz to ${name}"
    mkdir -p ${name}/fastq
    mv ${srr}*.fastq.gz ${name}/fastq
done < "/cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/5GBM_d/srr_group.txt"


#  sbatch 
queue="gpu"
queue_time="5780"
debugdir="/cluster/home/futing/Project/GBM/HiC/10loop"

# 定义 submit_job 函数
submit_job() {
    local name=$1
sbatch <<- EOF | egrep -o -e "\b[0-9]+$"
#!/bin/bash -l
#SBATCH -p $queue
#SBATCH -t $queue_time
#SBATCH --cpus-per-task=20
#SBATCH --output=/cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/5GBM_d/debug/${name}-%j.log
#SBATCH -J ${name}



date
# mkdir -p /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/5GBM/${name}
cd /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/5GBM_d/${name}

if [ ! -f fastq/*.fastq.gz ];then
    echo "File not found: fastq/*.fastq.gz"
    exit 1
fi

source /cluster/home/futing/miniforge-pypy3/etc/profile.d/conda.sh
conda activate juicer

sh /cluster/home/futing/software/juicer_CPU/scripts/juicer_single.sh \
    -D /cluster/home/futing/software/juicer_CPU/ \
    -d /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/5GBM_d/${name} -g hg38 \
    -p /cluster/home/futing/software/juicer_CPU/restriction_sites/hg38.genome \
    -z /cluster/home/futing/software/juicer_CPU/references/hg38.fa \
    -s HindIII
date
EOF
}

# for i in GB176 GB180 GB182 GB183 GB238;do
#     jid=$(submit_job "${i}")
#     echo "${i} Job ID: $jid"
# done
