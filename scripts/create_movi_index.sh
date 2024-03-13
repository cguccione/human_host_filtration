#!/bin/bash

#SBATCH -J build_movi_index
#SBATCH --nodes=1
#SBATCH --cpus-per-task=16
#SBATCH --partition=highmem
#SBATCH --mem 1400gb
#SBATCH --mail-user= # set email
#SBATCH --mail-type=ALL

echo "Building human movi index..."
bash /path/to/movi/preprocess_ref.sh default /path/to/assemblies.txt /path/to/out/folder
echo 'Done building'
