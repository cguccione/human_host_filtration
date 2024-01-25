#!/bin/bash -l
# author: Caitlin Guccione (cguccion@ucsd.edu)
# date: 1/23/2024
# description: Script to run HPRC alignment on single interleaved FASTQ file.

source config.sh
conda activate human-depletion

f=$1
basename=$(basename "$f" .fastq)

# verify index directory
if [ ! -d "$MINIMAP2_T2T_INDEX_PATH" ] || [ -z "$(ls -A "$MINIMAP2_T2T_INDEX_PATH"/*.mmi 2>/dev/null)" ]; then
  echo "Error: Index directory $MINIMAP2_T2T_INDEX_PATH does not exist, is not a directory, or does not contain *.mmi files."
  exit 1
fi

# run minimap2 and samtools based on the mode (PE or SE)
new_basename="${basename%.*}"
cp "${f}" "${TMPDIR}"/seqs.fastq
if [ "${MODE}" == "PE" ]; then
  for mmi in "${MMI}"/*.mmi
  do
    minimap2 -2 -ax sr -t 7 "${mmi}" "${TMPDIR}"/seqs.fastq | \
      samtools fastq -@ 1 -f 12 -F 256 > "${TMPDIR}"/seqs_new.fastq
    mv "${TMPDIR}"/seqs_new.fastq "${TMPDIR}"/seqs.fastq
  done
elif [ "${MODE}" == "SE" ]; then
fi

mv "${TMPDIR}"/seqs.fastq "${TMPDIR}/${new_basename}.ALIGN-HPRC.fastq"
