#!/bin/bash

hic=/cluster/home/futing/Project/GBM/eqtl/hic/merged_with_count.txt
epi_blood=/cluster/home/futing/Project/GBM/eqtl/Process2/blood_combined_clean.bed
epi_gbm=/cluster/home/futing/Project/GBM/eqtl/gbm_left_join/gbm_combined_clean.bed
RNA_gbm=/cluster/home/futing/Project/GBM/eqtl/RNA/RNA_GBM_symbol.bed

head -n 1 $hic > file2.txt
#SNP     SNPChr  SNPPos  is_gbm  Gene    Symbol  Genetype        GeneChr GeneStart       GeneEnd bin1_id bin2_id
tail -n +2 "$hic" | awk 'BEGIN{FS=OFS="\t"} {printf "%s_%s_%s\t%s\n", $2, ($3-1 > 0 ? $3-1 : 0), int($3), $0}' | sort -k1,1 > ./hic/hic_extend.bed



# join hic with epi
#chr_start_end   h3k27ac h3k27ac_signal  atac    atac_signal     ctcf    ctcf_signal
join -1 1 -2 1 -o "2.1,2.3,2.4,2.5,2.6,2.7,2.8,1.2,1.3,1.4,1.5,1.6,1.7" $epi_blood ./hic/hic_extend.bed | sort -k1,1 > ./Process3/epi_hic.bed
join -1 1 -2 1 -o "2.1,2.2,2.3,2.4,2.5,2.6,2.7,2.8,2.9,2.10,2.11,2.12,2.13,1.2,1.3,1.4,1.5,1.6,1.7" $epi_gbm ./Process3/epi_hic.bed | sort -k1,1 > ./Process3/epi_hic.tmp
mv ./Process3/epi_hic.tmp ./Process3/epi_hic.bed

# join RNA with hic
join -1 4 -2 1 -o "2.1,2.3,2.4,2.5,2.6,2.7,2.8,1.6,1.12" $RNA_gbm ./hic/hic_extend.bed | sort -k1,1 > ./RNA/RNA_hic.bed