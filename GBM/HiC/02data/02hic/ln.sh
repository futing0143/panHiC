#!/bin/bash
cd /cluster/home/futing/Project/GBM/HiC/02data/02hic
top_folder=/cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM

for prefix in 42MGBA GB180 GB182 GB176 GB183 GB238 H4 U251;do
    # 使用find命令递归搜索匹配的文件
    read -r -d '' hic_path < <(find "$top_folder" -type d -name $prefix -print0)
    hic_file=$(find $hic_path -type f -name "inter_30.hic")
    echo -e "\nln -s $hic_file ./GBM/${prefix}.hic"\n
    ln -s $hic_file ./GBM/${prefix}.hic

done 

for prefix in A172 SW1088 U87 U118 U343;do
    # 使用find命令递归搜索匹配的文件
    read -r -d '' hic_path < <(find "/cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/GBM_onedir" -type d -name $prefix -print0)
    hic_file=$(find $hic_path -type f -name "inter_30.hic")
    echo -e "\nln -s $hic_file ./GBM/${prefix}.hic"\n
    ln -s $hic_file ./GBM/${prefix}.hic
done 

ln -s /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/ourdata/onedir/ts543/mega/aligned/inter_30.hic ./GBM/ts543.hic
ln -s /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/ourdata/onedir/ts667/mega/aligned/inter_30.hic ./GBM/ts667.hic
ln -s /cluster/home/futing/Project/GBM/HiC/02data/01fastq/pHGG/mega/aligned/inter_30.hic ./pHGG.hic
ln -s /cluster/home/futing/Project/GBM/HiC/02data/01fastq/NPC_new/aligned/inter_30.hic ./NPC_new.hic
ln -s /cluster/home/futing/Project/GBM/HiC/02data/01fastq/iPSC_new/aligned/inter_30.hic ./iPSC_new.hic
ln -s /cluster/home/futing/Project/GBM/HiC/02data/01fastq/ipsc/onedir/mega/aligned/inter_30.hic ./iPSC.hic
ln -s /cluster/home/futing/Project/GBM/HiC/02data/01fastq/NPC/mega/aligned/NPC.inter_30.hic ./NPC.hic


find /cluster/home/futing/Project/GBM/HiC/02data/01fastq/EGA_re -name 'P*' -type d | while read name;do
    prefix=$(echo "$name" | awk -F'/' '{print $11}')
    hic_file=/cluster/home/futing/Project/GBM/HiC/02data/01fastq/EGA_re/${prefix}/aligned/inter_30.hic
    echo -e "\nln -s $hic_file ./GBM/${prefix##*/}.hic\n"
    ln -s $hic_file ./GBM/${prefix}.hic
done
