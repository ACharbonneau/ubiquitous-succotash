# We want to find SNPs that fall inside coding regions of antisense, lincRNA, snoRNA, and miRNAs

# First, make a list of chromosome names to go through. It will be faster to loop through them then search every name in every chromosome file

featurelist="lincRNA antisense snoRNA miRNA"

# Then, get coding regions for lincRNAs. Need to first get lincRNA names, then pull out their exons

for feature in `echo ${featurelist}`
   do
   zgrep "${feature}" Homo_sapiens.GRCh38.96.chr.gff3.gz | cut -f 2 -d ':' | cut -f 1 -d ';' > rnas.txt
   zgrep -f rnas.txt Homo_sapiens.GRCh38.96.chr.gff3.gz | grep 'exon' > "${feature}".txt
   rm rnas.txt 
   done
   
# Run the same code, but to get exons for other RNAs

# antisense

for c in `echo $chromo`
   do
   zgrep 'antisense' Homo_sapiens.GRCh38.96.chromosome.${c}.gff3.gz | cut -f 2 -d ':' | cut -f 1 -d ';' > rnas.txt   
   zgrep -f rnas.txt Homo_sapiens.GRCh38.96.chromosome.${c}.gff3.gz | grep 'exon'
   done >> antisenseExons.txt

# snoRNAs

for c in `echo $chromo`
   do
   zgrep 'snorna' Homo_sapiens.GRCh38.96.chromosome.${c}.gff3.gz | cut -f 2 -d ':' | cut -f 1 -d ';' > rnas.txt   
   zgrep -f rnas.txt Homo_sapiens.GRCh38.96.chromosome.${c}.gff3.gz | grep 'exon'
   done >> snoExons.txt

# antisense

for c in `echo $chromo`
   do
   zgrep 'mirna' Homo_sapiens.GRCh38.96.chromosome.${c}.gff3.gz | cut -f 2 -d ':' | cut -f 1 -d ';' > rnas.txt   
   zgrep -f rnas.txt Homo_sapiens.GRCh38.96.chromosome.${c}.gff3.gz | grep 'exon'
   done >> miExons.txt
