#!/bin/bash


wkdir=/cluster2/home/futing/Project/panCancer/Analysis/conserve/midata/0108/
mkdir -p $wkdir && cd $wkdir

annodir=/cluster2/home/futing/Project/GBM/HiC/09insulation/con_Boun/annotation/
endfix="010850k800k"
for prefix in panCan Ctrl;do
    bed=/cluster2/home/futing/Project/panCancer/Analysis/conserve/midata/0108/bin/${prefix}_${endfix}.bed
    end="${prefix}_${endfix}"

    # CGC TSS
    bedtools intersect -a ${annodir}/Census_tss.bed \
    -b <(tail -n +2 ${bed} | cut -f1-3) \
    -wao > ${wkdir}/CGC/CGC_${end}_all.bed
    awk 'BEGIN{FS=OFS="\t"}$10 ==1' ${wkdir}/CGC/CGC_${end}_all.bed > ${wkdir}/CGC/CGC_${end}.bed #Ctrl: 45/742 panCan: 50/742
    cut -f4 ${wkdir}/CGC/CGC_${end}.bed > ${wkdir}/CGC/CGC_${end}.txt

    # PCG TSS
    PCG=/cluster2/home/futing/ref_genome/hg38_gencode/genebed/gencode.v43.gene.tss/pcg.bed
    bedtools intersect -a <(cut -f1-3,7 $PCG) \
        -b <(tail -n +2 ${bed} | cut -f1-3) -wao | \
        awk 'BEGIN{FS=OFS="\t"}$8 ==1' > ${wkdir}/PCG/PCG_${end}.bed #Ctrl: 1628/20042 panCan: 1610/20042
    cut -f4 ${wkdir}/PCG/PCG_${end}.bed > ${wkdir}/PCG/PCG_${end}.txt
done



# ---- step 2 将 cancer ctrl 对比
# ctrl单独有
for type in CGC PCG;do
    mkdir -p ${wkdir}/${type}
    comm -23  <(sort ${wkdir}/${type}/${type}_Ctrl_${endfix}.txt) <(sort ${wkdir}/${type}/${type}_panCan_${endfix}.txt) > ./${type}/${type}_ctrluniq.txt
    comm -13 <(sort ${wkdir}/${type}/${type}_Ctrl_${endfix}.txt) <(sort ${wkdir}/${type}/${type}_panCan_${endfix}.txt) > ./${type}/${type}_panCanuniq.txt
    comm -12 <(sort ${wkdir}/${type}/{type}_Ctrl_${endfix}.txt) <(sort ${wkdir}/${type}/${type}_panCan_${endfix}.txt) > ./${type}/${type}_comm.txt
done 


# ---- step3 cancer ctrl bin预处理
for type in panCan Ctrl;do
    cut -f1-3 ${wkdir}/bin/${type}_${endfix}.bed \
        | awk 'BEGIN{FS=OFS="\t"}{print $1"_"$2"_"$3}' \
        > ${wkdir}/bin/${type}_${endfix}bin_id.bed
done
