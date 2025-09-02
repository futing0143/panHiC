#for file_name in `ls ./rawmixed/ `;do basename ${file_name%_*} | tee -a fileID.txt;done
#uniq fileID.txt > fileID_u.txt


#for i in $(find ./raw_data/ -name *.fq.gz);do cp -vf $i ./rawmixed/;done
cd rawmixed/
#for name in `ls *1.fq.gz`;do mv $name ${name%_1.fq.gz*}_R1.fq.gz;done
for name in `ls *2.fq.gz`;do mv $name ${name%_2.fq.gz*}_R2.fq.gz;done
