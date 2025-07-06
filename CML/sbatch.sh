#!/bin/bash

gse=$1
cell=$2
enzyme=$3
# 全局变量
queue="normal"
queue_time="5780"
debugdir="/cluster2/home/futing/Project/panCancer/CML/$gse/$cell/debug"
mkdir -p "$debugdir"
dir=/cluster2/home/futing/Project/panCancer/CML
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
# jid=$(submit_job "${cell}" "/cluster2/home/futing/Project/panCancer/CRC/juicer.sh MboI ${dir}/${gse}/${cell}")
# echo "Job ID: $jid"

# jid=$(submit_job "${cell}" "/cluster2/home/futing/Project/panCancer/CRC/juicerv2.sh -d ${dir}/${gse}/${cell} -e MboI")
# echo "Job ID: $jid"

jid=$(submit_job "${cell}" "/cluster2/home/futing/Project/panCancer/scripts/juicerv2.sh -d ${dir}/${gse}/${cell} -e ${enzyme}")
echo "${cell} Job ID: $jid"
