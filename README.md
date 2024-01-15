# Human Host Depletion Pipeline

This pipeline is designed to remove human DNA from microbial shotgun samples.

## Setup and Usage

1. **Clone the Repository**  
   `git clone [repository-link]`

2. **Setup Conda Environment**  
      `conda env create -f human-depletion.yml`

3. **Prepare Minimap References**  
         - Download hg38 + T2T genome and convert to minimap2 indexes:  
              `bash create_minimap_indexes/1_nonPangenome_humanRefs.sh`
                 - Download all 94 pangenome references:  
                      `bash create_minimap_indexes/2_download_pangenome_fastqs.sh`
                         - Convert pangenome references to minimap2 indexes:  
                              `bash create_minimap_indexes/3_create_pangenome_minimap_indexes.sh`

                              4. **Run the Pipeline**  
                                 - Customize `process.multiprep.pangenome.adapter-filter.pe.sbatch` to your specific requirements.
                                    - Modify and run:  
                                         `bash process.multiprep.pangenome.adapter-filter.pe.sh`

## References Used for Depletion

| Reference  | Description                                                                                         | Links                                                                                                                                                                                                                                                                                                     | Citation                                                                                                                                                                                                                                             |
|------------|-----------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **GRCH38** | Outdated host reference genome for human.                                                           | [Genome Reference](https://www.ncbi.nlm.nih.gov/data-hub/genome/GCF_000001405.40/)                                                                                                                                                                                                                       |                                                                                                                                                                                                                                                     |
| **T2T + PhiX** | Current host reference genome for human + PhiX.                                                 | [Human Genome Reference](https://www.ncbi.nlm.nih.gov/data-hub/genome/GCF_009914755.1/)<br>[PhiX Genome Reference](https://www.ncbi.nlm.nih.gov/nuccore/9626372)<br>[Associated Paper](https://www.science.org/doi/10.1126/science.abj6987) | Nurk, S., et al. (2022). The complete sequence of a human genome. Science. [DOI](https://doi.org/abj6987)                                                                                                           |
| **Pangenome**  | First draft of Human Pangenome, comprising genomes of 47 people.                                 | [Human Pangenome Project](https://humanpangenome.org)<br>[NCBI BioProject](https://www.ncbi.nlm.nih.gov/bioproject/730823)<br>[GitHub Repository](https://github.com/human-pangenomics/HPP_Year1_Assemblies)<br>[Download Link](https://s3-us-west-2.amazonaws.com/human-pangenomics/index.html?prefix=working/)<br>[Graph File](https://github.com/human-pangenomics/hpp_pangenome_resources#minigraph)<br>[Associated Paper](https://www.nature.com/articles/s41586-023-05896-x) | Liao, W., et al. (2023). A draft human pangenome reference. Nature, 617(7960), 312-324. [DOI](https://doi.org/10.1038/s41586-023-05896-x)                                                                                                     |

Please cite the corresponding references when using this pipeline in your work.
