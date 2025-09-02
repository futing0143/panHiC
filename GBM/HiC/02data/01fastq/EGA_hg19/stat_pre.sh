/cluster/home/jialu/4DN_iPSc/pipeline/extra/juicer/scripts/common/statistics.pl -q 1 -o /cluster/home/tmp/gaorx/GBM/GBM/mega1/inter.txt -s /cluster/home/tmp/EGA/hg38_Arima.txt -l XXXX /cluster/home/tmp/gaorx/GBM/GBM/mega/aligned/merged_nodups.txt
echo "q1 is done"
/cluster/home/jialu/4DN_iPSc/pipeline/extra/juicer/scripts/common/statistics.pl -q 30 -o /cluster/home/tmp/gaorx/GBM/GBM/mega1/inter_30.txt -s /cluster/home/tmp/EGA/hg38_Arima.txt -l XXXX /cluster/home/tmp/gaorx/GBM/GBM/mega/aligned/merged_nodups.txt 
echo "q30 is done"
/cluster/home/jialu/4DN_iPSc/pipeline/extra/juicer/scripts/common/juicer_tools pre -f /cluster/home/tmp/EGA/hg38_Arima.txt -s /cluster/home/tmp/gaorx/GBM/GBM/mega1/inter_30.txt -g /cluster/home/tmp/gaorx/GBM/GBM/mega1/inter_30_hists.m -q 30 /cluster/home/tmp/gaorx/GBM/GBM/mega/aligned/merged_nodups.txt /cluster/home/tmp/gaorx/GBM/GBM/mega1/inter_30.hic hg38 
echo "hic is done"        