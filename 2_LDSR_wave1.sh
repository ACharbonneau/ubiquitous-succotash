export PATH=$PATH:/mnt/research/PsychGenetics/rerunTraits/tools/bin/

# Traits autism, BPD, Edu years (and one other behavioral trait), one new neurological trait, and height

# Annotations: Atac-Seq peaks, primate conservation-PhastCons, within 50 nt of splice site, Coding_UCSC,  Conserved_LindbladToh, PromoterFlanking_Hoffman, Promoter_UCSC, TSS_Hoffman, UTR_3_UCSC, UTR_5_UCSC, PEC_snps, BivFlnk, Enh, EnhBiv, EnhG, Het, ReprPC, ReprPCWk, TssA, TssAFlnk, TssBiv, Tx, TxWk, ZNF_Rpts, antisense, lincRNA, miRNA


# ========= ld score estimation =========

# create annot files
bash src/s6-create-annot.sh s3/subset. oldannots/* roadmapannots/* pecannots/* rna

# create ldscore files based on annots (takes 24h at 8x parallel)
bash src/s7-create-ldscores.sh -j 8

# ======== prepare summary stats ========

# folder for munged sumstats files
mkdir -p mss

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


In addition to our four current traits, Brad is gathering GWAS summaries for autism, BPD, Edu years (and one other behavioral trait), one new neurological trait, and height.

I’d like to run LDSR on all these trait GWAS in the next few days, with the following changes to annotations:

Let’s drop these several annotation classes:
CTCF, Quiescent, Intron_UCSC, TxFlnk, and snoRNA
(the first two would be expected to have low h2; the third to be redundant with other better categories (in fact all three do have low h2 so far); TxFlnk and snoRNA are so rare as to be hard to estimate.

Let’s add  these several annotation classes:
Atac-Seq peaks primate conservation, (both PhastCons & PhyloP) and those within 50 nt of splice site.
