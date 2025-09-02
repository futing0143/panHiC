cat wgs.list | while read i
do
gatk --java-options "-Xmx200G -Djava.io.tmpdir=./" Funcotator -R /cluster/home/haojie/hg38/Homo_sapiens_assembly38.fasta -V ${i}/${i}.mutec2.filter.pass.vcf -O ${i}/${i}.annotation_pass.maf --data-sources-path /cluster/home/haojie/referencedata/funcotator/funcotator_dataSources.v1.7.20200521g --output-file-format MAF --ref-version hg38 
done
