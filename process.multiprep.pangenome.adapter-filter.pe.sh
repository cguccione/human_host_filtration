#!/bin/bash -l

<<com
Combine files into batches and submit jobs 
com

#(optional) debug mode
set -e
set -x

#Set paths for data_locatoin, tmp and output
output=/panfs/dtmcdonald/human-depletion/pangenome-adapter-filter
tmpdir=/panfs/dtmcdonald/tmp
data_location="/panfs/dtmcdonald/human-depletion/t2t-only/*/*"
# WARNING: split-similar-size-bins.py retains the */* directory names
# on compute. This was done as the current data are processed by 
# <qiita_id>/<artifact_id>. We wish to retain that organization
# and so this information is stored within the filelist for use on demux
# writing
mmi=/panfs/cguccion/23_06_25_Pangenome_Assembley/downloaded_fastqs/fastq_files/pangenome_individual_mmi
# [Create these in setUp / change path to that]

#Create batches
maxfilelistsize=2  #Sizes in GB (2 recommended)
#Max size of GB data to process in a job
batch_prefix=hd-split-pangenome-pe-$(date "+%Y.%m.%d")
batches=$(python split-similar-size-bins.py \
          "${data_location}" \
          ${maxfilelistsize} \
          ${batch_prefix})

#Submit jobs
sbatch \
    -J ${batch_prefix} \
    --array 1-${batches} \
    --mem 20G \
    --export MMI=${mmi},PREFIX=${batch_prefix},OUTPUT=${output},TMPDIR=${tmpdir} \
    process.multiprep.pangenome.adapter-filter.pe.sbatch