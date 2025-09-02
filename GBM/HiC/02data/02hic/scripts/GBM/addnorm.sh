#!/bin/bash

java -Xmx128G -Ddevelopment=false -jar /cluster/home/futing/software/juicer_CPU/scripts/common/juicer_tools.2.13.jar \
    addNorm -j 20 --check-ram-usage /cluster/home/futing/Project/GBM/HiC/02data/02hic/GBM/GBM.hic
