#!/bin/bash

name=$1
reso=$2
ischr=${3}

mkdir -p  /cluster/home/futing/Project/GBM/HiC/08TAD/OnTAD/${reso}
cd /cluster/home/futing/Project/GBM/HiC/08TAD/OnTAD/${reso}
filedir=/cluster/home/futing/Project/GBM/HiC/02data/02hic
source /cluster/home/futing/miniforge-pypy3/etc/profile.d/conda.sh
conda activate OnTAD
hicfile=$(find /cluster/home/futing/Project/GBM/HiC/02data/02hic/ -name ${name}.hic)

if [ -f $hicfile ];then
    echo -e "hicfile: ${hicfile} exists.\n"
else
    echo -e "hicfile: ${hicfile} does not exist.\n"
    exit 1
fi

mkdir -p ${name}
cd ${name}
if [ -z $ischr ];then
	# 每个染色体单独运行OnTAD，chr开头的HiC
    while IFS=$'\t' read -r chr length;do
        echo "chr: ${chr}, length: ${length}"
        /cluster/home/futing/software/OnTAD-master/src/OnTAD \
            ${hicfile} \
            -bedout ${chr} ${length} ${reso} \
            -o ./${name}_${chr} >> ./${name}.log

        awk -v chrn=$chr -v res=$reso 'BEGIN{FS=OFS="\t"}{print chrn,$1*res,$2*res,$3,$4,$5}' ${name}_${chr}.tad >> ${name}.bed
    done < "/cluster/home/futing/ref_genome/hg38.genome"
else
    while IFS=$'\t' read -r chr length;do
        echo "chr: ${chr}, length: ${length}"
        /cluster/home/futing/software/OnTAD-master/src/OnTAD \
            ${hicfile} \
            -bedout ${chr} ${length} ${reso} \
            -o ./${name}_${chr} >> ./${name}.log
        awk -v chrn=$chr -v res=$reso 'BEGIN{FS=OFS="\t"}{print "chr"chrn,$1*res,$2*res,$3,$4,$5}' ${name}_${chr}.tad >> ${name}.bed
    done < "/cluster/home/futing/ref_genome/hg38_24_nochr.chrom.sizes"
fi

if [ -d /cluster/home/futing/Project/GBM/HiC/08TAD/OnTAD/result/${reso} ];then
    continue
else
    mkdir -p /cluster/home/futing/Project/GBM/HiC/08TAD/OnTAD/result/${reso}
fi

# 整理OnTAD的输出，转变为 bedpe 格式
awk -v res=$reso 'BEGIN{FS=OFS="\t"}{print $1,$2,$2+res,$1,$3,$3+res,$4,$5}' \
        /cluster/home/futing/Project/GBM/HiC/08TAD/OnTAD/${reso}/${name}/${name}.bed \
		> /cluster/home/futing/Project/GBM/HiC/08TAD/OnTAD/result/${reso}/${name}.bed

# 检查状态
if [ $? -eq 0 ];then
    echo -e "OnTAD for ${name} done!!!\n"
    echo "${name}" >> /cluster/home/futing/Project/GBM/HiC/08TAD/OnTAD/done_${reso}.txt
else
    echo -e "OnTAD for ${name} failed.\n"
fi

