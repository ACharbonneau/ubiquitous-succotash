

# get all the full mrna coordinates

zcat RawData/Homo_sapiens.GRCh38.96.chr.gff3.gz | grep mRNA > hg38mRNA.gff

# get all the exon coordinates

zgrep "biotype=protein_coding" RawData/Homo_sapiens.GRCh38.96.chr.gff3.gz | cut -f 2 -d ':' | cut -f 1 -d ';' > mrnas.txt
zgrep 'exon' RawData/Homo_sapiens.GRCh38.96.chr.gff3.gz > allexons.gff
zgrep -f mrnas.txt allexons.gff > mrna_exons.gff
rm mrnas.txt 

# remove all the exons from the mrnas: subtract searches for features in B that overlap A, and removes B from A. (leaves just introns) 

bedtools subtract -a hg38mRNA.gff -b mrna_exons.gff -s > mrna_introns.gff

# Get coordinates that are first 50 bases

awk '{ print $1, "\t", $2, "\t", $3, "\t", $4, "\t", $4 + 50, "\t", $6, "\t", $7, "\t", $8, "\t", $9}' mrna_introns.gff > first50_mrna_introns.gff

# Get coordinates that are last 50 bases 

awk '{ print $1, "\t", $2, "\t", $3, "\t", $5 - 50, "\t", $5, "\t", $6, "\t", $7, "\t", $8, "\t", $9}' mrna_introns.gff > last50_mrna_introns.gff

# Remove overlap for short introns (keeps in first 50, truncates last 50)

bedtools subtract -a last50_mrna_introns.gff -b first50_mrna_introns.gff -s > last50_mrna_introns_trun.gff

#Remove any exon sequence (for very short introns)

bedtools subtract -a last50_mrna_introns_trun.gff -b mrna_exons.gff

bedtools subtract -a first50_mrna_introns_trun.gff -b mrna_exons.gff
