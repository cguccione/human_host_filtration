#!/bin/bash -l
# author: Lucas Patel (lpatel@ucsd.edu)
# date: 12/22/23 
# description: Script to run split an interleaved FASTQ file into separate R1/R2 files. Credit: https://biowize.wordpress.com/2015/03/26/the-fastest-darn-fastq-decoupling-procedure-i-ever-done-seen/

source config.sh
conda activate human-depletion

unweave() {
  local r1="$1"
  local basename=$(basename "$r1" .fastq)
  basename="${basename%%.*}"
  paste - - - - - - - - < ${r1} \
    | tee >(cut -f 1-4 | tr '\t' '\n' > ${OUT}/${basename}_R1.fastq) \
    | cut -f 5-8 | tr '\t' '\n' > ${OUT}/${basename}_R2.fastq

  gzip ${OUT}/${basename}_R1.fastq
  gzip ${OUT}/${basename}_R2.fastq
}

unweave "$1"
