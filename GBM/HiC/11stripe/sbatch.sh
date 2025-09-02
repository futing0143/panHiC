#!/bin/bash

# 全局变量
queue="normal"
queue_time="5780"
debugdir="/cluster/home/futing/Project/GBM/HiC/11stripe/debug"
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
# jid=$(submit_job "GBMcaller" "/cluster/home/futing/Project/GBM/HiC/11stripe/stripecaller.sh GBM")
# echo "Job ID: $jid"
jid=$(submit_job "NPCcaller" "/cluster/home/futing/Project/GBM/HiC/11stripe/stripecaller.sh NPC")
echo "Job ID: $jid"
jid=$(submit_job "iPSCcaller" "/cluster/home/futing/Project/GBM/HiC/11stripe/stripecaller.sh iPSC")
echo "Job ID: $jid"

# jid=$(submit_job "GBMstripew" "/cluster/home/futing/Project/GBM/HiC/11stripe/stripenn.sh GBM")
# echo "Job ID: $jid"

# jid=$(submit_job "NPCstripew" "/cluster/home/futing/Project/GBM/HiC/11stripe/stripenn.sh NPC")
# echo "Job ID: $jid"
# jid=$(submit_job "iPSCstripew" "/cluster/home/futing/Project/GBM/HiC/11stripe/stripenn.sh iPSC")
# echo "Job ID: $jid"