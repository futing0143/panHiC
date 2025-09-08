for j in $(seq $peerStart $peerEnd); do


if [[ -f "${path}/allFastqresults.peer${j}.txt" ]]
then
  echo "${path}/allFastqresults.peer${j}.txt exists on your file system."
else  
  echo "cat ${path}/peer${j}/AllSamples_fastqtl.* > ${path}/allFastqresults.peer${j}.txt
  
  wc -l ${path}/allFastqresults.peer${j}.txt >> ${path}/allQTLlineCounts.txt" > catJob.fastqtl.peer${j}.sh
  
  bsub -J peer${j}.fastQTL.catJob -e ${path}/JobOutfiles/peer${j}.fastQTL.catJob.err.txt -o ${path}/JobOutfiles/peer${j}fastQTL.catJob.out.txt sh catJob.fastqtl.peer${j}.sh
fi
done
