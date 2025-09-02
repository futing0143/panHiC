#!/bin/bash


:<<'END'
zcat /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/42MGBA/fastq/SRR25569739/SRR25569739_R1.fastq.gz | awk '{if(NR%4==1) print $0}' | cut -d " " -f1 | cut -d ":" -f1 > read1_names.txt
zcat /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/42MGBA/fastq/SRR25569739_R2.fastq.gz | awk '{if(NR%4==1) print $0}' | cut -d " " -f1 | cut -d ":" -f1 > read2_names.txt
diff read1_names.txt read2_names.txt > diff.txt
id=SRR25569739
x=$(echo $id | cut -b 1-6)
y=$(echo $id | cut -b 10-11)

ascp  -T -QT -l 20M -P 33001  -k 1 -i /cluster/home/futing/.aspera/connect/etc/asperaweb_id_dsa.openssh \
                    era-fasp@fasp.sra.ebi.ac.uk:vol1/fastq/SRR255/039/SRR25569739/   ./
ascp  -T -QT -l 20M -P 33001  -k 1 -i /cluster/home/futing/.aspera/connect/etc/asperaweb_id_dsa.openssh \
                    era-fasp@fasp.sra.ebi.ac.uk:vol1/srr/SRR255/039/SRR25569739/   ./
END

prefetch -p -X 60GB SRR25569739
source activate /cluster/home/futing/anaconda3/envs/download
echo -e "parallel-fastq-dump --sra-id SRR25569739 --threads 40 --outdir ./ --split-3 --gzip"
parallel-fastq-dump --sra-id SRR25569739 --threads 40 --outdir ./ --split-3 --gzip                   