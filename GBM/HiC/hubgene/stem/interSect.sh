#提取每个文件的前三列并且去重
cat file.list | while read i
do
    #awk 'NR>1' ${i} >> ${i}1
    awk '{print $1"\t"$2"\t"$3}' ${i}1 |sort |uniq > ${i%%_*}_E
    #awk '{print $5}' ${i}1 |sort |uniq > ${i%%_*}_G
    #rm ${i}.bed
done