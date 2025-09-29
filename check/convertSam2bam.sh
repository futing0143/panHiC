#!/bin/bash
#SBATCH -p normal
#SBATCH --cpus-per-task=20
#SBATCH --nodelist=node4
#SBATCH --output=/cluster2/home/futing/Project/panCancer/check/sam2bam/sam2bam-%j.log
#SBATCH -J "sam2bam"
ulimit -s unlimited
ulimit -l unlimited

# 定义包含SAM文件的根目录
source activate /cluster2/home/futing/miniforge3/envs/hic
# samtools install samtools -y
d=0926
convertfile="/cluster2/home/futing/Project/panCancer/check/sam2bam/sam2bam_${d}.txt"
# grep 'inter_30.hic' /cluster2/home/futing/Project/panCancer/check/hic/hicdone${d}.txt | cut -f1-3 > $convertfile


# while read -r cancer gse cell;do
# 	echo -e "Processing ${cancer}/${gse}/${cell}...\n"
# 	root_directory=/cluster2/home/futing/Project/panCancer/${cancer}/${gse}/${cell}
# 	# 检查samtools是否安装
# 	if ! command -v samtools &> /dev/null
# 	then
# 		echo "samtools could not be found, please install it first."
# 		exit 1
# 	fi

# 	# 使用find命令查找所有.sam文件，并执行samtools进行转换和删除操作
# 	find "$root_directory" -type f -name "*sam" -print0 | while IFS= read -r -d '' file
# 	do
# 		# 去除文件名末尾的回车符
# 		file="${file%$'\r'}"

# 		# 构建BAM文件的路径，将.sam替换为.bam
# 		bam_path="${file%.sam}.bam"
		
# 		# 使用samtools将SAM文件转换为BAM文件
# 		samtools view -@ 20 -bS "$file" > "$bam_path" && 
# 		# 如果转换成功，删除SAM文件
# 		rm "$file" && 
# 		echo "Converted and deleted: $file" && 
# 		# 输出转换后的BAM文件路径
# 		echo "Created BAM file: $bam_path"
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
