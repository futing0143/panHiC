#!/bin/bash
#SBATCH -J gbm_snp
#SBATCH --output=./down_%j.log 
#SBATCH --cpus-per-task=5

firehose_get -tasks snp stddata latest gbm