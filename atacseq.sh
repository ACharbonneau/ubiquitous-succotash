## Only use ACC_neuron and ACC_glia

mkdir atacseq

cd atacseq || exit

# To run interactivly do 
## qsub -I -l nodes=1:ppn=1,walltime=24:00:00,mem=100gb -N myjob


featurelist="ACC_neuron ACC_glia"

# Use bedtools to find the location intersection between the SNP list from NCBI that has SNP locations, atacseq files

for feature in ${featurelist}
   do bedtools intersect -wa -wb -a ../RawData/hg38PGCMasterSnps.bed -b ../RawData/${feature}.bed > ${feature}_SNP_Locations.txt
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
    do awk '{ print $1 "\t" $2 "\t" $3 "\t" $4 "\t" $5 "\t" $6 "\t" $10 "\t" $11 "\t" $13 "\t" $15 }' ${feature}_SNP_Somatic.txt  > ${feature}_SNP_Final.txt 
done


# Make files for LDSR

for feature in ${featurelist}
   do awk '{ print $4 }' ${feature}_SNP_Final.txt | sort | uniq  > ${feature}_LSDR.txt
done
