#!/bin/bash -l
# author: Lucas Patel (lpatel@ucsd.edu)
# date: 12/22/23 
# description: Script to run fastp on R1/R2 or interleaved FASTQ inputs as part of a full host filtration pipeline.

source config.sh
conda activate human-depletion

process_fastp() {
  local r1=$1
  local r2=$2
  local basename1=$(basename "$r1" .fastq)

  local fastp_options="-l 45 -w 7 --adapter_fasta ${ADAPTERS} --html /dev/null --json /dev/null --stdout -i ${r1}" # --interleaved_in"
  if [[ -n "${r2}" && -f "${r2}" ]]; then
    fastp_options+=" -I ${r2}"
  fi

  mkdir -p ${OUT}/fastp
  echo "fastp ${fastp_options}"
  fastp ${fastp_options} > "${OUT}/fastp/${basename1/_R1/}.adapter_filtered.fastq"
}

process_fastp "$1" "$2"
