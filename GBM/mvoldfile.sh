#!/bin/bash

# 此脚本用于合并 old GBM branch 到 新的目录下

cd /cluster2/home/futing/Project/panCancer/GBM/transfer

# =============== 01 先创建文件夹 ===============
wkdir=/cluster2/home/futing/Project/panCancer/GBM
IFS=$'\t'
while read -r gse cell enzyme;do
	if [ ! -d "${wkdir}/${gse}/${cell}" ];then
	    mkdir -p ${wkdir}/${gse}/${cell}/{aligned,fastq,debug,anno,cool,splits}
	fi 
done < "${wkdir}/GBM_meta.txt"

# ============= 02 处理 fastq splits align ============
# --------- part 1 fastq
old_dir=/cluster2/home/futing/Project/GBM/HiC/02data/01fastq/GBM

# 没有 EGA 的部分
sed -i 's/\r$//' ${wkdir}/GBM_down_sim.txt

awk -v wkdir="$wkdir" 'BEGIN{FS=OFS="\t"}{
    line = $1 OFS $2 OFS $3 OFS $4
    print line, wkdir"/"$1"/"$2"/fastq/"$4"_R1.fastq.gz"
    print line, wkdir"/"$1"/"$2"/fastq/"$4"_R2.fastq.gz"
}' ${wkdir}/GBM_down_sim.txt > tmp

# 02-2 构建旧文件的文件列表
find $old_dir \
	-type f -name '*fastq.gz' | awk -F'/' '{
    # cell 是 fastq 前一段，即倒数第三段
    cell = $(NF-2)
	gsub(/A172_2/, "A172", cell)
    # 文件名部分 SRR25569743_R2.fastq.gz
    split($NF, a, "_")
    srr = a[1]
	split(srr,b,".")
	clsrr = b[1]

    print cell, clsrr, $0
}' OFS="\t" | grep -Ev 'sra|ascp' > fastq_GBM.txt #删除fastq 

# 02-3 按照 cell srr合并
awk 'NR==FNR{key=$2"\t"$4; data[key]=$0; next}
{
  key=$1"\t"$2
  if(key in data)
     print data[key]"\t"$3
}' tmp fastq_GBM.txt  > fastq_transfer.txt
# ！！！ fastq_transfer.txt 合并后全是R2，single end 也有问题，手动处理，single

awk -F'\t' '
{
    key = $1 FS $2 FS $3 FS $4
    count[key]++

    if (count[key] == 1) {
        # 第一次出现 → 如果第5列是R2，改成R1
        sub(/_R2\.fastq\.gz$/, "_R1.fastq.gz", $5)
        sub(/_2\.fastq\.gz$/,  "_1.fastq.gz",  $5)
    }
    print
}' OFS="\t" fastq_transfer.txt > tmp && mv tmp fastq_transfer.txt

# 02-4 ln !
while read -r gse cell enzyme srr newlk oldfile;do
	if [ -L "$newlk" ] && [ -e "$newlk" ]; then
    echo "symlink exists and target exists"
	else
	ln -s $oldfile $newlk
	fi
done < "fastq_transfer.txt"


# ---------- part 2 splits align
dir="splits"
find $old_dir \
	-type d -name ${dir} | grep -Ev '\/5GBM|debug|ts667|ts543' |\
	awk -F '/' '{cell = $(NF-1) 
	print cell,$0
	}' > ${dir}_GBM.txt
# 按照cell合并
awk 'NR==FNR{key=$2;data[key]=$0;next}
{
  key=$1
  if(key in data)
	print data[key]"\t"$2
}' <(grep -v 'PRJNA532762' ${wkdir}/GBM_meta.txt) ${dir}_GBM.txt | awk -v wkdir=$wkdir -v dir=${dir} 'BEGIN{FS=OFS="\t"}{
print $0,wkdir"/"$1"/"$2"/"dir"/"
}' > ${dir}_transfer.txt # ！！！手动修改A172

# ln !
IFS=$'\t'
while read -r gse cell enzyme oldfile newlk;do
	if [ -L "$newlk" ] && [ -e "$newlk" ]; then
    echo "symlink exists and target exists"
	else
	ln -s $oldfile/* $newlk
	fi
done < "${dir}_transfer.txt"


#  ----------- 03 NC 部分，只需要处理 inter_30.hic
dir=NC
find /cluster2/home/futing/Project/GBM/HiC/02data/02hic/GBM -type f -name '*.hic' | awk -F'/' \
	'{id=$NF; sub(/\.hic$/, "", id); print id, $0}'> ${dir}_GBM.txt
awk 'NR==FNR{key=$2;data[key]=$0;next}
{
  key=$1  # 按照 cell name这一列合并，寻找匹配的GSE
  if(key in data)
	print data[key]"\t"$2
}' ${wkdir}/GBM_meta.txt ${dir}_GBM.txt | awk -v wkdir=$wkdir -v dir=${dir} 'BEGIN{FS=OFS="\t"}{
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


# ------------- 04 EGA 部分 处理 aligned fastq splits
# 先提前处理了里面的软链接，只有aligned文件夹里面的是源文件
sourcedir=/cluster2/home/futing/Project/GBM/HiC/02data/01fastq/EGA
targetdir=/cluster2/home/futing/Project/panCancer/GBM
grep 'EGAD00001010312' ${wkdir}/GBM_meta.txt | \
awk -v sourcedir=$sourcedir -v targetdir=$targetdir 'BEGIN{FS=OFS="\t"}{
	print sourcedir"/"$2"/aligned/",targetdir"/"$1"/"$2"/aligned/"
	print sourcedir"/"$2"/splits/",targetdir"/"$1"/"$2"/splits/"
	print sourcedir"/"$2"/fastq/",targetdir"/"$1"/"$2"/fastq/"
}' > EGA_transfer.txt
# 替换 . 为 _
awk 'BEGIN{FS=OFS="\t"}{gsub("_", ".", $1); print}' EGA_transfer.txt > tmp && mv tmp EGA_transfer.txt

IFS=$'\t'
while read -r oldfile newlk;do
	if [ -L "$newlk" ] && [ -e "$newlk" ]; then
    echo "symlink exists and target exists"
	else
	ln -s $oldfile/* $newlk
	fi
done < "EGA_transfer.txt"

# EGA 的fastq 重新用 srr link 一下
find /cluster2/home/futing/Project/panCancer/GBM/EGAD00001010312 -type l \
 -name '*fastq.gz' -exec bash -c 't=$(readlink -f "$0"); [[ -f "$t" && ! -s "$t" ]] && echo "$0" && rm "$0"' {} \;
IFS=$'\t'
while read -r gse cell enzyme srr;do
	echo "touching ${cell}/${srr}.fastq.gz"
	dir=/cluster2/home/futing/Project/panCancer/GBM/EGAD00001010312
	touch ${dir}/${cell}/fastq/${srr}_R1.fastq.gz
	touch ${dir}/${cell}/fastq/${srr}_R2.fastq.gz

done < <(grep 'EGAD00001010312' /cluster2/home/futing/Project/panCancer/GBM/GBM_down_sim.txt)

# -------------- 05 mcool 部分 ----------------
mcooldir=/cluster2/home/futing/Project/GBM/HiC/02data/04mcool/01GBM
dir=mcool
find /cluster2/home/futing/Project/GBM/HiC/02data/04mcool/01GBM -maxdepth 1 -name '*.mcool' |\
awk -F'/' '{
    cell = $NF
    sub(/\.mcool$/, "", cell)  # 只删除末尾的 .mcool
    gsub(/\./, "_", cell)      # 将剩余的点号替换为下划线
    print cell, $0
}' OFS="\t" > ${dir}_GBM.txt
# 按照cell合并
awk 'NR==FNR{key=$2;data[key]=$0;next}
{
  key=$1
  if(key in data)
	print data[key]"\t"$2
}' <(grep -v 'PRJNA532762' ${wkdir}/GBM_meta.txt) ${dir}_GBM.txt \
| awk -v wkdir=$wkdir -v dir=${dir} 'BEGIN{FS=OFS="\t"}{   #替换路径为$cell与原始的后缀
split($4,a,"/")
file=a[11]
n = split(file, b, ".")
end=b[n]
print $0,wkdir"/"$1"/"$2"/cool/"$2"."end}' | sort -k1 -k2 > mcool_transfer.txt #需要手动把A172加上去

IFS=$'\t'
while read -r gse cell enzyme oldfile newlk;do
	if [ -L "$newlk" ] && [ -e "$newlk" ]; then
    echo "symlink exists and target exists"
	else
	ln -s $oldfile $newlk
	fi
done < "${dir}_transfer.txt"

# =============== 05 cool 部分 ===============

# find /cluster2/home/futing/Project/GBM/HiC/02data/03cool_order -regex '.*/G1_[0-9]+\.cool$'

cooldir=/cluster2/home/futing/Project/GBM/HiC/02data/03cool_order/
find ${cooldir} -name '*.cool' | grep -v '25chr' |\
awk -F'/' -v res=$res '{
    cell = $NF
    sub(/_[^_]*$/, "", cell) #删除最后一个下划线以及之后的所有内容
    gsub(/\./, "_", cell)      # 将剩余的点号替换为下划，因为EGA的文件路径含有.，为了避免问题全改为下划线
    print cell, $0
}' OFS="\t" > ${dir}_GBM.txt
# 按照cell合并
awk 'NR==FNR{key=$2;data[key]=$0;next}
{
  key=$1
  if(key in data)
	print data[key]"\t"$2
}' <(grep -v 'PRJNA532762' ${wkdir}/GBM_meta.txt) ${dir}_GBM.txt \
| awk -v wkdir=$wkdir 'BEGIN{FS=OFS="\t"}{
split($4,a,"/")
file=a[11]
n = split(file, b, "_")
end=b[n]
print $0,wkdir"/"$1"/"$2"/cool/"$2"_"end}' | sort -k1 -k2  > cool_transfer.txt #需要手动把A172加上去

# ln 
IFS=$'\t'
while read -r gse cell enzyme oldfile newlk;do
	if [ -L "$newlk" ] && [ -e "$newlk" ]; then
    echo "symlink exists and target exists"
	else
	ln -s $oldfile $newlk
	fi
done < "${dir}_transfer.txt"

