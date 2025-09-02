for i in GBMDGC GBMstem
do
awk '{print $4":"$5}' ${i}_EnhancerPredictions.txt |sed 1d >> ${i}_EGpair_list.txt 
awk '{print $5}' ${i}_EnhancerPredictions.txt |sed 1d| sort |uniq -c >> ${i}_Gcount.txt
awk '{print $4}' ${i}_EnhancerPredictions.txt |sed 1d| sort |uniq -c >> ${i}_Ecount.txt
#cat ${i}_Gcount.txt|awk '{sum+=$1} END {print "Average = ", sum/NR}'
#cat ${i}_Ecount.txt|awk '{sum+=$1} END {print "Average = ", sum/NR}'  
#awk '{print $1}' ${i}_EnhancerPredictions.txt |sed 1d| sort |uniq -c >> ${i}_chr.txt
done
	