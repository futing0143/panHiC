	
bam=/cluster/home/futing/Project/GBM/HiCQTL/42MGBA_new/42MGBA_sorted.bam
threads=20
fraction=1.0
mapq=20
samtools cat -h mega_header.bam $bam > reads.bam
samtools cat -h mega_header.bam $bam | samtools view \
	-u -d "rt:0" -d "rt:1" -d "rt:2" -d "rt:3" -d "rt:4" -d "rt:5" -d "rt:7" -@ $((threads * 2)) -F 0x400 -q $mapq -s $fraction - \
	|  samtools sort -@ $threads -m 6G -o reads.sorted.bam
samtools cat -h mega_header.bam $bam | samtools view -u -@ $((threads * 2)) -F 0x400 - |  samtools sort -@ $threads -m 6G -o reads.sorted3.bam