#!/bin/bash -l
# author: Caitlin Guccione (cguccion@ucsd.edu)
# date: 1/23/2024
# description: Script to run T2T alignment on single interleaved fastq file

source config.sh
conda activate human-depletion

f=$1
basename=$(basename "$f" .fastq)

#Check if T2T index exists before running host depletion
if [ ! -f "$MINIMAP2_T2T_INDEX_PATH" ]; then
  echo "Error: File does not exist or is not a regular file."
  exit 1
fi

# Run minimap2 and samtools based on the mode (PE or SE)
new_basename="${basename%.*}"
if [ "${MODE}" == "PE" ]; then
  minimap2 -2 -ax sr -t "${THREADS}" "${MINIMAP2_T2T_INDEX_PATH}" "${f}" | samtools fastq -@ "${THREADS}" -f 12 -F 256 > "${TMPDIR}/${new_basename}.ALIGN-T2T.fastq"
elif [ "${MODE}" == "SE" ]; then
  minimap2 -2 -ax sr -t "${THREADS}" "${MINIMAP2_T2T_INDEX_PATH}" "${f}" \
    | samtools fastq -@ "${THREADS}" -f 4 -F 256 > "${TMPDIR}/${new_basename}.ALIGN-T2T.fastq"
fi
