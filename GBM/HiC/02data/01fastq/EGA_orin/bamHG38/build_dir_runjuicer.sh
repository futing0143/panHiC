# run_jucier_dir="run_juicer_new"
# while IFS= read -r bamfile; do
#    dirname=$(echo "$bamfile" | sed 's/.hic.bam$//')
#    mkdir "$run_jucier_dir/$dirname"
#    mv "$run_jucier_dir/$bamfile" "$run_jucier_dir/$dirname/merged_dedup.bam"
# done < hg38_bamfile.txt
# sh /cluster/home/jialu/myJuicerdir/juicer/CPU/mega_from_bams.sh \
#     -y /cluster/home/tmp/EGA/hg38_Arima.txt \
#     -d /cluster/home/tmp/EGA/EGAD00001010312/bamHG38/run_juicer_new \
#     -D /cluster/home/jialu/4DN_iPSc/pipeline/extra/juicer

# mv P530.SF12822v4_hg38.hic.bam run_juicer_new/P530.SF12822v4_hg38/merged_dedup.bam
# mv P530.SF12822v5_hg38.hic.bam run_juicer_new/P530.SF12822v5_hg38/merged_dedup.bam
#!/bin/bash

# 定义要搜索的目录和文件名模式
search_dir="/cluster/home/tmp/EGA/EGAD00001010312/bamHG38/run_juicer_new"
file_pattern="merged_dedup.sorted.bam"

# 遍历search_dir目录及其所有子目录
find "$search_dir" -type f -name "$file_pattern" | while read -r file; do
    # 对每个找到的文件执行samtools quickcheck
    samtools quickcheck "$file" && echo "File $file is intact."
done
