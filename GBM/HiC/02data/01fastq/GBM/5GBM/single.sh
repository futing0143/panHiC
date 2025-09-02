#!/bin/bash


# 全局变量
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
#SBATCH --output=/cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/5GBM/5GBM-%j.log
#SBATCH -J ${name}



date
# mkdir -p /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/5GBM/${name}
cd /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/5GBM/${name}
# mkdir -p fastq
# ln -s /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/${name}/fastq/${name}_R1.fastq.gz ./fastq/${name}1.fastq.gz
# ln -s /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/${name}/fastq/${name}_R2.fastq.gz ./fastq/${name}2.fastq.gz
source /cluster/home/futing/miniforge-pypy3/etc/profile.d/conda.sh
conda activate juicer

sh /cluster/home/futing/software/juicer_CPU/scripts/juicer_single.sh \
    -D /cluster/home/futing/software/juicer_CPU/ \
    -d /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/5GBM/${name} -g hg38 \
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


jid=$(submit_job "GB176")
