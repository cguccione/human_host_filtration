#!/bin/bash
#SBATCH -J host-deplete-HMF
#SBATCH --mail-type=ALL         #Mail to recive
#SBATCH --mail-user=cguccion@ucsd.edu
#SBATCH --time=200:00:00        # Walltime
#SBATCH --ntasks=16             # 2 tasks
#SBATCH --nodes=1               # number of nodes
#SBATCH --mem-per-cpu=10000    # memory/cpu (in MB)
#SBATCH --array=0

#conda activate ebi_sra_importer 

<<com
Date: 7/4/2023

Goal: Host depletion using 
only hg38 + T2T
com

#Find job array ID
J=$SLURM_ARRAY_TASK_ID
#J=`expr $J + 7000`
echo 'Job Arary #' $J

#Import file and final output path
#Replace this with list of fastq files you would like to host deplete
FN=/home/cguccion/projects/HMF_mets_shogtun/chm13_host_deplete/fastqList.txt
final_output=/panfs/cguccion/23_06_25_HMF_pangenome_hostDepletion

#Location of mmi 
human_GRC_mmi=/databases/minimap2/human-GRC-db.mmi
human_GCA_mmi=/databases/minimap2/human-GCA-phix-db.mmi

#Find line correlating to current job array id 
IFS=$'\n' read -d '' -r -a lines < $FN
LINE="${lines[$J]}"
echo $LINE

#Split line into R1 and R2
ARR=(${LINE//;/ })
R1=${ARR[0]}
R2=${ARR[1]}

#Folder name
fn=$(echo $R1 | cut -d "/" -f 1)

#Pull fastq file for R1
R1_only=$(echo $R1 | cut -d "/" -f 2)
R1_name=/qmounts/qiita_test_data/per_sample_FASTQ/$R1

#Pull fastq file for R2
R2_only=$(echo $R2 | cut -d "/" -f 2)
R2_name=/qmounts/qiita_test_data/per_sample_FASTQ/$R2

#Creating folder for output if needed
folder=$final_output/$fn
mkdir -p $folder

#Starting acutal depletion
echo 'Starting depletion'
echo 'R1 name' $R1_name
echo 'R2 name' $R2_name

#hg38 + T2T Host Depletion
fastp -l 45 -i $R1_name -I $R2_name -w 16 --stdout | minimap2 -ax sr -t 16 human-GRC-db.mmi - -a | samtools fastq -@ 16 -f 12 -F 256 | minimap2 -ax sr -t 16 human-GCA-phix-db.mmi - -a | samtools fastq -@ 16 -f 12 -F 256 -1 $final_output/$R1 -2 $final_output/$R2

echo 'Finished depletion, location:' $final_output/$R1

echo 'end'
