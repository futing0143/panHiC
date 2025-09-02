#!/bin/bash

# 全局变量
queue="normal"
queue_time="5780"
debugdir="/cluster/home/futing/Project/GBM/HiC/09insulation/5k_25k/debug"
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

cut -f1 /cluster/home/futing/Project/GBM/HiCQTL/tensorqtl/merged/sex_info.txt | while read i;do
	echo "Submitting job for $i"
	script_path="/cluster/home/futing/Project/GBM/HiC/09insulation/5k_25k/insul.sh $i"
	job_id=$(submit_job "$i" "$script_path")
	echo "Submitted job ID: $job_id"

done