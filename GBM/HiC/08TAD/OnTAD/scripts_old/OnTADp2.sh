#!/bin/bash

# 这个脚本用于无chr的hic文件的TAD检测   
cd /cluster/home/futing/Project/GBM/HiC/08TAD/OnTAD/result
filelist=$1
filedir=$2
source /cluster/home/futing/miniforge-pypy3/etc/profile.d/conda.sh
conda activate OnTAD
#source activate /cluster/home/futing/miniforge-pypy3/envs/OnTAD

cat ${filelist} | while read name;do
    hicfile=${filedir}/${name}.hic
    echo -e "hicfile: ${hicfile}...\n"
    mkdir -p ${name}
    cd ${name}
    
    rm ${name}.bed
    while IFS=$'\t' read -r chr length;do
        echo "chr: ${chr}, length: ${length}"
        /cluster/home/futing/software/OnTAD-master/src/OnTAD \
            ${hicfile} \
            -bedout ${chr} ${length} 10000 \
            -o ./${name}_${chr} >> ./${name}.log
        awk -v chrn=$chr 'BEGIN{FS=OFS="\t"}{print "chr"chrn,$1*10000,$2*10000,$3,$4,$5}' ${name}_${chr}.tad >> ${name}.bed
        
        
    done < "/cluster/home/futing/ref_genome/hg38_24_nochr.chrom.sizes"

    # merge all bed files

    cd ..
done

cat /cluster/home/futing/Project/GBM/HiC/08TAD/OnTAD/name_GBMp2.txt | while read line;do
    ls -l /cluster/home/futing/Project/GBM/HiC/08TAD/OnTAD/10000/${line}/${line}.bed
    awk 'BEGIN{FS=OFS="\t"}{print $1,$2,$2+10000,$1,$3,$3+10000,$4,$5}' \
        /cluster/home/futing/Project/GBM/HiC/08TAD/OnTAD/10000/${line}/${line}.bed \
        > /cluster/home/futing/Project/GBM/HiC/08TAD/OnTAD/result/10000/${line}.bed
done