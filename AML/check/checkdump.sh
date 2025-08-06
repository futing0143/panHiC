#!/bin/bash

cd /cluster2/home/futing/Project/panCancer/AML
find . -name '*_R2.fastq.gz' -exec basename {} _R2.fastq.gz \; | sort -u > ./meta/done.txt

grep -rl 'err' ./debug/*.log | cut -f3 -d '/' | cut -f1 -d '_' | sort -u > dumperr.txt
grep -w -F -v -f dumperr.txt done0718.txt > done.txt && rm done0718.txt #找到真正完整的
grep -w -F -v -f done.txt srr.txt > undone.txt #从所有中去掉真正完整的
grep -w -F -v -f dumperr.txt undone.txt > tmp && mv tmp undone.txt # 去掉dumpe err



IFS=$','
while read -r gse srr cell enzyme;do
	mkdir -p ${gse}/${cell}
	echo -e "mv ${srr}*.fastq.gz to ./${gse}/${cell}"
	mv ${srr}*.fastq.gz ./${gse}/${cell}
done < "AML_done.txt"