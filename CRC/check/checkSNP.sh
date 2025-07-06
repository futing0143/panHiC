#!/bin/bash

output_file=/cluster2/home/futing/Project/panCancer/CRC/check/CRC_bam.txt
meta_file=/cluster2/home/futing/Project/panCancer/CRC/meta/CRC_meta.txt

check_file() {
    local file="$1"
    if [ -e "$file" ] && [ -s "$file" ]; then
        return 0    # 存在且非空
    else
        return 1    # 不存在或为空
    fi
}

> "$output_file" 

IFS=','  
while read -r gse cell other; do
    dir="/cluster2/home/futing/Project/panCancer/CRC/${gse}/${cell}/splits"

    sam_exist=false
    bam_exist=false

    # 检查是否存在有效的sam文件
    for f in "$dir"/*.fastq.gz.sam; do
        [ -e "$f" ] && check_file "$f" && sam_exist=true
    done

    # 检查是否存在有效的bam文件
    for f in "$dir"/*.fastq.gz.bam; do
        [ -e "$f" ] && check_file "$f" && bam_exist=true
    done

    # 如果存在sam文件，或者不存在任何bam文件，则输出
    if $sam_exist || ! $bam_exist; then
        echo -e "${gse}\t${cell}" >> "$output_file"
    fi
    # 只有当文件夹中全是bam且没有sam时，才不输出

done < "$meta_file"
