#!/bin/bash

dir=$1
cell=$(basename ${dir})
inputcool=${dir}/cool/${cell}_10000.cool
outputcool=${dir}/cool/${cell}_50000.cool
cooler coarsen -k 5 $inputcool -o $outputcool

cooler balance  --max-iters 1000 $outputcool
