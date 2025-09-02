avgprofile_hub_summary.bed是/cluster/home/tmp/GBM/HiC/hubgene/new/chip/addID/filtered_GBM_chip.bedpe
和/cluster/home/jialu/genome/gencode.v38.pcg.dedup.tss.bed取交集

代码在/cluster/home/tmp/GBM/HiC/hubgene/new/avg_profile/avy_profile.ipynb
# awk -F '\t' '$7 >2 {print $4}' /cluster/home/tmp/GBM/HiC/hubgene/new/chip/addID/avgprofile_hub_summary.bed \
    # > /cluster/home/tmp/GBM/HiC/hubgene/new/venny_plot/GBM_over2gene.list
# ##维恩图 4个基因
EPAS1
LRP1B
BCL6
CTNND2

awk '$10 == "BCL6" {print $1"\t"$2"\t"$3"\t"$4":"$5"-"$6","$15}' \
    /cluster/home/tmp/GBM/HiC/hubgene/new/chip/addID/filtered_GBM_chip.bedpe   > BCL_GBM_washuloop
awk '$10 == "EPAS1" {print $1"\t"$2"\t"$3"\t"$4":"$5"-"$6","$15}' /cluster/home/tmp/GBM/HiC/hubgene/new/chip/addID/filtered_GBM_chip.bedpe   > EPAS1_GBM_washuloop
awk '$10 == "LRP1B" {print $1"\t"$2"\t"$3"\t"$4":"$5"-"$6","$15}' /cluster/home/tmp/GBM/HiC/hubgene/new/chip/addID/filtered_GBM_chip.bedpe   > LRP1B_GBM_washuloop
awk '$10 == "CTNND2" {print $1"\t"$2"\t"$3"\t"$4":"$5"-"$6","$15}' /cluster/home/tmp/GBM/HiC/hubgene/new/chip/addID/filtered_GBM_chip.bedpe   > CTNND2_GBM_washuloop
awk '{print $1"\t"$2"\t"$3"\t"$4":"$5"-"$6","$15}' /cluster/home/tmp/GBM/HiC/hubgene/new/chip/addID/filtered_GBM_chip.bedpe   > GBM_washuloop


 /cluster/home/tmp/GBM/HiC/hubgene/new/TPM_avg_updated.txt
 