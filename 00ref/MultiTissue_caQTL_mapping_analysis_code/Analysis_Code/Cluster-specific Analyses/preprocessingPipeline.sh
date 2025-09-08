numClusters=11
export numClusters
echo $numClusters

clusterFile=/path/to/cluster/ID/file/all_samples_peak_by_sample_matrix_CPM_average_genrich_10.19.22.hapmapIncluded.singleSample.${numClusters}clusters.meanScaled.allPeaks.noOutliers.2.1.24.txt
export clusterFile
echo $clusterFile

path=/path/to/cluster/analysis/dir/${numClusters}_clusters_analyses
export path
echo $path

scriptPath=/path/to/cluster/scripts/cluster_qtl_pipeline_scripts
export scriptPath
echo $scriptPath


####################################################


for i in $( eval echo {1..$numClusters}); do

  if [ -d "${path}/cluster${i}" ] 
  then
      echo "Directory exists." 
  else
      echo "Error: Directory does not exist."
      mkdir ${path}/cluster${i}
  fi


  if [ -d "${path}/cluster${i}/JobOutfiles" ] 
  then
      echo "Directory exists."
  else
      echo "Error: Directory does not exist."
      mkdir ${path}/cluster${i}/JobOutfiles
  fi



  if [ -d "${path}/cluster${i}/genotype" ]
  then
      echo "Directory exists."
  else
      echo "Error: Directory does not exist."
      mkdir ${path}/cluster${i}/genotype
  fi


done


#extract cluster samples
for i in $( eval echo {1..$numClusters}); do


  if [ -f "${path}/cluster${i}/cluster${i}_CPM_average_noBL.txt" ]
  then
      bsub -J extractCluster${i} -e ${path}/cluster${i}/JobOutfiles/extractCluster${i}.err.txt -o ${path}/cluster${i}/JobOutfiles/extractCluster${i}.out.txt "echo "File exists.""
  else
      bsub -J extractCluster${i} -e ${path}/cluster${i}/JobOutfiles/extractCluster${i}.err.txt -o ${path}/cluster${i}/JobOutfiles/extractCluster${i}.out.txt -M 120000 -R "rusage[mem=120000]" Rscript ${scriptPath}/extractCluster.R ${path}/cluster${i}/cluster${i}_samples.txt $i $path
  fi
done


##add cluster peak info
for i in $( eval echo {1..$numClusters}); do

 if [ -f "${path}/cluster${i}/cluster${i}_CPM_average_noBL.withPeakInfo.txt" ]
  then
      bsub -w "done(extractCluster${i})" -J addPeakInfo.${i} -e ${path}/cluster${i}/JobOutfiles/addPeakInfo.${i}.err.txt -o ${path}/cluster${i}/JobOutfiles/addPeakInfo.${i}.out.txt "echo "File exists.""
  else
      bsub -w "done(extractCluster${i})" -J addPeakInfo.${i} -e ${path}/cluster${i}/JobOutfiles/addPeakInfo.${i}.err.txt -o ${path}/cluster${i}/JobOutfiles/addPeakInfo.${i}.out.txt -M 15000 -R "rusage[mem=15000]" Rscript ${scriptPath}/addPeakInfo.R $i $path
  fi
done


##plink extract samples filter loop
for i in $( eval echo {1..$numClusters}); do
    
    if [ -f "${path}/cluster${i}/genotype/cluster${i}_plink.bed" ]
    then
      bsub -J plinkFilterJob.cluster${i} -e ${path}/cluster${i}/JobOutfiles/cluster${i}.plink.filter.err.txt -o ${path}/cluster${i}/JobOutfiles/cluster${i}.plink.filter.out.txt "echo "File Exists""
    else
      bsub -J plinkFilterJob.cluster${i} -e ${path}/cluster${i}/JobOutfiles/cluster${i}.plink.filter.err.txt -o ${path}/cluster${i}/JobOutfiles/cluster${i}.plink.filter.out.txt -M 40000 -R "rusage[mem=40000]" Rscript ${scriptPath}/plinkFilter.R ${path}/cluster${i}/cluster${i}_samples.txt $i $path

fi
done


##plink maf filter loop
for i in $( eval echo {1..$numClusters}); do

 if [ -f "${path}/cluster${i}/genotype/cluster${i}_maf_0.05_plink.bed" ]
 then
 	echo "Plink MAF file Exists"
 else

 	bsub -w "done(plinkFilterJob.cluster${i})" -J plinkFilterJob.maf.cluster${i} -n 5 -e ${path}/cluster${i}/JobOutfiles/cluster${i}.plink.maf.filter.err.txt -o ${path}/cluster${i}/JobOutfiles/cluster${i}.plink.maf.filter.out.txt sh ${scriptPath}/plinkFilter_maf_Loop.sh
 fi

done


##plink pca loop
for i in $( eval echo {1..$numClusters}); do

 if [ -f "${path}/cluster${i}/genotype/plink.eigenvec" ]
 then
 	echo "Plink file Exists"
 else

 	bsub -w "done(plinkFilterJob.maf.cluster${i})" -J plinkPCAJob.${i} -n 5 -e ${path}/cluster${i}/JobOutfiles/plink.pca.err.txt -o ${path}/cluster${i}/JobOutfiles/plink.pca.out.txt sh ${scriptPath}/getPCA.sh $path $i
 fi

done


