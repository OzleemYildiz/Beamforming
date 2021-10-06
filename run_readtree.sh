#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --time=48:00:00
#SBATCH --mem=8GB
#SBATCH --job-name=tree_read2
#SBATCH --mail-type=END
#SBATCH --mail-user=zy2043@nyu.edu
#SBATCH --output=out_tree_read_2.out
#SBATCH --error=tree_read_2.err

module purge
module load matlab/2020b
cd /scratch/zy2043/beamforming/Beamforming
cat aykin_readtree.m | srun matlab -nodisplay

