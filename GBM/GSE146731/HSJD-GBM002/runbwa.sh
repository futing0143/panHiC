#!/bin/bash
#SBATCH -p normal
#SBATCH -t unlimited
#SBATCH --cpus-per-task=10
#SBATCH --output=/cluster2/home/futing/Project/panCancer/GBM/GSE146731/HSJD-GBM002/bwa-%j.log
#SBATCH -J "HSJD-GBM002"

wkdir=/cluster2/home/futing/Project/panCancer/GBM/GSE146731/HSJD-GBM002
cd ${wkdir}
mkdir -p ./{fastq,cool,anno,splits,HiC_tmp}
rename _1 _R1 *fastq.gz
rename _2 _R2 *fastq.gz
rename .R1 _R1 *fastq.gz
rename .R2 _R2 *fastq.gz  
mv *.fastq.gz ./fastq
source activate juicer
ln -s ${wkdir}/fastq/SRR11281949* ${wkdir}/splits/

cd splits
threadstring="-t 20"
refSeq=/cluster/home/futing/software/juicer_CPU/references/hg38.fa
juiceDir=/cluster/home/futing/software/juicer_CPU
ext=".fastq.gz"
ligation="GATCGATC"
site="DpnII"
site_file="${juiceDir}/restriction_sites/hg38_${site}.txt"
usegzip=1
tmpdir=${wkdir}/HiC_tmp
# 01
# while read -r name;do
	name=SRR11281949
	name1=${name}_R1
	name2=${name}_R2
	source /cluster/home/futing/software/juicer_CPU/scripts/common/countligations.sh
	echo "Running: bwa mem -SP5M $threadstring $refSeq $name1$ext $name2$ext > $name$ext.sam"
	bwa mem -SP5M $threadstring $refSeq $name1$ext $name2$ext > "$name$ext.sam"
# done < '${wkdir}/srr.txt'
# 02
# name=SRR3586204
# name1=${name}_R1
# name2=${name}_R2
# source /cluster/home/futing/software/juicer_CPU/scripts/common/countligations_single.sh
# echo "bwa mem -SP5M $threadstring $refSeq $name$ext > $name$ext.sam"
# bwa mem -SP5M $threadstring $refSeq $name$ext > $name$ext.sam

# while read -r name;do
	nofrag=0
    touch "${name}${ext}_abnorm.sam" "${name}${ext}_unmapped.sam"  
    awk -v fname1="${name}${ext}_norm.txt" \
        -v fname2="${name}${ext}_abnorm.sam" \
        -v fname3="${name}${ext}_unmapped.sam" \
        -f "${juiceDir}/scripts/common/chimeric_blacklist.awk" "${name}${ext}.sam"
    if [ $? -ne 0 ]; then
        echo "***! Failure during chimera handling of ${name}${ext}"
        exit 1
    fi

    if [ -e "${name}${ext}_norm.txt" ] && [ "$site" != "none" ] && [ -e "$site_file" ]; then
        echo "${juiceDir}/scripts/common/fragment.pl ${name}${ext}_norm.txt ${name}${ext}.frag.txt $site_file..."
        "${juiceDir}/scripts/common/fragment.pl" "${name}${ext}_norm.txt" "${name}${ext}.frag.txt" "$site_file"
    elif [ "$site" == "none" ] || [ "$nofrag" -eq 1 ]; then
        echo "awk '{printf(\"%s %s %s %d %s %s %s %d\", \$1, \$2, \$3, 0, \$4, \$5, \$6, 1); for (i=7; i<=NF; i++) {printf(\" %s\", \$i);}printf(\"\n\");}' ${name}${ext}_norm.txt > ${name}${ext}.frag.txt"
        awk '{printf("%s %s %s %d %s %s %s %d", $1, $2, $3, 0, $4, $5, $6, 1); for (i=7; i<=NF; i++) {printf(" %s", $i);}printf("\n");}' "${name}${ext}_norm.txt" > "${name}${ext}.frag.txt"
    else                                                                    
        echo "***! No ${name}${ext}_norm.txt file created"
        exit 1
    fi 

    if [ $? -ne 0 ]; then
        echo "***! Failure during fragment assignment of ${name}${ext}"
        exit 1
    fi                              

    sort -T "${tmpdir}" --parallel=10 -k2,2d -k6,6d -k4,4n -k8,8n -k1,1n -k5,5n -k3,3n "${name}${ext}.frag.txt" > "${name}${ext}.sort.txt"
    if [ $? -ne 0 ]; then
        echo "***! Failure during sort of ${name}${ext}"
        exit 1
    else
        rm "${name}${ext}_norm.txt" "${name}${ext}.frag.txt"
    fi
# done < '${wkdir}/srr.txt'
