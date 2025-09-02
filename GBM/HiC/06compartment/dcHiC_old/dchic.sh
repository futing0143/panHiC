###下载https://github.com/ay-lab/dcHiC Technical Specifications / Errors To Check模块的hg38.refGene.gtf.gz；hg38.fa来自ref_genome；chrom.sizes来自genemo；cytoBand.txt.gz来自第一次的log文件
###对cytoBand.txt.gz和hg38.refGene.gtf.gz  解压>
#grep -E '^chr([1-9]|1[0-9]|2[0-2]|X)\b' cytoBand.txt >cytoBand.txt1 再压缩改名


##预处理
for i in 4DNFI5LCW273 NPC GBMmerge pGBMmerge 
do
python /cluster/home/jialu/BioSoft/dcHiC-master/utility/preprocess.py -input cool \
    -file /cluster/home/jialu/GBM/HiC/otherGBM/mcoolfile/100k/${i}_100k.cool \
    -genomeFile /cluster/home/jialu/GBM/HiC/otherGBM/mcoolfile/dchic/hg38_100000_goldenpathData/hg38.chrom.sizes \
    -res 100000 -prefix ${i}
done


###生成_PCA 文件夹
Rscript /cluster/home/jialu/BioSoft/dcHiC-master/dchicf.r --file input.txt --pcatype cis --dirovwt T 
Rscript /cluster/home/jialu/BioSoft/dcHiC-master/dchicf.r --file input.txt --pcatype select --dirovwt T --genome hg38 --gfolder hg38_100000_goldenpathData


###生成DifferentialResult/GBM_vs_3type 文件夹
Rscript /cluster/home/jialu/BioSoft/dcHiC-master/dchicf.r --file input.txt --pcatype analyze --dirovwt T --diffdir GBM_vs_3type
Rscript /cluster/home/jialu/BioSoft/dcHiC-master/dchicf.r --file input.txt  --pcatype subcomp --dirovwt T --diffdir GBM_vs_3type
Rscript /cluster/home/jialu/BioSoft/dcHiC-master/dchicf.r --file input.txt  --pcatype viz --diffdir GBM_vs_3type --genome hg38 
Rscript /cluster/home/jialu/BioSoft/dcHiC-master/dchicf.r --file input.txt --pcatype enrich --genome hg38  \
    --diffdir GBM_vs_3type --exclA F --region anchor --pcgroup pcQnm --interaction intra --pcscore F --compare F
