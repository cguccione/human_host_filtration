#!/bin/bash -l
# author: Caitlin Guccione (cguccion@ucsd.edu)
# date: 1/23/2024
# description: Script to run T2T alignment on single interleaved FASTQ file.

set -e 
set -o pipefail

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

# run minimap2 and samtools based on the mode (PE or SE or PE+SE)
new_basename="${basename%.*}"
cp "${f}" "${TMPDIR}"/seqs_${new_basename}.fastq
if [[ "${MODE}" == *"PE"* ]]; then
  minimap2 -2 -ax sr -t "${THREADS}" "${MINIMAP2_T2T_INDEX_PATH}" "${TMPDIR}"/seqs_${new_basename}.fastq | samtools fastq -@ "${THREADS}" -f 12 -F 256 > "${TMPDIR}"/seqs_new_${new_basename}.fastq
  mv "${TMPDIR}"/seqs_new_${new_basename}.fastq "${TMPDIR}"/seqs_${new_basename}.fastq
fi

if [[ "${MODE}" == *"SE"* ]]; then
  minimap2 -2 -ax sr -t "${THREADS}" "${MINIMAP2_T2T_INDEX_PATH}" "${TMPDIR}"/seqs_${new_basename}.fastq --no-pairing | samtools fastq -@ "${THREADS}" -f 4 -F 256 > "${TMPDIR}"/seqs_new_${new_basename}.fastq
  mv "${TMPDIR}"/seqs_new_${new_basename}.fastq "${TMPDIR}"/seqs_${new_basename}.fastq
fi

if [[ "${MODE}" == "PE+SE" ]]; then
  python scripts/pair.py "${TMPDIR}"/seqs_${new_basename}.fastq "${TMPDIR}"/seqs_new_${new_basename}.fastq
  mv "${TMPDIR}"/seqs_new_${new_basename}.fastq "${TMPDIR}/${new_basename}.ALIGN-T2T.fastq"
else
  mv "${TMPDIR}"/seqs_${new_basename}.fastq "${TMPDIR}/${new_basename}.ALIGN-T2T.fastq"
fi
