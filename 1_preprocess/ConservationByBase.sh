#!/bin/bash --login
########## SBATCH Lines for Resource Request ##########
 
#SBATCH --time=02:00:00             # limit of wall clock time - how long the job will run (same as -t)
#SBATCH --nodes=1-5                 # number of different nodes - could be an exact number or a range of nodes (same as -N)
#SBATCH --ntasks=1                  # number of tasks - how many tasks (nodes) that you require (same as -n)
#SBATCH --cpus-per-task=2           # number of CPUs (or cores) per task (same as -c)
#SBATCH --mem-per-cpu=100G            # memory required per allocated CPU (or core) - amount of memory (in bytes)
#SBATCH --job-name ConsByBase      # you can give your job a name for easier identification (same as -J)
 
########## Command Lines to Run ##########
 
module purge

#module load GCC/6.4.0-2.28 OpenMPI  ### load necessary modules, e.g.

module load icc/2016.3.210-GCC-5.4.0-2.26
module load impi/5.1.3.181
module load BEDTools

cd $SLURM_SUBMIT_DIR || exit 


mkdir ConsByBase

python3

import pyBigWig
bw = pyBigWig.open("hg38.phyloP30way.bw")
new_cons = open("../ConsByBase/ConsByBase.csv",'w')

for line in open("../RawData/NoMHC_GPHN_SNP_Hg38.bed"):
    cols = line.strip().split()
    vals = bw.values(cols[0], int(cols[1]), int(cols[2]))
    new_cons.write("%s, %s, %s, %s, %s, %s, %s\n" % (cols[0], cols[1], cols[2], cols[3], cols[4], cols[5], str(vals[0])))
    
exit()

cd ConsByBase || exit

#slower than expected evolution
sed 's/, /\t/g' ConsByBase.csv | awk '{if($7>.5)print $1 "\t" $2 "\t" $3 "\t" $4 "\t" $5 "\t" $6 "\t" $7}' > ConsByBase.tsv

#to add faster than expected evolution
#sed 's/, /\t/g' ConsByBase.csv | awk '{if($7<-.5)print $1 "\t" $2 "\t" $3 "\t" $4 "\t" $5 "\t" $6 "\t" $7}' >> ConsByBase.tsv

awk '{ print $4 }' ConsByBase.tsv > ConsByBase_LSDR.txt

scontrol show job $SLURM_JOB_ID 
