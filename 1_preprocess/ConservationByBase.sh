
mkdir ConsByBase

python3

import pyBigWig
bw = pyBigWig.open("hg38.phyloP30way.bw")
new_cons = open("../ConsByBase/ConsByBase.csv",'w')

for line in open("hg38PGCMasterSnps.bed"):
    cols = line.strip().split()
    vals = bw.values(cols[0], int(cols[1]), int(cols[2]))
    new_cons.write("%s, %s, %s, %s, %s, %s, %s\n" % (cols[0], cols[1], cols[2], cols[3], cols[4], cols[5], str(vals[0])))
    
exit()

cd ConsByBase || exit

#slower than expected evolution
sed 's/, /\t/g' ConsByBase.csv | awk '{if($7>.5)print $1 "\t" $2 "\t" $3 "\t" $4 "\t" $5 "\t" $6 "\t" $7}' > ConsByBase.tsv

#to add faster than expected evolution
#sed 's/, /\t/g' ConsByBase.csv | awk '{if($7<-.5)print $1 "\t" $2 "\t" $3 "\t" $4 "\t" $5 "\t" $6 "\t" $7}' >> ConsByBase.tsv

awk '{ print $4 }' ConsByBase.tsv > ConsByBase_LSDR.txt
