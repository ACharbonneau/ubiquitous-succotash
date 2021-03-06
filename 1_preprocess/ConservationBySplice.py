
# called from introns.sb

import pyBigWig
bw = pyBigWig.open("../RawData/hg38.phyloP30way.bw")
new_cons = open("ConsBySpliceFirst70.csv",'w')

for line in open("first70_mrna_introns_SNP_Filtered_Hg38.bed"):
    cols = line.strip().split()
    vals = bw.values(cols[0], int(cols[1]), int(cols[2]))
    new_cons.write("%s, %s, %s, %s, %s\n" % (cols[0], cols[1], cols[2], cols[3], str(vals[0])))
    
bw = pyBigWig.open("../RawData/hg38.phyloP30way.bw")
new_cons = open("ConsBySpliceLast70.csv",'w')

for line in open("last70_mrna_introns_SNP_Filtered_Hg38.bed"):
    cols = line.strip().split()
    vals = bw.values(cols[0], int(cols[1]), int(cols[2]))
    new_cons.write("%s, %s, %s, %s, %s\n" % (cols[0], cols[1], cols[2], cols[3], str(vals[0])))
    
