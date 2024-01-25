#!/bin/bash -l
# author: Caitlin Guccione (cguccion@ucsd.edu)
# date: 1/23/2024
# description: Script to run hg38 alignment on single interleaved FASTQ file.

source config.sh
conda activate human-depletion

f=$1
basename=$(basename "$f" .fastq)

# verify index
if [ ! -f "$MINIMAP2_HG38_INDEX_PATH" ]; then
  echo "Error: Index file $MINIMAP2_HG38_INDEX_PATH does not exist or is not a regular file."
  exit 1
fi

# run minimap2 and samtools based on the mode (PE or SE)
new_basename="${basename%.*}"
if [ "${MODE}" == "PE" ]; then
  minimap2 -2 -ax sr -t "${THREADS}" "${MINIMAP2_HG38_INDEX_PATH}" "${f}" | samtools fastq -@ "${THREADS}" -f 12 -F 256 > "${TMPDIR}/${new_basename}.ALIGN-HG38.fastq"
elif [ "${MODE}" == "SE" ]; then
  minimap2 -2 -ax sr -t "${THREADS}" "${MINIMAP2_HG38_INDEX_PATH}" "${f}" -a | samtools fastq -@ "${THREADS}" -f 4 -F 256 > "${TMPDIR}/${new_basename}.ALIGN-HG38.fastq"
fi
