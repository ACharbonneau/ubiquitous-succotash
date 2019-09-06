# ubiquitous-succotash

Code for building various datasets for LDSR

Unless otherwise noted, all of these scripts were built on the MSU High Performance Computing Cluster. Building it elsewhere may require installing several programs, and may require some editing of scripts. At a minimum, the machine running it will need:

git 2.10.1

bedtools v2.27.1

python 3.6.4
- This requires several conflicting packages and should be installed in a conda envrionment *but need to do the install with pip* Installing via conda will get non-conflicting package versions, which won't work with the LDSR code :/ 
- Also note that changing the order of the packages in the call below will break the install
- `pip install numpy==1.8.0 scipy==0.11.0 bitarray==0.8.3 pandas==0.17.0`

R 3.2.0 (packages will auto-install)

pandoc 1.17.3

mySQL 5.7 

TLDR:

1. Make a main directory
2. Clone repo into that directory
3. Change hardcoded file paths to snp files if necessary
4. Run script 0_GetData.sh, from the main directory to download all the raw SNP data
> bash ubiquitous-succotash/0_GetData.sh
5. Each SNP dataset needs it's own unique processing pipeline, all of these are in the '1_preprocess' folder and can be run in any order, or in parallel. Most can just be run with bash, i.e. `bash scriptname`, but a few are fiddly and need individual lines run, or <sigh> require setting up and querying a MySQL server. Some will take in excess of 12 hours to run.
6. Most of the phenotype data is controlled access and must be downloaded *manually and individually*. Filenames and links to the data portals for these files are provided in the **Traits** section below. These files must be saved in a folder called "ss" in the main directory
7. You'll also need some things that Jory made/built in ways that are mysterious to me, but that I will get filled in before I let anyone get close to publishing this. These are two tools folders: `tools/bin/` and `src`, which are some mix of Jory code and the original LDSR code. And th s3 folder contents, which are the files [here](https://data.broadinstitute.org/alkesgroup/LDSCORE/1000G_Phase3_plinkfiles.tgz), but renamed.
8. Run 2_LDSR_wave1.sh which processes all of the above files into a LDSR run. This will take days to run. I've been using interactive jobs, because it crashes often: `qsub -I -N MyJobName -l nodes=1:ppn=8,mem=64gb,walltime=47:58:00,feature='intel18'`
  - all of the raw phenotype data files need to be plain text files that are gzipped. If you have downloaded them from their sources, they will be a random mix. I've added zip/unzip steps to the 2_LDSR_wave1.sh code to make them work, but if this step breaks, it's likely that your copies of the files are at a different compression level than I've assumed.



## Files

#### Traits

| Trait | Filename |  N | Case | Control | Data Link | Reference |
|-------|----------|----|------|---------|------|-----------|
|**Psychiatric Traits**| | | | | | |
|*Anxiety* |anxiety.meta.full.fs.tbl.gz |18186 | - | - | | ANGST  - Otowa et al. 2016|
| Autism | iPSYCH-PGC_ASD_Nov2017  | 46351 | 18382 | 27969 |  https://www.med.unc.edu/pgc/results-and-downloads/asd/?choice=Autism+Spectrum+Disorder+%28ASD%29#  | https://doi.org/10.1186/s13229-017-0137-9 |
| Bipolar | daner_PGC_BIP32b_mds7a_0416a | 51710 | 20352 |	31358  | http://www.med.unc.edu/pgc/results-and-downloads  |    |   
| Major Depressive Disorder | MDD2018_ex23andMe.gz | 173005 | 59851 | 113154 | https://www.med.unc.edu/pgc/results-and-downloads/mdd/ | 
| Schizophrenia | gc.scz2.gz | 150064 | 36989 | 113075 | https://www.med.unc.edu/pgc/results-and-downloads/scz/ | https://doi.org/10.1038/nature13595 |
|**Substance Use** | | | | | | |
|Alcohol use | pgc_alcdep.eur_discovery.aug2018_release.txt.gz | 46568 | 11569 | 34999 | https://www.med.unc.edu/pgc/results-and-downloads/alcohol-dependence/ | http://dx.doi.org/10.1038/s41593-018-0275-1 |
|**Behavioral** | | | | | | |
| Education | GWAS_EA_excl23andMe.txt | 766345 |-|-| http://www.thessgac.org/data | https://doi.org/10.1038/s41588-018-0147-3 |
| Extraversion | GPC-2.EXTRAVERSION.full.txt | 63030 |  |   |    |   |
|*IQ* | |269867 | SavageJansen_2018_intelligence_metaanalysis.txt| | | Savage et al., 2018|
| *Neuroticism* | GPC-2.NEUROTICISM.full.txt | 63661 | - | - |   | De Moor et al. (2015). JAMA Psychiatry|
|*Risky Behavior* | RISK_GWAS_MA_UKB+replication.txt | 466571 | - | - |   | Karlsson Linnér et al. (2019)|
|*Well-being*  |SWB_Full.txt  | 298420 | - | - |   | Okbay et al. (2016)|
|**Neurological** | | | | | | |
| Alzheimers 1| AD_sumstats_Jansenetal.txt | | | |    |                 *** Jansen et al 2018|
|Alzheimers 2| Kunkle_etal_Stage1_results.txt | 63926 | 21982 | 41944 | https://www.niagads.org/system/tdf/public_docs/Kunkle_etal_Stage1_results.txt?file=1&type=field_collection_item&id=121&force= | https://doi.org/10.1038/s41588-019-0358-2 |
| Epilepsy | ILAE_All_Epi_11.8.14.txt |  |  |   |    | International League Against Epilepsy Consortium on Complex Epilepsies|
| Multiple Sclerosis | clinical_c_G35.v2.tar |  |  | | | G35 multiple sclerosis from the GeneAtlas UKBB|                       | Parkinsons's | Pankratz_Parkinsons_22687-SuppTable1.txt |  |  |  |  | Pankratz et al. |
|**Negative Control**  | | | | | | |  
|*Age-rel macular degen* |Fristche_AMDGene2013_Neovascular_v_Controls.txt | | 	Ncases |	Ncontrols|  | Fristche et al. 2013|
|*BMI* | Meta-analysis_Locke_et_al+UKBiobank_2018_UPDATED.txt |  681275 | - | - |   |  Yengo et al. (2018) |
| *Diabetes*|  |   |   | |  http://diagram-consortium.org/downloads.html |  Mahajan et al (2018b)| 
| *Height* | Meta-analysis_Wood_et_al+UKBiobank_2018.txt.gz |  693529 | - | - |   |   Yengo et al. (2018)|
|*Ulcerative Colitis* | clinical_c_K51.v2.tar | 452264 | 3497 | 448767 |  | K51 Ulcerative Colitis from the GeneAtlas UKBB |


#### Annotations 

| Annotation | Filename | Creation Code | Original Data Link | Reference |
|------------|----------|---------------|--------------------|-----------|
Atac-Seq peaks |  |  |  |  |
primate conservation-PhastCons |  |  |  |  |
within 50 nt of splice site |  |  |  |  |
Coding_UCSC |  |  |  |  |
Conserved_LindbladToh |  |  |  |  |
PromoterFlanking_Hoffman |  |  |  |  |
Promoter_UCSC  |  |  |  |  |
TSS_Hoffman |  |  |  |  |
UTR_3_UCSC |  |  |  |  |
UTR_5_UCSC |  |  |  |  |
PEC_snps |  |  |  |  |
BivFlnk |  |  |  |  |
Enh |  |  |  |  |
EnhBiv |  |  |  |  |
EnhG |  |  |  |  |
Het |  |  |  |  |
ReprPC |  |  |  |  |
ReprPCWk |  |  |  |  |
TssA |  |  |  |  |
TssAFlnk |  |  |  |  |
TssBiv |  |  |  |  |
Tx |  |  |  |  |
TxWk |  |  |  |  |
ZNF_Rpts |  |  |  |  |
antisense |  |  |  |  |
lincRNA |  |  |  |  |
miRNA |  |  |  |  |

