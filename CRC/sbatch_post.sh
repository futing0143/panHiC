#!/bin/bash

tools=$1
cell=$2
gse=${3:-GSE137188}
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
#SBATCH --cpus-per-task=10
#SBATCH --mem=20G
#SBATCH --output=$debugdir/$name-%j.log
#SBATCH -J "${name}"



date
sh $script_path
date
EOF
}
#SBATCH -d afterok:29629

# 提交任务

jid=$(submit_job "${cell}_${tools}" "/cluster/home/futing/Project/panCancer/scripts/${tools}_single.sh ${dir}/${gse}/${cell}")
echo "${cell}_${tools} Job ID: $jid"
