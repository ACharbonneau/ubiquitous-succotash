# ubiquitous-succotash

Code for building various datasets for LDSR

Each dataset needs it's own unique pipeline, all of these are in the '1_preprocess' folder.

Unless otherwise noted, all of these scripts were built on the MSU High Performance Computing Cluster. Building it elsewhere may require installing several programs, and may require some editing of scripts. At a minimum, the machine running it will need:

git 2.10.1

bedtools v2.27.1

python 3.6.4

R 3.2.0 (packages will auto-install)

pandoc 1.17.3

mySQL 5.7 

TLDR;

1. Make a main directory
2. Clone repo into that directory
3. Change hardcoded file paths to snp files if necessary
4. Run script 0_GetData.sh, from the main directory to download all the raw data.

> bash ubiquitous-succotash/0_GetData.sh

5. Run individual scripts from '1_preprocess'. Most can just be run with bash, i.e. `bash scriptname`, but a few are fiddly and need individual lines run

6. Run 2_LDSR_wave1.sh

## Files
