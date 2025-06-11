#!/bin/bash

rsync -avh --progress  --partial  /cluster/home/futing/Project/panCancer/CML /cluster2/home/futing/Project/panCancer/CML

rsync -avh --progress  --partial  /cluster/home/futing/Project/panCancer/CRC/GSE137188 /cluster2/home/futing/Project/panCancer/CRC/GSE137188

sh /cluster2/home/futing/Project/panCancer/CRC/sbatch.sh GSE137188 14-431 MboI
diff -qr /cluster2/home/futing/Project/panCancer /cluster/home/futing/Project/panCancer > check.txt
/cluster2/home/futing/Project/panCancer/CRC/GSE137188/14-431
