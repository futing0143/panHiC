#!/bin/bash

# 合并所有的GBM不同软件鉴定的loop，保留大于两个软件、大于2个样本的loop
# by Futing at Feb17

top_dir=/cluster/home/futing/Project/GBM/HiC/10loop
flank=5000
name=GBM
date

mkdir ${top_dir}/consensus/mid/${name}
cd ${top_dir}/consensus/mid/${name}

# #01 preprocess
peakachu=${top_dir}/peakachu/10000/results/${name}-peakachu-10kb-loops.0.95.bedpe
mustache=${top_dir}/mustache/10000/${name}_10kb_mustache.bedpe
cooldots=${top_dir}/cooltools/results/${name}/dots.10000.tsv
homer=${top_dir}/homer/results/${name}/10000/${name}.loop.2D.bed
fithic=${top_dir}/fithic/outputs/10000/${name}.intraOnly/${name}.merge.bed.gz
hiccups=/cluster/home/futing/Project/GBM/HiC/02data/02hic/scripts/GBM_hr/GBM_1030gpu_loops/postprocessed_pixels_10000.bedpe
awk 'BEGIN{OFS="\t"} {print $1"_"$2+5000"_"$5+5000,"peakachu"}' $peakachu | sort | uniq > ${name}_peakachu_str.bed
awk 'BEGIN{OFS="\t"} {print $1"_"$2+5000"_"$5+5000,"mustache"}' $mustache | sort | uniq > ${name}_mustache_str.bed
awk 'BEGIN{OFS="\t"} NR > 1 {print $1"_"$2+5000"_"$5+5000,"cooldots"}' $cooldots | sort | uniq > ${name}_cooldots_str.bed
awk 'BEGIN{OFS="\t"} NR > 2 { if ($1 !~ /^chr/) { print "chr"$1"_"$2+5000"_"$5+5000,"hiccups"} else { print $1"_"$2+5000"_"$5+5000,"hiccups"} }' $hiccups | sort | uniq > ${name}_hiccups_str.bed
zcat $fithic | awk 'BEGIN{OFS="\t"} NR >1 {print $1"_"int($2)"_"int($4),"fithic"}' | sort | uniq > ${name}_fithic_str.bed
sort -k1,1d -k2,2n -k4,4d -k5,5n $homer | awk 'BEGIN{OFS="\t"} {print $1"_"$2+5000"_"$5+5000,"homer"}' > ${name}_homer_str.bed

# 02 merge
/cluster/home/futing/Project/GBM/HiC/10loop/consensus/prepro/01mergev2.sh ${name}.bed \
    ${name}_peakachu_str.bed ${name}_mustache_str.bed ${name}_cooldots_str.bed \
    ${name}_hiccups_str.bed ${name}_homer_str.bed   #${name}_fithic_str.bed 

# 03 merge loops
# 将锚点相近的合并在一起
sh /cluster/home/futing/Project/GBM/HiC/10loop/consensus/prepro/02merge_loops.sh ${name}.bed

# 04 挑选那些共同loop数大于等于2的loop
echo "Filter loops occur twice for $name..."
cd /cluster/home/futing/Project/GBM/HiC/10loop/consensus/mid/${name}
awk 'NR ==1{print $0}
NR>1 && $NF >= 2{print $0}' ${name}_merged.bed > ${name}_over2.bed

# --------------------------- !!! qc !!! ------------------------
# 05 qc 计算loop数、交集数、交集比例、unique loop数、looppersoft、over2loops数、loop大小
# 第一个文件一定要是软件数最大的文件，因为会读取第一个文件的列名作为表头

files=()
file=/cluster/home/futing/Project/GBM/HiC/10loop/consensus/mid/${name}/${name}_merged.bed
files+=("$file")


qc_result=/cluster/home/futing/Project/GBM/HiC/10loop/consensus/result/GBM
# sh /cluster/home/futing/Project/GBM/HiC/10loop/consensus/scripts/03interall.sh \
#     ${qc_result}/nloop_all.txt "$file" 
sh /cluster/home/futing/Project/GBM/HiC/10loop/consensus/scripts/03inter2.sh \
    ${qc_result}/inter2.txt "$file" 
sh /cluster/home/futing/Project/GBM/HiC/10loop/consensus/scripts/03interp.sh \
    ${qc_result}/inter2p.txt "$file"
sh /cluster/home/futing/Project/GBM/HiC/10loop/consensus/scripts/03nloopv2.sh \
    ${qc_result} ${name}

# 06 将loop mid pos 拓宽为 loop bedpe
# 这个输出是用于 juicebox
output=/cluster/home/futing/Project/GBM/HiC/10loop/consensus/mid/GBM/GBM_over2.bedpe
echo -e "#chr1\tx1\tx2\tchr2\ty1\ty2" > $output
awk 'BEGIN{OFS="\t"} NR>1 {print $1, $2-5000, $2+5000, $1,$3-5000, $3+5000}' GBM_over2.bed >> $output

# 存flank bedpe 在merged文件夹里
filedir=/cluster/home/futing/Project/GBM/HiC/10loop/consensus/mid/GBM/
outdir=/cluster/home/futing/Project/GBM/HiC/10loop/consensus/merged/

awk 'BEGIN{OFS="\t"}NR==1 {print "chr1","start1","end1","chr2","start2","end2","Freq"}
	 NR>1 {print $1, $2-5000, $2+5000, $1,$3-5000, $3+5000,$NF}' ${filedir}/GBM_over2.bed > $outdir/flank0k/GBM_flank0k.bedpe
awk 'BEGIN{OFS="\t"}NR==1 {print "chr1","start1","end1","chr2","start2","end2","Freq"}
	 NR>1 {print $1, $2-15000, $2+15000, $1,$3-15000, $3+15000,$NF}' ${filedir}/GBM_over2.bed > $outdir/flank1k/GBM_flank1k.bedpe

awk 'BEGIN{OFS="\t"}NR>1 {print $1, $2-5000, $2+5000, $1,$3-5000, $3+5000,$NF}' \
	${filedir}/GBM_over2.bed > $outdir/flank0k/GBM_flank0k.bedpe



