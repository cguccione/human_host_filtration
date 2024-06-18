#!/bin/bash

echo "Downloading files"
wget -q -P ref/ https://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/009/914/755/GCA_009914755.4_T2T-CHM13v2.0/GCA_009914755.4_T2T-CHM13v2.0_genomic.fna.gz
echo "downloaded file1"
wget -q -P ref/ https://ftp.ncbi.nlm.nih.gov/refseq/H_sapiens/annotation/GRCh38_latest/refseq_identifiers/GRCh38_latest_genomic.fna.gz
echo "downloaded file2"

gunzip -q ref/GCA_009914755.4_T2T-CHM13v2.0_genomic.fna.gz
gunzip -q ref/GRCh38_latest_genomic.fna.gz

echo 'decompressed files'
cat ref/GCA_009914755.4_T2T-CHM13v2.0_genomic.fna ref/NC_001422.fna > ref/human-GCA-phix.fna

curl -o ref/link_index https://raw.githubusercontent.com/human-pangenomics/HPP_Year1_Assemblies/main/assembly_index/Year1_assemblies_v2_genbank.index

index_file="ref/link_index"

# Specify the output file
output_file="ref/hap1_aws_paths.txt"

# Use awk to extract everything after "://", and write to the output file
awk -F'\t' '{split($2, hap1_aws, "://"); split($3, hap2_aws, "://"); print hap1_aws[2] "\n" hap2_aws[2]}' "$index_file" > temp.txt


head -n -4 temp.txt > "$output_file"

echo "Last two rows removed. Output written to $output_file"

input_file=ref/hap1_aws_paths.txt


# Create a directory to store downloaded files (optional)
output_directory="ref/pangenomes"
mkdir -p "$output_directory"

# Iterate through each link in the file and use wget to download
while IFS= read -r link; do
    # Use wget to download the link to the output directory
    wget "https://s3-us-west-2.amazonaws.com/$link" -P "$output_directory"
done < "$input_file"

echo "Download complete. Files saved in $output_directory"

echo 'done downloading pangenomes'


input_directory=ref/pangenomes

for file in "$input_directory"/*.gz; do
    if [ -e "$file" ]; then
        echo "Decompressing: $file"
        gunzip "$file"
    fi
done

echo "Decompression complete."
