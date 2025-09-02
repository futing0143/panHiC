cat wgs.list | while read i
do
grep -v "##" ${i}/${i}.annotation_pass.maf | grep -v "#" > maf/${i}.maf 
done
