# GATK Variant Calling Pipeline with Nextflow

## Aim:

To build a reproducible Nextflow-based variant calling pipeline using GATK and Samtools.

## Pipeline overview

The pipeline takes aligned BAM files as input and performs the following steps:

```text
BAM files
   │
   ▼
Samtools Index
   │
   ▼
BAM + BAI
   │
   ▼
GATK HaplotypeCaller
   │
   ▼
Per-sample GVCFs
   │
   ▼
GenomicsDBImport
   │
   ▼
GenomicsDB
   │
   ▼
GenotypeGVCFs
   │
   ▼
Cohort-level VCF
```

## Tools used

- **Nextflow** – workflow management and pipeline orchestration
- **Samtools** – BAM indexing
- **GATK HaplotypeCaller** – per-sample variant calling in GVCF mode
- **GATK GenomicsDBImport** – imports multiple GVCFs into a GenomicsDB datastore
- **GATK GenotypeGVCFs** – joint genotyping across the cohort
- **Docker** – provides the software environments used by the pipeline

## Repository structure

```text
.
├── genomics.nf
├── nextflow.config
├── modules/
│   ├── samtools_index.nf
│   ├── gatk_haplotypecaller.nf
│   └── gatk_jointgenotyping.nf
```

## Expected outputs

The pipeline produces the following results:

```text
results/
├── bam/
│   ├── reads_father.bam
│   ├── reads_father.bam.bai
│   ├── reads_mother.bam
│   ├── reads_mother.bam.bai
│   ├── reads_son.bam
│   └── reads_son.bam.bai
│
├── indexed_bam/
│   ├── reads_father.bam
│   ├── reads_father.bam.bai
│   ├── reads_mother.bam
│   ├── reads_mother.bam.bai
│   ├── reads_son.bam
│   └── reads_son.bam.bai
│
├── gvcf/
│   ├── reads_father.bam.g.vcf
│   ├── reads_father.bam.g.vcf.idx
│   ├── reads_mother.bam.g.vcf
│   ├── reads_mother.bam.g.vcf.idx
│   ├── reads_son.bam.g.vcf
│   └── reads_son.bam.g.vcf.idx
│
├── vcf/
│   ├── reads_father.bam.vcf
│   ├── reads_father.bam.vcf.idx
│   ├── reads_mother.bam.vcf
│   ├── reads_mother.bam.vcf.idx
│   ├── reads_son.bam.vcf
│   └── reads_son.bam.vcf.idx
│
├── family_trio.joint.vcf
└── family_trio.joint.vcf.idx
```

The main output is `family_trio.joint.vcf`, which contains the **cohort-level jointly genotyped variant calls**.
