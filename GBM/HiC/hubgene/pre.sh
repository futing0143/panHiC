#pairToBed -a /cluster/home/jialu/GBM/HiC/peakachu/GBMmerge-peakachu-5kb-loops.0.95.bedpe -b /cluster/home/jialu/GBM/HiC/ABC/ts543_h3k27ac/rose/SRR12056338_all_TESE.bed > E
#pairToBed -a /cluster/home/jialu/GBM/HiC/peakachu/GBMmerge-peakachu-5kb-loops.0.95.bedpe -b /cluster/home/chenglong/reference/pcg_gene_tss_v38.bed |awk '{print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t"$6"\t"$9"\t"$10"\t"$11"\t"$15}' > GBM_G_loop.bedpe
##http://127.0.0.1:6660/notebooks/GBM/HiC/otherGBM/mcoolfile/dchic/DifferentialResult/GBM_vs_3type/fdr_result/pcOri2AB.ipynb



###work: 先用pcg注释，再用chip注释
pairToBed -a /cluster/home/jialu/GBM/hicnew/GBMmerge_mustache_10k_05.bedpe -b /cluster/home/jialu/GBM/HiC/otherGBM/mcoolfile/cgc/gencodev38_gene_PCG.bed |awk '{print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t"$6"\t"$9"\t"$10"\t"$11"\t"$13}' > GBM_musta_10k_05_G.bedpe
pairToBed -a GBM_musta_10k_05_G.bedpe -b /cluster/home/jialu/GBM/HiC/ABC/ts543_h3k27ac/rose/SRR12056338_all_TESE.bed > GBM_musta_10k_05_G_TESE.bedpe
##再用/cluster/home/tmp/GBM/HiC/06compartment/dcHiC_old/DifferentialResult/GBM_vs_3type/fdr_result/pcOri2AB.ipynb中”判断是否在同一个anchor“和“只保留一侧是基因，另一侧是enhancer的情况”两个模块筛选出一侧anchor是基因，另一侧是enhancer的loop
##获得GBM_G_mustache_TESE__final.bedpe
awk '{print $10}' GBM_G_mustache_TESE.bedpe |sort |uniq -c >E_mustache_gene  ##进行统计


###下面的基本不用看，是重复工作，尝试用了peakachu\fithic作为loop输入，ROSE里面的作为super enhancer的鉴定


##either- Report overlaps if either end of A overlaps B. Default
pairToBed -a /cluster/home/jialu/GBM/hicnew/GBMmerge_mustache.bed -b /cluster/home/jialu/GBM/HiC/otherGBM/mcoolfile/cgc/gencodev38_gene_PCG.bed | awk '{print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t"$6"\t"$9"\t"$10"\t"$11"\t"$13}' > GBM_G_mustache.bedpe
pairToBed -a GBM_G_mustache.bedpe -b /cluster/home/jialu/GBM/HiC/ABC/ts543_h3k27ac/rose/SRR12056338_all_TESE.bed > GBM_G_mustache_TESE.bedpe
pairToBed -a /cluster/home/jialu/GBM/HiC/peakachu/GBMmerge-peakachu-5kb-loops.0.95.bedpe -b /cluster/home/jialu/GBM/HiC/ABC/ts543_h3k27ac/rose/SRR12056338_all_TESE.bed > E
pairToBed -a /cluster/home/jialu/GBM/HiC/otherGBM/mcoolfile/fithic/gbm_1e10_merge.bedpe -b /cluster/home/chenglong/reference/pcg_gene_tss_v38.bed |awk '{print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t"$6"\t"$7"\t"$8"\t"$9"\t"$13}' > GBM_G_loop.bedpe
pairToBed -a GBM_G_loop.bedpe -b /cluster/home/jialu/GBM/HiC/ABC/ts543_h3k27ac/rose/SRR12056338_all_TESE.bed > G_loop_TESE.bedpe
pairToBed -a GBM_G_loop.bedpe -b /cluster/home/jialu/GBM/HiC/ABC/ts543_h3k27ac/rose/SRR12056338_SE.bed > G_loop_SE.bedpe
awk '{print $10}' GBM_G_loop.bedpe|sort |uniq -c  >gene

#名字有final的文件都是pcOri2AB.ipynb中那两个模块，改了文件名
awk '{print $10}' G_loop_SE_final.bedpe |sort |uniq -c >SE_gene
awk '{print $10}' G_loop_SE_final.bedpe |sort |uniq -c >SE_gene
awk '{print $10}' G_loop_TESE_final.bedpe |sort |uniq -c >E_gene
awk '{print $10}' G_loop_TESE_final.bedpe |sort |uniq -c >E_gene
awk '{print $10}' GBM_G_loop.bedpe|sort |uniq -c  >gene


#awk -F ' ' -v OFS='\t' '{print $2,$1}'  gene >gene1
#改名gene1为gene
awk -F ' ' -v OFS='\t' '{print $2,$1}'  /cluster/home/jialu/GBM/HiC/otherGBM/mcoolfile/hubgene/gene >/cluster/home/jialu/GBM/HiC/otherGBM/mcoolfile/hubgene/gene1