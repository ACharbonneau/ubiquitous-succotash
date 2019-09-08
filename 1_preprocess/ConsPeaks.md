# Getting Conservation peaks

This all has to be run manually and is terrible. Sorry.

Mark wants to use conservation scores from the 30 mammal (27 primate) [multiple alignment from UCSC](http://hgdownload.cse.ucsc.edu/goldenPath/hg38/phastCons30way/). They did this on HG38, and the calculated
peaks are only available as MySQL databases. However, Mark also wants to use Hg37/Hg19 as our reference.

So, the basic flow here is to 

1. Download the UCSC MySQL database (Hg38) and set up a MySQL server.
2. Use a liftover version of SNP list (Hg37 to Hg38) to find SNPs. I had to use the online liftover tool
3. Do SNP filtering
4. Retain the SNP names, but ignore the locations (which are now for Hg38)


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
../RawData/liftOver ../RawData/NoMHC_GPHN_SNP.bed ../RawData/hg19ToHg38.over.chain.gz NoMHC_GPHN_SNP_Hg38.bed unMapped
```

### local bash

```local bash
scp phastConsElements30way.tsv charbo24@hpcc.msu.edu:/mnt/research/PsychGenetics/LDSC_preprocess/ConsPeaks/
```
### HPC bash

```hpc bash

cut -f 2,3,4,5,6 phastConsElements30way.tsv > phastConsElements30way.bed

# Use bedtools to find the location intersection between the SNP list from NCBI that has SNP locations, atacseq files
module load BEDTools
bedtools intersect -wa -wb -a NoMHC_GPHN_SNP_Hg38.bed -b phastConsElements30way.bed > 30Cons_SNP_Locations.txt


# Get rid of X, Y chromosomes
grep -v chrX 30Cons_SNP_Locations.txt > temp
grep -v chrY temp > 30Cons_SNP_Somatic.txt
rm temp

# Reduce matrix to: chr, snpstart, snpend, rsID, allele, alt, intronstart, intronstop, strand, genename


awk '{ print $1 "\t" $2 "\t" $3 "\t" $4 "\t" $5 "\t" $6 "\t" $10 "\t" $11 "\t" $13 "\t" $15 }' 30Cons_SNP_Somatic.txt  > 30Cons_SNP_Final.txt 



# Make files for LDSR
awk '{ print $4 }' 30Cons_SNP_Final.txt | sort | uniq  > 30Cons_LSDR.txt
```

