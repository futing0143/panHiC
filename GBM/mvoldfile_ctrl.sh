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
done < <(cut -f1-2 ${wkdir}/GBM_ctrl_sim.txt | sort -u)

# ============= 02 处理 fastq splits align ============
# --------- part 1 fastq
old_dir=/cluster2/home/futing/Project/GBM/HiC/02data/01fastq/Ctrl

# 没有 EGA 的部分
sed -i 's/\r$//' ${wkdir}/GBM_ctrl_sim.txt

awk -v wkdir="$wkdir" 'BEGIN{FS=OFS="\t"}{
    line = $1 OFS $2 OFS $3 OFS $4
    print line, wkdir"/"$1"/"$2"/fastq/"$4"_R1.fastq.gz"
    print line, wkdir"/"$1"/"$2"/fastq/"$4"_R2.fastq.gz"
}' ${wkdir}/GBM_ctrl_sim.txt > tmp

# 02-2 构建旧文件的文件列表
find "$old_dir" -type f -name '*fastq.gz' \
| awk -F'/' '{
    # 默认 cell 是倒数第三段
    cell = $(NF-2)

    # 如果倒数第三段是 rep1，则 cell 用倒数第四段
    if (cell == "rep1") {
        cell = $(NF-3)
    }
    # 文件名部分 SRR25569743_R2.fastq.gz → 提取 SRR25569743
    split($NF, a, "_")
    srr = a[1]
    split(srr, b, ".")
    clsrr = b[1]

    print cell, clsrr, $0
}' OFS="\t" | grep -Ev 'sra|Oligo|OPC' \
| awk '{
# --- 3. 替换 Cell 名称 ---
    # $1 是 cell name 列
    if ($1 ~ /^astro/) $1="NHA";      # 匹配以 astro 开头
    else if (tolower($1) ~ /^ipsc/) $1="iPSC"; # 匹配以 iPSC 开头，不区分大小写
    else if ($1 ~ /^NPC/) $1="NPC";     # 匹配以 NPC 开头

    print
}' OFS="\t"  > fastq_Ctrl.txt


# 02-3 按照 cell srr合并
awk 'NR==FNR{key=$2"\t"$4; data[key]=$0; next}
{
  key=$1"\t"$2
  if(key in data)
     print data[key]"\t"$3
}' tmp fastq_Ctrl.txt  > fastq_ctrl_transfer.txt
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
}' OFS="\t" fastq_ctrl_transfer.txt > tmp && mv tmp fastq_ctrl_transfer.txt

# 02-4 ln !
while read -r gse cell enzyme srr newlk oldfile;do
	if [ -L "$newlk" ] && [ -e "$newlk" ]; then
    echo "symlink exists and target exists"
	else
	ln -s $oldfile $newlk
	fi
done < "fastq_ctrl_transfer.txt"



# ---------- part 2 splits align
# 因为重复的cell name 太多，所以从fastq中直接处理
awk -F'\t' '{
    # 提取第 1, 2, 4, 5, 6 列
    # 原始文件格式：
    # $1            $2    $3    $4         $5                                                                                                   $6
    # PRJNA532762   NHA   MboI  SRR8893590 /cluster2/home/futing/Project/panCancer/GBM/PRJNA532762/NHA/fastq/SRR8893590_R1.fastq.gz /cluster2/home/futing/Project/GBM/HiC/02data/01fastq/Ctrl/astro2/fastq/SRR8893590_R1.fastq.gz

    # 对第 5 列（$5）进行替换：将 '/fastq' 及后面的内容替换为 '/splits'
    # 使用 gsub 函数进行全局替换
    path5 = $5
    gsub(/\/fastq\/.*/, "/splits", path5)

    # 对第 6 列（$6）进行替换：将 '/fastq' 及后面的内容替换为 '/splits'
    path6 = $6
    gsub(/\/fastq\/.*/, "/splits", path6)

    # 打印结果：$1, $2, $3, 替换后的 $5, 替换后的 $6
    print $1, $2, $3, path5, path6
}' OFS="\t" "fastq_ctrl_transfer.txt" | sort -u -k2 > splits_ctrl_transfer.txt
find /cluster2/home/futing/Project/GBM/HiC/02data/01fastq/Ctrl -type d -name 'aligned'

# ln !
IFS=$'\t'
while read -r gse cell enzyme newlk oldfile;do
	if [ -L "$newlk" ] && [ -e "$newlk" ]; then
    echo "symlink exists and target exists"
	else
	ln -s $oldfile/* $newlk/
	fi
done < "${dir}_ctrl_transfer.txt"

# -------------- 05 mcool 部分 ----------------
mcooldir=/cluster2/home/futing/Project/GBM/HiC/02data/04mcool/Control
dir=mcool
find ${mcooldir} -maxdepth 1 -name '*.mcool' |\
awk -F'/' '{
    cell = $NF
    sub(/\.mcool$/, "", cell)  # 只删除末尾的 .mcool
    gsub(/\./, "_", cell)      # 将剩余的点号替换为下划线
    print cell, $0
}' OFS="\t" > ${dir}_ctrl.txt
# 太混乱了，手动匹配

IFS=$'\t'
while read -r gse cell enzyme newlk oldfile;do
	if [ -L "$newlk" ] && [ -e "$newlk" ]; then
    echo "symlink exists and target exists"
	else
	ln -s $oldfile $newlk
	fi
done < "${dir}_ctrl.txt"

# =============== 05 cool 部分 ===============

# find /cluster2/home/futing/Project/GBM/HiC/02data/03cool_order -regex '.*/G1_[0-9]+\.cool$'

cooldir=/cluster2/home/futing/Project/GBM/HiC/02data/03cool_order/
dir=cool
find ${cooldir} -name '*.cool' | grep -v '25chr' |\
awk -F'/' -v res=$res '{
    cell = $NF
    sub(/_[^_]*$/, "", cell) #删除最后一个下划线以及之后的所有内容
    gsub(/\./, "_", cell)      # 将剩余的点号替换为下划，因为EGA的文件路径含有.，为了避免问题全改为下划线
    print cell, $0
}' OFS="\t" | grep -v -w -F -f <(cut -f2 ${wkdir}/GBM_meta.txt) |\
 grep -Ev 'OPC|pHGG|ts543|ts667|A172|\/GBM\_' | sort -k1 > ${dir}_ctrl.txt

# 按照cell合并
awk 'NR==FNR{key=$4;data[key]=$0;next}
{
  key=$1
  if(key in data)
	print data[key]"\t"$2
}' ${wkdir}/GBM_ctrl_meta.txt ${dir}_ctrl.txt \
| awk -v wkdir=$wkdir 'BEGIN{FS=OFS="\t"}{
split($5,a,"/")
file=a[11]
n = split(file, b, "_")
end=b[n]

print $0,wkdir"/"$1"/"$2"/cool/"$2"_"end}' | sort -k1 -k2 > cool_ctrl_transfer.txt #需要手动把A172加上去

# ln 
IFS=$'\t'
while read -r gse cell enzyme oldname oldfile newlk;do
	if [ -L "$newlk" ] && [ -e "$newlk" ]; then
    echo "symlink exists and target exists"
	else
	ln -s $oldfile $newlk
	fi
done < "${dir}_ctrl_transfer.txt"

