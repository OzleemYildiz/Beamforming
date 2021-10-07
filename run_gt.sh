#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --time=72:00:00
#SBATCH --mem=8GB
#SBATCH --job-name=gt_f_1
#SBATCH --mail-type=END
#SBATCH --mail-user=zy2043@nyu.edu
#SBATCH --output=gt_f_1.out
#SBATCH --error=gt_f_1.err

module purge
module load matlab/2020b
cd /scratch/zy2043/beamforming/Beamforming
cat Group_Testing.m | srun matlab -nodisplay

