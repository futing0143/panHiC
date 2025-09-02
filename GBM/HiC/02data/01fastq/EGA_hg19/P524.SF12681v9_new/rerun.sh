
# /cluster/home/Gaoruixiang/software/juicer/scripts/juicer.sh \
# -S chimeric \
# -g hg19 \
# -d . \
# -s Arima \
# -p /cluster/home/Gaoruixiang/software/juicer/restriction_sites/hg19.chrom.sizes \
# -y /cluster/home/Gaoruixiang/software/juicer/restriction_sites/hg19_Arima.txt \
# -z /cluster/home/Gaoruixiang/software/juicer/references/hg19.fa \
# -D /cluster/home/Gaoruixiang/software/juicer

juiceDir="/cluster/home/Gaoruixiang/software/juicer"
site_file="/cluster/home/Gaoruixiang/software/juicer/restriction_sites/hg19_Arima.txt"
outputdir="/cluster/home/tmp/gaorx/GBM/GBM/P524.SF12681v9/aligned"
genomePath="/cluster/home/Gaoruixiang/software/juicer/restriction_sites/hg19.chrom.sizes"
${juiceDir}/scripts/common/juicer_tools pre -f $site_file -s $outputdir/inter_30.txt -g $outputdir/inter_30_hists.m -q 30 $outputdir/merged_nodups_hg19.txt $outputdir/inter_30.hic $genomePath
        