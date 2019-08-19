## This won't actually run in one place. I had to set up MySQL locally and then move the output to the HPC

### local bash
``` local bash
brew install mysql@5.7

/usr/local/Cellar/mysql\@5.7/5.7.26/bin/mysql.server start
/usr/local/Cellar/mysql\@5.7/5.7.26/bin/mysql -uroot
```
### local mysql

```mysql
CREATE DATABASE ConsElements;
EXIT
mysql.server stop
```
### local bash

```local bash
mv phastConsElements30way.MYI /usr/local/var/mysql/ConsElements
mv phastConsElements30way.frm /usr/local/var/mysql/ConsElements
mv phastConsElements30way.MYD /usr/local/var/mysql/ConsElements

mysql.server start

/usr/local/Cellar/mysql\@5.7/5.7.26/bin/mysql -uroot ConsElements -B -e "SELECT * FROM phastConsElements30way;" > ~/brainRNA/phastConsElements30way.tsv
```
### HPC bash

``` HPC bash
mkdir ConsPeaks
cd ConsPeaks/ || exit
```

### local bash

```local bash
scp phastConsElements30way.tsv charbo24@hpcc.msu.edu:/mnt/research/PsychGenetics/LDSC_preprocess/ConsPeaks/
```
### HPC bash

```hpc bash

cut -f 2,3,4,5,6 phastConsElements30way.tsv > phastConsElements30way.bed

# Use bedtools to find the location intersection between the SNP list from NCBI that has SNP locations, atacseq files

bedtools intersect -wa -wb -a ../RawData/hg38PGCMasterSnps.bed -b phastConsElements30way.bed > 30Cons_SNP_Locations.txt


# Get rid of X, Y chromosomes
grep -v chrX 30Cons_SNP_Locations.txt > temp
grep -v chrY temp > 30Cons_SNP_Somatic.txt
rm temp

# Reduce matrix to: chr, snpstart, snpend, rsID, allele, alt, intronstart, intronstop, strand, genename


awk '{ print $1 "\t" $2 "\t" $3 "\t" $4 "\t" $5 "\t" $6 "\t" $10 "\t" $11 "\t" $13 "\t" $15 }' 30Cons_SNP_Somatic.txt  > 30Cons_SNP_Final.txt 



# Make files for LDSR
awk '{ print $4 }' 30Cons_SNP_Final.txt | sort | uniq  > 30Cons_LSDR.txt
```

