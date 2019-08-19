# We want to find SNPs that fall inside coding regions of antisense, lincRNA, snoRNA, and miRNAs

# First, make a list of features to search for in the Ensembl genome gff, then loop through searching for them


# To run interactivly do 
## qsub -I -l nodes=1:ppn=1,walltime=12:00:00,mem=30gb -N myjob

mkdir rnas
cd rnas || exit

featurelist="lincRNA antisense snoRNA miRNA"

# Get coding regions for all these. Need to first get names, then pull out their exons. For ones without introns/exons the exons are the same locations as the overall feature

for feature in ${featurelist}
   do
   zgrep "biotype=${feature}" ../RawData/Homo_sapiens.GRCh38.96.chr.gff3.gz | cut -f 2 -d ':' | cut -f 1 -d ';' > rnas.txt
   zgrep -f rnas.txt ../RawData/allexons.gff > "${feature}".gff
   rm rnas.txt 
done

# Rename chromosomes in feature gffs to match SNP location file from hg38PGCMasterSnps.bed

for feature in ${featurelist}
   do awk '{ print "chr" $1 "\t" $2 "\t" $3, "\t" $5 - 50 "\t" $5 "\t" $6 "\t" $7 "\t" $8 "\t" $9}' ${feature}.gff > ${feature}_chr.gff
done

# Use bedtools to find the location intersection between the SNP list from NCBI that has SNP locations, and the feature list that has feature locations

for feature in ${featurelist}
   do bedtools intersect -wa -wb -a ../RawData/hg38PGCMasterSnps.bed -b ${feature}_chr.gff > ${feature}_SNP_Locations.txt
done


# Reduce matrix to requested format: rsID, chr, locus, ENSEMBL annotation
for feature in ${featurelist}
   do awk '{ print $4, $1, $2 }' ${feature}_SNP_Locations.txt | sort | uniq > ${feature}_final.txt
   sed -i "s/$/ ${feature}/g" ${feature}_final.txt
done

# Put in single file for Mark

#cat lincRNA_final.txt lncRNA_final.txt > linc_lnc_final.txt

# Make files for LDSR

for feature in ${featurelist}
   do awk '{ print $1 }' ${feature}_final.txt > ${feature}_LSDR.txt
done