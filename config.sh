#!/bin/bash

# configure experiment parameters
IN="data"
OUT="data/host-filtered"
MODE="PE" # "SE" (single-end) or "PE" (paired-end) or "PE+SE" (paired-end then single-end)
METHODS=("ALIGN-HG38" "ALIGN-T2T" "INDEX-HPRC") # any combination of "ALIGN-HG38", "ALIGN-T2T", "ALIGN-HPRC", or "INDEX-HPRC"
SAVE_INTERMEDIATE=1 # 0 for TRUE and 1 for FALSE
THREADS=7

# configure index filtration parameters
METRIC="custom" # "max", "average", or "custom"
THRESHOLD=0.175 # suggested thresholds are __ for "max", __ for "average", and 0.175 for "custom"
MIN_RUN_LENGTH=5

# configure software and reference paths
CONDA_ENV_NAME="human-filtration"
MOVI_PATH="/panfs/cguccion/packages/lucas_Movi/Movi/build/movi-default"  # path to movi-default executable on barnacle
MOVI_INDEX_PATH="/scratch/movi_hg38_chm13_hprc94" # path to prebuilt movi_index.bin on barnacle, must be on a compute node
MINIMAP2_PATH="minimap2" #Calling minimap2 from conda env
MINIMAP2_HG38_INDEX_PATH="/scratch/databases/minimap2/human-pangenome/human-GRC-db.mmi" # hg38 index on barnacle
MINIMAP2_T2T_INDEX_PATH="/scratch/databases/minimap2/human-pangenome/human-GCA-phix-db.mmi" # t2t index on barancle
MINIMAP2_HPRC_INDEX_PATH="/scratch/databases/minimap2/human-pangenome" # directory of pangenome indexes (including hg38 and t2t)
ADAPTERS="ref/known_adapters.fna" #Known adapters (used in paper)
TMP="/panfs/YOUR_USERNAME/tmp" #Change to your username on barnacle, create a TMP if you don't have one

# END CONFIGURATION

# check variables are valid
if [ -z "$TMP" ]; then
  echo "TMP is not set. Please set TMP to a valid directory."
  exit 1
fi

# check modes are valid
if [[ "$MODE" != "PE" && "$MODE" != "SE" && "$MODE" != "PE+SE" ]]; then
    echo "Error: Invalid MODE. MODE must be 'PE', 'SE', or 'PE+SE'."
    exit 1 
fi

# define filtration map
declare -A file_map
file_map["FASTP"]="filter_fastp.sh"
file_map["ALIGN-HG38"]="filter_align_hg38.sh"
file_map["ALIGN-T2T"]="filter_align_t2t.sh"
file_map["ALIGN-HPRC"]="filter_align_hprc.sh"
file_map["INDEX-HPRC"]="filter_index_hprc.sh"

source ~/.bashrc
conda activate $CONDA_ENV_NAME
