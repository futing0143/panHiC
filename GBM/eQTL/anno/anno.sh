###/cluster/home/tmp/gaorx/GBM/eQTL/GBM_tumor.cis_eQTL.txt下载于pancanQTL，提取第一列为snp.txt
###/cluster/home/tmp/gaorx/GBM/eQTL/zhsW14RMePgJbYrc.txt 下载于https://grch37.ensembl.org/Homo_sapiens/Tools/VEP/Results?tl=zhsW14RMePgJbYrc-10510176，  输入snp.txt
#01 snp注释格式转换
awk 'BEGIN{OFS="\t"} {
    split($2, a, "[:-]");
    output = "chr"a[1]"\t"a[2]"\t"a[3]"\t"$1;
    if (!seen[output]++) {
        print output;
    }
}' /cluster/home/tmp/gaorx/GBM/eQTL/zhsW14RMePgJbYrc.txt >snp_anno.txt

##02 合并文件
awk -F'\t' '{split($1, snp, ":"); split($2, gene, "|"); print snp[1] "\t" gene[1] "\t" $5 "\t" $3}' /cluster/home/tmp/gaorx/GBM/eQTL/pancanQTL/GBM_tumor.cis_eQTL.txt > snp_gene.txt ###SNP	gene	beta
awk '{print $1}' snp_gene.txt >snp.txt  
awk 'NR==FNR {snp[$4]=$1"\t"$2"\t"$3; next} $1 in snp {print snp[$1], $0}' /cluster/home/tmp/gaorx/GBM/eQTL/snp_anno.txt /cluster/home/tmp/gaorx/GBM/eQTL/snp_gene.txt > snp_gene_hg19.bed

##03 转为hg38
/cluster/home/jialu/biosoft/liftOver snp_gene_hg19.bed /cluster/home/jialu/biosoft/hg19ToHg38.over.chain.gz snp_gene_hg38.bed snp_gene_hg38_unmap.bed
