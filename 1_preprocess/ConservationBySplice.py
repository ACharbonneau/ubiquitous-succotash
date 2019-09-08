
# called from introns.sh

import pyBigWig
bw = pyBigWig.open("../RawData/hg38.phyloP30way.bw")
new_cons = open("ConsBySpliceFirst50.csv",'w')

for line in open("first50_mrna_introns_SNP_Filtered.bed"):
    cols = line.strip().split()
    vals = bw.values(cols[0], int(cols[1]), int(cols[2]))
    new_cons.write("%s, %s, %s, %s, %s, %s, %s\n" % (cols[0], cols[1], cols[2], cols[3], cols[4], cols[5], str(vals[0])))
    
bw.close()

bw = pyBigWig.open("../RawData/hg38.phyloP30way.bw")
new_cons = open("ConsBySpliceLast50.csv",'w')

for line in open("last50_mrna_introns_SNP_Filtered.bed"):
    cols = line.strip().split()
    vals = bw.values(cols[0], int(cols[1]), int(cols[2]))
    new_cons.write("%s, %s, %s, %s, %s, %s, %s\n" % (cols[0], cols[1], cols[2], cols[3], cols[4], cols[5], str(vals[0])))
    
bw.close()
