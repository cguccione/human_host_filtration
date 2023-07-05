#!/bin/bash
#SBATCH -J download_fastqs
#SBATCH --mail-type=ALL         #Mail to recive
#SBATCH --mail-user=cguccion@ucsd.edu
#SBATCH --time=200:00:00        # Walltime
#SBATCH --ntasks=1             # 2 tasks
#SBATCH --nodes=1               # number of nodes
#SBATCH --mem-per-cpu=10000    # memory/cpu (in MB)
#SBATCH --array=0-28 #29-46

<<com
Date: 6/25/23

Goal: To download all the human assemblies from the 
pangenome paper in order to combine together, create 
minimap2 reference and use for host depletion. 
com

final_output=/panfs/cguccion/22_08_25_HMF_chm13_hostDepletion/length_45

#Find job array ID
J=$SLURM_ARRAY_TASK_ID
echo 'Job Arary #' $J

#Import file with all fastq names
FN=hprc_year1_assemblies_v2_sample_metadata_nameOnly.txt

#Find line correlating to current job array id 
IFS=$'\n' read -d '' -r -a lines < $FN
NAME="${lines[$J]}"

#Remove the new line character
NAME=$(echo "$NAME" | tr -d '\r')

echo $NAME

#Create urls for each file (0-28)
URL_M=https://s3-us-west-2.amazonaws.com/human-pangenomics/working/HPRC/$NAME/assemblies/year1_f1_assembly_v2_genbank/$NAME.maternal.f1_assembly_v2_genbank.fa.gz
URL_P=https://s3-us-west-2.amazonaws.com/human-pangenomics/working/HPRC/$NAME/assemblies/year1_f1_assembly_v2_genbank/$NAME.paternal.f1_assembly_v2_genbank.fa.gz

#Create urls for each file (29-46)
#<uncomment for jobs 29-46, and comment out lines above
#URL_M=https://s3-us-west-2.amazonaws.com/human-pangenomics/working/HPRC_PLUS/$NAME/assemblies/year1_f1_assembly_v2_genbank/$NAME.maternal.f1_assembly_v2_genbank.fa.gz
#URL_P=https://s3-us-west-2.amazonaws.com/human-pangenomics/working/HPRC_PLUS/$NAME/assemblies/year1_f1_assembly_v2_genbank/$NAME.paternal.f1_assembly_v2_genbank.fa.gz


#Grab info from urls
wget $URL_M
wget $URL_P

echo 'done'
