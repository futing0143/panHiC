#!/bin/bash
#SBATCH -p normal
#SBATCH --cpus-per-task=20
#SBATCH --output=/cluster2/home/futing/Project/panCancer/check/sam2bam/debug/sam2bam-%j.log
#SBATCH -J "sam2bam"
ulimit -s unlimited
ulimit -l unlimited

# 定义包含SAM文件的根目录
source activate /cluster2/home/futing/miniforge3/envs/juicer
# samtools install samtools -y
# d=1123
convertfile="/cluster2/home/futing/Project/panCancer/check/sam2bam/sam2bam_all.txt"

: << 'EOF'
cp /cluster2/home/futing/Project/panCancer/check/sam2bam/sam2bam_undone1111.txt \
	/cluster2/home/futing/Project/panCancer/check/sam2bam/sam2bam_done1111.txt
cat /cluster2/home/futing/Project/panCancer/check/sam2bam/sam2bam_done+([0-9]).txt | sort -u > \
	/cluster2/home/futing/Project/panCancer/check/sam2bam/sam2bam_done.txt
grep -w -v -F -f /cluster2/home/futing/Project/panCancer/check/sam2bam/sam2bam_done.txt \
	/cluster2/home/futing/Project/panCancer/check/sam2bam/sam2bam_${d}.txt > \
	/cluster2/home/futing/Project/panCancer/check/sam2bam/sam2bam_undone${d}.txt

EOF
# while read -r cancer gse cell;do
# 	echo -e "Processing ${cancer}/${gse}/${cell}...\n"
# 	root_directory=/cluster2/home/futing/Project/panCancer/${cancer}/${gse}/${cell}/splits/
# 	# 检查samtools是否安装
# 	if ! command -v samtools &> /dev/null
# 	then
# 		echo "samtools could not be found, please install it first."
# 		exit 1
# 	fi

# 	find "$root_directory" -type f -name "*.sam" -size +0c -print0 | \
# 	while IFS= read -r -d '' file
# 	do
# 		# 去除文件名末尾可能存在的回车符
# 		file="${file%$'\r'}"

# 		# 判断是否存在非 header 的比对记录
# 		# samtools view 默认不输出 header
# 		if ! samtools view "$file" | head -n 1 | grep -q .; then
# 			echo "Skip header-only SAM: $file"
# 			continue
# 		fi

# 		# 构建 BAM 路径
# 		bam_path="${file%.sam}.bam"

# 		# SAM → BAM
# 		samtools view -@ 20 -bS "$file" > "$bam_path" && \
# 		rm "$file" && \
# 		echo "[$(date)] Converted and deleted: $file" && \
# 		echo "[$(date)] Created BAM file: $bam_path"
# 	done

# done < "$convertfile"

export -f convert_func
convert_func() {
    cancer=$1; gse=$2; cell=$3
    echo -e "Processing ${cancer}/${gse}/${cell}...\n"
    root_directory=/cluster2/home/futing/Project/panCancer/${cancer}/${gse}/${cell}

    if ! command -v samtools &> /dev/null; then
        echo "samtools could not be found, please install it first."
        exit 1
    fi

    find "$root_directory" -type f -name "*.sam" -print0 |
    while IFS= read -r -d '' file; do
        file="${file%$'\r'}"
        bam_path="${file%.sam}.bam"
        samtools view -@ 20 -bS "$file" > "$bam_path" &&
        rm "$file" &&
        echo "Converted and deleted: $file" &&
        echo "Created BAM file: $bam_path"
    done
}

export -f convert_func
parallel -j 5 --colsep '\t' --progress --eta \
	"convert_func {1} {2} {3}" :::: "$convertfile"
