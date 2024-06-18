#!/bin/bash

echo "Building human minimap2 databases"
minimap2 -ax sr -t 12 -d ref/human-GRC-db.mmi ref/GRCh38_latest_genomic.fna
minimap2 -ax sr -t 12 -d ref/human-GCA-phix-db.mmi ref/human-GCA-phix.fna

#remove large unneeded files
rm ref/GCA_009914755.4_T2T-CHM13v2.0_genomic.fna ref/GRCh38_latest_genomic.fna ref/human-GCA-phix.fna



echo "building pangenome minimap databases"
directory_path="ref/pangenomes"


for file in "$directory_path"/*
do
    if [ -f "$file" ]; then
	echo 'indexing' $file
        filename=$(basename "$file")
        mmi_name="${filename%.*}"
	minimap2 -d $mmi_name.mmi $directory_path/$file
    fi
done

echo 'done indexing'
