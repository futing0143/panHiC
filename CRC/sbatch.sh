#!/bin/bash

gse=$1
cell=$2
# 全局变量
queue="gpu"
queue_time="5780"
debugdir="/cluster/home/futing/Project/panCancer/CRC/$gse/$cell/debug"
dir=/cluster/home/futing/Project/panCancer/CRC
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
# jid=$(submit_job "${cell}" "/cluster/home/futing/Project/panCancer/CRC/juicer.sh MboI ${dir}/${gse}/${cell}")
# echo "Job ID: $jid"

# jid=$(submit_job "${cell}" "/cluster/home/futing/Project/panCancer/CRC/juicerv2.sh -d ${dir}/${gse}/${cell} -e MboI")
# echo "Job ID: $jid"

jid=$(submit_job "${cell}" "/cluster/home/futing/Project/panCancer/CRC/juicerv2.sh -d ${dir}/${gse}/${cell} -e MboI -s post")
echo "Job ID: $jid"