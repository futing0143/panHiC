#!/bin/bash

cd /cluster2/home/futing/Project/panCancer/new
grep -rl 'err' ./debug/*.log | cut -f3 -d '/' | cut -f1 -d '-' | cut -f1 -d '_' | sort -u > ./dumperr.txt

d=1105
# -- 01 检查需要dump的文件
find . -type f -name 'SRR*[0-9]' -exec basename {} \; > 01online${d}.txt
find . -type f -name 'SRR*[0-9].lite' -exec basename {} .lite \; >> 01online${d}.txt
find . -type f -name 'SRR*[0-9].sra' -exec basename {} .sra \; >> 01online${d}.txt
# find . -type f -name 'SRR*[0-9].fastq.gz' -exec basename {} .fastq.gz \; | cut -f1 -d '_' >> 01online${d}.txt
sort -u 01online${d}.txt > tmp2 && mv tmp2 01online${d}.txt

# -- 02 检查 dumpdone 的fastq
find . -maxdepth 1 -name '*.fastq.gz' -exec basename {} .fastq.gz \; | cut -f1 -d '_' | sort -u > ./dumpdone${d}.txt

# -- 03 合并 meta_sim 和 dumpdone 的 srr
# # tail -n +2 ./meta/undone_down.txt | sort -k3 > tmp && mv tmp ./meta/undone_down_sorted.txt
# join -t $'\t' -1 1 -2 3 -o 2.1,2.3,2.4,2.5,2.6,2.7,2.9 dumpdone${d}.txt ./meta/undone_down_sorted.txt > ./meta/done${d}.txt
# # 合并文件
# cat <(cut -f1,3,5 ./meta/done${d}.txt | sort -u | awk '{FS=OFS="\t"}{print $3,$1,$2}') ./meta/done_meta.txt | sort -u > tmp && mv tmp ./meta/done_meta.txt

# 合并 ctrl
grep -F -f ./dumpdone${d}.txt /cluster2/home/futing/Project/panCancer/check/meta/panCan_down_sim.txt > ./meta/done${d}.txt
cat ./meta/done1*.txt | cut -f4 | sort -u > ./meta/donectrl_srr.txt
grep -v -w -F -f ./dumpdone${d}.txt 01online${d}.txt > 01undump${d}.txt
grep -v -w -F -f ./meta/donectrl_srr.txt ./01undump${d}.txt > tmp2 && mv tmp2 01undump${d}.txt #因为有些fastq移走了，所以再去掉dump好的done_srr.txt
# -- 04 移动 fastq
# IFS=$'\t'
# shopt -s nullglob
# while read -r gse srr cell geno cancer other; do
#     outdir="/cluster2/home/futing/Project/panCancer/${cancer}/${gse}/${cell}"
#     mkdir -p "$outdir"
#     for f in ${srr}*.fastq.gz ./${srr}/${srr}*.fastq.gz; do
#         [ -e "$f" ] && mv "$f" "$outdir/"
#     done
# done < '/cluster2/home/futing/Project/panCancer/new/meta/done${d}.txt'

IFS=$'\t'
shopt -s nullglob
while read -r cancer gse cell srr; do
    outdir="/cluster2/home/futing/Project/panCancer/${cancer}/${gse}/${cell}"
    mkdir -p "$outdir"
    for f in ${srr}*.fastq.gz ./${srr}/${srr}*.fastq.gz; do
        [ -e "$f" ] && echo "mv "$f" "$outdir/"" && mv "$f" "$outdir/"
    done
done < "/cluster2/home/futing/Project/panCancer/new/meta/done${d}.txt"


# ------------------ 05 检查目录下所有fastq和bam
# # check all dump
find /cluster2/home/futing/Project/panCancer -name '*.fastq.gz' -exec basename {} .fastq.gz \; | cut -f1 -d '_' | cut -f1 -d '.' | sort -u > fastq${d}.txt
grep -w -v -F -f fastq${d}.txt 01online${d}.txt > 01undump${d}.txt

# 这个是真的有效的fastq数量
# cat ./meta/done+([0-9]).txt | cut -f2 | sort -u > ./meta/done_srr${d}.txt
# cat ./meta/done0*.txt | cut -f2 | sort -u > ./meta/done_srr${d}.txt #这个是之前的srr
cat ./meta/done_srr0926.txt ./meta/donectrl_srr.txt | sort -u > ./meta/done_srr${d}.txt

# # ！！！ 真正的差别
grep -w -v -F -f fastq${d}.txt \
	<(cut -f4 /cluster2/home/futing/Project/panCancer/check/meta/panCan_down_sim.txt)


# 检查从new获得的fastq与所有的差别，不合理的，因为有不从new走的
# while read -r a b c; do
#     grep -P "^$a\t$b\t$c\t" '/cluster2/home/futing/Project/panCancer/new/meta/undone_down_sim.txt'
# done < '/cluster2/home/futing/Project/panCancer/check/aligned/aligndone${d}.txt' > '/cluster2/home/futing/Project/panCancer/new/delete${d}.txt'
# grep -w -v -F -f /cluster2/home/futing/Project/panCancer/new/meta/done_srr.txt \
# 	 <(cut -f4 /cluster2/home/futing/Project/panCancer/check/meta/panCan_down_sim.txt)