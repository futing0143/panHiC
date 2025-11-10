#!/bin/bash

dir=$1
reso=${2:-5000} # reso, default 5000
hicfile=${dir}/aligned/inter_30.hic
out=${dir}/anno/fithic/${reso}/biasPerLocus/bias_juicer_${reso}.txt

cd ${dir}/aligned/
IFS=$'\t'
while read chr len;do
	
    # 计算该染色体共有多少个bin（向下取整）
    nbin=$((len / reso + 1 ))
    
    # 生成第二列坐标（从0开始，步长为reso）
   	seq $((reso / 2)) ${reso} $(( nbin * reso - reso / 2 )) > tmp_pos.txt


    # 获取对应染色体的KR归一化向量
    java -jar /cluster2/home/futing/software/juicer_CPU/scripts/common/juicer_tools.jar \
        dump norm KR ${hicfile} ${chr} BP ${reso} | tail -n +3 > tmp_bias.txt

    # paste 合并三列：chr + 位置 + KR值
    paste <(yes ${chr} | head -n ${nbin}) tmp_pos.txt tmp_bias.txt >> ${out}

    # 清理临时文件
    rm tmp_pos.txt tmp_bias.txt
done < "/cluster2/home/futing/ref_genome/hg38.genome"

gzip $out
