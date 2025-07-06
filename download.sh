#!/bin/bash

mkdir /cluster/home/futing/Project/panCancer/CML
cd /cluster/home/futing/Project/panCancer/CML
mkdir -p {K562,HAP1,KBM7}
# /cluster/home/futing/pipeline/Ascp/ascp.sh ../CML.txt ./ 10M
/cluster/home/futing/pipeline/Ascp/ascp.sh ./K562.txt ./K562 10M
/cluster/home/futing/pipeline/Ascp/ascp.sh ./HAP1.txt ./HAP1 10M
/cluster/home/futing/pipeline/Ascp/ascp.sh ./HAP1_p.txt ./HAP1 15M
/cluster/home/futing/pipeline/Ascp/ascp.sh ./KBM7.txt ./KBM7 10M

/cluster/home/futing/pipeline/Ascp/ascp.sh ./14-431.txt ./ 20M
/cluster/home/futing/pipeline/Ascp/ascp.sh ./GC.txt ./ 20M
