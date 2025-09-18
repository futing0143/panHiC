#!/bin/bash

# 全局变量
queue="normal"
queue_time="5780"
debugdir="/cluster2/home/futing/Project/HiCQTL/CRC"
mkdir -p $debugdir

# 定义 submit_job 函数
submit_job() {
    local name=$1
    local script_path=$2
sbatch <<- EOF | egrep -o -e "\b[0-9]+$"
#!/bin/bash -l
#SBATCH -p $queue
#SBATCH -t $queue_time
#SBATCH --cpus-per-task=10
#SBATCH --output=$debugdir/debug/$name-%j.log
#SBATCH -J "${name}"



date
sh $script_path
date
EOF
}
#SBATCH -d afterok:29629

# 提交任务

IFS=$','
while read -r gse cell enzyme; do
	# 处理每一行
	echo "Processing GSE: $gse, Cell: $cell, Enzyme: $enzyme"
	script_path="/cluster2/home/futing/Project/HiCQTL/hicQTL_single.sh /cluster2/home/futing/Project/panCancer/CRC/${gse}/${cell}/splits ${enzyme}"
	jid=$(submit_job "$cell" "$script_path")
	echo "Job ID for $cell: $jid"
done < "/cluster2/home/futing/Project/HiCQTL/CRCJun26.txt"

