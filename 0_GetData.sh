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

cd .. || exit 

# sh 1_RNAs.sh


## Conservation scores for alignments of 30 mammalian (27 primate) genomes with human
wget http://hgdownload.cse.ucsc.edu/goldenPath/hg38/phastCons30way/hg38.phastCons30way.bw


## Basewise conservation scores (phyloP) of 30 mammalian (27 primate) genomes with human
wget http://hgdownload.soe.ucsc.edu/goldenPath/hg38/phyloP30way/hg38.phyloP30way.mod
