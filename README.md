# Human Host Depletion

**Pipeline which removes human DNA from microbial shotgun samples.**

How to use pipeline:
- Create Minimap References needed for Host Depletion  
	- Run the *create_minimap_indexes/1_nonPangenome_humanRefs.sh* to download hg38 + T2T genome and convert them into minimap2 indexes  
  	- Run the *create_minimap_indexes/2_download_pangenome_fastqs.sh* to download all 94 pangenome references  
  	- Run the *create_minimap_indexes/3_create_pangenome_minimap_indexes.sh* to convert pangenome references into minimap2 indexes  
- Run Host Depletion Pipeline with Pangenome: *pangenome_host_deplete.sh*  
- Run Host Depletion Pipeline with Pangenome + hg38 + T2T: *hg38_T2T_pangenome_host_deplete.sh*

*New* version of pangenome in pipeline, using gfa:
- Instead of using all 94 pangenomes, can use a single graph file (more detail in email on pros/cons of approach)
	- Download minigraph and gfatools
 		- minigraph: https://github.com/lh3/minigraph
        - Download pangenome file:
		- `wget https://s3-us-west-2.amazonaws.com/human-pangenomics/pangenomes/freeze/freeze1/minigraph/hprc-v1.0-minigraph-chm13.gfa.gz`

Info on Human references used for depletion:

- GRCH38
	- description: host reference genome for human (outdated)
	- reference: GCF_000001405.40 (GRCh38.p14)
	- reference link: https://www.ncbi.nlm.nih.gov/data-hub/genome/GCF_000001405.40/   

- T2T + PhiX
	- description: host reference genome for human (current) + PhiX
	- reference (human): GCF_009914755.1 (T2T-CHM13v2.0)
	- reference (PhiX): NC_001422.1 (Escherichia phage phiX174)
	- reference link (human): https://www.ncbi.nlm.nih.gov/data-hub/genome/GCF_009914755.1/
	- reference link: (PhiX): https://www.ncbi.nlm.nih.gov/nuccore/9626372
 	- paper link: https://www.science.org/doi/10.1126/science.abj6987
  	- paper citation: Nurk, S., Koren, S., Rhie, A., Rautiainen, M., Bzikadze, A. V., Mikheenko, A., Vollger, M. R., Altemose, N., Uralsky, L., Gershman, A., Aganezov, S., Hoyt, S. J., Diekhans, M., Logsdon, G. A., Alonge, M., Antonarakis, S. E., Borchers, M., Bouffard, G. G., Brooks, S. Y., . . .  Phillippy, A. M. (2022). The complete sequence of a human genome. Science. https://doi.org/abj6987  

- Pangenome
	- description: First draft of Human Pangenome, comprising genomes of 47 people
	- reference (human): https://humanpangenome.org , https://www.ncbi.nlm.nih.gov/bioproject/730823 , https://github.com/human-pangenomics/HPP_Year1_Assemblies
	- reference link (download): 
		- https://s3-us-west-2.amazonaws.com/human-pangenomics/index.html?prefix=working/
		- Downloaded these using *create_minimap_indexes/2_download_pangenome_fastqs.sh* script
    	- graph file (download): https://github.com/human-pangenomics/hpp_pangenome_resources#minigraph
        - paper link: https://www.nature.com/articles/s41586-023-05896-x
  	- paper citation: Liao, W., Asri, M., Ebler, J., Doerr, D., Haukness, M., Hickey, G., Lu, S., Lucas, J. K., Monlong, J., Abel, H. J., Buonaiuto, S., Chang, X. H., Cheng, H., Chu, J., Colonna, V., Eizenga, J. M., Feng, X., Fischer, C., Fulton, R. S., . . .  Paten, B. (2023). A draft human pangenome reference. Nature, 617(7960), 312-324. https://doi.org/10.1038/s41586-023-05896-x
