#!/bin/bash -l
# author: Lucas Patel (lpatel@ucsd.edu)
# Split interleaved FASTQ using read identifiers

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <interleaved_fastq> <config_file>"
  exit 1
fi

input_fastq="$1"
config_fn="$2"

[ ! -f "$input_fastq" ] && echo "Error: Input FASTQ file not found." && exit 1

source $config_fn
conda activate "$CONDA_ENV_NAME"

[ -z "$OUT" ] && echo "Error: Output directory not defined." && exit 1

TEMP_DIR="${OUT}/fastq-pair"
mkdir -p "$TEMP_DIR"

unweave() {
  local r1="$1"
  local basename_r1=$(basename "$r1" .fastq)
  local basename_r1="${basename_r1%.*}"
  local basename_r2=$(echo "$basename_r1" | sed 's/_R1/_R2/')

  if [ "$basename_r1" = "$basename_r2" ]; then
    # If no _R1 found, add suffix
    basename_r2="${basename_r1}_R2"
    basename_r1="${basename_r1}_R1"
  fi

  echo "Processing ${r1} into ${basename_r1} and ${basename_r2}"

  # Split by read identifiers rather than position
  awk 'BEGIN {FS = " "}
  {
    header = $0;
    getline seq; getline plus; getline qual;

    if (header ~ /\/1$/ || header ~ /\s1$/ || header ~ /_1$/) {
      print header "\n" seq "\n" plus "\n" qual > "'${TEMP_DIR}/${basename_r1}.temp.fastq'";
    } else {
      print header "\n" seq "\n" plus "\n" qual > "'${TEMP_DIR}/${basename_r2}.temp.fastq'";
    }
  }' "$r1"

  # ensure pairing
  fastq_pair -t 50000000 "${TEMP_DIR}/${basename_r1}.temp.fastq" "${TEMP_DIR}/${basename_r2}.temp.fastq"

  gzip -c "${TEMP_DIR}/${basename_r1}.temp.fastq.paired.fq" > "${OUT}/${basename_r1}.fastq.gz"
  gzip -c "${TEMP_DIR}/${basename_r2}.temp.fastq.paired.fq" > "${OUT}/${basename_r2}.fastq.gz"

  if [ "$SAVE_INTERMEDIATE" -eq 0 ]; then
    gzip -f "${TEMP_DIR}/"*.single.fq
    rm -f "${TEMP_DIR}/"*.temp.fastq "${TEMP_DIR}/"*.paired.fq
  else
    rm -rf "$TEMP_DIR"
  fi
}

unweave "$input_fastq"
echo "Done! Paired FASTQ files available at ${OUT}/"
