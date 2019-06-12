# We want to find SNPs that fall inside coding regions of antisense, lincRNA, snoRNA, and miRNAs

# First, make a list of features to search for, then loop through searching for them

featurelist="lincRNA antisense snoRNA miRNA"

# Get coding regions for all these. Need to first get names, then pull out their exons. For ones without introns/exons the exons are the same locations as the overall feature

for feature in `echo ${featurelist}`
   do
   zgrep "${feature}" Homo_sapiens.GRCh38.96.chr.gff3.gz | cut -f 2 -d ':' | cut -f 1 -d ';' > rnas.txt
   zgrep -f rnas.txt Homo_sapiens.GRCh38.96.chr.gff3.gz | grep 'exon' > "${feature}".txt
   rm rnas.txt 
   done
 


