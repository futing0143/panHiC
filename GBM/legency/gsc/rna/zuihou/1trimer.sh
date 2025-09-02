#!/bin/bash

##usage:sh /cluster/home/chenglong/pipeline_suc/RNA_pipe/RNA_pipe.sh $thread
ls *.R1.fastq.gz | cut -d"." -f1 > filename.txt
thread=30
filename=filename.txt
star_indexpath="/cluster/share/ref_genome/hg38/index/star"
rsem_index="/cluster/share/ref_genome/hg38/index/rsem/hg38_rsem"
feature_count_gtf="/cluster/share/ref_genome/hg38/annotation/gencode.v38.annotation.gtf"

# mkdir star_out
# mkdir rsem_out
# mkdir trim
# mkdir fastqc
cat ${filename} | while read i
do
	
	##filtrate data 第一步首先去除低质量碱基，然后去除3' 末端的adapter, 如果没有指定具体的adapter，程序会自动检测前1million的序列，然后对比前12-13bp的序列是否符合以下类型的adapter Illumina: AGATCGGAAGAGC Small RNA: TGGAATTCTCGG Nextera: CTGTCTCTTATA
	trim_galore -q 25 --phred33 --length 50 -e 0.1 --stringency 3 --paired -o ./trim ${i}.R1.fastq.gz ${i}.R2.fastq.gz
##--phred anger/Illumina 1.9+ encoding为33; Illumina 1.5 encoding为64
	##qc after filtrate
	fastqc -o ./fastqc ./trim/${i}*gz
		
	##alignment
	STAR \
	--genomeDir ${star_indexpath} \
	--readFilesCommand gunzip -c \
	--readFilesIn ./trim/${i}*val_1* ./trim/${i}*val_2* \
	--runThreadN 12 \
	--runMode alignReads \
	--outSAMtype BAM SortedByCoordinate \
	--twopassMode Basic \
	--quantMode TranscriptomeSAM GeneCounts \
	--outBAMsortingThreadN 5 \
	--outFileNamePrefix ./star_out/${i}_

	##rsem count(can't ouput raw count,I decide to annotate it.) ###转录本水平的定量
	rsem-calculate-expression \
	 --no-bam-output -p ${thread} \
	--alignments --paired-end \
	./star_out/${i}_Aligned.toTranscriptome.out.bam \
	${rsem_index} ./rsem_out/${i}
	
done

##feature_count
#featureCounts -T 32 -a ${feature_count_gtf} -o ./RNA_raw_count.txt -p -B -C -t exon -g gene_id `find . -name *Aligned.sortedByCoord.out.bam`

##cut columns depend on your samples.
#awk '{if(NR > 1)print}' all_read_count.txt | cut -f 1,6,7,8,9,10,11 > RNA_count_and_length.txt
#awk '{if(NR > 1)print}' RNA_raw_count.txt | awk '{$2="";$3="";$4="";$5="";print $0}' > all.count.txt
