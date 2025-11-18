#!/bin/bash

# 此脚本用于合并 old GBM branch 到 新的目录下
# 01 先创建文件夹
wkdir=/cluster2/home/futing/Project/panCancer/GBM
IFS=$'\t'
while read -r gse cell enzyme;do
	if [ ! -d "${wkdir}/${gse}/${cell}" ];then
	    mkdir -p ${wkdir}/${gse}/${cell}/{aligned,fastq,debug,anno,cool,splits}
	fi 
done < "/cluster2/home/futing/Project/panCancer/GBM/GBM_meta.txt"

# 02 整理新旧路径

old_dir=/cluster2/home/futing/Project/GBM/HiC/02data/01fastq/GBM

# ------------- 02 先创建新文件的文件列表

# ----- part 1 fastq
# 没有 EGA 的部分
sed -i 's/\r$//' GBM_down_sim.txt

awk -v wkdir="$wkdir" 'BEGIN{FS=OFS="\t"}{
    line = $1 OFS $2 OFS $3 OFS $4
    print line, wkdir"/"$1"/"$2"/fastq/"$4"_R1.fastq.gz"
    print line, wkdir"/"$1"/"$2"/fastq/"$4"_R2.fastq.gz"
}' GBM_down_sim.txt > tmp

# 02-2 构建旧文件的文件列表
find $old_dir \
	-type f -name '*fastq.gz' | awk -F'/' '{
    # cell 是 fastq 前一段，即倒数第三段
    cell = $(NF-2)

    # 文件名部分 SRR25569743_R2.fastq.gz
    split($NF, a, "_")
    srr = a[1]
	split(srr,b,".")
	clsrr =b[1]

    print cell, clsrr, $0
}' OFS="\t" > fastq_GBM.txt

# 02-3 按照 cell srr合并
awk 'NR==FNR{key=$2"\t"$4; data[key]=$0; next}
{
  key=$1"\t"$2
  if(key in data)
     print data[key]"\t"$3
}' tmp fastq_GBM.txt  > fastq_transfer.txt
rm tmp

# 02-4 ln !
while read -r gse cell enzyme srr newlk oldfile;do
	if [ -L "$newlk" ] && [ -e "$newlk" ]; then
    echo "symlink exists and target exists"
	else
	ln -s $oldfile $newlk
	fi
done < "fastq_transfer.txt"



# ---- part 2
# 01 有 fastq 的部分
# splits align
dir="splits"
find $old_dir \
	-type d -name '${dir}' | grep -Ev '\/5GBM|debug|ts667|ts543' |\
	awk -F '/' '{cell = $(NF-1) 
	print cell,$0
	}' > ${dir}_GBM.txt
# 按照cell合并
awk 'NR==FNR{key=$2;data[key]=$0;next}
{
  key=$1
  if(key in data)
	print data[key]"\t"$2
}' GBM_meta.txt ${dir}_GBM.txt | awk -v wkdir=$wkdir -v dir=${dir} 'BEGIN{FS=OFS="\t"}{
print $0,wkdir"/"$1"/"$2"/"dir"/"
}' > ${dir}_transfer.txt

# ln !
IFS=$'\t'
while read -r gse cell enzyme oldfile newlk;do
	if [ -L "$newlk" ] && [ -e "$newlk" ]; then
    echo "symlink exists and target exists"
	else
	ln -s $oldfile/* $newlk
	fi
done < "${dir}_transfer.txt"


# NC 部分
dir=NC
find /cluster2/home/futing/Project/GBM/HiC/02data/02hic/GBM -type f -name '*.hic' | awk -F'/' \
	'{id=$NF; sub(/\.hic$/, "", id); print id, $0}'> ${dir}_GBM.txt
awk 'NR==FNR{key=$2;data[key]=$0;next}
{
  key=$1
  if(key in data)
	print data[key]"\t"$2
}' GBM_meta.txt ${dir}_GBM.txt | awk -v wkdir=$wkdir -v dir=${dir} 'BEGIN{FS=OFS="\t"}{
print $0,wkdir"/"$1"/"$2"/aligned/inter_30.hic"
}' > ${dir}_transfer.txt

# ln !
IFS=$'\t'
while read -r gse cell enzyme oldfile newlk;do
	if [ -L "$newlk" ] && [ -e "$newlk" ]; then
    echo "symlink exists and target exists"
	else
	ln -s $oldfile $newlk
	fi
done < "${dir}_transfer.txt"


# EGA 部分


# --- part 3 cool
