#!/bin/bash

##nohup sh pro.sh normal 50 _input rose no >> rose.out 2>&1 &


#################################################################################################
#Usage: 
#sh /cluster/home/chenglong/pipeline_suc/TAG2ROSE/cut2rose_lite.sh {[normal(default)/histone] [50(d)] [no(d)/${IgG_flag}] [no(d)/rose] [no(d)/yes]}
#
#${IgG_flag} means the string which can capture your control group data.(likes "IgG" or "input")
#If you choose default parameters as input, you can omit the parameters in "{}".
#If you need change some parameters,for example:
#sh /cluster/home/chenglong/pipeline_suc/TAG2ROSE/cut2rose_lite.sh "" 30 "" "" ""
#Based on version cut2rose_v6.sh
#################################################################################################


#################################################################################################
#RESTRICTION:
#
#1.rename module restrict: 
#Only can capture _R1.fastq.gz or .R1.fastq.gz files' prefix,
#and the prefix doesn't contain ".",otherwise you need to rename by yourself.
#
#2.IgG_flag restrict:
#Only 1 IgG file is supported, if you have multiple IgG files,
#you need to build map relationship by yourself.
#
#3.histone choice can only output broadPeak without summit sites.(find motif use "normal" parameter)
##################################################################################################

#source /cluster/home/chenglong/.bashrc
#source activate /cluster/home/chenglong/miniconda3/envs/tag2rose

protein_type=${1:-normal}
thread=${2:-50}
IgG_flag=${3:-no}
rose_flag=${4:-no}
retain_temp_file_flag=${5:-no}

#necessary file index
indexpath="/cluster/share/ref_genome/hg38/index/bowtie2/hg38"
chromosize="/cluster/share/ref_genome/hg38/assembly/hg38.chrom.sizes"
TSS_BED="/cluster/home/chenglong/reference/pcg_gene_tss_v38.bed"
main_chr_list_path="/cluster/home/chenglong/reference/chr_22XY.txt"
homer_hg38_ref="/cluster/home/chenglong/homer/data/genomes/hg38"
# build rose annotation soft link
#ln -s /cluster/home/chenglong/ROSE-master/annotation annotation
wd=`pwd`
wd_name=`basename ${wd}`


#rename _R1 .R1 *fastq.gz
#rename _R2 .R2 *fastq.gz
#ls *.R1.fastq.gz | cut -d"." -f1 > filename_pre.txt

#To ensure IgG as first file in circle.
#if [ ${IgG_flag} != "no" ];then
#	grep ${IgG_flag} filename_pre.txt > filename.txt
#	grep -v ${IgG_flag} filename_pre.txt >> filename.txt
#	rm filename_pre.txt
#else
#	mv filename_pre.txt filename.txt
#fi


mkdir -p ./{bigwig,heatmap,macs2,motif,rose,reads_flow,all_transfer_result}
mkdir -p ./all_transfer_result/{fastqc,fastp_report,fastqc_filt,alignment,fragmentLen,bam_files,bigwig,heatmap,macs2,motif,rose,reads_flow}

cat filename_pre.txt | while read i
do
	##bigwig
	bamCoverage -b ./bam_files/${i}.rmdup_sorted.bam -o ./bigwig/${i}.rpkm.bw --normalizeUsing RPKM
	
	##IgG choice:
	if [ $IgG_flag = "no" ];then
		#macs2 call peak
		if [ $protein_type = "normal" ];then
			macs2 callpeak -t ./bam_files/${i}.rmdup_sorted.bam -g hs -f BAM -n ${i} --outdir ./macs2 -q 0.05
		elif [ $protein_type = "histone" ];then
			macs2 callpeak -t ./bam_files/${i}.rmdup_sorted.bam -g hs -f BAM -n ${i} --outdir ./macs2 --broad --broad-cutoff 0.05
		fi
		
		#rename
		ls ./macs2/${i}_peaks.*Peak | grep -v gapped | xargs -i cp {} ./macs2/${i}_macs2peak.bed
		
		##run ROSE without IgG
		if [ ${rose_flag} = "rose" ];then
			ROSE_main.py -g HG38 -i ./macs2/${i}_macs2peak.bed -r ./bam_files/${i}.rmdup_sorted.bam -o ./rose -s 12500 -t 2500
			sed -n '6,$p' ./rose/${i}*AllStitched.table.txt > ./rose/${i}_all_enhancer_signal.txt
			sed -n '7,$p' ./rose/${i}*AllStitched.table.txt | cut -f2-4 | bedtools sort -i stdin > ./rose/${i}_all_TESE.bed
			sed -n '7,$p' ./rose/${i}*SuperStitched.table.txt | cut -f2-4 | bedtools sort -i stdin > ./rose/${i}_SE.bed
			bedtools intersect -a ./rose/${i}_all_TESE.bed -b ./rose/${i}_SE.bed -v > ./rose/${i}_TE.bed
		fi
	
	elif [[ ! (${i} =~ ${IgG_flag}) ]];then
		if [ $protein_type = "normal" ];then
			macs2 callpeak -t ./bam_files/${i}.rmdup_sorted.bam -c ./bam_files/*${IgG_flag}*.rmdup_sorted.bam -g hs -f BAM -n ${i} --outdir ./macs2 -q 0.05
		elif [ $protein_type = "histone" ];then
			macs2 callpeak -t ./bam_files/${i}.rmdup_sorted.bam -c ./bam_files/*${IgG_flag}*.rmdup_sorted.bam -g hs -f BAM -n ${i} --outdir ./macs2 --broad --broad-cutoff 0.05
		fi
		
		#rename
		ls ./macs2/${i}_peaks.*Peak | grep -v gapped | xargs -i cp {} ./macs2/${i}_macs2peak.bed
		
		##run ROSE
		if [ ${rose_flag} = "rose" ];then
			ROSE_main.py -g HG38 -i ./macs2/${i}_macs2peak.bed -r ./bam_files/${i}.rmdup_sorted.bam -c ./bam_files/*${IgG_flag}*.rmdup_sorted.bam -o ./rose -s 12500 -t 2500
			sed -n '6,$p' ./rose/${i}*AllStitched.table.txt > ./rose/${i}_all_enhancer_signal.txt
			sed -n '7,$p' ./rose/${i}*AllStitched.table.txt | cut -f2-4 | bedtools sort -i stdin > ./rose/${i}_all_TESE.bed
			sed -n '7,$p' ./rose/${i}*SuperStitched.table.txt | cut -f2-4 | bedtools sort -i stdin > ./rose/${i}_SE.bed
			bedtools intersect -a ./rose/${i}_all_TESE.bed -b ./rose/${i}_SE.bed -v > ./rose/${i}_TE.bed
		fi
	fi
	
	##motif
	mkdir ./motif/${i}_motif
	/cluster/home/chenglong/miniconda3/envs/tag2rose/bin/findMotifsGenome.pl \
	./macs2/${i}_macs2peak.bed ${homer_hg38_ref} ./motif/${i}_motif/ -size 200 -p ${thread}
	
	##statistic merge(reads_flow)
	###origin
	fastq-count ${i}.R1.fastq.gz ${i}.R2.fastq.gz > ./reads_flow/${i}_statistics.txt
	###fastp filtrate
	fastq-count ${i}_fil.R1.fastq.gz ${i}_fil.R2.fastq.gz >> ./reads_flow/${i}_statistics.txt
	
	##bulid statistic table
	#header line
	echo "process,reads,left_percentage,total_percentage" > ./reads_flow/${i}_reads_flow.csv
	
	#origin_line
	origin_reads=`head -n 1 ./reads_flow/${i}_statistics.txt | awk -F "," '{print $2}' | tr -cd "[0-9]"`
	echo "origin",${origin_reads},1,1 >> ./reads_flow/${i}_reads_flow.csv
	
	#fastp_filtrate line
	fastp_reads=`sed -n '2p' ./reads_flow/${i}_statistics.txt | awk -F "," '{print $2}' | tr -cd "[0-9]"`
	fastp_lpt=$(printf "%.5f" `echo "scale=5;${fastp_reads}/${origin_reads}"|bc`)
	fastp_tpt=${fastp_lpt}
	echo "fastp",${fastp_reads},${fastp_lpt},${fastp_tpt} >> ./reads_flow/${i}_reads_flow.csv
	
	#bowtie2_filtrate_line
	bowtie2_reads=`samtools view -c ./alignment/${i}_bowtie2.mapped.sam`
	bowtie2_lpt=$(printf "%.5f" `echo "scale=5;${bowtie2_reads}/${fastp_reads}"|bc`)
	bowtie2_tpt=$(printf "%.5f" `echo "scale=5;${bowtie2_reads}/${origin_reads}"|bc`)
	echo "bowtie2",${bowtie2_reads},${bowtie2_lpt},${bowtie2_tpt} >> ./reads_flow/${i}_reads_flow.csv
	
	#main-chr reads (ratio)
	main_chr_reads=`samtools view -c ./alignment/${i}_bowtie2_fil.sam`
	main_chr_ratio=$(printf "%.5f" `echo "scale=5;${main_chr_reads}/${bowtie2_reads}"|bc`)
	echo "main_chr",${main_chr_reads},${main_chr_ratio} >> ./reads_flow/${i}_reads_flow.csv
	
	#picard_filtrate_line
	picard_reads=`samtools view -c ./bam_files/${i}.rmdup_sorted.bam`
	picard_lpt=$(printf "%.5f" `echo "scale=5;${picard_reads}/${main_chr_reads}"|bc`)
	picard_tpt=$(printf "%.5f" `echo "scale=5;${picard_reads}/${origin_reads}"|bc`)
	echo "picard",${picard_reads},${picard_lpt},${picard_tpt} >> ./reads_flow/${i}_reads_flow.csv
	
	
	if [[ ! (${IgG_flag} != "no" && ${i} =~ ${IgG_flag}) ]]; then
		#peak number
		peak_n=`wc -l ./macs2/${i}_macs2peak.bed | awk '{print $1}'`
		echo "peak_n",${peak_n} >> ./reads_flow/${i}_reads_flow.csv
			
		#NRF,PBC1,PBC2
		bedtools bamtobed -i ./bam_files/${i}_bowtie2.bam | awk 'BEGIN{OFS="\t"}{print $1,$2,$3,$6}' | sort | uniq -c | \
		awk 'BEGIN{frag_all=0;m_all=0;m1=0;m2=0} \
		($1==1){m1=m1+1} ($1==2){m2=m2+1} {m_all=m_all+1} {frag_all=frag_all+$1} \
		END{m1_m2=-1.0; if(m2>0) m1_m2=m1/m2; printf "NRF,%.5f,NRF_ref,0.5\nPBC1,%.5f,PBC1_ref,0.5\nPBC2,%.5f,PBC2_ref,1\n",m_all/frag_all,m1/m_all,m1_m2}' \
		>> ./reads_flow/${i}_reads_flow.csv

		#FRiP
		call_peak_reads=${picard_reads}
		reads_in_peak_n=`bedtools sort -i ./macs2/${i}_macs2peak.bed | bedtools merge -i stdin | \
		bedtools intersect -u -nonamecheck -a ./bam_files/${i}.rmdup_sorted.bam -b stdin -ubam | samtools view -c`
		FRiP=$(printf "%.5f" `echo "scale=5;${reads_in_peak_n}/${call_peak_reads}"|bc`)
		echo "FRiP",${FRiP} >> ./reads_flow/${i}_reads_flow.csv
	fi
		
done

#multiqc -o ./fastqc ./fastqc/*zip
#multiqc -o ./fastqc_filt ./fastqc_filt/*zip

##heatmap in TSS region
computeMatrix reference-point -p $thread --referencePoint TSS -b 3000 -a 3000 -R $TSS_BED -S ./bigwig/*.bw --skipZeros -out ./heatmap/TSS_center.gz
plotHeatmap -m ./heatmap/TSS_center.gz -out ./heatmap/TSS_center.png


##merge all results to a result.tar.gz file.
cp ./fastqc/*html ./all_transfer_result/fastqc/
cp ./fastp_report/* ./all_transfer_result/fastp_report/
cp ./fastqc_filt/*html ./all_transfer_result/fastqc_filt/
cp ./alignment/*txt ./all_transfer_result/alignment/
cp ./fragmentLen/* ./all_transfer_result/fragmentLen/
cp ./bam_files/*rmdup.txt ./all_transfer_result/bam_files/
#cp ./bigwig/*bw ./all_transfer_result/bigwig/
cp ./heatmap/*png ./all_transfer_result/heatmap/
cp ./macs2/*_macs2peak.bed ./all_transfer_result/macs2/
cp ./rose/*png ./all_transfer_result/rose/
cp ./rose/*AllStitched_REGION_TO_GENE* ./all_transfer_result/rose/
cp ./rose/*_all_enhancer_signal.txt ./all_transfer_result/rose/
cp ./rose/*_all_TESE.bed ./all_transfer_result/rose/
cp ./rose/*_SE.bed ./all_transfer_result/rose/
cp ./rose/*_TE.bed ./all_transfer_result/rose/
cp -r ./motif/ ./all_transfer_result/motif/
cp ./reads_flow/*csv ./all_transfer_result/reads_flow/

tar -zcvf ${wd_name}_result.tar.gz ./all_transfer_result/{fastqc,fastp_report,fastqc_filt,alignment,fragmentLen,bam_files,bigwig,heatmap,macs2,motif,rose,reads_flow}


##remove not necessary files.
if [ $retain_temp_file_flag = "no" ];then
	rm ./alignment/*sam
	rm ./bam_files/*_bowtie2.bam
	ls ./bam_files/*.sorted.bam* | xargs rm
	ls ./*_fil.R*fastq.gz | xargs rm
fi
