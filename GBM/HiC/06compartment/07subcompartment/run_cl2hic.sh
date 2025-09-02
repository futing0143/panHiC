python3 cool2hic.py -i /cluster/home/jialu/GBM/HiC/otherGBM/mcoolfile/5000/GBMmerge_5000.cool -r 5000 -o GBMmerge_5k.txt
gzip GBMmerge_5k.txt
##----------执行代码------------------
/cluster/home/jialu/4DN_iPSc/pipeline/extra/juicer/scripts/common/juicer_tools pre -r 5000 \
-d GBMmerge_5k.txt.gz GBMmerge_5k.hic /cluster/home/jialu/genome/hg38_24chrm.chrom.size

##----------不执行代码------------------
juicer_tools = /cluster/home/futing/software/juicer_CPU/scripts/common/juicer_tools.1.9.9_jcuda.0.8.jar
cat cl2hic_10k.list | while read i
do
    cat /cluster/home/jialu/genome/hg38_23 | while read chr
    do
        input=$(echo ${i}|awk '{print $1}')
        output=$(echo ${i}|awk '{print $2}')
        hicfile=$(echo ${i}|awk '{print $3}')

        # 
        python3 cool2hic.py -i ${input} -r 10000 -o 10k_KR/${output}
        gzip 10k_KR/${output}
        java -jar ${juicer_tools} pre -r 10000  -q 1 10k_KR/${output}.gz 10k_KR/${hicfile} /cluster/home/jialu/BioSoft/ABC-Enhancer-Gene-Prediction/example_chr22/TCGAout/hg38.chrom.size
        java -Xmx5g -jar /cluster/home/jialu/BioSoft/hic_emt.jar info ${hicfile}
        
        ###提取每个样本特定染色体的观测值和经过 KR 标准化的值。输出的结果包括原始观测值和标准化值的文件
        mkdir 10k_KR/${output%%_*}
        java -Xms512m -Xmx2048m -jar ${juicer_tools} dump observed KR 10k_KR/${hicfile}  ${chr} ${chr} BP 10000  10k_KR/${output%%_*}/${chr}.KRobserved
        gzip 10k_KR/${output%%_*}/${chr}.KRobserved
        java -Xms512m -Xmx2048m -jar ${juicer_tools} dump observed KR 10k_KR/GBM_10k.hic  ${chr} ${chr} BP 10000  10k_KR/GBM/${chr}.KRobserved
        gzip 10k_KR/GBM/${chr}.KRobserved
    done
done

java -Xms512m -Xmx2048m -jar ${juicer_tools} dump observed VC SKNSH_100k.hic chr8 chr8 BP 100000 SKNSH/chr8.KRobserved
gzip SKNSH/chr8.KRobserved
java -Xms512m -Xmx2048m -jar ${juicer_tools} dump observed VC SKNSH_100k.hic chr8 chr8 BP 100000 SKNSH/chr8.KRobserved
gzip SKNSH/chr8.KRobserved
java -Xms512m -Xmx5g -jar ${juicer_tools} pre -r 10000  -q 1 10k_KR/GBM_10k.txt.gz 10k_KR/GBM_10k.hic  /cluster/home/jialu/BioSoft/ABC-Enhancer-Gene-Prediction/example_chr22/TCGAout/hg38.chrom.size 