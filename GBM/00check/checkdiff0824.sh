#!/bin/bash
#SBATCH -J diff
#SBATCH --output=./diff_%j.log 
#SBATCH --cpus-per-task=2
#SBATCH --nodelist=node1

dir1="/cluster/home/futing/Project/GBM"
dir2="/cluster2/home/futing/Project/panCancer/GBM"
file=/cluster/home/futing/Project/GBM/diff0906night.txt
>${file}
# file=/cluster/home/futing/Project/GBM/same.txt
echo "比较 $dir1 和 $dir2 ..."

# 遍历 dir1 下的文件
find "$dir1" -type f | while read -r f1; do
    rel_path="${f1#$dir1/}"      # 相对路径
    f2="$dir2/$rel_path"

    if [ -f "$f2" ]; then
        # 比较文件大小
        size1=$(stat -c%s "$f1")
        size2=$(stat -c%s "$f2")
		# if [ "$size1" -eq "$size2" ]; then
        if [ "$size1" -ne "$size2" ]; then
            echo "不同大小: $f1 ($size1) <> $f2 ($size2)" >> $file
			# echo $f1 >> $file
        fi
    else
        echo "只存在于 $dir1: $f1" >> $file
		# continue
    fi
done

# grep -v '/cluster2/home/futing/Project/panCancer/GBM' diff0906night.txt | cut -f3 -d ' ' | grep -v 'bam' > tmp && mv tmp diff0906night.txt
