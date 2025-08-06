#!/bin/bash

cd /cluster2/home/futing/Project/panCancer/mew
grep -rl 'err' ./debug/*.log | cut -f3 -d '/' | cut -f1 -d '-' | cut -f1 -d '_' | sort -u > ./dumperr.txt

find . -name '*_2.fastq.gz' -exec basename {} \; | cut -f1 -d '_' | sort -u > ./dumpdone.txt

grep -w -F -v -f ./dumpdone.txt ./dumpJul31.txt > ./dumpfail.txt



# 检查需要dump的文件
ls SRR*[0-9] > ./dumpAug04.txt


# 检查所有完成的文件

sort dumpdoneAug05.txt > tmp && mv tmp dumpdoneAug05.txt
# tail -n +2 ./meta/undone_down.txt | sort -k3 > tmp && mv tmp ./meta/undone_down_sorted.txt
join -t $'\t' -1 1 -2 3 -o 2.1,2.3,2.4,2.5,2.6,2.7,2.9 dumpdone.txt ./meta/undone_down_sorted.txt > ./meta/done.txt

IFS=$'\t'
while read -r gse srr cell geno cancer other;do
	mkdir -p /cluster2/home/futing/Project/panCancer/${cancer}/${gse}/${cell}
	echo -e "mv ${srr}*.fastq.gz /cluster2/home/futing/Project/panCancer/${cancer}/${gse}/${cell}"
	mv ${srr}*.fastq.gz /cluster2/home/futing/Project/panCancer/${cancer}/${gse}/${cell}
done < '/cluster2/home/futing/Project/panCancer/new/meta/doneAug05.txt'


IFS=$'\t'
while read -r gse srr cell geno cancer other;do
	mkdir -p /cluster2/home/futing/Project/panCancer/${cancer}/${gse}/${cell}
	echo -e "mv ${srr}*.fastq.gz /cluster2/home/futing/Project/panCancer/${cancer}/${gse}/${cell}"
	mv /cluster2/home/futing/Project/panCancer/UCEC/GSE128234/LEIO-PT967/${srr}*.fastq.gz /cluster2/home/futing/Project/panCancer/${cancer}/${gse}/${cell}
done < <(grep 'UCEC' '/cluster2/home/futing/Project/panCancer/new/meta/done.txt')