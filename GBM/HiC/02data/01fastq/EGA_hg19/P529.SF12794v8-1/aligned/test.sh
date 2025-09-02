mv merged_nodups.txt merged_nodups1.txt
awk '{print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t"$6"\t"$7"\t"$8"\t"$9"\t"$10"\t"$11"\t"$12"\t"$13"\t"$14"\t"$15"\t"$16}' merged_nodups1.txt > merged_nodups.txt

/cluster/home/jialu/4DN_iPSc/pipeline/extra/juicer/scripts/common/juicer_tools pre \
-f /cluster/home/tmp/EGA/hg38_Arima.txt \
-s inter_30.txt \
-g inter_30_hists.m \
-q 30 merged_nodups.txt inter_30test.hic hg38
