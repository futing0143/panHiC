# wget -c https://sra-pub-run-odp.s3.amazonaws.com/sra/SRR4417704/SRR4417704
# wget -c https://sra-pub-run-odp.s3.amazonaws.com/sra/SRR4417705/SRR4417705
# wget -c https://sra-pub-run-odp.s3.amazonaws.com/sra/SRR4417706/SRR4417706
# wget -c https://sra-pub-run-odp.s3.amazonaws.com/sra/SRR4423199/SRR4423199
# wget -c https://sra-pub-run-odp.s3.amazonaws.com/sra/SRR4423200/SRR4423200
/cluster/home/jialu/BioSoft/SRAToolkit/sratoolkit.2.11.2-centos_linux64/bin/fastq-dump --split-3 --gzip SRR4417704.sra -O /cluster/home/jialu/GBM/gsc/rna
/cluster/home/jialu/BioSoft/SRAToolkit/sratoolkit.2.11.2-centos_linux64/bin/fastq-dump --split-3 --gzip SRR4417705.sra -O /cluster/home/jialu/GBM/gsc/rna
/cluster/home/jialu/BioSoft/SRAToolkit/sratoolkit.2.11.2-centos_linux64/bin/fastq-dump --split-3 --gzip SRR4417706.sra -O /cluster/home/jialu/GBM/gsc/rna
/cluster/home/jialu/BioSoft/SRAToolkit/sratoolkit.2.11.2-centos_linux64/bin/fastq-dump --split-3 --gzip SRR4423199.sra -O /cluster/home/jialu/GBM/gsc/rna
/cluster/home/jialu/BioSoft/SRAToolkit/sratoolkit.2.11.2-centos_linux64/bin/fastq-dump --split-3 --gzip SRR4423200.sra -O /cluster/home/jialu/GBM/gsc/rna


