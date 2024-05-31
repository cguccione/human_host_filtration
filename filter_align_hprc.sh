#!/bin/bash -l
# author: Caitlin Guccione (cguccion@ucsd.edu)
# date: 1/23/2024
# description: Script to run HPRC alignment on single interleaved FASTQ file.

config_fn=$2
source $config_fn
conda activate $CONDA_ENV_NAME

f=$1
basename=$(basename "$f" .fastq)

# verify index directory
if [ ! -d "$MINIMAP2_HPRC_INDEX_PATH" ] || [ -z "$(ls -A "$MINIMAP2_HPRC_INDEX_PATH"/*.mmi 2>/dev/null)" ]; then
  echo "Error: Index directory $MINIMAP2_HPRC_INDEX_PATH does not exist, is not a directory, or does not contain *.mmi files."
  exit 1
fi

# run minimap2 and samtools based on the mode (PE or SE)
new_basename="${basename%.*}"
cp "${f}" "${TMPDIR}"/seqs_${new_basename}.fastq
if [[ "${MODE}" == *"PE"* ]]; then
  for mmi in "${MINIMAP2_HPRC_INDEX_PATH}"/*.mmi
  do
    echo "Running minimap2 (PE) on ${mmi}"
    minimap2 -2 -ax sr -t "${THREADS}" "${mmi}" "${TMPDIR}"/seqs_${new_basename}.fastq | \
      samtools fastq -@ "${THREADS}" -f 12 -F 256 > "${TMPDIR}"/seqs_new_${new_basename}.fastq
    mv "${TMPDIR}"/seqs_new_${new_basename}.fastq "${TMPDIR}"/seqs_${new_basename}.fastq
  done
fi
if [[ "${MODE}" == *"SE"* ]]; then
  for mmi in "${MINIMAP2_HPRC_INDEX_PATH}"/*.mmi
  do
    echo "Running minimap2 (SE) on ${mmi}"
    minimap2 -2 -ax sr --no-pairing -t "${THREADS}" "${mmi}" "${TMPDIR}"/seqs_${new_basename}.fastq | \
       samtools fastq -@ "${THREADS}" -f 4 -F 256 > "${TMPDIR}"/seqs_new_${new_basename}.fastq
    mv "${TMPDIR}"/seqs_new_${new_basename}.fastq "${TMPDIR}"/seqs_${new_basename}.fastq 
  done
fi

if [[ "${MODE}" == *"SE"* ]] && [[ "${MODE}" == *"PE"* ]]; then
    echo "MODE contains both SE and PE so running splitter"
    python /projects/benchmark-human-depletion/human_host_depletion/scripts/splitter.py "${TMPDIR}"/seqs_${new_basename}.fastq "${TMPDIR}"/seqs_new_${new_basename}.fastq
    mv "${TMPDIR}"/seqs_new_${new_basename}.fastq "${TMPDIR}"/seqs_${new_basename}.fastq
fi
  
mv "${TMPDIR}"/seqs_${new_basename}.fastq "${TMPDIR}"/${new_basename}.ALIGN-HPRC.fastq
