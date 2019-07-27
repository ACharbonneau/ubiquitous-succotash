mkdir RawData || exit

cd RawData || exit

# Human gene list with exons, as gff3 

wget ftp://ftp.ensembl.org/pub/release-96/gff3/homo_sapiens/Homo_sapiens.GRCh38.96.chr.gff3.gz

# Human genome

#wget -r ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/release/20130502/supporting/GRCh38_positions/

# Chromatin states Core 15-state model (5 marks, 127 epigenomes)

wget https://egg2.wustl.edu/roadmap/data/byFileType/chromhmmSegmentations/ChmmModels/coreMarks/jointModel/final/E001_15_coreMarks_hg38lift_dense.bed.gz

# SNP locations

wget ftp://ftp.ncbi.nih.gov/snp/latest_release/VCF/GCF_000001405.38.bgz



# sh 1_RNAs.sh


## Conservation scores for alignments of 30 mammalian (27 primate) genomes with human
wget http://hgdownload.cse.ucsc.edu/goldenPath/hg38/phastCons30way/hg38.phastCons30way.bw


## Basewise conservation scores (phyloP) of 30 mammalian (27 primate) genomes with human
http://hgdownload.soe.ucsc.edu/goldenPath/hg38/phyloP30way/hg38.phyloP30way.bw

## Get the sql database for the conserved elements in human +29

wget ftp://hgdownload.soe.ucsc.edu/mysql/hg38/phastConsElements30way.MYD
wget ftp://hgdownload.soe.ucsc.edu/mysql/hg38/phastConsElements30way.MYI
wget ftp://hgdownload.soe.ucsc.edu/mysql/hg38/phastConsElements30way.frm

wget ftp://hgdownload.soe.ucsc.edu/mysql/hg38/phastCons30way.MYD
wget ftp://hgdownload.soe.ucsc.edu/mysql/hg38/phastCons30way.MYI
wget ftp://hgdownload.soe.ucsc.edu/mysql/hg38/phastCons30way.frm

## The current set of regulatory features along with their predicted activity in every cell type.

wget ftp://ftp.ensembl.org/pub/release-97/regulation/homo_sapiens/homo_sapiens.GRCh38.Regulatory_Build.regulatory_features.20190329.gff.gz




cd .. || exit 
