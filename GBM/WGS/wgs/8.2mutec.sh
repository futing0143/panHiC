cat wgs.list | while read i
do
gatk --java-options "-Xmx200G -Djava.io.tmpdir=$i" GetPileupSummaries -R /cluster/home/haojie/hg38/Homo_sapiens_assembly38.fasta \
	-L /cluster/home/haojie/referencedata/mutec2/somatic-hg38_small_exac_common_3.hg38.vcf.gz \
	-V /cluster/home/haojie/referencedata/mutec2/somatic-hg38_small_exac_common_3.hg38.vcf.gz \
	-I $i/bwa/$i.sorted.MarkDuplicates.BQSR.bam \
	-O $i/$i.pileups.table
done
