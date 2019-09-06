########

## This LDSR program is ridiculously finicky. You can't have any modules loaded, or anything in your path 
## it doesn't expect. I also had to uninstall linuxbrew completely, because for some reason it was 
## still trying to use the linuxbrew glibc *even though it was absolutly not in my path anymore* I 
## don't even know how that's possible.

########


#screen 

#qsub -I -N MyJobName -l nodes=1:ppn=8,mem=64gb,walltime=47:58:00,feature='intel18'


cd /mnt/research/PsychGenetics/aug31_runTraits

export PATH=$PATH:/mnt/research/PsychGenetics/aug31_runTraits/tools/bin/

module load Anaconda2/4.2.0

#Build a SNP list file to pass to LD score calculation of chromosome 6 and 14
awk '{if($4 > 66705000 )print $1 "\t" $2 "\t" $3 "\t" $4 "\t" $5 "\t" $6}' s3/subset.14.bim | awk '{if($4 < 67900000 )print $1 "\t" $2 "\t" $3 "\t" $4 "\t" $5 "\t" $6}' > GPHNsnps.bed
awk '{if($4 > 28477000 )print $1 "\t" $2 "\t" $3 "\t" $4 "\t" $5 "\t" $6}' s3/subset.6.bim | awk '{if($4 < 33448000 )print $1 "\t" $2 "\t" $3 "\t" $4 "\t" $5 "\t" $6}' > MHCsnps.bed
comm -23 s3/subset.6.bim MHCsnps.bed
diff s3/subset.6.bim MHCsnps.bed --suppress-common-lines --new-line-format= --unchanged-line-format= > chr6noMHC.bed
diff s3/subset.14.bim GPHNsnps.bed --suppress-common-lines --new-line-format= --unchanged-line-format=  > chr14noGPHN.bed

rm s6/NoMHC_GPHN.txt
touch s6/NoMHC_GPHN.txt
for i in `seq 1 5`
do cut -f 2 s3/subset.${i}.bim
done >> s6/NoMHC_GPHN.txt

cut -f 2 chr6noMHC.bed >> s6/NoMHC_GPHN.txt

for i in `seq 7 13`
do cut -f 2 s3/subset.${i}.bim
done >> s6/NoMHC_GPHN.txt

cut -f 2 chr14noGPHN.bed >> s6/NoMHC_GPHN.txt

for i in `seq 15 22`
do cut -f 2 s3/subset.${i}.bim
done >> s6/NoMHC_GPHN.txt

#conda create --name ldsr python=2
source activate ldsr
# pip install pandas==0.17.0 numpy==1.8.0 scipy==0.11.0 bitarray==0.8.3


# Annotations: Atac-Seq peaks, primate conservation-PhastCons, within 50 nt of splice site, Coding_UCSC, Conserved_LindbladToh, PromoterFlanking_Hoffman, Promoter_UCSC, TSS_Hoffman, UTR_3_UCSC, UTR_5_UCSC, PEC_snps, BivFlnk, Enh, EnhBiv, EnhG, Het, ReprPC, ReprPCWk, TssA, TssAFlnk, TssBiv, Tx, TxWk, ZNF_Rpts, antisense, lincRNA, miRNA


# ========= ld score estimation =========

# create annot files
bash src/s6-create-annot.sh -f s3/subset. oldannots/* roadmapannots/* pecannots/* rnaannots/* atacseqannots/* consannots/* spliceannots/*

# create ldscore files based on annots (takes 24h at 8x parallel)
bash src/s7-create-ldscores.sh  -f -j 8

# ======== prepare summary stats ========

## Raw summary stat files should be saved in the ss folder

# folder for munged sumstats files
mkdir -p mss

## Psychiatric Traits

### Anxiety

gzip SavageJansen_2018_intelligence_metaanalysis.txt
bash src/s5-provide-summary-statistics.sh ss/daner_PGC_BIP32b_mds7a_0416a.gz



# view columns for Bipolar
bash src/s5-provide-summary-statistics.sh ss/daner_PGC_BIP32b_mds7a_0416a.gz
# munge bipolar
# let it calculate N from daner columns
python tools/ldsc/munge_sumstats.py --sumstats ss/daner_PGC_BIP32b_mds7a_0416a.gz --out mss/munged.daner_PGC_BIP32b_mds7a_0416a --a1-inc --daner-n --snp SNP --a1 A1 --a2 A2 --p P 

# view columns for Education and munge
# N from http://ssgac.org/documents/README_EA3.txt
bash src/s5-provide-summary-statistics.sh ss/GWAS_EA_excl23andMe.txt.gz
python tools/ldsc/munge_sumstats.py --sumstats ss/GWAS_EA_excl23andMe.txt.gz --out mss/munged.GWAS_EA_excl23andMe --merge-alleles s5/w_hm3.snplist --a1-inc --N 766345 --snp MarkerName --a1 A1 --a2 A2 --p Pval

# view columns for Autism and munge
# N from Table S6 of https://www.biorxiv.org/content/10.1101/428391v2.full
bash src/s5-provide-summary-statistics.sh ss/iPSYCH-PGC_ASD_Nov2017.gz
python tools/ldsc/munge_sumstats.py --sumstats ss/iPSYCH-PGC_ASD_Nov2017.gz --out mss/munged.iPSYCH-PGC_ASD_Nov2017 --merge-alleles s5/w_hm3.snplist --a1-inc --N-cas 18381 --N-con 27969

# view columns for Extraversion and munge
bash src/s5-provide-summary-statistics.sh ss/GPC-2.EXTRAVERSION.full.txt.gz
python tools/ldsc/munge_sumstats.py --sumstats ss/GPC-2.EXTRAVERSION.full.txt.gz --out mss/munged.GPC-2.EXTRAVERSION.full --merge-alleles s5/w_hm3.snplist --a1-inc --N 63030 --snp RSNUMBER --a1 Allele1 --a2 Allele2 --p PVALUE

# view columns for Parkinsons and munge
bash src/s5-provide-summary-statistics.sh ss/Pankratz_Parkinsons_22687-SuppTable1.txt.gz
python tools/ldsc/munge_sumstats.py --sumstats ss/Pankratz_Parkinsons_22687-SuppTable1.txt.gz --out mss/munged.Pankratz_Parkinsons_22687-SuppTable1 --merge-alleles s5/w_hm3.snplist --a1-inc --N-cas 857 --N-con 867 --snp MarkerName --a1 Allele1 --a2 Allele2 --p P-value

# view columns for Multiple Sclerosis and munge  
#bash src/s5-provide-summary-statistics.sh ss/clinical_c_G35.v2.tar

# view columns for Epilepsy and munge  
bash src/s5-provide-summary-statistics.sh ss/ILAE_All_Epi_11.8.14.gz
python tools/ldsc/munge_sumstats.py --sumstats ss/ILAE_All_Epi_11.8.14.gz --out mss/munged.ILAE_All_Epi_11.8.14 --merge-alleles s5/w_hm3.snplist --a1-inc --N-cas 15212 --N-con 29677 --snp MarkerName --a1 Allele1 --a2 Allele2 --p P-value

# view columns for Alzheimers and munge
bash src/s5-provide-summary-statistics.sh ss/AD_sumstats_Jansenetal.txt.gz
python tools/ldsc/munge_sumstats.py --sumstats ss/AD_sumstats_Jansenetal.txt.gz --out mss/munged.AD_sumstats_Jansenetal --merge-alleles s5/w_hm3.snplist --a1-inc --N 381761

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

# scz 
bash src/s5-provide-summary-statistics.sh ss/pgc.scz2.gz
python tools/ldsc/munge_sumstats.py --sumstats ss/pgc.scz2.gz --out mss/munged.pgc.scz2 --merge-alleles s5/w_hm3.snplist --a1-inc --N-cas 36989 --N-con 113075 --snp snpid --a1 a1 --a2 a2 --p p

# ======== perform a regression =========

# perform the regression for niagads.ad
# copy sumstats to expected location
bash src/s8-do-regression.sh mss/munged.pgc.scz2.sumstats.gz
bash src/s8-do-regression.sh mss/munged.niagads.ad.sumstats.gz
bash src/s8-do-regression.sh mss/munged.pgc.mdd.sumstats.gz
bash src/s8-do-regression.sh mss/munged.pgc.aud.sumstats.gz
bash src/s8-do-regression.sh mss/munged.daner_PGC_BIP32b_mds7a_0416a.sumstats.gz
bash src/s8-do-regression.sh mss/munged.GWAS_EA_excl23andMe.sumstats.gz
bash src/s8-do-regression.sh mss/munged.iPSYCH-PGC_ASD_Nov2017.sumstats.gz
bash src/s8-do-regression.sh mss/munged.GPC-2.EXTRAVERSION.full.sumstats.gz
bash src/s8-do-regression.sh mss/munged.Pankratz_Parkinsons_22687-SuppTable1.sumstats.gz
bash src/s8-do-regression.sh mss/munged.AD_sumstats_Jansenetal.sumstats.gz
bash src/s8-do-regression.sh mss/munged.ILAE_All_Epi_11.8.14.sumstats.gz

