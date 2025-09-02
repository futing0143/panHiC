tmp=""
for i in $(ls *.vcf.gz)
do
    argv="$tmp -V $i"
    tmp=$argv
done
echo ${argv} 

gatk --java-options "-Xmx200G -Djava.io.tmpdir=./" GenomicsDBImport \
    -R /cluster/home/haojie/hg38/Homo_sapiens_assembly38.fasta \
    -L /cluster/home/jialu/wes_data_0705/WES/LCOC/hg38_RefSeq.interval_list \
    --reader-threads 20 \
    --genomicsdb-workspace-path pon_db \
    ${argv}
