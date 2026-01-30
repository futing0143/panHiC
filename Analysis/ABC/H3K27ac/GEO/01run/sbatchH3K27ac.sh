#!/bin/bash

submit_job() {
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
    local script="/cluster2/home/futing/pipeline/ChIP_CUTTAG/cut2rose_sev6.sh"
    local log_dir="${dir}/debug"
    
    # 确保日志目录存在
    mkdir -p "$log_dir"

    # 4. 使用 Here Document 提交 sbatch
    sbatch <<EOT
#!/bin/bash
#SBATCH -p gpu
#SBATCH --job-name=${id}
#SBATCH --output=${log_dir}/${id}_%j.log
#SBATCH --cpus-per-task=15
#SBATCH --nodelist=node2

echo "Job started at: \$(date)"
echo "Processing ID: ${id}"

# 执行核心脚本
bash ${script} -d ${dir} -n ${id} -s ${srr_file} -c input

echo "Job ended at: \$(date)"
EOT

    echo "Status: Job for ${id} has been submitted."
}

IFS=$'\t'
while read -r cancer gse id;do
	wkdir=/cluster2/home/futing/Project/panCancer/Analysis/ABC/H3K27ac/GEO/${cancer}/${gse}/${id}
	submit_job ${id} ${wkdir} ${wkdir}/sample.txt


done < <(sed -n '11,13p' "/cluster2/home/futing/Project/panCancer/Analysis/ABC/H3K27ac/GEO/01run/H3K27ac_se0128.txt")
# SBATCH --nodelist=node1
