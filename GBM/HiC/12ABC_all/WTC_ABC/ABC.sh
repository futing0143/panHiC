#!/bin/bash
##conda activate macs-py2.7
#macs2 callpeak -t /cluster/home/jialu/GBM/HiC/ABC/atac/bam_files/SRR12055979.rmdup_sorted.bam -n atac_rep1 -f BAM -g hs -p .1 --call-summits --outdir atac/peak 

#Sort narrowPeak file
#bedtools sort -faidx /cluster/share/ref_genome/hg38/assembly/hg38.chrom.sizes -i atac/peak/atac_rep1_peaks.narrowPeak > atac/peak/atac_rep1_peaks.narrowPeak.sorted

#conda activate final-abc-env
#python /cluster/home/jialu/BioSoft/ABC-Enhancer-Gene-Prediction/src/makeCandidateRegions.py --narrowPeak /cluster/home/jialu/GBM/HiC/WTC_ABC/WTC.atac.merge.narrowPeak.sorted.merged --bam  /cluster/home/jialu/GBM/HiC/WTC_ABC/WTC_atac_merge.bam --outDir CandidateRegion --chrom_sizes /cluster/share/ref_genome/hg38/assembly/hg38.chrom.sizes --regions_blocklist /cluster/home/jialu/GBM/HiC/ABC/ENCFF356LFX_blacklist_downfromencode.bed --regions_includelist /cluster/home/jialu/BioSoft/ABC-Enhancer-Gene-Prediction/reference/hg38/RefSeqCurated.170308.bed.CollapsedGeneBounds.hg38.TSS500bp.bed --peakExtendFromSummit 250 --nStrongestPeaks 150000

#python /cluster/home/jialu/BioSoft/ABC-Enhancer-Gene-Prediction/src/compute_powerlaw_fit_from_hic.py --hicDir merge_all_hic/ --outDir merge_all_hic/powerlaw_new/ --maxWindow 1000000 --minWindow 5000 --resolution 5000 --chr all





#awk -F ' ' -v OFS='\t' '{print $1,$2}' /cluster/home/jialu/GBM/HiC/NPC_ABC/NPC_tpm_avg.txt > /cluster/home/jialu/GBM/HiC/NPC_ABC/NPC_tpm_avg1.txt
# python /cluster/home/jialu/BioSoft/ABC-Enhancer-Gene-Prediction/src/run.neighborhoods.py \
# --candidate_enhancer_regions /cluster/home/jialu/GBM/HiC/WTC_ABC/CandidateRegion/WTC.atac.merge.narrowPeak.sorted.merged.candidateRegions.bed \
# --genes /cluster/home/jialu/BioSoft/ABC-Enhancer-Gene-Prediction/reference/hg38/RefSeqCurated.170308.bed.CollapsedGeneBounds.hg38.bed \
# --H3K27ac /cluster/home/jialu/GBM/HiC/WTC_ABC/h3k27ac/bam_files/SRR13720988.rmdup_sorted.bam,/cluster/home/jialu/GBM/HiC/WTC_ABC/h3k27ac/bam_files/SRR13720989.rmdup_sorted.bam \
# --ATAC /cluster/home/jialu/GBM/HiC/WTC_ABC/atac/bam_files/WTCrep1.rmdup_sorted.bam,/cluster/home/jialu/GBM/HiC/WTC_ABC/atac/bam_files/WTCrep2.rmdup_sorted.bam \
# --expression_table IPSC_tpm_avg.txt --chrom_sizes /cluster/home/jialu/BioSoft/ABC-Enhancer-Gene-Prediction/reference/hg38.chrom.size \
# --cellType WTC   --outdir Neighborhoods --qnorm /cluster/home/jialu/BioSoft/ABC-Enhancer-Gene-Prediction/src/EnhancersQNormRef.K562.txt

# python /cluster/home/jialu/BioSoft/ABC-Enhancer-Gene-Prediction/src/juicebox_dump.py \
# --hic_file /cluster/home/jialu/GBM/hicnew/ipsc/onedir/mega/aligned/inter_30.hic \
# --juicebox "java -Xms512m -Xmx2048m -jar /cluster/home/jialu/4DN_iPSc/pipeline/extra/juicer/scripts/common/juicer_tools_1.22.01.jar" 
# --outdir HiC --chromosomes all


python /cluster/home/jialu/BioSoft/ABC-Enhancer-Gene-Prediction/src/compute_powerlaw_fit_from_hic.py \
--hicDir HiC --outDir HiC/powerlaw_new/ --maxWindow 1000000 --minWindow 5000 --resolution 5000 --chr all

python /cluster/home/jialu/BioSoft/ABC-Enhancer-Gene-Prediction/src/predict.py --enhancers Neighborhoods/EnhancerList.txt \
--genes Neighborhoods/GeneList.txt \
--HiCdir HiC \
--chrom_sizes  /cluster/home/jialu/BioSoft/ABC-Enhancer-Gene-Prediction/reference/hg38.chrom.size \
--hic_resolution 5000  --scale_hic_using_powerlaw --threshold .02 --cellType WTC --outdir Predictions  --make_all_putative 


