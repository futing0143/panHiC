cat wgs.list | while read i
do
gatk --java-options "-Xmx200G -Djava.io.tmpdir=./" FilterMutectCalls -R /cluster/home/haojie/hg38/Homo_sapiens_assembly38.fasta -V ${i}/${i}.mutect2.vcf --contamination-table ${i}/${i}.calculatecontamination.table --stats ${i}/${i}.mutect2.vcf.stats --ob-priors ${i}/${i}.read.orientation.model.tar.gz -O ${i}/${i}.mutect2.filter.vcf
done
