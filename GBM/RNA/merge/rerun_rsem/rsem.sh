#!/bin/bash

# 尝试重新RSEM 因为GTF的基因数量不同

source /cluster/home/futing/miniforge-pypy3/etc/profile.d/conda.sh
conda activate scRNAseq

datadir=/cluster/home/futing/Project/GBM/RNA/sample/20240830/analysis
name=$1

find ${datadir}/${name}/ -maxdepth 1 -mindepth 1 -type d -name 'SRR*' | while read dir;do
	mkdir -p ${datadir}/${name}/rsem_out

	i=$(basename $dir)
	echo -e "Rsem ${i} in ${name}..."
	rsem-calculate-expression --paired-end -no-bam-output --alignments -p 20 \
		${datadir}/${name}/${i}/aligned/${i}Aligned.toTranscriptome.out.bam \
		/cluster/home/futing/ref_genome/hg38_gencode/RSEM/RSEM \
		${datadir}/${name}/rsem_out/
done