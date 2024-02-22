#!/bin/bash -l
#SBATCH -J build_human_refs
#SBATCH --mail-type=ALL         #Mail to recive
#SBATCH --mail-user=cguccion@ucsd.edu
#SBATCH --time=10:00:00        # Walltime
#SBATCH --ntasks=12
#SBATCH --nodes=1               # number of nodes
#SBATCH --mem-per-cpu=10000    # memory/cpu (in MB)
#SBATCH --partition=highmem

<<com
Author: Caitlin Guccione : cguccion@ucsd.edu
Date: 1/15/2024
Goal: Download HG38 file and build minimap2 database
com

mamba activate human-depletion

output_path="minimap_indexes"

#Check to see if file already exists
if [ -d "${output_path}/human-GRCh38-db-Phix.mmi" ]; then
	echo "${output_path}/human-GRCh38-db-Phix.mmi already exists"
else
	echo "GRCh38 minimap index does not exist, creating now"
	mkdir -p ${output_path}
	cd ${output_path} 	
	
	echo "Downloading files"
	wget -q https://ftp.ncbi.nlm.nih.gov/refseq/H_sapiens/annotation/GRCh38_latest/refseq_identifiers/GRCh38_latest_genomic.fna.gz
	gunzip -q GRCh38_latest_genomic.fna.gz
	cat GRCh38_latest_genomic.fna ../create_minimap_indexes/NC_001422.fna > human-GRCh38-db-Phix.fna
	
	echo "Building minimap2 database"
	minimap2 -ax sr -t 12 -d human-GRCh38-db-Phix.mmi human-GRCh38-db-Phix.fna	

	echo "Removing unneeded files"
	rm human-GRCh38-db-Phix.fna GRCh38_latest_genomic.fna
fi

