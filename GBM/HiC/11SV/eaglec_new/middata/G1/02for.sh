echo $(pwd)
for i in {1..16}; do sbatch "$(pwd)/slurm-predictSV.sh"; sleep 40s; done
#The above command will launch 16 parallelized jobs and should be able to finish within 2 hours.
