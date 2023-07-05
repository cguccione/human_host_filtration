#!/bin/bash
#SBATCH -J create_minimap_index
#SBATCH --mail-type=ALL         #Mail to recive
#SBATCH --mail-user=cguccion@ucsd.edu
#SBATCH --time=200:00:00        # Walltime
#SBATCH --mem-per-cpu=20000     # memory/cpu (in MB)
#SBATCH --ntasks=1              # tasks
#SBATCH --cpus-per-task=1       # number of cores per task
#SBATCH --nodes=1               # number of nodes
#SBATCH --array=0-93

<<com
Date: 7/3/23

Goal: To create a minimap2 index from each of the fastq files
in the pangenome.  Will use this minimap2 index for
host depletion across all pangenome.
com

#Find job array ID
J=$SLURM_ARRAY_TASK_ID
echo 'Job Arary #' $J
echo

#Import file with filenames
folder_path="/panfs/cguccion/23_06_25_Pangenome_Assembley/downloaded_fastqs/fastq_files/fastqs"
FN=pangenome_filenames.txt

#Find line correlating to current job array id 
IFS=$'\n' read -d '' -r -a lines < $FN
LINE="${lines[$J]}"
echo $LINE

#Extract part of line with fastq file
FA=$(echo $LINE | cut -d " " -f 9)

# Extract the desired part of the filename for mmi renaming
IFS='.' read -ra parts <<< "$FA"
variable_name="${parts[0]}.${parts[1]}"
echo 'Fastq filename' $FA
echo 'Varible name' $variable_name

#Create minimap2 index
minimap2 -d $variable_name.mmi $folder_path/$FA

echo 'done'
