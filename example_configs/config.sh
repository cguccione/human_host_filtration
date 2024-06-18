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
MOVI_PATH="/path/to/movi-default" # path to movi-default executable
MOVI_INDEX_PATH="ref/movi" # path to prebuilt movi_index.bin
MINIMAP2_PATH="$(which minimap2)" # path to minimap2 executable
MINIMAP2_HG38_INDEX_PATH="ref/mmi/hg38.mmi" # one index
MINIMAP2_T2T_INDEX_PATH="ref/mmi/t2t.mmi" # one index
MINIMAP2_HPRC_INDEX_PATH="ref/mmi" # directory of indexes
ADAPTERS="ref/known_adapters.fna"
TMP="" # path to temporary directory for writing

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
else

# check input path is valid (barnacle2 only)
abs_path=$(realpath "$IN")
if [[ "$HOSTNAME" == "barnacle2" && ( "$abs_path" == /home* || "$abs_path" == /projects* ) ]]; then    
  echo "Input files are in /home or /projects. Please use /panfs for IO-intensive workloads such as host filtration."
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
