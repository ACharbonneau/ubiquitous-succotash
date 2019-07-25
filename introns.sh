

# get all the full mrna coordinates

zcat RawData/Homo_sapiens.GRCh38.96.chr.gff3.gz | grep mRNA > hg38mRNA.gff

# get all the exon coordinates

zgrep "biotype=protein_coding" RawData/Homo_sapiens.GRCh38.96.chr.gff3.gz | cut -f 2 -d ':' | cut -f 1 -d ';' > mrnas.txt
zgrep 'exon' RawData/Homo_sapiens.GRCh38.96.chr.gff3.gz > allexons.gff
zgrep -f mrnas.txt allexons.gff > mrna_exons.gff
rm mrnas.txt 

# remove all the exons from the mrnas (leaves just introns)

bedtools subtract -a hg38mRNA.gff -b mrna_exons.gff -s > mrna_introns.gff

# 

