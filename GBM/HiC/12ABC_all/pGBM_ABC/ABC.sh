#!/bin/bash
##conda activate macs-py2.7
#macs2 callpeak -t /cluster/home/jialu/GBM/HiC/ABC/atac/bam_files/SRR12055979.rmdup_sorted.bam -n atac_rep1 -f BAM -g hs -p .1 --call-summits --outdir atac/peak 

#Sort narrowPeak file
#bedtools sort -faidx /cluster/share/ref_genome/hg38/assembly/hg38.chrom.sizes -i atac/peak/atac_rep1_peaks.narrowPeak > atac/peak/atac_rep1_peaks.narrowPeak.sorted

#conda activate final-abc-env
#python /cluster/home/jialu/BioSoft/ABC-Enhancer-Gene-Prediction/src/makeCandidateRegions.py --narrowPeak /cluster/home/jialu/GBM/HiC/pGBM_ABC/atac/pHGG.atac.merge.narrowPeak.sorted.merged --bam  /cluster/home/jialu/GBM/HiC/pGBM_ABC/atac/pHGG_atac_merge.bam --outDir CandidateRegion --chrom_sizes /cluster/share/ref_genome/hg38/assembly/hg38.chrom.sizes --regions_blocklist /cluster/home/jialu/GBM/HiC/ABC/ENCFF356LFX_blacklist_downfromencode.bed --regions_includelist /cluster/home/jialu/BioSoft/ABC-Enhancer-Gene-Prediction/reference/hg38/RefSeqCurated.170308.bed.CollapsedGeneBounds.hg38.TSS500bp.bed --peakExtendFromSummit 250 --nStrongestPeaks 150000


python /cluster/home/jialu/BioSoft/ABC-Enhancer-Gene-Prediction/src/juicebox_dump.py \
--hic_file /cluster/home/jialu/GBM/hicnew/pHGG/tohic/mega/aligned/inter_30.hic \
--juicebox "java -Xms512m -Xmx2048m -jar /cluster/home/jialu/4DN_iPSc/pipeline/extra/juicer/scripts/common/juicer_tools_1.22.01.jar" \
--outdir HiC --chromosomes all

python /cluster/home/jialu/BioSoft/ABC-Enhancer-Gene-Prediction/src/compute_powerlaw_fit_from_hic.py --hicDir HiC/ --outDir HiC/powerlaw_new/ --maxWindow 1000000 --minWindow 5000 --resolution 5000 --chr all

python /cluster/home/jialu/BioSoft/ABC-Enhancer-Gene-Prediction/src/run.neighborhoods.py \
--candidate_enhancer_regions /cluster/home/jialu/GBM/HiC/pGBM_ABC/CandidateRegion/pHGG.atac.merge.narrowPeak.sorted.merged.candidateRegions.bed \
--genes /cluster/home/jialu/BioSoft/ABC-Enhancer-Gene-Prediction/reference/hg38/RefSeqCurated.170308.bed.CollapsedGeneBounds.hg38.bed \
--H3K27ac /cluster/home/jialu/GBM/HiC/pGBM_ABC/h3k27ac/bam_files/SRR13238358.rmdup_sorted.bam,/cluster/home/jialu/GBM/HiC/pGBM_ABC/h3k27ac/bam_files/SRR13238359.rmdup_sorted.bam,/cluster/home/jialu/GBM/HiC/pGBM_ABC/h3k27ac/bam_files/SRR13238360.rmdup_sorted.bam,/cluster/home/jialu/GBM/HiC/pGBM_ABC/h3k27ac/bam_files/SRR13238361.rmdup_sorted.bam,/cluster/home/jialu/GBM/HiC/pGBM_ABC/h3k27ac/bam_files/SRR13238379.rmdup_sorted.bam,/cluster/home/jialu/GBM/HiC/pGBM_ABC/h3k27ac/bam_files/SRR13238380.rmdup_sorted.bam \
--ATAC /cluster/home/jialu/GBM/HiC/pGBM_ABC/atac/bam_files/SRR13252800.rmdup_sorted.bam,/cluster/home/jialu/GBM/HiC/pGBM_ABC/atac/bam_files/SRR13252801.rmdup_sorted.bam,/cluster/home/jialu/GBM/HiC/pGBM_ABC/atac/bam_files/SRR13252802.rmdup_sorted.bam,/cluster/home/jialu/GBM/HiC/pGBM_ABC/atac/bam_files/SRR13252803.rmdup_sorted.bam,/cluster/home/jialu/GBM/HiC/pGBM_ABC/atac/bam_files/SRR13252804.rmdup_sorted.bam,/cluster/home/jialu/GBM/HiC/pGBM_ABC/atac/bam_files/SRR13252805.rmdup_sorted.bam \
--expression_table pHGG_tpm_avg.txt --chrom_sizes /cluster/home/jialu/BioSoft/ABC-Enhancer-Gene-Prediction/reference/hg38.chrom.size \
--cellType pHGG   --outdir Neighborhoods --qnorm /cluster/home/jialu/BioSoft/ABC-Enhancer-Gene-Prediction/src/EnhancersQNormRef.K562.txt

python /cluster/home/jialu/BioSoft/ABC-Enhancer-Gene-Prediction/src/predict.py --enhancers Neighborhoods/EnhancerList.txt --genes Neighborhoods/GeneList.txt \
--HiCdir HiC --chrom_sizes  /cluster/home/jialu/BioSoft/ABC-Enhancer-Gene-Prediction/reference/hg38.chrom.size \
--hic_resolution 5000  --scale_hic_using_powerlaw --threshold .02 --cellType pHGG --outdir Predictions  --make_all_putative  
