#!/bin/bash

#----------------------------------注释-------------------------------------#
#这个脚本的作用是获取所有的文件路径及文件名，然后把文件名写入到gene-fpkm02-matrix.txt中
#--------------------------------------------------------------------------#
list_csv=""
list_name="gene"
for i in ./rsem_out/*genes.results
do
    #把所有的genes.results文件路径都放到list_csv中
    list_csv=${list_csv}" "${i}
    # i_name1=${i#*/}
    # i_name2=${i_name1#*/}
    i_name2=$(basename $i .genes.results)
    #把所有的genes.results文件名都放到list_name中
    list_name=${list_name}" "${i_name2}
    #echo ${list_name}
done
echo $list_name > ./gene-fpkm-matrix.txt
echo $list_name > ./gene-tpm-matrix.txt
echo $list_name > ./gene-count-matrix.txt

#python ./rsem-count-extract.py ${list_csv}
python /cluster/home/futing/pipeline/RNA/feature-count-extract.py 6 ${list_csv} >> ./gene-fpkm-matrix.txt
python /cluster/home/futing/pipeline/RNA/feature-count-extract.py 5 ${list_csv} >> ./gene-tpm-matrix.txt
python /cluster/home/futing/pipeline/RNA/feature-count-extract.py 4 ${list_csv} >> ./gene-count-matrix.txt