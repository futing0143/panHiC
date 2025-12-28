#!/bin/bash


# 第一步：找出重复的 cancer cell 组合
awk 'BEGIN{FS=OFS="\t"}{key=$1" "$3; count[key]++; lines[key]=lines[key] ? lines[key] ORS $0 : $0} 
END {for(k in count) if(count[k]>1) print lines[k]}' \
/cluster2/home/futing/Project/panCancer/check/meta/panCan_meta.txt \
> /cluster2/home/futing/Project/panCancer/check/meta/backup_duplicates.txt

awk 'BEGIN{FS=OFS="\t"}{print "/cluster2/home/futing/Project/panCancer/"$1"/"$2"/"$3"/cool/"$3"_5000.cool"}' \
/cluster2/home/futing/Project/panCancer/check/meta/backup_duplicates.txt \
> /cluster2/home/futing/Project/panCancer/check/meta/backup_duplicates_paths.txt

awk 'BEGIN{FS=OFS="\t"}{print "/cluster2/home/futing/Project/panCancer/"$1"/"$2"/"$3"/cool/"$3"_5000.cool"}' \
/cluster2/home/futing/Project/panCancer/check/meta/panCan_meta.txt \
> /cluster2/home/futing/Project/panCancer/check/meta/backup_cool_all.txt

# 没下载的文件
grep -w -v -F -f /cluster2/home/futing/Project/panCancer/backup_cool.txt \
/cluster2/home/futing/Project/panCancer/check/meta/backup_all.txt \
> /cluster2/home/futing/Project/panCancer/check/meta/backup_cool_1214.txt

# 找到所有SRR文件，清一下目录
find /cluster2/home/futing/Project/panCancer -type f \
  -regex '.*/SRR[0-9]\+\(\.sra\)\?$'

# HiC 文件
awk 'BEGIN{FS=OFS="\t"}{print "/cluster2/home/futing/Project/panCancer/"$1"/"$2"/"$3"/aligned/inter_30.hic",$2"_"$3".hic"}' \
/cluster2/home/futing/Project/panCancer/check/meta/panCan_meta.txt \
> /cluster2/home/futing/Project/panCancer/check/backup/backup_hic_all.txt
