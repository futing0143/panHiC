#!/bin/bash

cd /cluster2/home/futing/Project/panCancer/check/meta

# ---- Section 1: cancer gse cell enzynme 的 PanCan_meta.txt 文件
outputmeta="/cluster2/home/futing/Project/panCancer/check/meta/cancer_meta.txt"

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
ln /cluster2/home/futing/Project/panCancer/new/meta/done_meta.txt done_meta.txt
cat cancer_meta.txt done_meta.txt | sort -u > panCan_meta.txt

# 处理重复的细胞系
# outputmeta=/cluster2/home/futing/Project/panCancer/check/hic/insul0918.txt
# awk -F',' 'BEGIN{FS=OFS="\t"}{
#     count[$3]++
#     if (count[$3]==1) {
#         uniq=$3
#     } else {
#         uniq=$3"_"count[$3]
#     }
#     print $0,uniq
# }' ${outputmeta} > tmp && mv tmp ${outputmeta}

# ---- Section 2: cancer gse cell srr 的 PanCan_down_sim.txt 文件
outputsim="/cluster2/home/futing/Project/panCancer/check/meta/cancer_down_sim.txt"
>${outputsim}  # 清空输出文件
for cancer in CML CRC BRCA GC MB TALL AML PRAD NSCLC; do
    metafile="/cluster2/home/futing/Project/panCancer/${cancer}/meta/${cancer}.csv"
	sed -i "s/,/\t/g" "$metafile"  # 替换逗号为制表符
    if [ -f "$metafile" ]; then
        # 去掉表头，并在每行前添加 "$cancer,"
        awk -v cancer="$cancer" 'BEGIN{FS=OFS="\t"}NR>1{print cancer,$1,$4,$3}' "$metafile" >> "$outputsim"
    else
        echo "Warning: File not found - $metafile" >&2
    fi
done


# 02 合并
# 合并 CRC_ctrl cancer
grep 'Normal' /cluster2/home/futing/Project/panCancer/CRC/meta/ctrl.txt | awk 'BEGIN{FS=OFS="\t"}{print "CRC",$1,$4"_"$5,$2}' >> ${outputsim}
# 合并 cancer undone
ln -s /cluster2/home/futing/Project/panCancer/new/meta/undone_down_sim.txt undone_down_sim.txt
cat cancer_down_sim.txt undone_down_sim.txt | sort -u > panCan_down_sim.txt

# 合并 ctrl_merge.txt panCan_down_sim.txt;panCan_meta.txt;panCan_merge.txt;cell_list.txt
# <(cut -f1-4 meta1028.txt)  <(cut -f1-3,5 meta1028.txt) 
# cat <(cut -f1-5 ctrl_merge.txt) panCan_merge.txt | sort -u > tmp && mv tmp panCan_merge.txt
sed -i 's/ /_/g' ctrl_merge.txt
cat <(cut -f1-4 ctrl_merge.txt) panCan_down_sim.txt | sort -u > tmp && mv tmp panCan_down_sim.txt
cat <(cut -f1-3,5 ctrl_merge.txt) panCan_meta.txt | sort -u > tmp && mv tmp panCan_meta.txt

# 合并 cancer list
# awk 'BEGIN{FS=OFS="\t"}{print $1,$2,$3,"1"}' ctrl_merge.txt >> /cluster2/home/futing/Project/panCancer/Analysis/dchic/cell_list.txt
# sed -i 's/ /_/g' /cluster2/home/futing/Project/panCancer/Analysis/dchic/cell_list.txt
# sort -u /cluster2/home/futing/Project/panCancer/Analysis/dchic/cell_list.txt -o tmp && mv tmp /cluster2/home/futing/Project/panCancer/Analysis/dchic/cell_list.txt