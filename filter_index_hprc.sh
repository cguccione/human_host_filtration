#!/bin/bash -l
# author: Lucas Patel (lpatel@ucsd.edu)
# date: 12/22/23 
# description: Script to perform index-based host filtration on FASTQ files from metagenomics experiments by assessing PML distributions generated by Movi to distinguish human from non-human reads.

set -e
set -o pipefail

config_fn=$2
source $config_fn
conda activate $CONDA_ENV_NAME

f=$1
basename=$(basename "$f" .fastq)

# Check if input file is provided and exists
if [ -z "$f" ] || [ ! -f "$f" ]; then
  echo "Error: FASTQ input not provided or does not exist."
  exit 1
fi

retry_count=0
max_retries=10

while [ $retry_count -lt $max_retries ]; do
  # First, compute pseudo matching lengths
  #cmd="$MOVI_PATH query $MOVI_INDEX_PATH $f" 
  cmd="$MOVI_PATH query --pml --index $MOVI_INDEX_PATH --read $f" # updated
  echo $cmd
  eval $cmd 2>&1

  # Check if command was successful
  if [ $? -ne 0 ]; then
    echo "Attempt $(($retry_count + 1)) failed to compute pseudo matching lengths."
    retry_count=$(($retry_count + 1))
    continue
  fi

  # Check if .bin file exists after command execution
  if [ -f "$f.default.mpml.bin" ]; then
    echo "Successfully created $f.default.mpml.bin."
    break
  else
    echo "Attempt $(($retry_count + 1)) failed to create $f.default.mpml.bin."
    retry_count=$(($retry_count + 1))
  fi
done

# Check if .bin file exists before converting PMLs
if [ ! -f "$f.default.mpml.bin" ]; then
  echo "Error: $f.default.mpml.bin does not exist."
  exit 1
fi

# Next, convert PMLs to readable format
#cmd="$MOVI_PATH view $f.default.mpml.bin > $f.mpml.txt"
cmd="$MOVI_PATH view --pml-file $f.default.mpml.bin > $f.mpml.txt" # updated
echo $cmd
eval $cmd 2>&1
# Check if command was successful
if [ $? -ne 0 ]; then
  echo "Error: Failed to convert PMLs to readable format."
  exit 1
fi

# Compare line counts
lines_reads=$(wc -l < "$f")
lines_mpml_txt=$(wc -l < "$f.mpml.txt")
expected_lines_mpml_txt=$((lines_reads / 2))

if [ $lines_mpml_txt -ne $expected_lines_mpml_txt ]; then
  echo "Error: Line count of $f.mpml.txt does not match expected count."
  exit 1
fi

echo "python scripts/qiita_filter_pmls.py $f.mpml.txt $f $TMPDIR"
python scripts/hf_filter_pmls.py $f.mpml.txt $f $TMPDIR | seqtk subseq $f - > "$TMPDIR/${basename}.fastq.mpml.non-human.fastq"
#echo "seqtk subseq $f $TMPDIR/${basename}.non-human.ids.txt > $TMPDIR/${basename}.fastq.mpml.non-human.fastq"


# Check if new .fastq files exist
if [ ! -f "$TMPDIR/${basename}.fastq.mpml.non-human.fastq" ]; then
  echo "Error: $TMPDIR/${basename}.fastq.mpml.non-human.fastq does not exist."
  exit 1
fi

new_basename="${basename%.*}"
echo "$TMPDIR/${basename}.fastq.mpml.non-human.fastq" "$TMPDIR/${new_basename}.INDEX-HPRC.fastq"
mv "$TMPDIR/${basename}.fastq.mpml.non-human.fastq" "$TMPDIR/${new_basename}.INDEX-HPRC.fastq"
