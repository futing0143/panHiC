#!/bin/bash

# 全局变量
queue="normal"
queue_time="5780"
debugdir="/cluster/home/futing/Project/GBM/WGS/GSE202644"
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
# jid=$(submit_job "WGSdump" "/cluster/home/futing/Project/GBM/WGS/PRJNA541986/sra.sh")
# echo "Job ID: $jid"
# jid=$(submit_job "WGS644" "/cluster/home/futing/Project/GBM/WGS/GSE202644/sra.sh")
# echo "Job ID: $jid"
# jid=$(submit_job "WGS_790" "/cluster/home/futing/Project/GBM/WGS/GSE202644/run_wgs.sh SRR19156790")
# echo "Job ID: $jid"
# jid=$(submit_job "WGS_791" "/cluster/home/futing/Project/GBM/WGS/GSE202644/run_wgs.sh SRR19156791")
# echo "Job ID: $jid"
# jid=$(submit_job "WGS_790" "/cluster/home/futing/Project/GBM/WGS/GSE202644/fixbam.sh SRR19156790")
# echo "Job ID: $jid"
# jid=$(submit_job "WGS_791" "/cluster/home/futing/Project/GBM/WGS/GSE202644/fixbam.sh SRR19156791")
# echo "Job ID: $jid"
jid=$(submit_job "WGS_merge" "/cluster/home/futing/Project/GBM/WGS/GSE202644/run_wgsm.sh")
echo "Job ID: $jid"