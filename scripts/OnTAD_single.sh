#!/bin/bash


dir=$1
reso=${2:-50000} # 默认分辨率为50000
ischr=${3:-}
name=$(awk -F '/' '{print $NF}' <<< ${dir})

mkdir -p ${dir}/anno/OnTAD/
cd ${dir}/anno/OnTAD
source activate ~/miniforge3/envs/OnTAD
hicfile=${dir}/aligned/inter_30.hic

if [ -f $hicfile ];then
    echo -e "hicfile: ${hicfile} exists.\n"
else
    echo -e "hicfile: ${hicfile} does not exist.\n"
    exit 1
fi


if [ -z $ischr ];then
	# 每个染色体单独运行OnTAD，chr开头的HiC
    while IFS=$'\t' read -r chr length;do
        echo "chr: ${chr}, length: ${length}"
        /cluster2/home/futing/software/OnTAD-master/src/OnTAD \
            ${hicfile} \
            -bedout ${chr} ${length} ${reso} \
            -o ./${name}_${chr} >> ./${name}.log

        awk -v chrn=$chr -v res=$reso 'BEGIN{FS=OFS="\t"}{print chrn,$1*res,$2*res,$3,$4,$5}' ${name}_${chr}.tad >> ${name}.bed
    done < "/cluster2/home/futing/ref_genome/hg38.genome"
else
    while IFS=$'\t' read -r chr length;do
        echo "chr: ${chr}, length: ${length}"
        /cluster2/home/futing/software/OnTAD-master/src/OnTAD \
            ${hicfile} \
            -bedout ${chr} ${length} ${reso} \
            -o ./${name}_${chr} >> ./${name}.log
        awk -v chrn=$chr -v res=$reso 'BEGIN{FS=OFS="\t"}{print "chr"chrn,$1*res,$2*res,$3,$4,$5}' ${name}_${chr}.tad >> ${name}.bed
    done < "/cluster2/home/futing/ref_genome/hg38_24_nochr.chrom.sizes"
fi

# 整理OnTAD的输出，转变为 bedpe 格式
awk -v res=$reso 'BEGIN{FS=OFS="\t"}{print $1,$2,$2+res,$1,$3,$3+res,$4,$5}' \
        ./${name}.bed \
		> ${name}_${reso}.bed

# 检查状态
if [ $? -eq 0 ];then
    echo -e "OnTAD for ${name} done!!!\n"
else
    echo -e "OnTAD for ${name} failed.\n"
fi

