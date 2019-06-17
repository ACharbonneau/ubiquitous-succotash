# We want to find SNPs that fall inside coding regions of antisense, lincRNA, snoRNA, and miRNAs

# First, make a list of features to search for in the Ensembl genome gff, then loop through searching for them


# To run interactivly do 
## qsub -I -l nodes=1:ppn=1,walltime=12:00:00,mem=20gb -N myjob

featurelist="lincRNA antisense snoRNA miRNA"

# Get coding regions for all these. Need to first get names, then pull out their exons. For ones without introns/exons the exons are the same locations as the overall feature

for feature in ${featurelist}
   do
   zgrep "biotype=${feature}" Homo_sapiens.GRCh38.96.chr.gff3.gz | cut -f 2 -d ':' | cut -f 1 -d ';' > rnas.txt
   zgrep -f rnas.txt Homo_sapiens.GRCh38.96.chr.gff3.gz | grep 'exon' > "${feature}".gff
   rm rnas.txt 
   done

# Rename chromosomes in feature gffs to match SNP location file from NCBI: GCF_000001405.38.gz

chromosomes=`seq 1 9`

for feature in ${featurelist}
do 
   for chromo in ${chromosomes}
      do sed -ri s/^${chromo}\\t/NC_00000${chromo}.11\\t/g ${feature}.gff
   done
done

chromosomes=`seq 10 22`

for feature in ${featurelist}
do 
   for chromo in ${chromosomes}
      do sed -ri s/^${chromo}\\t/NC_0000${chromo}.11\\t/g ${feature}.gff
   done
done

# Remove X and Y

for feature in ${featurelist}
   do grep -v "^X" ${feature}.gff | grep -v "^Y" > ${feature}.gff
done



# Use bedtools to find the location intersection between the overall SNP list from NCBI that has SNP locations, and the feature list that has feature locations

for feature in ${featurelist}
   do bedtools intersect -wa -wb -a GCF_000001405.38.gz -b ${feature}.gff > ${feature}_SNP_Locations.txt
done

# Filter intersection lists by 10M SNP list

for feature in ${featurelist}
   do python filter.py snps.csv ${feature}_SNP_Locations.txt > ${feature}_filteredSNP.txt
done

# Reduce matrix to requested format: rsID, chr, locus, ENSEMBL annotation
for feature in ${featurelist}
   do awk '{ print $3, $1, $2 }' ${feature}_filteredSNP.txt > ${feature}_final.txt
   sed -i "s/$/ ${feature}/g" ${feature}_final.txt
done

# Put in single file for Mark

#cat lincRNA_final.txt lncRNA_final.txt > linc_lnc_final.txt

# Make files for LDSR

for feature in ${featurelist}
   do awk '{ print $3 }' ${feature}_filteredSNP.txt > ${feature}_LSDR.txt
done
