#因为gsc的几个亚类没有给原始数据 就只能把.hic转为txt
#再用ABC的一个脚本把几个亚类合并成一个
#按各染色体合并成一个txt
#再用juicer转为.hic
cat chrname.list | while read chr
do
    gunzip GSC_avghic/${chr}/${chr}.avg.gz
    awk -v i=$chr 'BEGIN{OFS="\t"}{print 0,i,$1,0,0,i,$2,1,$3}' GSC_avghic/${chr}/${chr}.avg |sort -k 2 -k 3n -k 7n > GSC_avghic/${chr}/${chr}.avg.sort
    cat GSC_avghic/${chr}/${chr}.avg.sort | grep -v nan >>  GSC_avghic.avg.sort.nano
done
/cluster/home/jialu/4DN_iPSc/pipeline/extra/juicer/scripts/common/juicer_tools pre \
GSC_avghic.avg.sort.nano GSC_avghic.avg.hic \
/cluster/home/jialu/BioSoft/ABC-Enhancer-Gene-Prediction/example_chr22/TCGAout/hg38.chrom.size -t tmp/ -r 5000