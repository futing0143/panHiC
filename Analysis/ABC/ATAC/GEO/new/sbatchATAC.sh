#!/bin/bash

submit_atac_job() {
    # 1. 参数获取
    local id=$1
    local dir=$2
    local srr_file=$3

    # 2. 检查参数是否完整
    if [[ -z "$id" || -z "$dir" || -z "$srr_file" ]]; then
        echo "Usage: submit_atac_job <id> <dir> <srr_file>"
        return 1
    fi

    # 3. 环境变量与路径定义
    local script="/cluster2/home/futing/pipeline/newATAC/ATAC_v4.sh"
    local log_dir="${dir}/debug"
    
    # 确保日志目录存在
    mkdir -p "$log_dir"

    # 4. 使用 Here Document 提交 sbatch
    sbatch <<EOT
#!/bin/bash
#SBATCH -p normal
#SBATCH --job-name=${id}
#SBATCH --output=${log_dir}/${id}_%j.log
#SBATCH --cpus-per-task=10
#SBATCH --nodelist=node1

echo "Job started at: \$(date)"
echo "Processing ID: ${id}"

# 执行核心脚本
bash ${script} -d ${dir} -n ${id} -s ${srr_file} -p yes

echo "Job ended at: \$(date)"
EOT

    echo "Status: Job for ${id} has been submitted."
}

IFS=$'\t'
while read -r cancer gse id;do
	wkdir=/cluster2/home/futing/Project/panCancer/Analysis/ABC/ATAC/GEO/${cancer}/${gse}/${id}
	submit_atac_job ${id} ${wkdir} ${wkdir}/srr.txt


done < <(sed -n '5,9p' "/cluster2/home/futing/Project/panCancer/Analysis/ABC/ATAC/GEO/new/ATACtest0126.tsv")
# SBATCH --nodelist=node1
