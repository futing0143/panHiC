#!/bin/bash
###下载https://github.com/ay-lab/dcHiC
# Technical Specifications / Errors To Check模块的hg38.refGene.gtf.gz；hg38.fa来自ref_genome；chrom.sizes来自genemo；cytoBand.txt.gz来自第一次的log文件
###对cytoBand.txt.gz和hg38.refGene.gtf.gz  解压>
#grep -E '^chr([1-9]|1[0-9]|2[0-2]|X)\b' cytoBand.txt >cytoBand.txt1 再压缩改名


##预处理
cd /cluster/home/futing/Project/GBM/HiC/06compartment/dcHiC/preprocess
top_folder=/cluster/home/futing/Project/GBM/HiC/02data/03cool/100000
source activate /cluster/home/futing/anaconda3/envs/dchic
cat /cluster/home/futing/Project/GBM/HiC/02data/04mcool/name.txt | while read prefix;do
    # 使用find命令递归搜索匹配的文件
    read -r -d '' mcool_file < <(find "$top_folder" -type f -name "${prefix}_100000.cool" -print0)
    echo -e "\nmcool_file: $mcool_file...\n"
    python /cluster/home/futing/software/dcHiC/utility/preprocess.py -input cool \
    -file $mcool_file -genomeFile /cluster/home/futing/ref_genome/hg38_24.chrom.sizes \
    -res 100000 -prefix ${prefix}

done

##awk '{print $1"_100000.matrix""\t"$1"_100000_abs.bed""\t"$1"\t""GBM"}' /cluster/home/tmp/GBM/HiC/02data/04mcool/name.txt >input.txt ##并将P开头的第三列.改成_。生成_PCA 文件夹的名字是第三列

###生成_PCA 文件夹
Rscript /cluster/home/jialu/biosoft/dcHiC-master/dchicf.r --file input.txt --pcatype cis --dirovwt T 
Rscript /cluster/home/jialu/biosoft/dcHiC-master/dchicf.r --file input.txt --pcatype select --dirovwt T --genome hg38 


###生成DifferentialResult/GBM_vs_3type 文件夹
#Rscript /cluster/home/jialu/biosoft/dcHiC-master/dchicf.r --file input.txt --pcatype analyze --dirovwt T --diffdir diff
#Rscript /cluster/home/jialu/biosoft/dcHiC-master/dchicf.r --file input.txt  --pcatype subcomp --dirovwt T --diffdir diff
#Rscript /cluster/home/jialu/biosoft/dcHiC-master/dchicf.r --file input.txt  --pcatype viz --diffdir diff --genome hg38 
#Rscript /cluster/home/jialu/biosoft/dcHiC-master/dchicf.r --file input.txt --pcatype enrich --genome hg38  \
#    --diffdir diff --exclA F --region anchor --pcgroup pcQnm --interaction intra --pcscore F --compare F
