# get all the full mrna coordinates

module load Anaconda2/4.2.0

conda create --name psyche python=3.3

conda install --channel bioconda gffutils

conda install --channel bioconda pybedtools bedtools biopython


zcat RawData/Homo_sapiens.GRCh38.96.chr.gff3.gz | grep mRNA > hg38mRNA.gff

# To run interactivly do 
## qsub -I -l nodes=1:ppn=1,walltime=12:00:00,mem=100gb -N myjob

# get all the exon coordinates

zgrep "biotype=protein_coding" RawData/Homo_sapiens.GRCh38.96.chr.gff3.gz | cut -f 2 -d ':' | cut -f 1 -d ';' > mrnas.txt
zgrep -f mrnas.txt RawData/Homo_sapiens.GRCh38.96.chr.gff3.gz | grep 'exon' > mrna_exons.gff
rm mrnas.txt 

# remove all the exons from the mrnas (leaves just introns)

bedtools subtract -a hg38mRNA.gff -b mrna_exons.gff -s

# 

