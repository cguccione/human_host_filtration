#!/bin/bash -l
# author: Caitlin Guccione (cguccion@ucsd.edu)
# date: 1/23/2024
# description: Script to run T2T alignment on single interleaved fastq file

source config.sh
conda activate human-depletion-lucas

f=$1
basename=$(basename "$f" .fastq)

#Check if T2T index exists before running host depletion
if [ ! -f "$MINIMAP2_T2T_INDEX_PATH" ]; then
  echo "Error: File does not exist or is not a regular file."
  exit 1
fi

echo "Starting T2T Alignment Host Depletion"
echo ${MINIMAP2_T2T_INDEX_PATH}
echo ${f}
echo "minimap2 -2 -ax sr -t ${THREADS} ${MINIMAP2_T2T_INDEX_PATH} ${f}"

if [ "${MODE}" == "PE" ]; then
  minimap2 -2 -ax sr -t ${THREADS} ${MINIMAP2_T2T_INDEX_PATH} ${f} | samtools fastq -@ ${THREADS} -f 12 -F 256 > "$TMPDIR/${basename}.ALIGN-T2T.fastq"
elif [ "${MODE}" == "SE" ]; then
  minimap2 -2 -ax sr -t ${THREADS} ${MINIMAP2_T2T_INDEX_PATH} ${f} -a | samtools fastq -@ ${THREADS} -f 4 -F 256 > "$TMPDIR/${basename}.ALIGN-T2T.fastq"
fi

echo "T2T Alignment Complete"
