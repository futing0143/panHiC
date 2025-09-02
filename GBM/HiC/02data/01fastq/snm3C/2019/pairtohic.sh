#!/bin/bash
filedir=/cluster/home/Kangwen/Hic/data_new/sn_m3c_hum/GSE130711/
tmpdir=/cluster/home/futing/Project/GBM/HiC/02data/01fastq/snm3C/2019/tmp
mkdir -p "${tmpdir}"
cd /cluster/home/futing/Project/GBM/HiC/02data/01fastq/snm3C/2019

files=()
while IFS= read -r line; do
    hicfile="${filedir}/sn_m3c_${line}_tmp/Result/${line}.nodups.pairs.gz"
    if [[ -f "$hicfile" ]]; then
        # files+=("<(gunzip -c \"$hicfile\")")
        files+=("$hicfile")
    else
        echo "文件 $hicfile 不存在，跳过..."
    fi
done < "/cluster/home/futing/Project/GBM/HiC/02data/01fastq/snm3C/2019/meta/OPC.txt"

# 使用 eval 将数组中的每个文件解压内容传递给 sort 命令
# eval sort --parallel=20 -T "${tmpdir}" -m -k2,2d -k4,4d "${files[@]}" > "./OPC.nodups.pairs"
sh /cluster/home/futing/Project/GBM/HiC/02data/01fastq/snm3C/2019/merge_pairs.sh OPC ${files[@]}

# process the 1_10 combination error
gunzip -c /cluster/home/futing/Project/GBM/HiC/02data/01fastq/snm3C/2019/old/OPC.pairs.gz | grep -v "^#" > OPC_noheader.pairs
# awk '{if ($2 == "chr1" && $4 == "chr10") {print NR,$0; exit}}' OPC_noheader.pairs
# awk '{if ($2 == "chr10" && $4 == "chr1") {print NR,$0; exit}}'

awk '{if ($2 <= $4) print $0; else print $1,$4,$5,$3,$4,$7,$6,$8,$10,$9,$14,$15,$16,$11,$12,$13}' /cluster/home/futing/Project/GBM/HiC/02data/01fastq/snm3C/2019/OPC_noheader.pairs \
		> /cluster/home/futing/Project/GBM/HiC/02data/01fastq/snm3C/2019/OPC_noheader_correct.pairs
cat header.pairs OPC_noheader_correct.pairs > OPC.pairs

bgzip -f OPC.pairs
pairtools sort --nproc 12 \
    /cluster/home/futing/Project/GBM/HiC/02data/01fastq/snm3C/2019/OPC.pairs.gz \
    -o OPC_sorted.pairs.gz
pairix -f OPC_sorted.pairs.gz

echo -e "(-: Finished sorting all merged_nodups files into a single merge."

java -Xmx200G -Xms100G -Djava.awt.headless=true \
    -jar /cluster/home/futing/software/juicer_CPU/scripts/common/juicer_tools.jar \
    pre --threads 20 -j 20 OPC_sorted.pairs.gz OPC.hic /cluster/home/futing/ref_genome/hg38.genome
echo "(-: Finished creating .hic file."

