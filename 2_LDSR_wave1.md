In addition to our four current traits, Brad is gathering GWAS summaries for autism, BPD, Edu years (and one other behavioral trait), one new neurological trait, and height.

I’d like to run LDSR on all these trait GWAS in the next few days, with the following changes to annotations:

Let’s drop these several annotation classes:
CTCF, Quiescent, Intron_UCSC, TxFlnk, and snoRNA
(the first two would be expected to have low h2; the third to be redundant with other better categories (in fact all three do have low h2 so far); TxFlnk and snoRNA are so rare as to be hard to estimate.

Let’s add  these several annotation classes:
Atac-Seq peaks primate conservation, (both PhastCons & PhyloP) and those within 50 nt of splice site.
