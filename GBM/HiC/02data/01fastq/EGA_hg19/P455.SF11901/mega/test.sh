# awk '{print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t"$6"\t"$7"\t"$8"\t"$9"\t"$10"\t"$11"\t"$12"\t"$13"\t"$14"\t"$15"\t"$16}' /cluster/home/tmp/gaorx/GBM/GBM/P455.SF11901/mega/aligned/merged_nodups1.txt > /cluster/home/tmp/gaorx/GBM/GBM/P455.SF11901/mega/aligned/merged_nodups.txt

# /cluster/home/jialu/4DN_iPSc/pipeline/extra/juicer/scripts/common/mega1.sh \
#     -g hg38 \
#     -d /cluster/home/tmp/gaorx/GBM/GBM/P455.SF11901 \
#     -D /cluster/home/jialu/4DN_iPSc/pipeline/extra/juicer\
#     -s /cluster/home/tmp/EGA/hg38_Arima.txt

#hicConvertFormat -m aligned/inter_30.hic --inputFormat hic --outputFormat cool -o aligned/P455.SF11901.mcool
#/cluster/home/jialu/4DN_iPSc/pipeline/extra/juicer/scripts/common/juicer_tools addNorm aligned/inter_30.hic


file="/cluster/home/tmp/gaorx/GBM/GBM/P455.SF11901"
# echo "Processing $file"
# cd "$file"
# mv mega/aligned/merged_nodups.txt mega/aligned/merged_nodups1.txt
# awk '{print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t"$6"\t"$7"\t"$8"\t"$9"\t"$10"\t"$11"\t"$12"\t"$13"\t"$14"\t"$15"\t"$16}' mega/aligned/merged_nodups1.txt > mega/aligned/merged_nodups.txt

/cluster/home/jialu/4DN_iPSc/pipeline/extra/juicer/scripts/common/mega1.sh \
        -g /cluster/home/jialu/4DN_iPSc/pipeline/ref/hg38/hg38.genome \
        -d "$file" \
        -D /cluster/home/jialu/4DN_iPSc/pipeline/extra/juicer\
        -s /cluster/home/tmp/EGA/hg38_Arima.txt


