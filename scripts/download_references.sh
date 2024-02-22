#!/bin/bash

echo "Downloading files"
wget -q -P refs/ https://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/009/914/755/GCA_009914755.4_T2T-CHM13v2.0/GCA_009914755.4_T2T-CHM13v2.0_genomic.fna.gz
echo "downloaded file1"
wget -q -P refs/ https://ftp.ncbi.nlm.nih.gov/refseq/H_sapiens/annotation/GRCh38_latest/refseq_identifiers/GRCh38_latest_genomic.fna.gz
echo "downloaded file2"

gunzip -q refs/GCA_009914755.4_T2T-CHM13v2.0_genomic.fna.gz
gunzip -q refs/GRCh38_latest_genomic.fna.gz

echo 'decompressed files'
cat refs/GCA_009914755.4_T2T-CHM13v2.0_genomic.fna create_minimap_indexes/NC_001422.fna > refs/human-GCA-phix.fna


echo "Building human minimap2 databases"
minimap2 -ax sr -t 12 -d refs/human-GRC-db.mmi refs/GRCh38_latest_genomic.fna
minimap2 -ax sr -t 12 -d refs/human-GCA-phix-db.mmi refs/human-GCA-phix.fna

#remove large unneeded files
rm refs/GCA_009914755.4_T2T-CHM13v2.0_genomic.fna refs/GRCh38_latest_genomic.fna refs/human-GCA-phix.fna

curl -o refs/link_index https://raw.githubusercontent.com/human-pangenomics/HPP_Year1_Assemblies/main/assembly_index/Year1_assemblies_v2_genbank.index

index_file="refs/link_index"

# Specify the output file
output_file="refs/hap1_aws_paths.txt"

# Use awk to extract everything after "://", and write to the output file
awk -F'\t' '{split($2, hap1_aws, "://"); split($3, hap2_aws, "://"); print hap1_aws[2] "\n" hap2_aws[2]}' "$index_file" > temp.txt


head -n -4 temp.txt > "$output_file"

echo "Last two rows removed. Output written to $output_file"

input_file=refs/hap1_aws_paths.txt


# Create a directory to store downloaded files (optional)
output_directory="refs/pangenomes"
mkdir -p "$output_directory"

# Iterate through each link in the file and use wget to download
while IFS= read -r link; do
    # Use wget to download the link to the output directory
    wget "https://s3-us-west-2.amazonaws.com/$link" -P "$output_directory"
done < "$input_file"

echo "Download complete. Files saved in $output_directory"

echo 'done downloading pangenomes'


input_directory=refs/pangenomes

for file in "$input_directory"/*.gz; do
    if [ -e "$file" ]; then
        echo "Decompressing: $file"
        gunzip "$file"
    fi
done

echo "Decompression complete."
