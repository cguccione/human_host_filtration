#!/bin/bash
#

# configure experiment parameters
IN="/panfs/cguccion/23_11_07_HostDepletionBenchmarkOverflow/mixed_simulation_tmp/final_combo/LITTLE_99.95p-HUMAN_0.05p-MICROBE/raw/fastq_paired/h1000000-m1000000"
current_fn="1M_99.95H-0.05M_stat_m1"
OUT="/panfs/cguccion/23_11_07_HostDepletionBenchmarkOverflow/mixed_simulation_tmp/final_combo/LITTLE_99.95p-HUMAN_0.05p-MICROBE/host_depleted/${current_fn}"
MODE="PE" # "SE" (single-end) or "PE" (paired-end)
METHODS=("ALIGN-HG38" "ALIGN-T2T" "INDEX-HPRC")
#METHODS=("ALIGN-HPRC" "INDEX-HPRC")
#METHODS=("INDEX-HPRC")
SAVE_INTERMEDIATE=0 # 0 for TRUE and 1 for FALSE
THREADS=7

# configure index filtration parameters
METRIC="custom" # "max", "average", or "custom"
THRESHOLD=0.175 # suggested thresholds are __ for "max", __ for "average", and 0.175 for "custom"
MIN_RUN_LENGTH=5

# configure software and reference paths
MOVI_PATH="/panfs/cguccion/packages/lucas_Movi/Movi/build/movi-default"
MOVI_INDEX_PATH="/scratch/movi_hg38_chm13_hprc84"
#MOVI_INDEX_PATH="/panfs/lpatel/reference/movi_all" # path to prebuilt movi_index.bin
MINIMAP2_PATH="/panfs/cguccion/packages/minimap2-2.26_x64-linux/minimap2"
MINIMAP2_HG38_INDEX_PATH="/panfs/cguccion/23_06_25_Pangenome_Assembley/downloaded_fastqs/fastq_files/pangenome_individual_mmi/human-GRC-db.mmi" # one index
MINIMAP2_T2T_INDEX_PATH="/panfs/cguccion/23_06_25_Pangenome_Assembley/downloaded_fastqs/fastq_files/pangenome_individual_mmi/human-GCA-phix-db.mmi" # one index
MINIMAP2_HPRC_INDEX_PATH="/panfs/cguccion/23_06_25_Pangenome_Assembley/downloaded_fastqs/fastq_files/pangenome_individual_mmi" # directory of indexes
ADAPTERS="ref/known_adapters.fna"
TMP="/panfs/cguccion/tmp"

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
file_map["ALIGN-HPRC"]="filter_align_hprc_subset.sh"
file_map["INDEX-HPRC"]="filter_index_hprc.sh"

#file_map["ALIGN-HPRC"]="filter_align_hprc.sh"
#file_map["ALIGN-HPRC-PESE"]="filter_align_hg38_PESE.sh"

# conda
CONDA_ENV_NAME=human-depletion-lucas
source ~/.bashrc

