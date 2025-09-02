#!/bin/bash

# 全局变量
queue="normal"
queue_time="5780"
debugdir="/cluster/home/futing/Project/GBM/WGS/GSE215420"
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
#SBATCH --output=$debugdir/$name-%j.log
#SBATCH -J "${name}"



date
sh $script_path
date
EOF
}
#SBATCH -d afterok:29629

# 提交任务
# jid=$(submit_job "WGSdump" "/cluster/home/futing/Project/GBM/WGS/PRJNA541986/sra.sh")
# echo "Job ID: $jid"

jid=$(submit_job "WGS420" "/cluster/home/futing/Project/GBM/WGS/GSE215420/sra.sh")
echo "Job ID: $jid"