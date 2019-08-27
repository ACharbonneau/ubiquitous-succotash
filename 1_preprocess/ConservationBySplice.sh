
# Relies on output from introns.sh

mkdir ConsBySplice

cut -f 1,2,3,4,5,6 introns/first50_mrna_introns_SNP_Filtered.txt > ConsBySplice/first50_mrna_introns_SNP_Filtered.bed
cut -f 1,2,3,4,5,6 introns/last50_mrna_introns_SNP_Filtered.txt > ConsBySplice/last50_mrna_introns_SNP_Filtered.bed


python3

import pyBigWig
bw = pyBigWig.open("RawData/hg38.phyloP30way.bw")
new_cons = open("ConsBySplice/ConsBySpliceFirst50.csv",'w')

for line in open("ConsBySplice/first50_mrna_introns_SNP_Filtered.bed"):
    cols = line.strip().split()
    vals = bw.values(cols[0], int(cols[1]), int(cols[2]))
    new_cons.write("%s, %s, %s, %s, %s, %s, %s\n" % (cols[0], cols[1], cols[2], cols[3], cols[4], cols[5], str(vals[0])))
    
bw.close()

bw = pyBigWig.open("RawData/hg38.phyloP30way.bw")
new_cons = open("ConsBySplice/ConsBySpliceLast50.csv",'w')

for line in open("ConsBySplice/last50_mrna_introns_SNP_Filtered.bed"):
    cols = line.strip().split()
    vals = bw.values(cols[0], int(cols[1]), int(cols[2]))
    new_cons.write("%s, %s, %s, %s, %s, %s, %s\n" % (cols[0], cols[1], cols[2], cols[3], cols[4], cols[5], str(vals[0])))
    
bw.close()
