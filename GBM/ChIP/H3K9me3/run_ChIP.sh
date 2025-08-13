#!/bin/bash

cd /cluster/home/futing/Project/GBM/CTCF/NPC/NL_25_CTCF
/cluster/home/futing/pipeline/ChIP_CUTTAG/cut2rose_lite_single.sh "" 30 SRR22398555 rose "" > NL_25_CTCF.log 2>&1
cd /cluster/home/futing/Project/GBM/CTCF/NPC/NL_25_H3K9me3
/cluster/home/futing/pipeline/ChIP_CUTTAG/cut2rose_lite_single.sh "" 30 SRR22398554 rose "" > NL_25_H3K9me3.log 2>&1
cd /cluster/home/futing/Project/GBM/CTCF/NPC/NL_27_CTCF
/cluster/home/futing/pipeline/ChIP_CUTTAG/cut2rose_lite_single.sh "" 30 SRR22398596 rose "" > NL_27_CTCF.log 2>&1
cd /cluster/home/futing/Project/GBM/CTCF/NPC/NL_27_H3K9me3
/cluster/home/futing/pipeline/ChIP_CUTTAG/cut2rose_lite_single.sh "" 30 SRR22398562 rose "" > NL_27_H3K9me3.log 2>&1
cd /cluster/home/futing/Project/GBM/CTCF/NPC/NL_18
/cluster/home/futing/pipeline/ChIP_CUTTAG/cut2rose_lite_single.sh "" 30 SRR22398558 rose "" > NL_18.log 2>&1