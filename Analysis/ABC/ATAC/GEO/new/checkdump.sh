#!/bin/bash
metafile=/cluster2/home/futing/Project/panCancer/Analysis/ABC/ATAC/GEO/ATACmeta.tsv
cd /cluster2/home/futing/Project/panCancer/Analysis/ABC/ATAC/GEO/new
tail -n +2 $metafile | cut -f9 | sort -u | grep -w -v -F -f srr0118.txt | grep -w -v -F -f srr0119.txt > srr0120.txt

d=0121
grep -rl 'err' ./debug/*.log | cut -f3 -d '/' | cut -f1 -d '-' | cut -f1 -d '_' | sort -u > ./dumperr${d}.txt

# 下载的所有 SRR 编号
find . -type f \
  -regextype posix-extended \
  -regex '.*/SRR[0-9]+(\.sra)?' \
  -exec basename {} \; | \
  sed 's/\.sra$//' | \
  sort -u > srr_done${d}.txt

# 已经成功dump的SRR编号：有fastq.gz文件的,去掉dumperr${d}.txt中的SRR
find . -type f -name 'SRR*.fastq.gz' \
  -exec basename {} \; | \
  sed -E 's/\.fastq\.gz$//' | \
  cut -f1 -d '_' | \
  sort -u | \
  grep -w -F -v -f dumperr${d}.txt \
  > dumpdone${d}.txt

# 需要进行SRR重新dump的列表：去掉已经提交任务的dumperr.txt
grep -w -v -F -f dumpdone${d}.txt srr_done${d}.txt | grep -v -w -F -f dumperr${d}.txt > redump${d}.txt


# 检查没下的 SRR
grep -w -v -F -f srr_done${d}.txt srr.txt > srr_undone${d}.txt

# 检查 srr -> gsm
find /cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/GEO -name 'GSM*.fastq.gz' | \
  xargs -n1 basename | \
  sed -E 's/\.fastq\.gz$//' | \
  cut -f1 -d '_' | \
  sort -u > gsm_done${d}.txt

grep -w -v -F -f gsm_done${d}.txt <(cut -f6 $metafile)
# 检查biological err
grep -rl 'non-biological READS'./debug/*.log | cut -f3 -d '/' | cut -f1 -d '-' | cut -f1 -d '_' | sort -u > ./biological_${d}.txt