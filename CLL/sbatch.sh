#!/bin/bash

gse=$1
cell=$2
enzyme=$3
juicerstage=${4:-""}  # 新增参数，默认值为空
cancer=CLL
# 全局变量
queue="gpu"
queue_time="8000"
debugdir="/cluster2/home/futing/Project/panCancer/${cancer}/$gse/$cell/debug"
mkdir -p "$debugdir"
dir=/cluster2/home/futing/Project/panCancer/${cancer}
# 定义 submit_job 函数
submit_job() {
    local name=$1
    local script_path=$2
sbatch <<- EOF | egrep -o -e "\b[0-9]+$"
#!/bin/bash -l
#SBATCH -p $queue
#SBATCH -t $queue_time
#SBATCH --cpus-per-task=10
#SBATCH --nodelist=node2
#SBATCH --output=$debugdir/$name-%j.log
#SBATCH -J "${name}"



date
sh $script_path
date
EOF
}

jid=$(submit_job "${cell}" "/cluster2/home/futing/Project/panCancer/scripts/juicerv1.sh -d ${dir}/${gse}/${cell} -e ${enzyme} -j \"${juicerstage}\"")
echo "${cell} Job ID: $jid"
