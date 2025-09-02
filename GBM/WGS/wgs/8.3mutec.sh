cat wgs.list | while read i
do
gatk --java-options "-Xmx200G -Djava.io.tmpdir=./" CalculateContamination -I ${i}/${i}.pileups.table  -O ${i}/${i}.calculatecontamination.table 

gatk --java-options "-Xmx200G -Djava.io.tmpdir=./" LearnReadOrientationModel \
       -I ${i}/${i}.tar.gz \
       -O ${i}/${i}.read.orientation.model.tar.gz
done
