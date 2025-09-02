cat wgs.list | while read i
do
grep "#" ${i}/${i}.mutect2.filter.vcf > ${i}/tmp.vcf
grep -v "##" ${i}/${i}.mutect2.filter.vcf | awk -F " " '{if($7~/^PASS/) print $0}'  > ${i}/tmp2.vcf
cat ${i}/tmp.vcf ${i}/tmp2.vcf > ${i}/${i}.mutec2.filter.pass.vcf
rm ${i}/tmp.vcf
rm ${i}/tmp2.vcf
done
