#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --time=140:00:00
#SBATCH --mem=8GB
#SBATCH --job-name=tree1
#SBATCH --mail-type=END
#SBATCH --mail-user=zy2043@nyu.edu
#SBATCH --output=out_tree1_cont.out
#SBATCH --error=tree1_cont.err

module purge
module load matlab/2020b
cd /scratch/zy2043/beamforming/Beamforming
cat combine_aykin_tree.m | srun matlab -nodisplay

