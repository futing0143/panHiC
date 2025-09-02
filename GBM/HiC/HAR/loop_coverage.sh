#!/bin/bash

loopdir=/cluster/home/futing/Project/GBM/HiC/10loop/consensus/merged/flank0k
outdir=/cluster/home/futing/Project/GBM/HiC/HAR/loop_coverage
# 计算 loop anchor 的覆盖率

sort -k1,1d /cluster/home/futing/ref_genome/hg38.genome > hg38.bed
for i in GBM NPC NHA iPSC;do
	# 01 先计算每个染色体的anchor长度
	awk '{print $1"\t"$2"\t"$3; print $4"\t"$5"\t"$6}' $loopdir/${i}_flank0k.bedpe | 
	sort -k1,1 -k2,2n | 
	bedtools merge | 
	awk '{print $1"\t"($3-$2)}' | 
	datamash -g 1 sum 2 count 2 > ${outdir}/${i}_coverage.txt

	# 02 合并染色体长度
	sort -k1,1d ${outdir}/${i}_coverage.txt > \
		${outdir}/${i}.tmp

	join -1 1 -2 1 ${outdir}/${i}.tmp \
		hg38.bed \
		> ${outdir}/${i}_coverage.txt
	
	# 算比例
	awk '{
		if ($4 != 0) {
		ratio = $2 / $4;
		} else {
		ratio = 0;  # 避免除以零错误
		}
		print $0 "\t" ratio;
	}' ${outdir}/${i}_coverage.txt > \
		${outdir}/${i}_coverage_final.txt
	
	mv ${outdir}/${i}_coverage_final.txt ${outdir}/${i}_coverage.txt
	rm coverage/${i}.tmp
done

# ---- 合并四个文件 -----
# 提取第一列和第五列（比列）
output_file="${outdir}/loop_overlap_final.txt"
output_file="${outdir}/loop_overlap_length.txt"
# 提取每个文件的第一列和第五列，并保存到临时文件
echo -e "chr\tGBM\tNHA\tNPC\tiPSC" > $output_file
for i in GBM NHA NPC iPSC; do
	# $2是长度 $5是比例
	awk '{print $1 "\t" $5}' ${outdir}/${i}_coverage.txt > \
	${outdir}/${i}_col1_col5.txt
done

# 使用 paste 按列合并文件
paste ${outdir}/GBM_col1_col5.txt \
      ${outdir}/NHA_col1_col5.txt \
      ${outdir}/NPC_col1_col5.txt \
      ${outdir}/iPSC_col1_col5.txt | \
  awk '{
    # 提取第一列和每个文件的第二列（第五列）
    printf "%s\t%s\t%s\t%s\t%s\n", $1, $2, $4, $6, $8;
  }' >> "$output_file"

# 清理临时文件
rm ${outdir}/*_col1_col5.txt