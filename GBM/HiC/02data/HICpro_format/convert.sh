
cool_dir=/cluster/home/tmp/GBM/HiC/02data/03cool_order/1000000

for cool_file in "$cool_dir"/*.cool; do
    # 从文件名中去掉 "_1000000.cool"，提取前缀
    prefix=$(basename "$cool_file" .cool | sed 's/_1000000//')

    # 运行 Python 脚本
    python /cluster/home/jialu/biosoft/dcHiC-master/utility/preprocess.py -input cool \
        -file "$cool_file" -genomeFile /cluster/home/jialu/genome/hg38_24chrm.chrom.size \
        -res 1000000 -prefix "${prefix}"
done


