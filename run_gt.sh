#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=4
#SBATCH --time=140:00:00
#SBATCH --mem=8GB
#SBATCH --job-name=gt_fix
#SBATCH --mail-type=END
#SBATCH --mail-user=zy2043@nyu.edu
#SBATCH --output=gt_fix.out
#SBATCH --error=gt_fix.err

module purge
module load matlab/2020b
cd /scratch/zy2043/beamforming/Beamforming
cat GT_prob.m | srun matlab -nodisplay

