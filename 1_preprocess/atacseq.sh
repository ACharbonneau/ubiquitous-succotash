#!/bin/bash --login
########## SBATCH Lines for Resource Request ##########
 
#SBATCH --time=02:00:00             # limit of wall clock time - how long the job will run (same as -t)
#SBATCH --nodes=1-5                 # number of different nodes - could be an exact number or a range of nodes (same as -N)
#SBATCH --ntasks=1                  # number of tasks - how many tasks (nodes) that you require (same as -n)
#SBATCH --cpus-per-task=2           # number of CPUs (or cores) per task (same as -c)
#SBATCH --mem-per-cpu=5G            # memory required per allocated CPU (or core) - amount of memory (in bytes)
#SBATCH --job-name GetRawSNPs      # you can give your job a name for easier identification (same as -J)
 
########## Command Lines to Run ##########
 
module purge

#module load GCC/6.4.0-2.28 OpenMPI  ### load necessary modules, e.g.
cd $SLURM_SUBMIT_DIR || exit                 ### change to the directory where your code is located

#### NOTES ####
# Everything in the final analysis is using HG37/HG19
# But some of the SNP catagories we're using ONLY exist for Hg38, so we are downloading both, 
# and doing a backwards liftover of some of the files after filtering
################# Only use ACC_neuron and ACC_glia

mkdir atacseq

cd atacseq || exit

# To run interactivly do 
## qsub -I -l nodes=1:ppn=1,walltime=24:00:00,mem=100gb -N myjob


featurelist="ACC_neuron ACC_glia"

# Use bedtools to find the location intersection between the SNP list from NCBI that has SNP locations, atacseq files

for feature in ${featurelist}
   do bedtools intersect -wa -wb -a ../RawData/NoMHC_GPHN_SNP.bed -b ../RawData/${feature}.bed > ${feature}_SNP_Locations.txt
done

# Get rid of X, Y chromosomes
for feature in ${featurelist}
    do grep -v chrX ${feature}_SNP_Locations.txt > temp
       grep -v chrY temp > ${feature}_SNP_Somatic.txt
done
rm temp

# Reduce matrix to: chr, snpstart, snpend, rsID, allele, alt, intronstart, intronstop, strand, genename

for feature in ${featurelist}
    do awk '{ print $1 "\t" $2 "\t" $3 "\t" $4 "\t" $5 "\t" $6 "\t" $10 "\t" $11 "\t" $13 "\t" $15 }' ${feature}_SNP_Somatic.txt  > ${feature}_SNP_Final.txt 
done


# Make files for LDSR

for feature in ${featurelist}
   do awk '{ print $4 }' ${feature}_SNP_Final.txt | sort | uniq  > ${feature}_LSDR.txt
done

scontrol show job $SLURM_JOB_ID 
