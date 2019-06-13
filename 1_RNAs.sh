# We want to find SNPs that fall inside coding regions of antisense, lincRNA, snoRNA, and miRNAs

# First, make a list of features to search for in the Ensembl genome gff, then loop through searching for them

featurelist="lincRNA antisense snoRNA miRNA"

# Get coding regions for all these. Need to first get names, then pull out their exons. For ones without introns/exons the exons are the same locations as the overall feature

for feature in ${featurelist}
   do
   zgrep "${feature}" Homo_sapiens.GRCh38.96.chr.gff3.gz | cut -f 2 -d ':' | cut -f 1 -d ';' > rnas.txt
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

for feature in ${featurelist}
   do sed -ri s/^X\\t/NC_000023.11\\t/g ${feature}.gff
done

for feature in ${featurelist}
   do sed -ri s/^Y\\t/NC_000024.11\\t/g ${feature}.gff
done

# Use bedtools to find the location intersection between the overall SNP list from NCBI that has SNP locations, and the feature list that has feature locations

for feature in ${featurelist}
   do bedtools intersect -wa -wb -a GCF_000001405.38.gz -b ${feature}.gff > ${feature}_SNP_Locations.txt
done

# Filter intersection lists by 10M SNP list



