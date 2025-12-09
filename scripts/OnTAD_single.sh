#!/bin/bash


dir=$1
reso=${2:-50000} # 默认分辨率为50000
ischr=${3:-}
name=$(basename ${dir})

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

module load gcc/12.3.0
JUICER_JAR="/cluster2/home/futing/software/juicer_CPU/scripts/common/juicer_tools.jar"
echo "Checking chromosome naming convention for OnTAD..."
check_output=$(java -Xms4G -jar ${JUICER_JAR} dump norm VC ${hicfile} chr1 BP ${reso} 2>&1 || true)

if [[ "$check_output" == *"Invalid chromosome"* ]]; then
    echo -e "Detected style: No 'chr' (e.g., 1, 2...)\n"
    genome_file="/cluster2/home/futing/ref_genome/hg38_24_nochr.chrom.sizes"
    add_prefix="chr"
else
    echo -e "Detected style: With 'chr' (e.g., chr1, chr2...)\n"
    genome_file="/cluster2/home/futing/ref_genome/hg38.genome"
    add_prefix=""
fi

while IFS=$'\t' read -r chr length; do
    echo "Processing chr: ${chr}, length: ${length}"
    
    # 运行 OnTAD
    /cluster2/home/futing/software/OnTAD-master/src/OnTAD \
        ${hicfile} \
        -bedout ${chr} ${length} ${reso} \
        -o ./${name}_${chr} >> ./${name}.log

    # 运行 AWK 处理数据
    # 通过 -v p="${add_prefix}" 将前缀传入 awk
    # 如果是 no-chr 模式，p="chr"，结果就是 "chr1"
    # 如果是 chr 模式，p=""，结果也是 "chr1"
    awk -v p="${add_prefix}" -v chrn="${chr}" -v res="${reso}" \
        'BEGIN{FS=OFS="\t"}{print p chrn, $1*res, $2*res, $3, $4, $5}' \
        ${name}_${chr}.tad >> ${name}.bed

done < "${genome_file}"

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

