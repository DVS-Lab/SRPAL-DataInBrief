# SRPAL-DataInBrief
This repository This repository contains the final code for managing and processing all current data in our SRPAL project.

## A few prerequisites and recommendations
- Understand BIDS and be comfortable navigating Linux
- Install [FSL](https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FslInstallation)
- Install [miniconda or anaconda](https://stackoverflow.com/questions/45421163/anaconda-vs-miniconda)
- Install PyDeface: `pip install pydeface`
- Make singularity containers for heudiconv (version: 0.9.0), mriqc (version: 0.16.1), and fmriprep (version: 20.2.3).


## Notes on repository organization and files
- Raw DICOMS (an input to heudiconv) are only accessible locally
- Some of the contents of this repository are not tracked (.gitignore) because the files are large and we do not yet have a nice workflow for datalad. Note that we only track key text files in `bids`.
- Tracked folders and their contents:
  - `code`: analysis code
  - `bids`: contains the standardized "raw" in BIDS format (output of heudiconv)
  - `stimuli`: psychopy scripts and matlab scripts for delivering stimuli and organizing output. This directory also contains the sourcedata for the raw behavioral data.


## Downloading Data
```

```


## Acknowledgments


[openneuro]: https://openneuro.org/
