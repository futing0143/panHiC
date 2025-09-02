#!/bin/bash
#SBATCH -J dLOAD
#SBATCH -N 1
#SBATCH -p normal
#SBATCH --output=dLOAD.out
#SBATCH --error=dLOAD.err
#SBATCH --mail-type=all
#SBATCH --mail-user=kalozzhou@163.com #change to your email address

wget https://ftp.ncbi.nlm.nih.gov/geo/samples/GSM4417nnn/GSM4417603/suppl/GSM4417603_U118-MG_b38d5.mcool
wget https://ftp.ncbi.nlm.nih.gov/geo/samples/GSM4417nnn/GSM4417604/suppl/GSM4417604_U87-MG_b38d5.hic
wget https://ftp.ncbi.nlm.nih.gov/geo/samples/GSM4417nnn/GSM4417604/suppl/GSM4417604_U87-MG_b38d5.mcool
wget https://ftp.ncbi.nlm.nih.gov/geo/samples/GSM4417nnn/GSM4417627/suppl/GSM4417627_U343_b38d5.hic
wget https://ftp.ncbi.nlm.nih.gov/geo/samples/GSM4417nnn/GSM4417627/suppl/GSM4417627_U343_b38d5.mcool
wget https://ftp.ncbi.nlm.nih.gov/geo/samples/GSM4417nnn/GSM4417601/suppl/GSM4417601_A172_b38d5.hic
wget https://ftp.ncbi.nlm.nih.gov/geo/samples/GSM4417nnn/GSM4417601/suppl/GSM4417601_A172_b38d5.mcool
wget https://ftp.ncbi.nlm.nih.gov/geo/samples/GSM4417nnn/GSM4417602/suppl/GSM4417602_SW1088_b38d5.hic
wget https://ftp.ncbi.nlm.nih.gov/geo/samples/GSM4417nnn/GSM4417602/suppl/GSM4417602_SW1088_b38d5.hmcool
wget https://ftp.ncbi.nlm.nih.gov/geo/samples/GSM4969nnn/GSM4969658/suppl/GSM4969658_DIPG007-un-hic.hic
wget https://ftp.ncbi.nlm.nih.gov/geo/samples/GSM4969nnn/GSM4969659/suppl/GSM4969659_SF9427-un-hic.hic
wget https://ftp.ncbi.nlm.nih.gov/geo/samples/GSM4969nnn/GSM4969660/suppl/GSM4969660_NHA-un-hic.hic
wget https://ftp.ncbi.nlm.nih.gov/geo/samples/GSM4969nnn/GSM4969661/suppl/GSM4969661_DIPG-3810-Arima-allReps-filtered.hic
wget https://ftp.ncbi.nlm.nih.gov/geo/samples/GSM4969nnn/GSM4969657/suppl/GSM4969657_DIPGXIII-un-hic.hic
wget https://www.ncbi.nlm.nih.gov/geo/download/?acc=GSM4969660&format=file&file=GSM4969660%5FNHA%2Dun%2Dhic%2Ehic
wget https://ftp.ncbi.nlm.nih.gov/geo/series/GSE185nnn/GSE185192/suppl/GSE185192_NPC_HiC_IsoE.hic
wget https://ftp.ncbi.nlm.nih.gov/geo/samples/GSM4417nnn/GSM4417602/suppl/GSM4417602_SW1088_b38d5.mcool
wget https://ftp.ncbi.nlm.nih.gov/geo/samples/GSM4417nnn/GSM4417603/suppl/GSM4417603_U118-MG_b38d5.hic
wget https://ftp.ncbi.nlm.nih.gov/geo/samples/GSM4417nnn/GSM4417601/suppl/GSM4417601_A172_b38d5.hic
wget https://ftp.ncbi.nlm.nih.gov/geo/samples/GSM4417nnn/GSM4417601/suppl/GSM4417601_A172_b38d5.mcool
wget https://ftp.ncbi.nlm.nih.gov/geo/samples/GSM4417nnn/GSM4417602/suppl/GSM4417602_SW1088_b38d5.hic
wget https://ftp.ncbi.nlm.nih.gov/geo/samples/GSM4417nnn/GSM4417602/suppl/GSM4417602_SW1088_b38d5.hmcool
wget https://ftp.ncbi.nlm.nih.gov/geo/samples/GSM4969nnn/GSM4969658/suppl/GSM4969658_DIPG007-un-hic.hic
wget https://ftp.ncbi.nlm.nih.gov/geo/samples/GSM4969nnn/GSM4969659/suppl/GSM4969659_SF9427-un-hic.hic
wget https://ftp.ncbi.nlm.nih.gov/geo/samples/GSM4969nnn/GSM4969660/suppl/GSM4969660_NHA-un-hic.hic
wget https://ftp.ncbi.nlm.nih.gov/geo/samples/GSM4969nnn/GSM4969661/suppl/GSM4969661_DIPG-3810-Arima-allReps-filtered.hic
wget https://ftp.ncbi.nlm.nih.gov/geo/samples/GSM4969nnn/GSM4969657/suppl/GSM4969657_DIPGXIII-un-hic.hic
wget https://wangftp.wustl.edu/hubs/johnston_gallo/G523_inter_30.hic
wget https://wangftp.wustl.edu/hubs/johnston_gallo/G567_inter_30.hic
wget https://wangftp.wustl.edu/hubs/johnston_gallo/G583_inter_30.hic
