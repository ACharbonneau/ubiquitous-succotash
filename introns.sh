
mkdir introns

cd introns || exit

# To run interactivly do 
## qsub -I -l nodes=1:ppn=1,walltime=24:00:00,mem=100gb -N myjob


# get all the full mrna coordinates

zgrep "biotype=protein_coding" ../RawData/Homo_sapiens.GRCh38.96.chr.gff3.gz > hg38mRNA.gff

# get all the exon coordinates

zgrep "biotype=protein_coding" ../RawData/Homo_sapiens.GRCh38.96.chr.gff3.gz | cut -f 2 -d ':' | cut -f 1 -d ';' > mrnas.txt
zgrep -f mrnas.txt ../RawData/allexons.gff > mrna_exons.gff
rm mrnas.txt 

# remove all the exons from the mrnas: subtract searches for features in B that overlap A, and removes B from A. (leaves just introns) 

bedtools subtract -a hg38mRNA.gff -b mrna_exons.gff -s > mrna_introns.gff

# Get coordinates that are first 100 bases (replace start coordinate with starting -50, end coordinate with starting coordinate + 50)

awk '{ print $1 "\t" $2 "\t" $3 "\t" $4 -50 "\t" $4 + 50 "\t" $6 "\t" $7 "\t" $8 "\t" $9}' mrna_introns.gff > first50_mrna_introns.gff

# Get coordinates that are last 100 bases (replace start coordinate with ending coordinate - 50, ending coordinate with ending + 50)

awk '{ print $1 "\t" $2 "\t" $3, "\t" $5 - 50 "\t" $5 +50 "\t" $6 "\t" $7 "\t" $8 "\t" $9}' mrna_introns.gff > last50_mrna_introns.gff


# Remove overlap for any introns < 100 bases (overlap stays in first 50 file, is removed from last 50 file)

bedtools subtract -a last50_mrna_introns.gff -b first50_mrna_introns.gff -s > last50_mrna_introns_trun.gff


## Was only getting intron side, now getting both (above)
# Get coordinates that are first 50 bases (replace end coordinate with starting coordinate + 50)

#awk '{ print $1 "\t" $2 "\t" $3 "\t" $4 "\t" $4 + 50 "\t" $6 "\t" $7 "\t" $8 "\t" $9}' mrna_introns.gff > first50_mrna_introns.gff

# Get coordinates that are last 50 bases (replace start coordinate with ending coordinate + 50)

#awk '{ print $1 "\t" $2 "\t" $3, "\t" $5 - 50 "\t" $5 "\t" $6 "\t" $7 "\t" $8 "\t" $9}' mrna_introns.gff > last50_mrna_introns.gff

# Remove overlap for any introns < 100 bases (overlap stays in first 50 file, is removed from last 50 file)

#bedtools subtract -a last50_mrna_introns.gff -b first50_mrna_introns.gff -s > last50_mrna_introns_trun.gff

#Remove any exon sequence that was added by addition/subtraction operations (for very short introns)

#bedtools subtract -a last50_mrna_introns_trun.gff -b mrna_exons.gff > last50_mrna_introns_final.gff

#bedtools subtract -a first50_mrna_introns.gff -b mrna_exons.gff > first50_mrna_introns_final.gff

# Rename chromosomes in feature gffs to match SNP location file from hg38PGCMasterSnps.bed

featurelist="last50_mrna_introns first50_mrna_introns"

for feature in ${featurelist}
   do awk '{ print "chr" $1 "\t" $2 "\t" $3, "\t" $5 - 50 "\t" $5 "\t" $6 "\t" $7 "\t" $8 "\t" $9}' ${feature}.gff > ${feature}_chr.gff
done


# Use bedtools to find the location intersection between the SNP list from NCBI that has SNP locations, intron files

for feature in ${featurelist}
   do bedtools intersect -wa -wb -a ../RawData/hg38PGCMasterSnps.bed -b ${feature}_chr.gff > ${feature}_SNP_Locations.txt
done

# Get rid of X, Y chromosomes
for feature in ${featurelist}
    do grep -v chrX ${feature}_SNP_Locations.txt > temp
       grep -v chrY temp > ${feature}_SNP_Somatic.txt
done
rm temp

# File has lots of mostly duplicate rows because many genes have more than one mrna that use the same exons. 
# Need to remove duplicates and Reduce matrix to: chr, snpstart, snpend, rsID, allele, alt, intronstart, intronstop, strand, genename

for feature in ${featurelist}
    do awk '{ print $1 "\t" $2 "\t" $3 "\t" $4 "\t" $5 "\t" $6 "\t" $10 "\t" $11 "\t" $13 "\t" $15 }' ${feature}_SNP_Somatic.txt | sed 's/ID=transcript:\w\+;//g' | sed 's/ID=gene://g' | sed 's/Parent=gene://g' | cut -f 1 -d ';' | sort | uniq > ${feature}_SNP_Filtered.txt 
done


# Make files for LDSR

for feature in ${featurelist}
   do awk '{ print $4 }' ${feature}_SNP_Filtered.txt | sort | uniq  > ${feature}_LSDR.txt
done
