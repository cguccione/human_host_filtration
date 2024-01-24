#!/bin/bash
#

# configure experiment parameters
IN="data"
OUT="data/host-filtered"
MODE="PE" # "SE" (single-end) or "PE" (paired-end)
METHODS=("ALIGN-HPRC", "INDEX-HPRC") # any combination of "ALIGN-HG38", "ALIGN-T2T", "ALIGN-HPRC", or "INDEX-HPRC"

# configure index filtration parameters
METRIC="custom" # "max", "average", or "custom"
THRESHOLD=0.175 # suggested thresholds are __ for "max", __ for "average", and 0.175 for "custom"
MIN_RUN_LENGTH=5

# configure software and reference paths
MOVI_PATH="~/software/Movi/build/movi-default" # path to movi-default executable
MOVI_INDEX_PATH="/panfs/lpatel/reference/movi_all" # path to prebuilt movi_index.bin
MINIMAP2_PATH="/home/lpatel/software/miniconda3/envs/human-depletion/bin/minimap2" # path to minimap2 executable
MINIMAP2_HG38_INDEX_PATH="/panfs/cguccion/23_06_25_Pangenome_Assembley/downloaded_fastqs/fastq_files/pangenome_individual_mmi/human-GRC-db.mmi" # one index
MINIMAP2_T2T_INDEX_PATH="/panfs/cguccion/23_06_25_Pangenome_Assembley/downloaded_fastqs/fastq_files/pangenome_individual_mmi/human-GCA-phix-db.mmi" # one index
MINIMAP2_HPRC_INDEX_PATH="/panfs/cguccion/23_06_25_Pangenome_Assembley/downloaded_fastqs/fastq_files/pangenome_individual_mmi" # directory of indexes
ADAPTERS="ref/known_adapters.fna"
TMPDIR="/panfs/lpatel/tmp"

# END CONFIGURATION

# check variables are valid
if [ -z "$TMPDIR" ]; then
  echo "TMPDIR is not set. Please set TMPDIR to a valid directory."
  exit 1
fi

# define filtration map
declare -A file_map
file_map["FASTP"]="filter_fastp.sh"
file_map["ALIGN-HG38"]="filter_align_hg38.sh"
file_map["ALIGN-T2T"]="filter_align_t2t.sh"
file_map["ALIGN-HPRC"]="filter_align_hprc.sh"
file_map["INDEX-HPRC"]="filter_index_hprc.sh"
