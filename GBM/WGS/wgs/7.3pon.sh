gatk --java-options "-Xmx200G -Djava.io.tmpdir=./" CreateSomaticPanelOfNormals -R /cluster/home/haojie/hg38/Homo_sapiens_assembly38.fasta \
	-V gendb://pon_db \
	-O pon.vcf.gz
