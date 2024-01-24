#!/bin/bash
# author: Lucas Patel (lpatel@ucsd.edu)
# date: 12/22/23 
# description: Script to run fastp on arbitrary inputs as part of a full host filtration pipeline. The adapters used are based on manual curation and conversion of ____.

#SBATCH -J host_filter
#SBATCH --mail-type=ALL
#SBATCH --mail-user=lpatel@ucsd.edu
#SBATCH --time=24:00:00
#SBATCH --ntasks=7
#SBATCH --nodes=1
#SBATCH --mem=200gb
#SBATCH --output=logs/%x-%A_%a.out
#SBATCH --error=logs/%x-%A_%a.err

source config.sh
echo $TMPDIR
echo "Beginning host filtration on directory: ${IN}"

# make new temp directory
export TMPDIR="${TMPDIR}/$(basename $(mktemp -d))"
mkdir -p ${TMPDIR}
echo $TMPDIR

# find all candidate fastq files for filtration
find "$IN" -maxdepth 1 -type f -name '*_R1*.fastq*' -exec sh -c 'for f; do echo "$f" >> "$TMPDIR/r1_files.txt"; done' sh {} +
find "$IN" -maxdepth 1 -type f -name '*_R2*.fastq*' -exec sh -c 'for f; do echo "$f" >> "$TMPDIR/r2_files.txt"; done' sh {} +
find "$IN" -maxdepth 1 -type f -name '*.fastq*' | grep -vE '_R[12]' > "$TMPDIR/other_files.txt"

echo "Found $(wc -l < "$TMPDIR/r1_files.txt") R1 FASTQ files" && echo "Found $(wc -l < "$TMPDIR/r2_files.txt") R2 FASTQ files" && [ $(wc -l < "$TMPDIR/r1_files.txt") -eq $(wc -l < "$TMPDIR/r2_files.txt") ] || echo "Warning: The number of R1 and R2 FASTQ files is not the same."
echo "Found $(wc -l < "$TMPDIR/other_files.txt") other files"

# read R1 and R2 files line by line simultaneously
paste "$TMPDIR/r1_files.txt" "$TMPDIR/r2_files.txt" | while IFS=$'\t' read -r r1_file r2_file; do
    base_r1="${r1_file%_R1*}"
    base_r2="${r2_file%_R2*}"

    # check the base names
    if [[ "$base_r1" != "$base_r2" ]]; then
        echo "Mismatch in FASTQ file names: $r1_file and $r2_file"
        exit 1
    fi
    
    # first, run fastp
    echo ${file_map["FASTP"]}

    # next, run each host filtration method
    for key in "$(METHODS[@])"; do
        script="${file_map[$key]}"
        if [[ -f "$script" && -x "$script" ]]; then
            #bash "$script" "$r1_file" "$r2_file"
        else
            echo "Key $key not valid or file-path $script not found."
        fi
    done
done

echo "Cleaning up $TMPDIR"
rm -r $TMPDIR
