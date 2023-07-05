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

Goal: Host depletion using pangenome
com

#Find job array ID
J=$SLURM_ARRAY_TASK_ID
#J=`expr $J + 7000`
echo 'Job Arary #' $J

#Import file and final output path
#Replace this with list of fastq files you would like to host deplete
FN=/home/cguccion/projects/HMF_mets_shogtun/chm13_host_deplete/fastqList.txt
final_output=/panfs/cguccion/23_06_25_HMF_pangenome_hostDepletion

#Location of pangenome mmi 
pangenome_mmi=/panfs/cguccion/23_06_25_Pangenome_Assembley/downloaded_fastqs/fastq_files/pangenome_individual_mmi

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

fastp -l 45 -i $R1_name -I $R2_name -w 16 --stdout | minimap2 -ax sr -t 16 $pangenome_mmi/HG002.maternal.mmi - -a | samtools fastq -@ 16 -f 12 -F 256 | minimap2 -ax sr -t 16 $pangenome_mmi/HG00673.maternal.mmi - -a | samtools fastq -@ 16 -f 12 -F 256 | minimap2 -ax sr -t 16 $pangenome_mmi/HG01071.maternal.mmi - -a | samtools fastq -@ 16 -f 12 -F 256 | minimap2 -ax sr -t 16 $pangenome_mmi/HG01175.maternal.mmi - -a | samtools fastq -@ 16 -f 12 -F 256 | minimap2 -ax sr -t 16 $pangenome_mmi/HG01361.maternal.mmi - -a | samtools fastq -@ 16 -f 12 -F 256 | minimap2 -ax sr -t 16 $pangenome_mmi/HG01978.maternal.mmi - -a | samtools fastq -@ 16 -f 12 -F 256 | minimap2 -ax sr -t 16 $pangenome_mmi/HG02145.maternal.mmi - -a | samtools fastq -@ 16 -f 12 -F 256 | minimap2 -ax sr -t 16 $pangenome_mmi/HG02559.maternal.mmi - -a | samtools fastq -@ 16 -f 12 -F 256 | minimap2 -ax sr -t 16 $pangenome_mmi/HG02717.maternal.mmi - -a | samtools fastq -@ 16 -f 12 -F 256 | minimap2 -ax sr -t 16 $pangenome_mmi/HG03098.maternal.mmi - -a | samtools fastq -@ 16 -f 12 -F 256 | minimap2 -ax sr -t 16 $pangenome_mmi/HG03516.maternal.mmi - -a | samtools fastq -@ 16 -f 12 -F 256 | minimap2 -ax sr -t 16 $pangenome_mmi/NA19240.maternal.mmi - -a |samtools fastq -@ 16 -f 12 -F 256 -1 $final_output/$R1.v1.gz -2 $final_output/$R2.v1.gz 

fastp -l 45 -i $final_output/$R1.v1.gz -I $final_output/$R2.v1.gz -w 16 --stdout |minimap2 -ax sr -t 16 $pangenome_mmi/HG002.paternal.mmi - -a | samtools fastq -@ 16 -f 12 -F 256 | minimap2 -ax sr -t 16 $pangenome_mmi/HG00673.paternal.mmi - -a | samtools fastq -@ 16 -f 12 -F 256 | minimap2 -ax sr -t 16 $pangenome_mmi/HG01071.paternal.mmi - -a | samtools fastq -@ 16 -f 12 -F 256 | minimap2 -ax sr -t 16 $pangenome_mmi/HG01175.paternal.mmi - -a | samtools fastq -@ 16 -f 12 -F 256 | minimap2 -ax sr -t 16 $pangenome_mmi/HG01361.paternal.mmi - -a | samtools fastq -@ 16 -f 12 -F 256 | minimap2 -ax sr -t 16 $pangenome_mmi/HG01978.paternal.mmi - -a | samtools fastq -@ 16 -f 12 -F 256 | minimap2 -ax sr -t 16 $pangenome_mmi/HG02145.paternal.mmi - -a | samtools fastq -@ 16 -f 12 -F 256 | minimap2 -ax sr -t 16 $pangenome_mmi/HG02559.paternal.mmi - -a | samtools fastq -@ 16 -f 12 -F 256 | minimap2 -ax sr -t 16 $pangenome_mmi/HG02717.paternal.mmi - -a | samtools fastq -@ 16 -f 12 -F 256 | minimap2 -ax sr -t 16 $pangenome_mmi/HG03098.paternal.mmi - -a | samtools fastq -@ 16 -f 12 -F 256 | minimap2 -ax sr -t 16 $pangenome_mmi/HG03516.paternal.mmi - -a | samtools fastq -@ 16 -f 12 -F 256 | minimap2 -ax sr -t 16 $pangenome_mmi/NA19240.paternal.mmi - -a | samtools fastq -@ 16 -f 12 -F 256 | minimap2 -ax sr -t 16 $pangenome_mmi/HG00438.maternal.mmi - -a | samtools fastq -@ 16 -f 12 -F 256 | minimap2 -ax sr -t 16 $pangenome_mmi/HG00733.maternal.mmi - -a | samtools fastq -@ 16 -f 12 -F 256 | minimap2 -ax sr -t 16 $pangenome_mmi/HG01106.maternal.mmi - -a | samtools fastq -@ 16 -f 12 -F 256 | minimap2 -ax sr -t 16 $pangenome_mmi/HG01243.maternal.mmi - -a |samtools fastq -@ 16 -f 12 -F 256 -1 $final_output/$R1.v2.gz -2 $final_output/$R2.v2.gz

fastp -l 45 -i $final_output/$R1.v2.gz -I $final_output/$R2.v2.gz -w 16 --stdout | minimap2 -ax sr -t 16 $pangenome_mmi/HG01891.maternal.mmi - -a | samtools fastq -@ 16 -f 12 -F 256 | minimap2 -ax sr -t 16 $pangenome_mmi/HG02055.maternal.mmi - -a | samtools fastq -@ 16 -f 12 -F 256 | minimap2 -ax sr -t 16 $pangenome_mmi/HG02148.maternal.mmi - -a | samtools fastq -@ 16 -f 12 -F 256 | minimap2 -ax sr -t 16 $pangenome_mmi/HG02572.maternal.mmi - -a | samtools fastq -@ 16 -f 12 -F 256 | minimap2 -ax sr -t 16 $pangenome_mmi/HG02723.maternal.mmi - -a | samtools fastq -@ 16 -f 12 -F 256 | minimap2 -ax sr -t 16 $pangenome_mmi/HG03453.maternal.mmi - -a | samtools fastq -@ 16 -f 12 -F 256 | minimap2 -ax sr -t 16 $pangenome_mmi/HG03540.maternal.mmi - -a | samtools fastq -@ 16 -f 12 -F 256 | minimap2 -ax sr -t 16 $pangenome_mmi/NA20129.maternal.mmi - -a | samtools fastq -@ 16 -f 12 -F 256 | minimap2 -ax sr -t 16 $pangenome_mmi/HG00438.paternal.mmi - -a | samtools fastq -@ 16 -f 12 -F 256 | minimap2 -ax sr -t 16 $pangenome_mmi/HG00733.paternal.mmi - -a | samtools fastq -@ 16 -f 12 -F 256 | minimap2 -ax sr -t 16 $pangenome_mmi/HG01106.paternal.mmi - -a | samtools fastq -@ 16 -f 12 -F 256 | minimap2 -ax sr -t 16 $pangenome_mmi/HG01243.paternal.mmi - -a | samtools fastq -@ 16 -f 12 -F 256 | minimap2 -ax sr -t 16 $pangenome_mmi/HG01891.paternal.mmi - -a | samtools fastq -@ 16 -f 12 -F 256 | minimap2 -ax sr -t 16 $pangenome_mmi/HG02055.paternal.mmi - -a | samtools fastq -@ 16 -f 12 -F 256 | minimap2 -ax sr -t 16 $pangenome_mmi/HG02148.paternal.mmi - -a | samtools fastq -@ 16 -f 12 -F 256 | minimap2 -ax sr -t 16 $pangenome_mmi/HG02572.paternal.mmi - -a | samtools fastq -@ 16 -f 12 -F 256 | minimap2 -ax sr -t 16 $pangenome_mmi/HG02723.paternal.mmi - -a | samtools fastq -@ 16 -f 12 -F 256 | minimap2 -ax sr -t 16 $pangenome_mmi/HG03453.paternal.mmi - -a | samtools fastq -@ 16 -f 12 -F 256 | minimap2 -ax sr -t 16 $pangenome_mmi/HG03540.paternal.mmi - -a | samtools fastq -@ 16 -f 12 -F 256 -1 $final_output/$R1.v3.gz -2 $final_output/$R2.v3.gz

fastp -l 45 -i $final_output/$R1.v3.gz -I $final_output/$R2.v3.gz -w 16 --stdout | minimap2 -ax sr -t 16 $pangenome_mmi/NA20129.paternal.mmi - -a | samtools fastq -@ 16 -f 12 -F 256 | minimap2 -ax sr -t 16 $pangenome_mmi/HG005.maternal.mmi - -a | samtools fastq -@ 16 -f 12 -F 256 | minimap2 -ax sr -t 16 $pangenome_mmi/HG00735.maternal.mmi - -a | samtools fastq -@ 16 -f 12 -F 256 | minimap2 -ax sr -t 16 $pangenome_mmi/HG01109.maternal.mmi - -a | samtools fastq -@ 16 -f 12 -F 256 | minimap2 -ax sr -t 16 $pangenome_mmi/HG01258.maternal.mmi - -a | samtools fastq -@ 16 -f 12 -F 256 | minimap2 -ax sr -t 16 $pangenome_mmi/HG01928.maternal.mmi - -a | samtools fastq -@ 16 -f 12 -F 256 | minimap2 -ax sr -t 16 $pangenome_mmi/HG02080.maternal.mmi - -a | samtools fastq -@ 16 -f 12 -F 256 | minimap2 -ax sr -t 16 $pangenome_mmi/HG02257.maternal.mmi - -a | samtools fastq -@ 16 -f 12 -F 256 | minimap2 -ax sr -t 16 $pangenome_mmi/HG02622.maternal.mmi - -a | samtools fastq -@ 16 -f 12 -F 256 | minimap2 -ax sr -t 16 $pangenome_mmi/HG02818.maternal.mmi - -a | samtools fastq -@ 16 -f 12 -F 256 | minimap2 -ax sr -t 16 $pangenome_mmi/HG03486.maternal.mmi - -a | samtools fastq -@ 16 -f 12 -F 256 | minimap2 -ax sr -t 16 $pangenome_mmi/HG03579.maternal.mmi - -a | samtools fastq -@ 16 -f 12 -F 256 | minimap2 -ax sr -t 16 $pangenome_mmi/NA21309.maternal.mmi - -a | samtools fastq -@ 16 -f 12 -F 256 | minimap2 -ax sr -t 16 $pangenome_mmi/HG005.paternal.mmi - -a | samtools fastq -@ 16 -f 12 -F 256 | minimap2 -ax sr -t 16 $pangenome_mmi/HG00735.paternal.mmi - -a | samtools fastq -@ 16 -f 12 -F 256 | minimap2 -ax sr -t 16 $pangenome_mmi/HG01109.paternal.mmi - -a | samtools fastq -@ 16 -f 12 -F 256 | minimap2 -ax sr -t 16 $pangenome_mmi/HG01258.paternal.mmi - -a | samtools fastq -@ 16 -f 12 -F 256 | minimap2 -ax sr -t 16 $pangenome_mmi/HG01928.paternal.mmi - -a | samtools fastq -@ 16 -f 12 -F 256 | minimap2 -ax sr -t 16 $pangenome_mmi/HG02080.paternal.mmi - -a | samtools fastq -@ 16 -f 12 -F 256 -1 $final_output/$R1.v4.gz -2 $final_output/$R2.v4.gz

fastp -l 45 -i $final_output/$R1.v4.gz -I $final_output/$R2.v4.gz -w 16 --stdout | minimap2 -ax sr -t 16 $pangenome_mmi/HG02257.paternal.mmi - -a | samtools fastq -@ 16 -f 12 -F 256 | minimap2 -ax sr -t 16 $pangenome_mmi/HG02622.paternal.mmi - -a | samtools fastq -@ 16 -f 12 -F 256 | minimap2 -ax sr -t 16 $pangenome_mmi/HG02818.paternal.mmi - -a | samtools fastq -@ 16 -f 12 -F 256 | minimap2 -ax sr -t 16 $pangenome_mmi/HG03486.paternal.mmi - -a | samtools fastq -@ 16 -f 12 -F 256 | minimap2 -ax sr -t 16 $pangenome_mmi/HG03579.paternal.mmi - -a | samtools fastq -@ 16 -f 12 -F 256 | minimap2 -ax sr -t 16 $pangenome_mmi/NA21309.paternal.mmi - -a | samtools fastq -@ 16 -f 12 -F 256 | minimap2 -ax sr -t 16 $pangenome_mmi/HG00621.maternal.mmi - -a | samtools fastq -@ 16 -f 12 -F 256 | minimap2 -ax sr -t 16 $pangenome_mmi/HG00741.maternal.mmi - -a | samtools fastq -@ 16 -f 12 -F 256 | minimap2 -ax sr -t 16 $pangenome_mmi/HG01123.maternal.mmi - -a | samtools fastq -@ 16 -f 12 -F 256 | minimap2 -ax sr -t 16 $pangenome_mmi/HG01358.maternal.mmi - -a | samtools fastq -@ 16 -f 12 -F 256 | minimap2 -ax sr -t 16 $pangenome_mmi/HG01952.maternal.mmi - -a | samtools fastq -@ 16 -f 12 -F 256 | minimap2 -ax sr -t 16 $pangenome_mmi/HG02109.maternal.mmi - -a | samtools fastq -@ 16 -f 12 -F 256 | minimap2 -ax sr -t 16 $pangenome_mmi/HG02486.maternal.mmi - -a | samtools fastq -@ 16 -f 12 -F 256 | minimap2 -ax sr -t 16 $pangenome_mmi/HG02630.maternal.mmi - -a | samtools fastq -@ 16 -f 12 -F 256 | minimap2 -ax sr -t 16 $pangenome_mmi/HG02886.maternal.mmi - -a | samtools fastq -@ 16 -f 12 -F 256 | minimap2 -ax sr -t 16 $pangenome_mmi/HG03492.maternal.mmi - -a | samtools fastq -@ 16 -f 12 -F 256 | minimap2 -ax sr -t 16 $pangenome_mmi/NA18906.maternal.mmi - -a | samtools fastq -@ 16 -f 12 -F 256 | minimap2 -ax sr -t 16 $pangenome_mmi/HG00621.paternal.mmi - -a | samtools fastq -@ 16 -f 12 -F 256 | minimap2 -ax sr -t 16 $pangenome_mmi/HG00741.paternal.mmi - -a | samtools fastq -@ 16 -f 12 -F 256 | minimap2 -ax sr -t 16 $pangenome_mmi/HG01123.paternal.mmi - -a | samtools fastq -@ 16 -f 12 -F 256 -1 $final_output/$R1.v5.gz -2 $final_output/$R2.v5.gz

fastp -l 45 -i $final_output/$R1.v5.gz -I $final_output/$R2.v5.gz -w 16 --stdout | minimap2 -ax sr -t 16 $pangenome_mmi/HG01358.paternal.mmi - -a | samtools fastq -@ 16 -f 12 -F 256 | minimap2 -ax sr -t 16 $pangenome_mmi/HG01952.paternal.mmi - -a | samtools fastq -@ 16 -f 12 -F 256 | minimap2 -ax sr -t 16 $pangenome_mmi/HG02109.paternal.mmi - -a | samtools fastq -@ 16 -f 12 -F 256 | minimap2 -ax sr -t 16 $pangenome_mmi/HG02486.paternal.mmi - -a | samtools fastq -@ 16 -f 12 -F 256 | minimap2 -ax sr -t 16 $pangenome_mmi/HG02630.paternal.mmi - -a | samtools fastq -@ 16 -f 12 -F 256 | minimap2 -ax sr -t 16 $pangenome_mmi/HG02886.paternal.mmi - -a | samtools fastq -@ 16 -f 12 -F 256 | minimap2 -ax sr -t 16 $pangenome_mmi/HG03492.paternal.mmi - -a | samtools fastq -@ 16 -f 12 -F 256 | minimap2 -ax sr -t 16 $pangenome_mmi/NA18906.paternal.mmi - -a | samtools fastq -@ 16 -f 12 -F 256 -1 $final_output/$R1 -2 $final_output/$R2

echo 'Finished depletion, location:' $final_output/$R1

echo 'end'
