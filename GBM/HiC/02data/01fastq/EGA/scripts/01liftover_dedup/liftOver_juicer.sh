#！/bin/bash

data=/cluster/home/tmp/gaorx/GBM/GBM/
result=/cluster/home/futing/Project/GBM/HiC/02data/01fastq/EGA

#find /cluster/home/tmp/EGA/EGAD00001010312/ -type f -name '*.hic.bam' -exec basename {} .hic.bam > name.txt \;

cat namep1.txt | while read line
do
    echo -e '\n'Processing $line...'\n'
    source activate juicer
    name=$(basename $line .hic.bam)
    mkdir -p $result/$name/{liftOver,aligned,tmp}
    cd $result/$name

    # 01 分割文件 准备liftOver
    awk '{print $0, NR}' "$data/$name/aligned/merged_sort.txt" > "$result/$name/liftOver/merged_sort_hg19NR.bed"     
    awk '{print $2"\t"($3-1)"\t"$3"\t"NR}' "$data/$name/aligned/merged_sort.txt" > "$result/$name/liftOver/HG19_read1.bed"
    awk '{print $6"\t"($7-1)"\t"$7"\t"NR}' "$data/$name/aligned/merged_sort.txt" > "$result/$name/liftOver/HG19_read2.bed"

    # 02 liftOver
    echo -e '\nLiftOver...\n'
    liftOver "$result/$name/liftOver/HG19_read1.bed" /cluster/home/futing/ref_genome/liftover/hg19ToHg38.over.chain "$result/$name/liftOver/HG38_read1.bed" "$result/$name/liftOver/HG38_read1_unmap.bed"
    liftOver "$result/$name/liftOver/HG19_read2.bed" /cluster/home/futing/ref_genome/liftover/hg19ToHg38.over.chain "$result/$name/liftOver/HG38_read2.bed" "$result/$name/liftOver/HG38_read2_unmap.bed"

    # 03 合并 read1 read2 再合并merged_sort.txt
    echo -e '\nMerging read1 read2 and merged_sort.txt...\n'

    sort -t $'\t' -k4,4 ./liftOver/HG38_read1.bed > ./liftOver/HG38_read1_sorted.bed
    sort -t $'\t' -k4,4 ./liftOver/HG38_read2.bed > ./liftOver/HG38_read2_sorted.bed

    # 合并 read1 read2
    join -t $'\t' -1 4 -2 4 -o 1.1,1.3,2.1,2.3,1.4 ./liftOver/HG38_read1_sorted.bed ./liftOver/HG38_read2_sorted.bed > ./liftOver/read1_read2_hg38.bed
    # 合并 read1_read2 merged_nohups_hg19
    sed -i 's/\t/ /g' ./liftOver/read1_read2_hg38.bed
    sort -k17,17 ./liftOver/merged_sort_hg19NR.bed > ./liftOver/merged_sort_hg19_sorted.bed

    join -1 5 -2 17 -o 2.1,1.1,1.2,2.4,2.5,1.3,1.4,2.8,2.9,2.10,2.11,2.12,2.13,2.14,2.15,2.16 \
        ./liftOver/read1_read2_hg38.bed \
        ./liftOver/merged_sort_hg19_sorted.bed > ./liftOver/merged_sort_hg38.bed
    # 确保第二列小于第六列 chr1 100 200 chr10 300 400    
    awk '{if ($2 <= $6) print $0; else print $1,$6,$7,$8,$5,$2,$3,$4,$12,$13,$14,$9,$10,$11,$16,$15}' \
        ./liftOver/merged_sort_hg38.bed > ./liftOver/merged_sort_correct.txt
    sort -k2,2d -k6,6d ./liftOver/merged_sort_correct.txt > aligned/merged_sort.txt

    # 04 准备 juicer

    echo -e '\nPreparing juicer...\n'
    cp $data/$name/aligned/header ./aligned/
    ln -s $data/$name/fastq .
    ln -s $data/$name/splits .

    # -y Arima之前没有
    /cluster/home/futing/software/juicer_CPU/scripts/juicer.sh \
        -S dedup \
        -g hg38 \
        -d $result/$name \
        -y Arima \   #参数写错了
        -p /cluster/home/futing/software/juicer_CPU/restriction_sites/hg38.genome \
        -y /cluster/home/futing/software/juicer_CPU/restriction_sites/hg38_Arima.txt \
        -z /cluster/home/futing/software/juicer_CPU/references/hg38.fa \
        -D /cluster/home/futing/software/juicer_CPU/ > juicer.log 2>&1

done


