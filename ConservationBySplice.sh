cut -f 1,2,3,4,5,6 first50_mrna_introns_final_SNP_Filtered.txt

python3

import pyBigWig
bw = pyBigWig.open("hg38.phyloP30way.bw")
new_cons = open("../ConsBySpliceFirst50.csv",'w')

for line in open("hg38PGCMasterSnps.bed"):
    cols = line.strip().split()
    vals = bw.values(cols[0], int(cols[1]), int(cols[2]))
    new_cons.write("%s, %s, %s, %s, %s, %s, %s\n" % (cols[0], cols[1], cols[2], cols[3], cols[4], cols[5], str(vals[0])))
    
bw.close()
