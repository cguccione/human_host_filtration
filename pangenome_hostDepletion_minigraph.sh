#!/bin/bash
#SBATCH -J mini_graph_pan
#SBATCH --mail-type=ALL         #Mail to recive
#SBATCH --mail-user=cguccion@ucsd.edu
#SBATCH --time=100:00:00        # Walltime
#SBATCH --mem-per-cpu=200000     # memory/cpu (in MB)
#SBATCH --ntasks=1              # tasks
#SBATCH --cpus-per-task=1       # number of cores per task
#SBATCH --nodes=1               # number of nodes

#conda env: host_depletion 

<<com
Date: 8/14/2023 (modified)
Goal: Host depletion using minigraph and 
the CHM-T2T minigraph build of the pangenome
com

<<com Install instructions for below if needed:
minigraph: https://github.com/lh3/minigraph

pangenome
wget https://s3-us-west-2.amazonaws.com/human-pangenomics/pangenomes/freeze/freeze1/minigraph/hprc-v1.0-minigraph-chm13.gfa.gz
gzip -d hprc-v1.0-minigraph-chm13.gfa.gz
com

#Define tool & pangenome paths (upadte with correct paths)
minigraph=/panfs/cguccion/packages/minigraph/minigraph
pangenome=/panfs/cguccion/23_08_14_pangenome_minigraph/hprc-v1.0-minigraph-chm13.gfa

#Define filepath
filepath=/panfs/cguccion/23_08_14_pangenome_minigraph/
cd $filepath

#Sample specific files
sample_name=TCGA-05.sorted.filtered.R1.trimmed

#Convert fastq file into a fasta file for input into minigraph
awk 'NR%4 == 1 {print ">" $0} NR%4 == 2 {print}' $filepath/$sample_name.fastq > $filepath/$sample_name.fa

#Run minigraph using pangenome on sample
$minigraph -x sr $pangenome $filepath/$sample_name.fa > $filepath/$sample_name.chm13.gaf

echo $sample_name 'complete'




