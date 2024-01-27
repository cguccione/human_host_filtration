#!/bin/bash -l
# author: Lucas Patel (lpatel@ucsd.edu)
# date: 12/22/23 
# description: Script to run fastp on arbitrary inputs as part of a full host filtration pipeline. The adapters used are based on manual curation and conversion of ____.

#SBATCH -J host_filter
#SBATCH --mail-type=ALL
#SBATCH --mail-user=lpatel@ucsd.edu
#SBATCH --time=24:00:00
#SBATCH --partition=short
#SBATCH --ntasks=7
#SBATCH --nodes=1
#SBATCH --mem=128gb
#SBATCH --output=logs/%x-%A_%a.out
#SBATCH --error=logs/%x-%A_%a.err

source config.sh
echo "Beginning host filtration (job array mode) on directory: ${IN}"

process_files() {
  local r1_file="$1"
  local r2_file="${2:-}"  # Second argument is optional
  local base_name

  # Determine base name based on R1 or single-end file
  if [[ -n "$r2_file" ]]; then
    base_name="${r1_file%_R1*}"
    if [[ "$base_name" != "${r2_file%_R2*}" ]]; then
      echo "Error: Mismatch in FASTQ file names: $r1_file and $r2_file"
      exit 1
    fi
  else
    base_name="${r1_file%.*}"
  fi

  echo "Running FASTP..."
  bash "${file_map['FASTP']}" "$r1_file" "$r2_file"
  local in_file="${OUT}/fastp/$(basename "$base_name").FASTP.fastq"

  for key in "${METHODS[@]}"; do
    local script="${file_map[$key]}"
    if [[ -f "$script" ]]; then
      echo "Running $key filtration..."
      bash "$script" "$in_file"
    else
      echo "Key $key not valid or file-path $script not found."
      continue
    fi

    if [ "$SAVE_INTERMEDIATE" -eq 0 ]; then
      mkdir -p "${OUT}/${key,,}"
      mv "${TMPDIR}/$(basename "$base_name").${key}.fastq" "${OUT}/${key,,}/$(basename "$base_name").${key}.fastq"
      in_file="${OUT}/${key,,}/$(basename "$base_name").${key}.fastq"
    else
      in_file="${TMPDIR}/$(basename "$base_name").${key}.fastq"
    fi
  done

  echo "Splitting into R1/R2..."
  bash split_fastq.sh "$in_file"
}

line_num=$SLURM_ARRAY_TASK_ID
read -r file <<< $(sed -n "${line_num}p" "$TMPDIR/all_files.txt")
mate=
if [[ "$file" == *"_R1"* ]]; then
  mate="${file/_R1/_R2}"
fi
process_files "$file" "$mate"