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
