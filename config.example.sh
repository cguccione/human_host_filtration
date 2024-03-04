#!/bin/bash
#

# configure experiment parameters
IN="/path/to/raw/fastq/files" 
OUT="/path/of/output/host-filtered/files"
MODE="PE" # "SE" (single-end) or "PE" (paired-end), majority of the data used in the Knight lab is paired-end
METHODS=("ALIGN-HG38" "ALIGN-T2T" "INDEX-HPRC") # any combination of "ALIGN-HG38", "ALIGN-T2T", "ALIGN-HPRC"(Note: The way this is stored in barnacle currently, this will also filter for hg38 and T2T), or "INDEX-HPRC"; do not comma separate
SAVE_INTERMEDIATE=1 # 0 for TRUE and 1 for FALSE
THREADS=7 # changes to THREADS must also be reflected in #SBATCH --ntasks=7 within `filter.sh`

# configure index filtration parameters
METRIC="custom" # "max", "average", or "custom" (custom was used in the paper)
THRESHOLD=0.175 # suggested thresholds are 31 for "max", 3.206 for "average", and 0.175 for "custom" (0.175 was used in the paper)
MIN_RUN_LENGTH=5 # part of the custom algorithm (5 was used in the paper)

# configure software and reference paths
MOVI_PATH="/panfs/cguccion/packages/lucas_Movi/Movi/build/movi-default"  # path to movi-default executable on barnacle
MOVI_INDEX_PATH="/scratch/movi_hg38_chm13_hprc94" # path to prebuilt movi_index.bin on barnacle, must be on a compute node
MINIMAP2_PATH="minimap2" #Calling minimap2 from conda env
MINIMAP2_HG38_INDEX_PATH="/panfs/cguccion/23_06_25_Pangenome_Assembley/downloaded_fastqs/fastq_files/pangenome_individual_mmi/human-GRC-db.mmi" # hg38 index on barnacle
MINIMAP2_T2T_INDEX_PATH="/panfs/cguccion/23_06_25_Pangenome_Assembley/downloaded_fastqs/fastq_files/pangenome_individual_mmi/human-GCA-phix-db.mmi" # t2t index on barancle
MINIMAP2_HPRC_INDEX_PATH="/panfs/cguccion/23_06_25_Pangenome_Assembley/downloaded_fastqs/fastq_files/pangenome_individual_mmi" # directory of pangenome indexes (including hg38 and t2t)
ADAPTERS="ref/known_adapters.fna" #Known adapters (used in paper)
TMP="/panfs/YOUR_USERNAME/tmp" #Change to your username on barnacle, create a TMP if you don't have one

# END CONFIGURATION

# check variables are valid
if [ -z "$TMP" ]; then
  echo "TMP is not set. Please set TMP to a valid directory."
  exit 1
fi

# define filtration map
declare -A file_map
file_map["FASTP"]="filter_fastp.sh"
file_map["ALIGN-HG38"]="filter_align_hg38.sh"
file_map["ALIGN-T2T"]="filter_align_t2t.sh"
file_map["INDEX-HPRC"]="filter_index_hprc.sh"
file_map["ALIGN-HPRC"]="filter_align_hprc.sh"
#file_map["ALIGN-HPRC-PESE"]="filter_align_hg38_PESE.sh"

# conda
CONDA_ENV_NAME=human-filtration #update this if your conda env has a different name
source ~/.bashrc
