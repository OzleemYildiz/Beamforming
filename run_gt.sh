#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --time=24:00:00
#SBATCH --mem=8GB
#SBATCH --job-name=gt
#SBATCH --mail-type=END
#SBATCH --mail-user=zy2043@nyu.edu
#SBATCH --output=gt.out
#SBATCH --error=slurm_out/gt.err

module purge
module load matlab/2020b
cd /scratch/zy2043/beamforming/Beamforming
cat Group_Testing.m | srun matlab -nodisplay

