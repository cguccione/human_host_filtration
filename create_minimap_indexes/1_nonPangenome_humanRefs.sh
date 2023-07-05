#!/bin/bash
#SBATCH -J build_human_refs
#SBATCH --mail-type=ALL         #Mail to recive
#SBATCH --mail-user=cguccion@ucsd.edu
#SBATCH --time=10:00:00        # Walltime
#SBATCH --ntasks=12
#SBATCH --nodes=1               # number of nodes
#SBATCH --mem-per-cpu=10000    # memory/cpu (in MB)

echo "Downloading files"
wget -q https://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/009/914/755/GCA_009914755.4_T2T-CHM13v2.0/GCA_009914755.4_T2T-CHM13v2.0_genomic.fna.gz
wget -q https://ftp.ncbi.nlm.nih.gov/refseq/H_sapiens/annotation/GRCh38_latest/refseq_identifiers/GRCh38_latest_genomic.fna.gz
gunzip -q GCA_009914755.4_T2T-CHM13v2.0_genomic.fna.gz
gunzip -q GRCh38_latest_genomic.fna.gz
cat GCA_009914755.4_T2T-CHM13v2.0_genomic.fna NC_001422.fna > human-GCA-phix.fna
          
echo "Building human minimap2 databases"
minimap2 -ax sr -t 12 -d human-GRC-db.mmi GRCh38_latest_genomic.fna
minimap2 -ax sr -t 12 -d human-GCA-phix-db.mmi human-GCA-phix.fna

#remove large unneeded files
rm GCA_009914755.4_T2T-CHM13v2.0_genomic.fna GRCh38_latest_genomic.fna NC_001422.fna human-GCA-phix.fna
