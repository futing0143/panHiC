#!/bin/bash


outputmeta="/cluster2/home/futing/Project/panCancer/check/cancer_meta.txt"

>${outputmeta}  # 清空输出文件
for cancer in CML CRC BRCA GC MB TALL AML PRAD NSCLC; do
    metafile="/cluster2/home/futing/Project/panCancer/${cancer}/meta/${cancer}_meta.txt"
	sed -i "s/,/\t/g" "$metafile"  # 替换逗号为制表符
    if [ -f "$metafile" ]; then
        # 去掉表头，并在每行前添加 "$cancer,"
        awk -v cancer="$cancer" '{FS=OFS="\t"}{print cancer,$1,$2,$3}' "$metafile" >> "$outputmeta"
    else
        echo "Warning: File not found - $metafile" >&2
    fi
done

cat cancer_meta.txt done_meta.txt | sort -u > panCan_meta.txt