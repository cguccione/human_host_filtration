#!/bin/bash -l
# author: Lucas Patel
# date: $(date +%Y-%m-%d)
# description: Generate directory-wise summary statistics for .fastq and .fastq.gz files

# Check for the correct number of arguments
#if [ "$#" -ne 4 ]; then
#  echo "Usage: $0 <directory> <identifier> <X> <Y>"
#  exit 1
#fi

directory=$1
identifier=$2
X=$3
Y=$4

output_file="${directory}/summary_statistics.tsv"

# Check if X and Y are provided and numeric
if [[ -n $X && -n $Y && $X =~ ^[0-9]+$ && $Y =~ ^[0-9]+$ ]]; then
  compute_confusion_matrix=true
  echo -e "file\tkey\tline count\thuman count\tmicrobe count\tTP\tFP\tTN\tFN" > "$output_file"
else
  compute_confusion_matrix=false
  echo -e "file\tkey\tline count" > "$output_file"
fi

# Function to calculate counts
calculate_counts() {
  file=$1
  if [[ $file == *.gz ]]; then
    zgrep -c "$2" "$file"
  else
    grep -c "$2" "$file"
  fi
}

# Loop over all .fastq and .fastq.gz files in the directory
for file in "${directory}"/*.{fastq,fastq.gz}; do
  if [[ -f "$file" ]]; then
    line_count=$(calculate_counts "$file" "")
    human_count=$(calculate_counts "$file" "HUMAN")
    microbe_count=$(calculate_counts "$file" "MICROBE")
    
    if [ "$compute_confusion_matrix" = true ]; then
      TP=$((X - human_count))
      FP=$((Y - microbe_count))
      TN=$microbe_count
      FN=$human_count
      echo -e "$(realpath "$file")\t${identifier}\t${line_count}\t${human_count}\t${microbe_count}\t${TP}\t${FP}\t${TN}\t${FN}" >> "$output_file"
    else
      echo -e "$(realpath "$file")\t${identifier}\t${line_count}" >> "$output_file"
    fi
  fi
done


