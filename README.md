# Human Host Depletion

Pipeline which removes human DNA from microbial shotgun samples.  
  
Human references used for depletion:

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

- Pangenome
	- description: First draft of Human Pangenome, comprising genomes of 47 people
	- reference (human): https://humanpangenome.org , https://www.ncbi.nlm.nih.gov/bioproject/730823 , https://github.com/human-pangenomics/HPP_Year1_Assemblies
	- reference link (download): 
		- https://s3-us-west-2.amazonaws.com/human-pangenomics/index.html?prefix=working/
		- Downloaded these using X script
