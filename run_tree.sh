#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --time=6:00:00
#SBATCH --mem=8GB
#SBATCH --job-name=MatlabJobName
#SBATCH --mail-type=END
#SBATCH --mail-user=YOURNETID@nyu.edu
#SBATCH --output=slurm_out/MatlabJobName.out
#SBATCH --error=slurm_out/MatlabJobName.err

module purge
module load matlab/2020b
cd /scratch/zy2043/beamforming
cat combine_aykin_tree.m | srun matlab -nodisplay

