bedtools intersect -a GSC_vs_DGC_deseq2_sig_match.bed -b /cluster/home/jialu/genome/gencode.v38.pcg.bed.dedup -wo >GSC_vs_DGC_deseq2_sig_match_gene.bed
bedtools intersect -a GSC_vs_DGC_edgeR_sig_match.bed -b /cluster/home/jialu/genome/gencode.v38.pcg.bed.dedup -wo >GSC_vs_DGC_edgeR_sig_match_gene.bed
