# Social Reward Processing Across the Lifespan (SRPAL)
This repository contains the code for managing and processing the imaging data tied to our Social Reward Processing Across the Lifespan (SRPAL) project, which is funded by the National Institute on Aging (R01-AG067011 to David V. Smith).

The data is available on OpenNeuro (https://openneuro.org/datasets/ds005123/versions/1.0.0) and we expect to update the dataset with additional imaging data and phenotype data when the project is complete.

A paper describing the interim dataset has been submitted to Data in Brief.

## Repository organization and files
- Some of the contents of this repository are not tracked (.gitignore) because the files are large and we do not yet have a nice workflow for datalad. Note that we only track key text files in `bids`.
- Tracked folders and their contents:
  - `code`: analysis and data curation code
  - `bids`: contains the standardized "raw" in BIDS format (output of heudiconv). Note that directory is what we uploaded to OpenNeuro.
  - `stimuli`: psychopy scripts and matlab scripts for delivering stimuli and organizing output. This directory also contains the sourcedata for the raw behavioral data.


## Downloading Data
```
# using AWS
aws s3 sync --no-sign-request s3://openneuro.org/ds005123 ds005123-download/

# using datalad
datalad install https://github.com/OpenNeuroDatasets/ds005123.git
cd ds005123
datalad get .
```


## Acknowledgments
We thank Jeffery Dennison, Ori Zaff, Rita Ludwig, Makayla Collins, Ashley Hawk, Enes Yanilmaz, and Matthew J. Drayton for assistance with data collection. We also thank the Temple University High-Performance Computing Team for providing resources and support for preprocessing and data analysis.
