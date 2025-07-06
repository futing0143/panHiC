#!/bin/bash

echo -e "\n\n\n 000# ascp Download FASTQ !!! \n\n\n" 
date

gse=$1
# output dir
outfile=$2
openssh=/Users/joanna/Documents/02.Project/GBM/Ascp/asperaweb_id_dsa.openssh

speed=$3
# 公共
total=`cat $gse | wc -l` #统计gse.txt文件的行数
# gse.txt



# 循环读取gse.txt文件
for ((i=0; i<total+2; i++));do
    id=`sed -n "$i"p $gse` #从gse.txt中读取第i行的内容

    num=`echo $id | wc -m ` #这里注意，wc -m 会把每行结尾$也算为一个字符，统计SRX的长度
    
    if [ -e $outfile/$id'_fastq/'$id'_1.fastq.gz' ] && [ -e $outfile/$id'_fastq/'$id'_2.fastq.gz' ];then
        echo "$i ||$total ||""$id  fastq is exist"
        continue 
    fi

    if [ -e $outfile/$id'/'$id'.sra' ] || [ -e $outfile/$id'/'$id'.sralite' ];then
        echo "$i ||$total ||""$id  sra is exist"
        continue  
    fi

    if [ -e $outfile/$id'/'$id'_1.fastq.gz' ] && [ -e $outfile/$id'/'$id'_2.fastq.gz' ];then
        echo "$i ||$total ||""$id  ascp is exist"
        continue 
    fi

     echo "$i ||$total || $id ing"

    if [ $num -eq 12 ]
    then
            echo "SRR + 8"
            x=$(echo $id | cut -b 1-6)
            y=$(echo $id | cut -b 10-11)
            echo "Downloading $id "
            (ascp  -T -QT -l $speed -P 33001  -k 1 -i $openssh \
                    era-fasp@fasp.sra.ebi.ac.uk:vol1/fastq/$x/0$y/$id/   ${outfile} ) # fastq改成srr
    #如果样本编号为SRR+7位数 #
    elif [ $num -eq 11 ]
    then
            echo  "SRR + 7"
            x=$(echo $id | cut -b 1-6)
            y=$(echo $id | cut -b 10-10)
            echo "Downloading $id "
            (ascp  -T -QT -l $speed -P 33001  -k 1 -i $openssh \
                            era-fasp@fasp.sra.ebi.ac.uk:vol1/fastq/$x/00$y/$id/  ${outfile} )
    #如果样本编号为SRR+6位数 #
    elif [ $num -eq 10 ]
    then
            echo  "SRR + 6"
            x=$(echo $id |cut -b 1-6)
            echo "Downloading $id "
            (ascp  -T -QT -l $speed -P 33001 -k 1 -i  $openssh \
                            era-fasp@fasp.sra.ebi.ac.uk:vol1/fastq/$x/$id/    ${outfile} )
    fi
  
done

echo $(date)
echo 'done'
