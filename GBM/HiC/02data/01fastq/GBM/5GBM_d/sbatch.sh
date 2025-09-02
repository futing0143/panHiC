#!/bin/bash

# 全局变量
queue="normal"
queue_time="5780"
debugdir="/cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/5GBM_d"
mkdir -p $debugdir

# 定义 submit_job 函数
submit_job() {
    local name=$1
    local script_path=$2
sbatch <<- EOF | egrep -o -e "\b[0-9]+$"
#!/bin/bash -l
#SBATCH -p $queue
#SBATCH -t $queue_time
#SBATCH --cpus-per-task=20
#SBATCH --output=$debugdir/debug/$name-%j.log
#SBATCH -J "${name}"



date
sh $script_path
date
EOF
}
#SBATCH -d afterok:29629

# 提交任务
jid=$(submit_job "11dump" "/cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/5GBM_d/sra.sh SRR3586211")
echo "Job ID: $jid"

# jid=$(submit_job "08dump" "/cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/5GBM_d/sra.sh SRR3586208")
# echo "Job ID: $jid"

# jid=$(submit_job "12dump" "/cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/5GBM_d/sra.sh SRR3586212")
# echo "Job ID: $jid"

# jid=$(submit_job "14dump" "/cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/5GBM_d/sra.sh SRR3586214")
# echo "Job ID: $jid"

# jid=$(submit_job "15dump" "/cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/5GBM_d/sra.sh SRR3586215")
# echo "Job ID: $jid"

# jid=$(submit_job "17dump" "/cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/5GBM_d/sra.sh SRR3586217")
# echo "Job ID: $jid"