#perform VC normalization
#提取每个样本特定染色体的观测值和经过 VC 标准化的值。输出的结果包括原始观测值和标准化值的文件
cat VC.list | while read i
do
    sample=$(echo ${i} | awk '{print $1}')
    name=$(echo ${i} | awk '{print $2}')
    chr=$(echo ${i} | awk '{print $3}')
    echo "sample is ${sample}"
    echo "name is ${name}"
    echo "chr is ${chr}"
    
    java -Xms512m -Xmx2048m -jar /cluster/home/futing/software/juicer_CPU/scripts/common/juicer_tools.jar \
    dump observed VC ${sample} ${chr} ${chr} BP 5000 ./${name}/chr${chr}/chr${chr}.VCobserved
    java -Xms512m -Xmx2048m -jar /cluster/home/futing/software/juicer_CPU/scripts/common/juicer_tools.jar \
    dump norm VC ${sample} ${chr} BP 5000 ./${name}/chr${chr}/chr${chr}.VCnorm
    
    gzip ./${name}/chr${chr}/chr${chr}.VCobserved
    gzip ./${name}/chr${chr}/chr${chr}.VCnorm
done

# . 原本是 GBM_hic