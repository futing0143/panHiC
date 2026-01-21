#!/bin/bash
#SBATCH -p gpu
#SBATCH --cpus-per-task=10
#SBATCH --output=/cluster2/home/futing/Project/panCancer/check/gzip-%j.log
#SBATCH -J "gzip"
ulimit -s unlimited
ulimit -l unlimited


# 
# d=1111
# cat /cluster2/home/futing/Project/panCancer/check/gzip/gzip_+([0-9]).txt | sort -u > \
# 	/cluster2/home/futing/Project/panCancer/check/gzip/gzip_done.txt
# grep -w -v -F -f /cluster2/home/futing/Project/panCancer/check/gzip/gzip_done.txt \
# 	<(grep 'inter_30.hic' /cluster2/home/futing/Project/panCancer/check/post/all/hicdone1206.txt | cut -f1-3) \
# 	> /cluster2/home/futing/Project/panCancer/check/gzip/gzip_${d}.txt
#
# 定义包含SAM文件的根目录
source activate /cluster2/home/futing/miniforge3/envs/juicer
readonly WKDIR="/cluster2/home/futing/Project/panCancer/check"
cd "${WKDIR}" || exit 1

parallel_execute() {
    local cancer="$1"
    local gse="$2"
    local cell="$3"
    
    local log_file="/cluster2/home/futing/Project/panCancer/${cancer}/${gse}/${cell}/debug/gzip-$(date +%Y%m%d_%H%M%S).log"
    
    # 使用代码块统一重定向
    {
		echo -e "Processing ${cancer}/${gse}/${cell}...\n"
		root_directory=/cluster2/home/futing/Project/panCancer/${cancer}/${gse}/${cell}/aligned
		root_directory2=/cluster2/home/futing/Project/panCancer/${cancer}/${gse}/${cell}/splits
		find "$root_directory" "$root_directory2" -type f -name "*.txt" -print0 |
		while IFS= read -r -d '' file; do
			file="${file%$'\r'}"
			gzip "$file"
			echo "compress gzip: $file"
		done

    } >> "${log_file}" 2>&1
}

export -f parallel_execute
export WKDIR
readonly PARALLEL_JOBS=10

# 执行并行任务
parallel -j "${PARALLEL_JOBS}" --colsep '\t' --progress --eta \
	--tmpdir "${WKDIR}/debug" \
    "parallel_execute {1} {2} {3}" :::: "/cluster2/home/futing/Project/panCancer/check/sam2bam/sam2bam_all.txt"

date