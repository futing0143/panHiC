#!/bin/bash

cd /cluster2/home/futing/Project/panCancer/OV

# for f in /cluster2/home/futing/Project/panCancer/OV/*.fastq.gz; do
#     if gzip -t "$f" 2>/dev/null; then
#         echo "[OK]   $f"
#     else
#         echo "[BAD]  $f"
#     fi
# done
source activate ~/miniforge3/envs/juicer
for f in /cluster2/home/futing/Project/panCancer/OV/SRR24134017_2.fastq.gz;do
	if gzip -t "$f" 2>/dev/null; then
		echo "[OK]   $f"
	else
		echo "[BAD]  $f"
	fi
done

for f in /cluster2/home/futing/Project/panCancer/OV/*.fastq.gz.1;do
	if gzip -t "$f" 2>/dev/null; then
		echo "[OK]   $f"
	else
		echo "[BAD]  $f"
	fi
done