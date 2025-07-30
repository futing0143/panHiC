#!/bin/bash
################################################################################
# Cooler pipeline of Micro-C processing
# pre-requirements:
#   - bwa
#   - samtools
#   - pairtools
#   - pairix
#   - cooler
#   - cooltools
#--------------- 1. prepare reference--------------
# 下载参考基因组索引文件 
# wget https://s3.amazonaws.com/4dn-dcic-public/hic-data-analysis-bootcamp/hg38.bwaIndex.tgz
# 参考基因组大小
# wget https://s3.amazonaws.com/4dn-dcic-public/hic-data-analysis-bootcamp/hg38.mainonly.chrom.size
## using
# bname=$1: inputdir: need inputdir/fastq/*_R*.gz 文件
# binsize=$2: 分bin的大小，默认5000
# threads=$3: number of threads

################################################################################
source activate HiC # 需要修改 ！！！激活自己的 conda 环境

#------------------------------------------------------------------------------#
# parse parameters
#------------------------------------------------------------------------------#

log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}


# Check if output exists and is not empty
check_output() {
    local file=$1
    local step_name=$2
    if [ -s "$file" ]; then
        log_message "Skipping $step_name - output file already exists: $file"
        return 0
    else
        log_message "Starting $step_name"
        return 1
    fi
}

#------------------------------------------------------------------------------#
# Parse parameters
#------------------------------------------------------------------------------#
# Set path of the pipeline
bdir=$(dirname $0)

# Input parameters
bname=$1 # 输入目录，包含 ./fastq 目录，fastq目录下放置 fastq.gz 文件
binsize=${2:-5000} # default 5000
threads=${3:-15} # default 15


# Setup paths and variables
ref=/cluster2/home/futing/Project/panCancer/CRC/GSE178593/test/GCF_000146045.2/GCF_000146045.2_R64_genomic.fna #!!! 需要修改为自己的参考基因组路径
chromsize=/cluster2/home/futing/Project/panCancer/CRC/GSE178593/test/GCF_000146045.2/genome.sizes #!!! 需要修改为自己的参考基因组大小文件路径
FileName=$(basename $bname) # 文件名
resolution=1000,5000,10000,25000,50000,100000,250000,500000,1000000,2500000  # mcool的分辨率

log_message "----------------------------Input info --------------------------------------------------"
log_message "Input dir: ${bname}, replicate(s)"
log_message "Genome: ${ref}"
mkdir -p ${bname}/{aligned,cool,tmp}
rename _1 _R1 ${bname}/fastq/*.fastq.gz
rename _2 _R2 ${bname}/fastq/*.fastq.gz
rename .R1 _R1 ${bname}/fastq/*.fastq.gz
rename .R2 _R2 ${bname}/fastq/*.fastq.gz

fastq1=$(ls ${bname}/fastq/*_R1*.gz | head -n1)
fastq2=$(ls ${bname}/fastq/*_R2*.gz | head -n1)


#------------------------------------------------------------------------------#
# Pipeline Steps
#------------------------------------------------------------------------------#

if [ -z "$bname" ] || [ ! -d "$bname/fastq" ]; then
    log_message "Error: Input directory not provided or fastq directory does not exist"
    exit 1
fi

# 1. BWA Alignment
if ! check_output "${bname}/aligned/${FileName}.bam" "BWA mem"; then
	bwa mem -SP5M -t ${threads} ${ref} ${fastq1} ${fastq2} | samtools view -bhS - > ${bname}/aligned/${FileName}.bam || {
		log_message "Error: BWA alignment failed"
		exit 1
	}
	log_message "finished BWA"
fi



# 2. Parsing BAM to pairs
if ! check_output "${bname}/aligned/${FileName}.pairs.gz" "BAM parsing"; then
    log_message "------------------------------------------------------------------------------"
    log_message "Parsing BAM to pairs"
    #  --walks-policy all 
	pairtools parse ${bname}/aligned/${FileName}.bam --chroms-path ${chromsize} \
		--drop-sam --drop-seq \
		--output-stats ${bname}/aligned/${FileName}.stats \
		--min-mapq 30 \
		--walks-policy 5unique \
		--max-inter-align-gap 30 \
		--assembly hg38 \
		--add-columns mapq \
		--nproc-in 10 \
		--nproc-out 10 \
		-o ${bname}/aligned/${FileName}.pairs.gz

fi


# 3. Sorting pairs
if ! check_output "${bname}/aligned/${FileName}.sorted.pairs.gz" "Pair sorting"; then
    log_message "------------------------------------------------------------------------------"
    log_message "Sorting pairs"
    pairtools sort --nproc 10 ${bname}/aligned/${FileName}.pairs.gz \
		--tmpdir ${bname}/tmp \
		-o ${bname}/aligned/${FileName}.sorted.pairs.gz
fi


# 4.1 Generate restriction Site and Filtering 
if ! check_output "${bname}/aligned/${FileName}.filt.sorted.pairs.gz" "Filtering"; then
    # log_message "Generate restriction Site"
    # python ${bdir}/digest_genome.py ${ref} -r ${enzyme} -o ${enzymefile}
    # pairtools restrict -f ${enzymefile} ${bname}/aligned/${FileName}.sorted.pairs.gz -o ${bname}/aligned/${FileName}.restrict.sorted.pairs.gz

    log_message "Filtering pairs"
    pairtools select '(pair_type == "UU") or (pair_type == "UR") or (pair_type == "RU")' \
        ${bname}/aligned/${FileName}.sorted.pairs.gz -o ${bname}/aligned/${FileName}.filt.sorted.pairs.gz
fi



# 5. Deduplication and split
if ! check_output "${bname}/aligned/${FileName}.nodups.pairs.gz" "Deduplication"; then
    log_message "------------------------------------------------------------------------------"
    log_message "Deduplicating and splitting pairs"
    #      --max-mismatch 3 \
    pairtools dedup \
        --mark-dups \
		--output >( pairtools split --output-pairs ${bname}/aligned/${FileName}.nodups.pairs.gz --output-sam ${bname}/aligned/${FileName}.nodups.bam ) \
		--output-unmapped >( pairtools split --output-pairs ${bname}/aligned/${FileName}.unmapped.pairs.gz --output-sam ${bname}/aligned/${FileName}.unmapped.bam ) \
		--output-dups >( pairtools split --output-pairs ${bname}/aligned/${FileName}.dups.pairs.gz --output-sam ${bname}/aligned/${FileName}.dups.bam) \
		--output-stats ${bname}/aligned/${FileName}.dedup.stats \
        ${bname}/aligned/${FileName}.filt.sorted.pairs.gz
fi

# 6. Sorting nodups pairs
if ! check_output "${bname}/aligned/${FileName}.nodups.sorted.pairs.gz" "Nodups Pair sorting"; then
    log_message "------------------------------------------------------------------------------"
    log_message "Sorting pairs"
	pairtools sort --nproc 10 \
		--tmpdir ${bname}/tmp \
		-o ${bname}/aligned/${FileName}.nodups.sorted.pairs.gz \
		${bname}/aligned/${FileName}.nodups.pairs.gz
	pairix ${bname}/aligned/${FileName}.nodups.sorted.pairs.gz
fi


# 6. Creating .cool file
if ! check_output "${bname}/cool/${FileName}.${binsize}.cool" "Cooler binning"; then
    log_message "------------------------------------------------------------------------------"
    log_message "Creating .cool file with bin size ${binsize}"
    cooler cload pairix --nproc ${threads} ${chromsize}:${binsize} ${bname}/aligned/${FileName}.nodups.sorted.pairs.gz ${bname}/cool/${FileName}.${binsize}.cool
    
    # Matrix balancing
    log_message "------------------------------------------------------------------------------"
    log_message "Balancing contact matrix"

    cooler balance ${bname}/cool/${FileName}.${binsize}.cool

fi



# 7. Multi-resolution cooler file
if ! check_output "${bname}/cool/${FileName}.mcool" "Multi-resolution conversion"; then
    log_message "------------------------------------------------------------------------------"
    log_message "Creating multi-resolution .mcool file"
    cooler zoomify ${bname}/cool/${FileName}.${binsize}.cool \
        -o ${bname}/cool/${FileName}.mcool \
        --resolutions ${resolution} \
        --nproc ${threads}
fi



