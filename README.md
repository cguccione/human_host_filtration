# Human Host Depletion Pipeline

This is a bioinformatics pipeline designed to provide highly-conservative depletion of human reads from metagenomic sequencing data. The pipeline is designed to be flexible and can be used with any host reference genome(s), though certain specific human reference genomes are suggested. The pipeline is designed to be used with paired-end Illumina sequencing data, but can be easily modified to work with single-end data. The pipeline is designed for SLURM and PBS job schedulers, but can be easily modified to run independently.

Implementation details are discussed in [Guccione and Patel et al. (2024)](). A preprint is available [here]().

## Setup

First, clone the repository.
```bash
git clone https://github.com/cguccione/human_host_depletion
```

Next, ensure your environment has the following packages installed:
* [Fastp](https://github.com/OpenGene/fastp)
* [Minimap2](https://github.com/lh3/minimap2)
* [Samtools](https://github.com/lh3/samtools)
* [Movi](https://github.com/mohsenzakeri/Movi)

We recommend using the provided prebuilt [conda](https://docs.conda.io/en/latest/#) to install the required packages. Movi does not have a conda package, so it must be installed separately. See the [installation instructions for Movi](https://github.com/mohsenzakeri/Movi#install-movi-and-its-dependencies-from-source).
```bash
conda env create -f human-depletion.yml
```

Next, download the human reference genomes to be used for filtration. We recommend [GRCh38](https://www.ncbi.nlm.nih.gov/datasets/genome/GCF_000001405.26/), [T2T-CHM13v2.0](https://www.ncbi.nlm.nih.gov/datasets/genome/GCF_009914755.1/), and all currently available pangenomes from the [Human Pangenome Reference Consortium (HPRC)](https://humanpangenome.org). See the table below for additional information and citations for the reference genomes used in this pipeline. A download script is provided for convenience.
```bash
bash download_references.sh
```

Next, create Minimap2 and Movi indexes for the previously downloaded reference genomes. A script is provided for convenience.
```bash
bash create_indexes.sh
```

Next, configure the file `config.sh` with the necessary files and executables for your environment. The file `config.sh` is sourced by all other scripts in the pipeline, so it is important to ensure that it is configured correctly. Some of the variables in `config.sh` have specific constraints that must be followed. These constraints are described in the comments of `config.sh`. An example is provided below:
```bash
# configure experiment parameters
IN="data"
OUT="data/host-filtered"
MODE="PE" # "SE" (single-end) or "PE" (paired-end)
METHODS=("ALIGN-HPRC" "INDEX-HPRC") # any combination of "ALIGN-HG38", "ALIGN-T2T", "ALIGN-HPRC", or "INDEX-HPRC"; do not comma separate
SAVE_INTERMEDIATE=1 # 0 for TRUE and 1 for FALSE
THREADS=7 # changes to THREADS must also be reflected in #SBATCH --ntasks=7 within `filter.sh`

# configure index filtration parameters
METRIC="custom" # "max", "average", or "custom"
THRESHOLD=0.175 # suggested thresholds are 31 for "max", 3.206 for "average", and 0.175 for "custom"
MIN_RUN_LENGTH=5

# configure software and reference paths
MOVI_PATH="/path/to/movi-default" # path to movi-default executable
MOVI_INDEX_PATH="ref/movi" # path to prebuilt movi_index.bin
MINIMAP2_HG38_INDEX_PATH="ref/mmi/hg38.mmi" # one index
MINIMAP2_T2T_INDEX_PATH="ref/mmi/t2t.mmi" # one index
MINIMAP2_HPRC_INDEX_PATH="ref/mmi" # directory of indexes
ADAPTERS="ref/known_adapters.fna"
TMP="" # path to temporary directory for writing
```

Finally, run the pipeline. Outputs will be found in the directory specified by the `OUT` variable in `config.sh`.
```
bash filter.sh
```

## Usage
In [Guccione and Patel et al. (2024)]() we found that the choice of human reference genome(s) and the method of filtration can have a significant impact on the resulting metagenomic data. This pipeline ensembles several different human reference genomes and filtration methods to provide a highly-conservative, user-configurable method for removal of human reads from metagenomic sequencing data. Users may choose to run one or all methods in sequence.

This pipeline has several modes that can be executed independently depending on the preferences of the user. The four modes are:
  * Human host filration by alignment (GRCh38) 
  * Human host filration by alignment (GRCh38 + T2T-CHM13v2.0) 
  * Human host filration by alignment (GRCh38 + T2T-CHM13v2.0 + HPRC) 
  * Human host filration by indexing (GRCh38 + T2T-CHM13v2.0 + HPRC) 

## Troubleshooting

> **"I am trying to host-deplete my data using an 'ALIGN' method, but my outputs have zero reads. The logs note "No input sequence specified." What is going on?"**

This issue typically arises when running the pipeline in paired-end mode with unconventional read IDs. Minimap2 requires that paired-end reads have the same read ID, with the only difference being the `/1` or `/2` suffix. If your read IDs do not follow this convention, the pipeline will not be able to properly pair your reads. To resolve this issue, you must modify your read IDs to follow the convention.

## References
Please cite [Guccione and Patel et al. (2024)]() when using this pipeline in your work.
```
Guccione, C., Patel L., et al. (2024). Human host depletion: a bioinformatics pipeline for highly-conservative depletion of human reads from metagenomic sequencing data. [DOI]()
```

Additionally, the following human reference genomes are used in this pipeline.

| Human Reference | Link                                                                   | Citation                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
|-----------------|------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| GRCh38          | [NCBI](https://www.ncbi.nlm.nih.gov/datasets/genome/GCF_000001405.26/) | Schneider VA, Graves-Lindsay T, Howe K, Bouk N, Chen HC, Kitts PA, Murphy TD, Pruitt KD, Thibaud-Nissen F, Albracht D, Fulton RS, Kremitzki M, Magrini V, Markovic C, McGrath S, Steinberg KM, Auger K, Chow W, Collins J, Harden G, Hubbard T, Pelan S, Simpson JT, Threadgold G, Torrance J, Wood JM, Clarke L, Koren S, Boitano M, Peluso P, Li H, Chin CS, Phillippy AM, Durbin R, Wilson RK, Flicek P, Eichler EE, Church DM. Evaluation of GRCh38 and de novo haploid genome assemblies demonstrates the enduring quality of the reference assembly. Genome Res. 2017 May;27(5):849-864. doi: 10.1101/gr.213611.116. Epub 2017 Apr 10. PMID: 28396521; PMCID: PMC5411779.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
| T2T-CHM13v2.0   | [NCBI](https://www.ncbi.nlm.nih.gov/datasets/genome/GCF_009914755.1/)  | Nurk S, Koren S, Rhie A, Rautiainen M, Bzikadze AV, Mikheenko A, Vollger MR, Altemose N, Uralsky L, Gershman A, Aganezov S, Hoyt SJ, Diekhans M, Logsdon GA, Alonge M, Antonarakis SE, Borchers M, Bouffard GG, Brooks SY, Caldas GV, Chen NC, Cheng H, Chin CS, Chow W, de Lima LG, Dishuck PC, Durbin R, Dvorkina T, Fiddes IT, Formenti G, Fulton RS, Fungtammasan A, Garrison E, Grady PGS, Graves-Lindsay TA, Hall IM, Hansen NF, Hartley GA, Haukness M, Howe K, Hunkapiller MW, Jain C, Jain M, Jarvis ED, Kerpedjiev P, Kirsche M, Kolmogorov M, Korlach J, Kremitzki M, Li H, Maduro VV, Marschall T, McCartney AM, McDaniel J, Miller DE, Mullikin JC, Myers EW, Olson ND, Paten B, Peluso P, Pevzner PA, Porubsky D, Potapova T, Rogaev EI, Rosenfeld JA, Salzberg SL, Schneider VA, Sedlazeck FJ, Shafin K, Shew CJ, Shumate A, Sims Y, Smit AFA, Soto DC, Sović I, Storer JM, Streets A, Sullivan BA, Thibaud-Nissen F, Torrance J, Wagner J, Walenz BP, Wenger A, Wood JMD, Xiao C, Yan SM, Young AC, Zarate S, Surti U, McCoy RC, Dennis MY, Alexandrov IA, Gerton JL, O'Neill RJ, Timp W, Zook JM, Schatz MC, Eichler EE, Miga KH, Phillippy AM. The complete sequence of a human genome. Science. 2022 Apr;376(6588):44-53. doi: 10.1126/science.abj6987. Epub 2022 Mar 31. PMID: 35357919; PMCID: PMC9186530.                                                                                                                                                                       |
| HPRC            | [NCBI](https://www.ncbi.nlm.nih.gov/bioproject/730823)                 | Liao WW, Asri M, Ebler J, Doerr D, Haukness M, Hickey G, Lu S, Lucas JK, Monlong J, Abel HJ, Buonaiuto S, Chang XH, Cheng H, Chu J, Colonna V, Eizenga JM, Feng X, Fischer C, Fulton RS, Garg S, Groza C, Guarracino A, Harvey WT, Heumos S, Howe K, Jain M, Lu TY, Markello C, Martin FJ, Mitchell MW, Munson KM, Mwaniki MN, Novak AM, Olsen HE, Pesout T, Porubsky D, Prins P, Sibbesen JA, Sirén J, Tomlinson C, Villani F, Vollger MR, Antonacci-Fulton LL, Baid G, Baker CA, Belyaeva A, Billis K, Carroll A, Chang PC, Cody S, Cook DE, Cook-Deegan RM, Cornejo OE, Diekhans M, Ebert P, Fairley S, Fedrigo O, Felsenfeld AL, Formenti G, Frankish A, Gao Y, Garrison NA, Giron CG, Green RE, Haggerty L, Hoekzema K, Hourlier T, Ji HP, Kenny EE, Koenig BA, Kolesnikov A, Korbel JO, Kordosky J, Koren S, Lee H, Lewis AP, Magalhães H, Marco-Sola S, Marijon P, McCartney A, McDaniel J, Mountcastle J, Nattestad M, Nurk S, Olson ND, Popejoy AB, Puiu D, Rautiainen M, Regier AA, Rhie A, Sacco S, Sanders AD, Schneider VA, Schultz BI, Shafin K, Smith MW, Sofia HJ, Abou Tayoun AN, Thibaud-Nissen F, Tricomi FF, Wagner J, Walenz B, Wood JMD, Zimin AV, Bourque G, Chaisson MJP, Flicek P, Phillippy AM, Zook JM, Eichler EE, Haussler D, Wang T, Jarvis ED, Miga KH, Garrison E, Marschall T, Hall IM, Li H, Paten B. A draft human pangenome reference. Nature. 2023 May;617(7960):312-324. doi: 10.1038/s41586-023-05896-x. Epub 2023 May 10. PMID: 37165242; PMCID: PMC10172123. |
