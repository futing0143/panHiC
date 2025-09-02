#!/bin/bash

cd /cluster2/home/futing/Project/panCancer/new
grep -rl 'err' ./debug/*.log | cut -f3 -d '/' | cut -f1 -d '-' | cut -f1 -d '_' | sort -u > ./dumperr.txt

find . -name '*_2.fastq.gz' -exec basename {} \; | cut -f1 -d '_' | sort -u > ./dumpdoneAug30.txt

# 检查需要dump的文件
find . -type f -name 'SRR*[0-9]' -exec basename {} \; > 01online0830.txt
find . -type f -name 'SRR*[0-9].lite' -exec basename {} .lite \; >> 01online0830.txt
find . -type f -name 'SRR*[0-9].fastq.gz' -exec basename {} .fastq.gz \; | cut -f1 -d '_' >> 01online0830.txt
sort -u 01online0830.txt > tmp && mv tmp 01online0830.txt

# 检查所有完成的文件
# tail -n +2 ./meta/undone_down.txt | sort -k3 > tmp && mv tmp ./meta/undone_down_sorted.txt
join -t $'\t' -1 1 -2 3 -o 2.1,2.3,2.4,2.5,2.6,2.7,2.9 dumpdoneAug30.txt ./meta/undone_down_sorted.txt > ./meta/doneAug30.txt
# 合并文件
cat <(cut -f1,3,5 ./meta/doneAug30.txt | sort -u | awk '{FS=OFS="\t"}{print $3,$1,$2}') ./meta/done_meta.txt | sort -u > tmp && mv tmp ./meta/done_meta.txt

# | awk '{FS=OFS="\t"}{print $3,$1,$2,$4}'
IFS=$'\t'
while read -r gse srr cell geno cancer other;do
	mkdir -p /cluster2/home/futing/Project/panCancer/${cancer}/${gse}/${cell}
	echo -e "mv ${srr}*.fastq.gz /cluster2/home/futing/Project/panCancer/${cancer}/${gse}/${cell}"
	mv ${srr}*.fastq.gz /cluster2/home/futing/Project/panCancer/${cancer}/${gse}/${cell}
done < '/cluster2/home/futing/Project/panCancer/new/meta/doneAug30.txt'

# check all dump
find /cluster2/home/futing/Project/panCancer -name '*.fastq.gz' -exec basename {} .fastq.gz \; | cut -f1 -d '_' | cut -f1 -d '.' | sort -u > fastq0830.txt
grep -w -v -F -f fastq0830.txt 01online0830.txt > 01undump.txt
cat ./meta/doneAug* | cut -f2 | sort -u > ./meta/done_srr0830.txt
# awk 'NR==FNR{key[$1 FS $2 FS $3]; next} ($1 FS $2 FS $3) in key' \
# 	/cluster2/home/futing/Project/panCancer/new/meta/undone_down_sim.txt \
# 	/cluster2/home/futing/Project/panCancer/check/aligned/aligndone0830.txt > \
# 	/cluster2/home/futing/Project/panCancer/new/delete0830.txt

# while read -r a b c; do
#     grep -P "^$a\t$b\t$c\t" '/cluster2/home/futing/Project/panCancer/new/meta/undone_down_sim.txt'
# done < '/cluster2/home/futing/Project/panCancer/check/aligned/aligndone0830.txt' > '/cluster2/home/futing/Project/panCancer/new/delete0830.txt'
