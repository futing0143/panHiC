#!/bin/bash
shopt -s extglob
IFS=$'\t'

out="/cluster2/home/futing/Project/panCancer/Analysis/QC/nContacts/reso/res1219.txt"
>$out
wkdir=/cluster2/home/futing/Project/panCancer/Analysis/QC/nContacts/reso
while read -r cancer gse cell; do

    logfile=$(ls ${wkdir}/debug/reso_${cancer}_${gse}_${cell}_*.log 2>/dev/null | sort | tail -1)

    echo "Processing ${cancer} ${gse} ${cell}"

    # 若日志不存在 → 输出空 resolution
    if [ -z "$logfile" ]; then
        echo -e "${cancer}\t${gse}\t${cell}\t" >> "$out"
        continue
    fi

    awk -v g1="$cancer" -v g2="$gse" -v g3="$cell" '
        BEGIN { found=0 }

        /The map resolution is/ {
            match($0,/[0-9]+/,m)
            res=m[0]
            found=1
        }

        END {
            if (found)
                print g1 "\t" g2 "\t" g3 "\t" res
            else
                print g1 "\t" g2 "\t" g3 "\t"
        }
    ' "$logfile" >> "$out"

done < "${wkdir}/reso1210.txt"



# awk '
#  /^[A-Za-z]{3} [A-Za-z]{3} [0-9]{1,2} / {cancer=$0; next}       # 匹配日期行，暂时存起来
#  /^[^\t]+\t[^\t]+\t[^\t]+$/ {split($0,a,"\t"); g1=a[1]; g2=a[2]; g3=a[3]; next}  # cancer,gse,cell
#  /The map resolution is/ {match($0,/[0-9]+/,m); res=m[0]; print g1 "\t" g2 "\t" g3 "\t" res}
#  ' /cluster2/home/futing/Project/panCancer/check/debug/calres-16551.log \
# > /cluster2/home/futing/Project/panCancer/check/res1106.txt

# awk '
#  /^[A-Za-z]{3} [A-Za-z]{3} [0-9]{1,2} / {cancer=$0; next}       # 匹配日期行，暂时存起来
#  /^[^\t]+\t[^\t]+\t[^\t]+$/ {split($0,a,"\t"); g1=a[1]; g2=a[2]; g3=a[3]; next}  # cancer,gse,cell
#  /The map resolution is/ {match($0,/[0-9]+/,m); res=m[0]; print g1 "\t" g2 "\t" g3 "\t" res}
#  ' /cluster2/home/futing/Project/panCancer/check/debug/calres-13892.log \
# > /cluster2/home/futing/Project/panCancer/check/res1015.txt

# 合并所有的res结果

# cat res+([0-9]).txt | sort -k1 -k2 -u > res.txt

