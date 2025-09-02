ls /cluster/home/tmp/EGA/EGAD00001010312/*/P524.SF12681v9.hic.bam | while read line 
do 
	file_name=$(basename $line)
	dir=${file_name%.hic.bam}
	mkdir -p ${dir}/fastq ${dir}/splits
	touch ${dir}/fastq/${file_name}_R1.fastq ${dir}/fastq/${file_name}_R2.fastq
    cd ${dir}/splits
	ln -s ../fastq/* .
	cd ../.. 
done


ls /cluster/home/tmp/EGA/EGAD00001010312/*/P524.SF12681v9.hic.bam | while read line
do
	file_name=$(basename $line)
	dir=${file_name%.hic.bam}
	sam=$dir/splits/${dir}.hic.fastq.sam
	samtools view -h -o $sam -O SAM $line
	/cluster/home/Gaoruixiang/software/juicer/scripts/juicer.sh \
	-S chimeric \
	-g hg19 \
	-d /cluster/home/Gaoruixiang/gaorx/GBM/$dir \
	-s Arima \
	-p /cluster/home/Gaoruixiang/software/juicer/restriction_sites/hg19.chrom.sizes
	-y /cluster/home/Gaoruixiang/software/juicer/restriction_sites/hg19_Arima.txt
	-z /cluster/home/Gaoruixiang/software/juicer/references/hg19.fa
	-D /cluster/home/Gaoruixiang/software/juicer > $dir/juicer.log
done
