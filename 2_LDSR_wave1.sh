########

## This program is ridiculously finicky. You can't have any modules loaded, or anything in your path 
## it doesn't expect. I also had to uninstall linuxbrew completely, because for some reason it was 
## still trying to use the linuxbrew glibc *even though it was absolutly not in my path anymore* I 
## don't even know how that's possible.

########


screen 

qsub -I -N MyJobName -l nodes=1:ppn=8,mem=64gb,walltime=47:58:00,feature='intel18'

cd /mnt/research/PsychGenetics/runTraitshg19

export PATH=$PATH:/mnt/research/PsychGenetics/rerunTraits/tools/bin/

module load Anaconda2/4.2.0

#conda create --name ldsr python=2
source activate ldsr
# pip install pandas==0.17.0 numpy==1.8.0 scipy==0.11.0 bitarray==0.8.3

# Traits autism, BPD, Edu years (and one other behavioral trait), one new neurological trait, and height
# Alzheimers: mss/munged.niagads.ad.sumstats.gz
# Alcohol use: mss/munged.pgc.aud.sumstats.gz
# Major Depressive Disorder: mss/munged.pgc.mdd.sumstats.gz
# Schizophrenia: mss/munged.pgc.scz2.sumstats.gz
# Education: GWAS_EA_excl23andMe.txt
# Bipolar: daner_PGC_BIP32b_mds7a_0416a
# Autism: iPSYCH-PGC_ASD_Nov2017
# Extraversion: GPC-2.EXTRAVERSION.full.txt 


# Annotations: Atac-Seq peaks, primate conservation-PhastCons, within 50 nt of splice site, Coding_UCSC, Conserved_LindbladToh, PromoterFlanking_Hoffman, Promoter_UCSC, TSS_Hoffman, UTR_3_UCSC, UTR_5_UCSC, PEC_snps, BivFlnk, Enh, EnhBiv, EnhG, Het, ReprPC, ReprPCWk, TssA, TssAFlnk, TssBiv, Tx, TxWk, ZNF_Rpts, antisense, lincRNA, miRNA


# ========= ld score estimation =========

# create annot files
bash src/s6-create-annot.sh -f s3/subset. oldannots/* roadmapannots/* pecannots/* rnaannots/* atacseqannots/* consannots/* spliceannots/*

# create ldscore files based on annots (takes 24h at 8x parallel)
bash src/s7-create-ldscores.sh  -f -j 8

# ======== prepare summary stats ========

# folder for munged sumstats files
mkdir -p mss

# view columns for Bipolar
bash src/s5-provide-summary-statistics.sh ss/daner_PGC_BIP32b_mds7a_0416a.gz
# munge bipolar
# let it calculate N from daner columns
python tools/ldsc/munge_sumstats.py --sumstats ss/daner_PGC_BIP32b_mds7a_0416a.gz --out mss/munged.daner_PGC_BIP32b_mds7a_0416a.ad --a1-inc --daner-n --snp SNP --a1 A1 --a2 A2 --p P 

# view columns for Education and munge
# N from http://ssgac.org/documents/README_EA3.txt
bash src/s5-provide-summary-statistics.sh ss/GWAS_EA_excl23andMe.txt.gz
python tools/ldsc/munge_sumstats.py --sumstats ss/GWAS_EA_excl23andMe.txt.gz --out mss/munged.GWAS_EA_excl23andMe.ad --merge-alleles s5/w_hm3.snplist --a1-inc --N 766345 --snp MarkerName --a1 A1 --a2 A2 --p Pval

# view columns for Autism and munge
# N from Table S6 of https://www.biorxiv.org/content/10.1101/428391v2.full
bash src/s5-provide-summary-statistics.sh ss/iPSYCH-PGC_ASD_Nov2017.gz
python tools/ldsc/munge_sumstats.py --sumstats ss/iPSYCH-PGC_ASD_Nov2017.gz --out mss/munged.iPSYCH-PGC_ASD_Nov2017.ad --merge-alleles s5/w_hm3.snplist --a1-inc --N-cas 18381 --N-con 27969

# view columns for Extraversion and munge
bash src/s5-provide-summary-statistics.sh ss/GPC-2.EXTRAVERSION.full.txt.gz
python tools/ldsc/munge_sumstats.py --sumstats ss/GPC-2.EXTRAVERSION.full.txt.gz --out mss/munged.GPC-2.EXTRAVERSION.full.ad --merge-alleles s5/w_hm3.snplist --a1-inc --N 160958 --snp RSNUMBER --a1 Allele1 --a2 Allele2 --p PVALUE



# view columns for AD (autism) and munge
bash src/s5-provide-summary-statistics.sh ss/niagads.ad.gz
# munge ad gwas niagadds.ad
python tools/ldsc/munge_sumstats.py --sumstats ss/niagads.ad.gz --out mss/munged.niagads.ad --a1-inc --N-cas 30344 --N-con 52427 --snp MarkerName --a1 Effect_allele --a2 Non_Effect_allele --p Pvalue

# view columns for AUD (alcoholism) and munge
# NOTE must go to ss/ and run prepare.pgc.aud.sh to clean data.
bash src/s5-provide-summary-statistics.sh ss/pgc.aud.gz
python tools/ldsc/munge_sumstats.py --sumstats ss/pgc.aud.gz --out mss/munged.pgc.aud --a1-inc --N-cas 11569 --N-con 34999 --snp SNP --a1 A1 --a2 A2 --p P

# same thing for MDD (depression)
mv mss/munged.sumstats.gz mss/munged.pgc.aud.gz
bash src/s5-provide-summary-statistics.sh ss/pgc.mdd.gz
python tools/ldsc/munge_sumstats.py --sumstats ss/pgc.aud.gz --out mss/munged.pgc.mdd --a1-inc --N-cas 59851 --N-con 113154

# ======== perform a regression =========

# perform the regression for niagads.ad
# copy sumstats to expected location
bash src/s8-do-regression.sh mss/munged.pgc.scz2.sumstats.gz
bash src/s8-do-regression.sh mss/munged.niagads.ad.sumstats.gz
bash src/s8-do-regression.sh mss/munged.pgc.mdd.sumstats.gz
bash src/s8-do-regression.sh mss/munged.pgc.aud.sumstats.gz
bash src/s8-do-regression.sh mss/munged.daner_PGC_BIP32b_mds7a_0416a.ad.sumstats.gz
bash src/s8-do-regression.sh mss/munged.GWAS_EA_excl23andMe.ad.sumstats.gz
bash src/s8-do-regression.sh mss/munged.iPSYCH-PGC_ASD_Nov2017.ad.sumstats.gz
bash src/s8-do-regression.sh mss/munged.GPC-2.EXTRAVERSION.full.ad.sumstats.gz

