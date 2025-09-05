#!/bin/bash

bam=$1  ## 样本ID
outdir=$(dirname ${bam})
sample=$(basename ${outdir})
source activate /cluster/home/futing/miniforge-pypy3/envs/HiC.
cd $outdir
# 一些软件和工具的路径, 根据实际
trimmomatic=~/miniforge-pypy3/envs/HiC/bin/trimmomatic
bwa=~/miniforge-pypy3/envs/HiC/bin/bwa
samtools=~/miniforge-pypy3/envs/HiC/bin/samtools
gatk=/cluster/home/futing/software/gatk-4.6.2.0/gatk
mapq=10
threads=`parallel --number-of-cores`
threads=$((threads/2))
# adjust for mem usage
tmp=`awk '/MemTotal/ {threads=int($2/1024/1024/2/6-1)}END{print threads+0}' /proc/meminfo 2>/dev/null`
tmp=$((tmp+0))
([ $tmp -gt 0 ] && [ $tmp -lt $threads ]) && threads=$tmp

#reference
reference=/cluster/home/futing/ref_genome/hg38_gencode/bwa/hg38.fa
GATK_bundle=/cluster/home/futing/ref_genome/hg38_gencode/GATK/bundle

if [ ! -d $outdir/bwa ]
then mkdir -p $outdir/bwa
fi

if [ ! -d $outdir/gatk ]
then mkdir -p $outdir/gatk
fi

# ------------------------------------------------------------------
if [ ! -f $outdir/bwa/${sample}.sorted.markdup.bam ];then
	echo -e "$(date) MarkDuplicates $bam" >&1
	# 00 MarkDuplicates
	$gatk --java-options "-Xmx64g -Djava.io.tmpdir=/cluster2/home/futing/Project/HiCQTL/CRC_gvcf/debug" MarkDuplicates \
	-I ${bam} \
	-M $outdir/bwa/${sample}.markdup_metrics.txt \
	-O $outdir/bwa/${sample}.sorted.markdup.bam && echo "** ${sample}.sorted.bam MarkDuplicates done **"
fi

if [ ! -f $outdir/bwa/${sample}.sorted.markdup.bam.bai ];then
	time ${samtools} index \
		${outdir}/bwa/${sample}.sorted.markdup.bam && echo "** ${sample}.sorted.markdup.bam.bai done **"
fi

#--------------------------------------------------
echo "...Analyzing reference data." >&1

[ "${reference: -3}" == ".gz" ] && { echo >&2 ":( Please unzip your reference. Exiting!"; exit 1; }
[ -f `basename $reference` ] || ln -sf $reference .

echo "	...Looking for $reference.fai."
[ -f $reference".fai" ] && ln -sf $reference".fai" . || samtools faidx $reference

echo "	...Looking for ${reference%.*}.dict."

refbasename=`basename $reference .fa`
[ -f ${reference%.*}".dict" ] && ln -sf ${reference%.*}".dict" . || gatk CreateSequenceDictionary -R $reference -O "$refbasename.dict"

echo "	...Looking for "${reference%.*}".interval_list."
[ -f ${reference%.*}".interval_list" ] && ln -sf ${reference%.*}".interval_list" . || gatk ScatterIntervalsByNs -R $reference -OT ACGT -N 500 -O "$refbasename.interval_list"

reference=`basename $reference`

totlen=`awk -F '\t' '$0!~/^@/{c+=$3-$2}END{print c}' $refbasename.interval_list`
threads=`awk -v len=$((totlen/threads + 1)) 'BEGIN{FS="\t"; OFS="\t"; counter++}$0~/^@/{next}{if(c>len){counter++; c=0}; print $0>"split."counter".bed"; c+=$3-$2}END{print counter}' $refbasename.interval_list`

echo "...Will use $threads threads." >&1

coverage=$(samtools depth $outdir/bwa/${sample}.sorted.markdup.bam -b split.1.bed | awk 'FILENAME==ARGV[1]{l+=$3-$2;next}{c+=$3}END{print int(1000*c/l)}' split.1.bed -)
target_coverage=30
[[ $coverage -eq 0 ]] || fraction=`echo "scale=2; ${target_coverage}/${coverage}" | bc -l`

([[ $coverage -eq 0 ]] || [[ `echo "$fraction > 1" | bc` -eq 1 ]]) && (echo "Estimated \"clean\" coverage (${coverage}X) is lower than requested coverage (${target_coverage}X). Will use all available data." | tee -a /dev/stderr && fraction="1.0")
echo "...Fraction to be used for SNP calling: "$fraction"."

#------------------------------------------------------------------
# 01 BaseRecalibrator & ApplyBQSR
echo "...Starting BaseRecalibrator & ApplyBQSR." >&1
time seq 1 $threads | parallel --will-cite --joblog temp.log \
"gatk --java-options \"-Xmx10G -XX:+UseParallelGC -XX:ParallelGCThreads=4\" \
	BaseRecalibrator \
	-L split.{}.bed \
    -R ${reference} \
    -I ${outdir}/bwa/${sample}.sorted.markdup.bam \
    --known-sites $GATK_bundle/1000G_phase1.snps.high_confidence.hg38.vcf \
    --known-sites $GATK_bundle/Mills_and_1000G_gold_standard.indels.hg38.vcf \
    --known-sites $GATK_bundle/dbsnp138.hg38.vcf \
    -O ${outdir}/bwa/${sample}.sorted.markdup.recal_data_{}.table" && echo "** ${sample}.sorted.markdup.recal_data.table done **" 
exitval=`awk 'NR>1{if($7!=0){c=1; exit}}END{print c+0}' temp.log`
[ $exitval -eq 0 ] || { echo ":( Pipeline failed at gatk BaseRecalibator. See err stream for more info. Exiting! " | tee -a /dev/stderr && exit 1; }

echo "...Applying BQSR to bam." >&1
seq 1 $threads | parallel --will-cite --joblog temp.log \
	"gatk ApplyBQSR --java-options \"-Xmx4G -Xmx4G -XX:+UseParallelGC -XX:ParallelGCThreads=4\" \
	--bqsr-recal-file $outdir/bwa/${sample}.sorted.markdup.recal_data_{}.table \
	-R ${reference} \
	-L split.{}.bed \
	--static-quantized-quals 10 \
	--static-quantized-quals 20 \
	--static-quantized-quals 30 \
	-I $outdir/bwa/${sample}.sorted.markdup.bam \
	-O $outdir/bwa/reads.prepped_{}.bam" && echo "** ApplyBQSR done **"
exitval=`awk 'NR>1{if($7!=0){c=1; exit}}END{print c+0}' temp.log`

[ $exitval -eq 0 ] || { echo ":( Pipeline failed at gatk ApplyBQSR. See err stream for more info. Exiting! " | tee -a /dev/stderr && exit 1; }

seq 1 $threads | parallel --will-cite "rm recal_data_{}.table"
rm temp.log

# --------------------------------------------------
# 02 HaplotypeCaller
## 输出样本的全gVCF，面对较大的输入文件时，速度较慢
tmp_count=`find . -maxdepth 1 -name "reads.prepped_*.bam" | wc -l`
tmp_count2=`find . -maxdepth 1 -name "reads.prepped_*.bai" | wc -l`

([ $tmp_count -eq $threads ] && [ $tmp_count2 -eq $threads ]) || { echo >&2 ":( Files from previous stages of the pipeline appear to be missing. Exiting!"; exit 1; }

echo "...Calling haplotypes." >&1

time seq 1 $threads | parallel --will-cite --joblog temp.log \
	"gatk --java-options \"-Xmx4G -XX:+UseParallelGC -XX:ParallelGCThreads=1\" \
	HaplotypeCaller \
	--emit-ref-confidence GVCF \
	-R ${reference} -I $outdir/bwa/reads.prepped_{}.bam \
	-O $outdir/gatk/raw_{}.g.vcf.gz -L split.{}.bed \
	--dont-use-soft-clipped-bases true -pairHMM FASTEST_AVAILABLE \
	--native-pair-hmm-threads 10 \
	--dbsnp $GATK_bundle/dbsnp138.hg38.vcf \
	--disable-read-filter MappingQualityReadFilter \
	--smith-waterman FASTEST_AVAILABLE --min-base-quality-score $mbq" && echo "** GVCF ${sample}.HC.g.vcf.gz done **"
exitval=`awk 'NR>1{if($7!=0){c=1; exit}}END{print c+0}' temp.log`
[ $exitval -eq 0 ] || { echo ":( Pipeline failed at GATK HaplotypeCaller. See err stream for more info. Exiting! " | tee -a /dev/stderr && exit 1; }

# 03 cleanup bam
seq 1 $threads | parallel --will-cite "rm $outdir/bwa/reads.prepped_{}.bam $outdir/bwa/reads.prepped_{}.bai"


# 04 CombineGVCFs
arg=$(seq 1 $threads | parallel --will-cite -k "printf -- \" -V %s\" raw_{}.g.vcf.gz")

time gatk --java-options "-Xmx4G" CombineGVCFs \
	-R $reference $arg \
	-O $outdir/gatk/${sample}.HC.g.vcf.gz && echo "** CombineGVCFs ${sample}.HC.g.vcf.gz done **"

[ $? -eq 0 ] || { echo ":( Failed at GATK GatherVcfs. See err stream for more info. Exiting!" | tee -a /dev/stderr && exit 1; }

# cleanup
seq 1 $threads | parallel --will-cite "rm raw_{}.g.vcf.gz raw_{}.g.vcf.gz.idx"
rm temp.log