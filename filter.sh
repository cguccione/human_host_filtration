#!/bin/bash -l
# author: Lucas Patel (lpatel@ucsd.edu)
# date: 12/22/23 
# description: Script to run fastp on arbitrary inputs as part of a full host filtration pipeline. The adapters used are based on manual curation and conversion of ____.

#SBATCH -J host_filter
#SBATCH --mail-type=ALL
#SBATCH --mail-user=cguccion@ucsd.edu
#SBATCH --time=24:00:00
#SBATCH --ntasks=7
#SBATCH --nodes=1
#SBATCH --mem=200gb
#SBATCH --output=logs/%x-%A_%a.out
#SBATCH --error=logs/%x-%A_%a.err

config_fn="config.example.sh"
#config_fn="config.cg.hmf.sh"
#config_fn="config.cg.100k.sh"

source ${config_fn}
echo "Beginning host filtration on directory: ${IN}"

# make new temp directory
export TMPDIR="${TMP}/$(basename $(mktemp -d))"
mkdir -p ${TMPDIR}
echo $TMPDIR

# find all candidate fastq files for filtration
find "$IN" -maxdepth 1 -type f \( -name '*_R1*.fastq' -o -name '*_R1*.fastq.gz' \) -exec sh -c 'for f; do echo "$f"; done >> "$TMPDIR/r1_files.txt"' sh {} +
find "$IN" -maxdepth 1 -type f \( -name '*_R2*.fastq' -o -name '*_R2*.fastq.gz' \) -exec sh -c 'for f; do echo "$f"; done >> "$TMPDIR/r2_files.txt"' sh {} +
find "$IN" -maxdepth 1 -type f \( -name '*.fastq' -o -name '*.fastq.gz' \) | grep -vE '_R[12]' > "$TMPDIR/other_files.txt"

echo "Found $(wc -l < "$TMPDIR/r1_files.txt") R1 FASTQ files" && echo "Found $(wc -l < "$TMPDIR/r2_files.txt") R2 FASTQ files" && [ $(wc -l < "$TMPDIR/r1_files.txt") -eq $(wc -l < "$TMPDIR/r2_files.txt") ] || echo "Warning: The number of R1 and R2 FASTQ files is not the same."
echo "Found $(wc -l < "$TMPDIR/other_files.txt") other files"

strip_extensions() {
  local file_name="$1"
  local stripped_name="${file_name%.fastq.gz}"
  stripped_name="${stripped_name%.fastq}"
  echo "$stripped_name"
}

process_files() {
  local r1_file="$1"
  local r2_file="${2:-}"  # Second argument is optional
  local base_name
  local base_name_r2

  # Determine base name based on R1 or single-end file
  if [[ -n "$r2_file" ]]; then
    base_name=$(strip_extensions "$r1_file")
    base_name_r2=$(strip_extensions "$r2_file")
    if [[ "${base_name%_R1*}" != "${base_name_r2%_R2*}" ]]; then
      echo "Error: Mismatch in FASTQ file names: $r1_file and $r2_file"
      exit 1
    fi
  else
    base_name=$(strip_extensions "$r1_file")
  fi

  echo "Running FASTP..."
  bash "${file_map['FASTP']}" "$r1_file" "$r2_file" "$config_fn"
  local in_file="${OUT}/fastp/$(basename "$base_name").FASTP.fastq"

  for key in "${METHODS[@]}"; do
    local script="${file_map[$key]}"
    if [[ -f "$script" ]]; then
      echo "Running $key filtration..."
      bash "$script" "$in_file" "$config_fn"
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

  if [[ -n "$r2_file" ]]; then
    echo "Splitting into R1/R2..."
    bash split_fastq.sh "$in_file" "$config_fn"
  fi
}

# process PE
paste "$TMPDIR/r1_files.txt" "$TMPDIR/r2_files.txt" | while IFS=$'\t' read -r r1_file r2_file; do
  process_files "$r1_file" "$r2_file"
done

# process SE
while IFS= read -r file; do
  process_files "$file"
done < "$TMPDIR/other_files.txt"

echo "Cleaning up $TMPDIR"
ls $TMPDIR
#rm -r $TMPDIR
