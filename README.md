# ubiquitous-succotash
Code for analyzing long non-coding RNAs

This paper was built on the MSU High Performance Computing Cluster. Building it elsewhere may require installing several programs, and may require some editing of submission scripts. At a minimum, the machine running it will need:

git 2.10.1

bedtools v2.27.1

python 3.6.4

R 3.2.0 (packages will auto-install)

pandoc 1.17.3

TLDR;

1. Make a main directory
2. Clone repo into that directory
3. Change hardcoded file paths to snp files if necessary
4. Run script 0_GetData.sh, from the main directory.

> bash ubiquitous-succotash/0_GetData.sh

## Files
