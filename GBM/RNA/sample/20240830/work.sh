ls -d /cluster/home/tmp/gaorx/lft/20240830/analysis/*/SRR* | while read line; do 
	sh ~/RNAseq_analysis/rna1.sh $line 
done > work.log 2>&1 &
[3] 23805
cat se.txt | while read line; do 
	items=($line); dir=${items[0]}
	srr_acc=${items[1]}
	sh ~/RNAseq_analysis/rna_se.sh \
		/cluster/home/tmp/gaorx/lft/20240830/analysis/$dir/$srr_acc
done > work_se.log 2>&1 &
[3] 304259
