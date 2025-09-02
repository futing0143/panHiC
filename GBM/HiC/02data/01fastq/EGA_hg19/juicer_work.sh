ls /cluster/home/tmp/EGA/EGAD00001010312/*/*bam | while read line
do
	file_name=$(basename $line)
	dir=${file_name%.hic.bam}
	sam=$dir/splits/${file_name}.fastq.sam
	samtools view -h -o $sam -O SAM $line 
	cd $dir 
	/cluster/home/Gaoruixiang/software/juicer/scripts/juicer.sh \
	 -S chimeric \
	 -g hg19 \
	 -d /cluster/home/Gaoruixiang/gaorx/GBM/$dir \
	 -s Arima \
	 -p /cluster/home/Gaoruixiang/software/juicer/restriction_sites/hg19.chrom.sizes \
	 -y /cluster/home/Gaoruixiang/software/juicer/restriction_sites/hg19_Arima.txt \
	 -z /cluster/home/Gaoruixiang/software/juicer/references/hg19.fa \
	 -D /cluster/home/Gaoruixiang/software/juicer > $dir/juicer.log
	cd ..
done
