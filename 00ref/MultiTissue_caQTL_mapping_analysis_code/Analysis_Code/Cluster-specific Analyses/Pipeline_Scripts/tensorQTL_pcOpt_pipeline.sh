for j in $(seq $prCompStart $prCompEnd); do
	covFile=$path/${cpm}.pc${j}.covs.tensorQTL.txt
	if [ -f "$covFile" ]; then
		bsub -J makeCovs.peer${j} echo "$covFile exists." 
	else  
		bsub -J makeCovs.peer${j} -K -e ${path}/JobOutfiles/makeCovs.peer${j}.err.txt -o ${path}/JobOutfiles/makeCovs.peer${j}.out.txt Rscript makeCovsLoop_pipeline.pca.R $j $pcFile $sampleNumber $plinkFile $path ${path}/$cpm $i
  	fi
  

bsub -q voltron_normal -e ${path}/JobOutfiles/cluster${i}.pc${j}.Optimization.tensorqtl.allChr.err.txt -o ${path}/JobOutfiles/cluster${i}.pc${j}.Optimization.tensorqtl.allChr.out.txt -M 10000 -R "rusage[mem=10000]" "/path/to/tensorqtl --mode cis --covariates ${path}/prinComp_${j}/cluster${i}.pca${j}.covs.tensorQTL.txt --permutations 1000 --window 10000 ${path}/genotype/cluster${i}_maf_0.05_plink ${path}/chr1_subset.bed.gz ${path}/prinComp_${j}/tensorqtl_cluster${i}_prinComp${j}_Chr1_pcOptimization_4.3.24 --seed 123"
done
