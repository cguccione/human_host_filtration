#!/bin/bash -l
# author: Caitlin Guccione (cguccion@ucsd.edu)
# date: 1/23/2024
# description: Script to run T2T alignment on single interleaved FASTQ file.

config_fn=$2
source $config_fn
conda activate $CONDA_ENV_NAME

f=$1
basename=$(basename "$f" .fastq)

# verify index
if [ ! -f "$MINIMAP2_T2T_INDEX_PATH" ]; then
  echo "Error: Index file $MINIMAP2_T2T_INDEX_PATH does not exist or is not a regular file."
  exit 1
fi

# run minimap2 and samtools based on the mode (PE or SE)
new_basename="${basename%.*}"
if [[ "${MODE}" == *"PE"* ]]; then
  minimap2 -2 -ax sr -t "${THREADS}" "${MINIMAP2_T2T_INDEX_PATH}" "${f}" | samtools fastq -@ "${THREADS}" -f 12 -F 256 > "${TMPDIR}/${new_basename}.ALIGN-T2T.fastq"
fi

if [[ "${MODE}" == *"SE"* ]]; then
  minimap2 -2 -ax sr -t "${THREADS}" "${MINIMAP2_T2T_INDEX_PATH}" "${f}" \
    | samtools fastq -@ "${THREADS}" -f 4 -F 256 > "${TMPDIR}/${new_basename}.ALIGN-T2T.fastq"
fi
