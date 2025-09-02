cat wgs.list | while read i
do
gatk --java-options "-Xmx200G -Djava.io.tmpdir=./" Mutect2 \
	-R /cluster/home/haojie/hg38/Homo_sapiens_assembly38.fasta \
	-I $i/bwa/$i.sorted.MarkDuplicates.BQSR.bam  \
	-O $i/$i.mutect2.vcf \
	--germline-resource /cluster/home/haojie/hg38/af-only-gnomad.hg38.biallelic.vcf.gz \
	--f1r2-tar-gz $i/$i.tar.gz \
	-pon /cluster/home/jialu/GBM/WGS/1000g_pon.hg38.vcf 
done
