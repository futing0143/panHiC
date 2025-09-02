#for file_name in `ls ./raw_TNmixed/ `;do basename ${file_name%_*} | tee -a fileID.txt;done
#uniq fileID.txt > fileID_u.txt

cat wgs_left.list | while read i
do
sh ./map2.sh /cluster/home/hjwu/dfci/gbm_data/wgs/fastq/${i}/${i}
done 
