#!/bin/bash

cd /cluster2/home/futing/Project/panCancer/new
grep -rl 'err' ./debug/*.log | cut -f3 -d '/' | cut -f1 -d '-' | cut -f1 -d '_' | sort -u > ./dumperr.txt


# -- 01 检查需要dump的文件
find . -type f -name 'SRR*[0-9]' -exec basename {} \; > 01online1026.txt
find . -type f -name 'SRR*[0-9].lite' -exec basename {} .lite \; >> 01online1026.txt
# find . -type f -name 'SRR*[0-9].fastq.gz' -exec basename {} .fastq.gz \; | cut -f1 -d '_' >> 01online1026.txt
sort -u 01online1026.txt > tmp && mv tmp 01online1026.txt

# -- 02 检查 dumpdone 的fastq
find . -name '*.fastq.gz' -exec basename {} .fastq.gz \; | cut -f1 -d '_' | sort -u > ./dumpdone1026.txt
sort -u ./dumpdone1026.txt > tmp && mv tmp ./dumpdone1026.txt

# -- 03 合并 meta_sim 和 dumpdone 的 srr
# # tail -n +2 ./meta/undone_down.txt | sort -k3 > tmp && mv tmp ./meta/undone_down_sorted.txt
# join -t $'\t' -1 1 -2 3 -o 2.1,2.3,2.4,2.5,2.6,2.7,2.9 dumpdone1026.txt ./meta/undone_down_sorted.txt > ./meta/done1026.txt
# # 合并文件
# cat <(cut -f1,3,5 ./meta/done1026.txt | sort -u | awk '{FS=OFS="\t"}{print $3,$1,$2}') ./meta/done_meta.txt | sort -u > tmp && mv tmp ./meta/done_meta.txt

# 合并 ctrl
grep -F -f ./dumpdone1026nig.txt /cluster2/home/futing/Project/panCancer/check/meta/panCan_down_sim.txt > ./meta/done1026nig.txt

# -- 04 移动 fastq
# IFS=$'\t'
# shopt -s nullglob
# while read -r gse srr cell geno cancer other; do
#     outdir="/cluster2/home/futing/Project/panCancer/${cancer}/${gse}/${cell}"
#     mkdir -p "$outdir"
#     for f in ${srr}*.fastq.gz ./${srr}/${srr}*.fastq.gz; do
#         [ -e "$f" ] && mv "$f" "$outdir/"
#     done
# done < '/cluster2/home/futing/Project/panCancer/new/meta/done1026.txt'

IFS=$'\t'
shopt -s nullglob
while read -r cancer gse cell srr; do
    outdir="/cluster2/home/futing/Project/panCancer/${cancer}/${gse}/${cell}"
    mkdir -p "$outdir"
    for f in ${srr}*.fastq.gz ./${srr}/${srr}*.fastq.gz; do
        [ -e "$f" ] && mv "$f" "$outdir/"
    done
done < '/cluster2/home/futing/Project/panCancer/new/meta/done1026nig.txt'


# check all dump
find /cluster2/home/futing/Project/panCancer -name '*.fastq.gz' -exec basename {} .fastq.gz \; | cut -f1 -d '_' | cut -f1 -d '.' | sort -u > fastq1026.txt
grep -w -v -F -f fastq1026.txt 01online1026.txt > 01undump1026.txt
# 这个是真的有效的fastq数量
cat ./meta/done0* | cut -f2 | sort -u > ./meta/done_srr1026.txt


# while read -r a b c; do
#     grep -P "^$a\t$b\t$c\t" '/cluster2/home/futing/Project/panCancer/new/meta/undone_down_sim.txt'
# done < '/cluster2/home/futing/Project/panCancer/check/aligned/aligndone1026.txt' > '/cluster2/home/futing/Project/panCancer/new/delete1026.txt'
grep -w -v -F -f /cluster2/home/futing/Project/panCancer/new/meta/done_srr0926.txt <(cut -f4 /cluster2/home/futing/Project/panCancer/new/meta/undone_down_sim.txt)