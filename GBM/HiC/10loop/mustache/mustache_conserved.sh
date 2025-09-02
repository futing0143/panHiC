#git clone https://github.com/ay-lab/mustache
#cd ~/BioSoft
#conda env create -f environment.yml
#conda activate mustache

#bedpe 是tsv转换的 删掉首行BIN1_CHR	BIN1_START	BIN1_END	BIN2_CHROMOSOME	BIN2_START	BIN2_END	FDR	DETECTION_SCALE

for file in /cluster/home/tmp/GBM/HiC/02data/03cool/10000/*cool; do
    col_name=$(basename "$file" _10000.cool)
    cd /cluster/home/tmp/GBM/HiC/10loop/mustache/10k
    # cooler balance /cluster/home/futing/Project/GBM/HiC/02data/03cool/5000/${i}_5000.cool
	mustache -f $file -pt 0.05 -st 0.8 -r 10kb -norm weight -o ${col_name}_10k_mustache.tsv
    sed '1d' ${col_name}_10k_mustache.tsv > ${col_name}_10k_mustache.bedpe
    rm ${col_name}_10k_mustache.tsv
    #cat ${i}_mustache.bedpe|awk -v T=${i} '{print T"\t"$1"\t"($5+$6-$2-$3)/2}' >> GBMsample_merge_loop_size.txt
    #awk '{print $1"\t"(($2+$6)/2-5000)"\t"(($2+$6)/2+5000)}' ${i}_mustache.bedpe > ${i}_mustache.bed
    #awk '{print $1"\t"$2"\t"$6}' ${i}_mustache.bedpe > ${i}_mustache_edges.bed
done

# ##画loopsize和cmpt关系图   保留最左边和最右边的位点
#awk '{print $1"\t"$2"\t"$6"\t""GBM""\t"$8}' /cluster/home/jialu/GBM/hicnew/GBMmerge_mustache.bed \
#    > /cluster/home/jialu/GBM/hicnew/GBMmerge_mustache_loop.bed



# python3 /cluster/home/jialu/BioSoft/mustache-master/mustache/diff_mustache.py -f1 /cluster/home/futing/Project/GBM/HiC/02data/03cool/5000/GBM_common_5000.cool -f2 /cluster/home/futing/Project/GBM/HiC/02data/03cool/5000/GBMstem_5000.cool -pt 0.05 -pt2 0.1 -o DGCvsGSC -r 5000 -st 0.8
# 处理DGCvsGSC.diffloop1文件并写入到temp_processed
# awk -F'\t' '{printf "%s\t%s\t%d\n", "DGC", $1, int(($5 + $6 - $2 - $3) / 2)}' DGCvsGSC.loop1 > temp_processed
# awk -F'\t' '{printf "%s\t%s\t%d\n", "GSC", $1, int(($5 + $6 - $2 - $3) / 2)}' DGCvsGSC.loop2 >> temp_processed
# mv temp_processed DGCvsGSC_loop_size.txt



