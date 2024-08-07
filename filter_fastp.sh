#!/bin/bash -l
# author: Lucas Patel (lpatel@ucsd.edu)
# date: 12/22/23 
# description: Script to run fastp on R1/R2 or interleaved FASTQ inputs as part of a full host filtration pipeline.

set -e 
set -o pipefail

config_fn=$3
source $config_fn
conda activate $CONDA_ENV_NAME

strip_extensions() {
  local file_name="$1"
  local stripped_name="${file_name%.fastq.gz}"
  stripped_name="${stripped_name%.fastq}"
  echo "$stripped_name"
}

process_fastp() {
  local r1=$1
  local r2=$2
  local base_name=$(strip_extensions "$r1")

  local fastp_options="-l 100 -w ${THREADS} --adapter_fasta ${ADAPTERS} --html /dev/null --json /dev/null --stdout -i ${r1}" # --interleaved_in"
  if [[ -n "${r2}" && -f "${r2}" ]]; then
    fastp_options+=" -I ${r2}"
  fi

  mkdir -p ${OUT}/fastp
  echo "fastp ${fastp_options} > ${OUT}/fastp/$(basename "$base_name").FASTP.fastq"
  fastp ${fastp_options} > "${OUT}/fastp/$(basename "$base_name").FASTP.fastq"
}

process_fastp "$1" "$2"
