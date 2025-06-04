#!/bin/bash
res=$1
name=$2
mega=${3:-no}
hic_dir=/cluster/home/futing/Project/GBM/HiC/02data/01fastq/
source /cluster/home/futing/miniforge-pypy3/etc/profile.d/conda.sh
conda activate homer


mkdir -p /cluster/home/futing/Project/GBM/HiC/10loop/homer/results/${name}
cd /cluster/home/futing/Project/GBM/HiC/10loop/homer/results/${name}

# 01 hic 2 homer

if [ -f ${name}_fil.homer ];then
    echo "${name}.homer exists, skip..."
else
    if [ $mega == "yes" ];then
        dir=$(find -L ${hic_dir} -name ${name} -type d)
        echo -e "Using mega file: ${dir}/mega/aligned/merged_nodups.txt"
        sh /cluster/home/futing/Project/GBM/HiC/02data/05file_transform/hic2homer.sh \
            ${dir}/mega/aligned/merged_nodups.txt $name
    else
        if [[ $name =~ ^P.*\.SF.*$ ]];then
            dir=$(find -L ${hic_dir}/EGA -name ${name} -type d)
            echo -e "Using hic file: ${dir}/aligned/merged_nodups.txt"
            sh /cluster/home/futing/Project/GBM/HiC/02data/05file_transform/hic2homer.sh \
                ${dir}/aligned/merged_nodups.txt $name
        else
            dir=$(find -L ${hic_dir} -name ${name} -type d)
            echo -e "Using hic file: ${dir}/aligned/merged_nodups.txt"
            sh /cluster/home/futing/Project/GBM/HiC/02data/05file_transform/hic2homer.sh \
                ${dir}/aligned/merged_nodups.txt $name
        fi
    fi
fi

# 02 make tag directory
if [ -d ./TagDir ];then
    echo "TagDir exists, skip..."
else
    echo -e "------------ makeTagDirectory TagDir/ -format HiCsummary ${name}_fil.homer -tbp 1 -----------"
    makeTagDirectory TagDir -format HiCsummary ./${name}_fil.homer -tbp 1
fi

# 03 find TADs and loops
win=$((res * 3))

if [ -f ./TagDir/TagDir.tad.2D.bed ];then
    echo "${name}.log exists, skip..."
else
    echo -e "------------- findTADsAndLoops.pl find TagDir/ -cpu 10 -res ${res} -window ${win} -genome hg38 -p /cluster/home/futing/software/homer/data/badRegions.bed"

    findTADsAndLoops.pl find TagDir/ -cpu 10 -res ${res} \
        -window ${win} -genome hg38 \
        -p /cluster/home/futing/software/homer/data/badRegions.bed
fi

# 04 mv TAD andl loops files
mkdir ${res}
find TagDir/ -name "TagDir*" -type f -exec mv {} ./${res}/ \;
rename TagDir ${name} ${res}/*
ls -l ${res}

if [ $? -eq 0 ]; then
    echo -e "Homer finished successfully for ${name} at ${res} resolution!!!"
else
    echo "***! Problem while running Homer";
    exit 1
fi