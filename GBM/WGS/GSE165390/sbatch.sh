#!/bin/bash

# 全局变量
queue="normal"
queue_time="5780"
debugdir="/cluster/home/futing/Project/GBM/WGS/GSE165390/"
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
# jid=$(submit_job "WGS_SRR13515301" "/cluster/home/futing/Project/GBM/WGS/GSE165390/run_wgs.sh SRR13515301")
# echo "SRR13515301 WGS Job ID: $jid"
# jid=$(submit_job "WGS_SRR13515303" "/cluster/home/futing/Project/GBM/WGS/GSE165390/run_wgs.sh SRR13515303")
# echo "SRR13515303 WGS Job ID: $jid"
jid=$(submit_job "WGS_SRR13515302" "/cluster/home/futing/Project/GBM/WGS/GSE165390/run_wgs.sh SRR13515302")
echo "SRR13515303 WGS Job ID: $jid"