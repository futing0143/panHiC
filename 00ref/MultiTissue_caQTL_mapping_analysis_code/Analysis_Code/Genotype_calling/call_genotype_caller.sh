ml gcc/5.5.0
ml picard
ml samtools
ml gatk
ml bowtie2
ml bcftools
ml vcftools
ml bedtools
ml htslib

source activate snakemake

## Define the params to run in config.yaml

## Run multiple jobs in parallel
snakemake --use-conda --jobs 50 \
    --cluster "sbatch --ntasks=1 --time=10:00:00 --partition lrgmem" \
    --rerun-incomplete \
    --keep-going \
    --latency-wait 10 \
    --printshellcmds \
    $@


