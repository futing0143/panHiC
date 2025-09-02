#!/bin/bash
cd /cluster/home/futing/Project/GBM/RNA/merge/count
# 从 gene counts 归一化，存在问题，覆盖区域有问题


sed 's/\<NA\>/0/g' ./NPC.bedGraph | awk '$4 != 0' \
	> ./NPC.bedGraph.tmp && mv ./NPC.bedGraph.tmp ./NPC.bedGraph
sed 's/\<NA\>/0/g' ./U87.bedGraph | awk '$4 != 0' \
	> ./U87.bedGraph.tmp && mv ./U87.bedGraph.tmp ./U87.bedGraph

bedGraphToBigWig ./U87.bedGraph \
	/cluster/home/futing/ref_genome/hg38_25.genome ./U87_maxmin.bw

bedGraphToBigWig ./NPC.bedGraph \
	/cluster/home/futing/ref_genome/hg38_24.chrom.sizes ./NPC_maxmin.bw